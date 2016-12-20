import Foundation
import AudioKit

class AudioHandler: AKMIDIListener  {
    static let sharedInstance = AudioHandler()
    
    var generator = GeneratorBank()
    
    var roland: AKRolandTB303Filter! = nil
    var rolandDryWetMixer: AKDryWetMixer! = nil
    
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
        bitCrusher.stop()
        
        lowPassFilter = LowPass(bitCrusher)
        lpDryWetMixer = AKDryWetMixer(generator, lowPassFilter, balance: 0.0)
        
        roland = AKRolandTB303Filter(lowPassFilter)
        roland.cutoffFrequency = 450
        // It will produce noise without input if this is too high
        roland.resonance = 0.1
        rolandDryWetMixer = AKDryWetMixer(lpDryWetMixer, roland, balance: 0.0)

        highPassFilter = HighPass(roland)
        hpDryWetMixer = AKDryWetMixer(rolandDryWetMixer, highPassFilter, balance: 0.0)
        
        delay = VariableDelay(highPassFilter)
        delayDryWetMixer = AKDryWetMixer(hpDryWetMixer, delay, balance: 0.0)

        reverb = AKCostelloReverb(delay)
        reverbDryWetMixer = AKDryWetMixer(delayDryWetMixer, reverb, balance: 0.0)

        autoWah = AutoWah(reverb)
        autoWahDryWetMixer = AKDryWetMixer(reverbDryWetMixer, autoWah, balance: 0.0)
        
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
