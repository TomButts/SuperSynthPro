import Foundation
import AudioKit

class AudioHandler: AKMIDIListener  {
    static let sharedInstance = AudioHandler()
    
    var generator = GeneratorBank()
    
    var bitCrusher: AKBitCrusher! = nil
    
    var lowPassFilter: LowPass! = nil
    var lowPassFilter2: LowPass! = nil
    var highPassFilter: AKHighPassFilter! = nil
    
    var lowPassFilterMixer: AKMixer! = nil
    var lowPassFilter2Mixer: AKMixer! = nil

    var wobble: Wobble! = nil
    
    var delay: VariableDelay! = nil
    
    var reverb: AKFlatFrequencyResponseReverb! = nil
    
    var autoWah: AutoWah! = nil

    var maximumBend: Double = 2.0

    var filterMixer: AKDryWetMixer! = nil
    
    var effects: AKDryWetMixer! = nil
    
    var master: AKMixer! = nil
    
    init() {
        AKSettings.audioInputEnabled = true
        
        let expander = AKExpander(generator)
        expander.expansionRatio = 50
        expander.expansionThreshold = 50
        expander.masterGain = -15
        
        bitCrusher = AKBitCrusher(expander)
        bitCrusher.stop()
    
        lowPassFilter = LowPass(bitCrusher)
        lowPassFilterMixer = AKMixer(lowPassFilter)
        
        lowPassFilter2 = LowPass(lowPassFilterMixer)
        lowPassFilter2Mixer = AKMixer(lowPassFilter2)
        
        highPassFilter = AKHighPassFilter(lowPassFilter2)
        
        // Filter section output
        filterMixer = AKDryWetMixer(generator, highPassFilter, balance: 1.0)
        
        // Wobble
        wobble = Wobble(filterMixer)
    
        // Delay
        delay = VariableDelay(wobble)

        // Reverb
        reverb = AKFlatFrequencyResponseReverb(delay)

        // Wah
        autoWah = AutoWah(reverb)
        
        effects = AKDryWetMixer(expander, autoWah, balance: 0.0)
        
        master = AKMixer(effects)
        
        let clipper = AKClipper(master)
        clipper.limit = 0.2
        
        let compressor = AKCompressor(
            clipper,
            threshold: -20,
            headRoom: 2.0,
            masterGain: -10
        )
        
        let lowPara = AKLowShelfParametricEqualizerFilter(compressor)
        lowPara.cornerFrequency = 200
        lowPara.q = 20
        
        AudioKit.output = lowPara
        
        AudioKit.start()
        
        let midi = AKMIDI()
        
        midi.createVirtualPorts()
        
        midi.openInput("Session 1")
        
        midi.addListener(self)
    }
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: Int) {
        generator.play(noteNumber: noteNumber, velocity: velocity)
    }
    
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: Int) {
        generator.stop(noteNumber: noteNumber)
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: Int, channel: Int) {
        let bendSemi =  (Double(pitchWheelValue - 8192) / 8192.0) * maximumBend
        generator.globalbend = bendSemi
    }
    
}
