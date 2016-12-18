import Foundation
import AudioKit

class AudioHandler: AKMIDIListener  {
    static let sharedInstance = AudioHandler()
    
    var generator = GeneratorBank()
    
    var compressor: AKCompressor! = nil
    
    var bitCrusher: AKBitCrusher! = nil
    
    var delay: VariableDelay! = nil
    var delayDryWetMixer: AKDryWetMixer! = nil
    
    var lowPassFilter: LowPass! = nil
    var lpDryWetMixer: AKDryWetMixer! = nil
    
    var highPassFilter: HighPass! = nil
    var hpDryWetMixer: AKDryWetMixer! = nil
    
    var reverb: AKCostelloReverb! = nil
    var reverbDryWetMixer: AKDryWetMixer! = nil
    
    var autoWah: AutoWah! = nil
    var autoWahDryWetMixer: AKDryWetMixer! = nil

    var maximumBend: Double = 2.0

    var effects: AKMixer! = nil
    
    var master: AKMixer! = nil
    
    init() {
        AKSettings.audioInputEnabled = true
        
        bitCrusher = AKBitCrusher(generator)
        
        delay = VariableDelay(bitCrusher)
        delayDryWetMixer = AKDryWetMixer(bitCrusher, delay, balance: 0.0)
    
        lowPassFilter = LowPass(delayDryWetMixer)
        lpDryWetMixer = AKDryWetMixer(bitCrusher, lowPassFilter, balance: 0.0)
        
        compressor = AKCompressor(lpDryWetMixer)
        compressor.dryWetMix = 0.0

        highPassFilter = HighPass(compressor)
        hpDryWetMixer = AKDryWetMixer(bitCrusher, highPassFilter, balance: 0.0)

        reverb = AKCostelloReverb(hpDryWetMixer)
        reverbDryWetMixer = AKDryWetMixer(bitCrusher, reverb, balance: 0.0)

        autoWah = AutoWah(reverbDryWetMixer)
        autoWahDryWetMixer = AKDryWetMixer(bitCrusher, autoWah, balance: 0.0)
        
        effects = AKMixer(bitCrusher, delayDryWetMixer, lpDryWetMixer, hpDryWetMixer, reverbDryWetMixer, autoWahDryWetMixer)
        
        master = AKMixer(generator, effects)
        
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
