import Foundation
import AudioKit

class AudioHandler: AKMIDIListener  {
    static let sharedInstance = AudioHandler()
    
    var generator = GeneratorBank()
    
    var bitCrusher: AKBitCrusher! = nil
    
    var lowPassFilter: LowPass! = nil
    var lowPassFilter2: LowPass! = nil
    
    var highPassFilter: AKHighPassFilter! = nil

    var wobble: Wobble! = nil
    
    var delay: VariableDelay! = nil
    
    var reverb: AKCombFilterReverb! = nil
    
    var autoWah: AutoWah! = nil

    var maximumBend: Double = 2.0

    var filterMixer: AKDryWetMixer! = nil
    
    var effects: AKDryWetMixer! = nil
    
    var master: AKMixer! = nil
    
    init() {
        AKSettings.audioInputEnabled = true
        
        bitCrusher = AKBitCrusher(generator)
        bitCrusher.stop()
    
        lowPassFilter = LowPass(bitCrusher)
        lowPassFilter2 = LowPass(lowPassFilter)
        highPassFilter = AKHighPassFilter(lowPassFilter2)
        
        // Filter section output
        filterMixer = AKDryWetMixer(generator, highPassFilter)
        
        // Wobble
        wobble = Wobble(filterMixer)
    
        // Delay
        delay = VariableDelay(wobble)

        // Reverb
        reverb = AKCombFilterReverb(delay)

        // Wah
        autoWah = AutoWah(reverb)
        
        effects = AKDryWetMixer(generator, autoWah, balance: 0.0)
        
        master = AKMixer(effects)
    
        AudioKit.output = master
        
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
