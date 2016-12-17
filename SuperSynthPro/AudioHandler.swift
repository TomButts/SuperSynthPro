import Foundation
import AudioKit

class AudioHandler: AKMIDIListener  {
    static let sharedInstance = AudioHandler()
    
    var generator = GeneratorBank()
    
    var compressor: AKCompressor! = nil
    
    var delay: VariableDelay! = nil
    var delayDryWet: AKDryWetMixer! = nil
    
    var lowPassFilter: LowPass! = nil
    var lpDryWet: AKDryWetMixer! = nil
    
    var highPassFilter: HighPass! = nil
    var hpDryWet: AKDryWetMixer! = nil
    
    var reverb: AKCostelloReverb! = nil
    var reverbDryWet: AKDryWetMixer! = nil
    
    var autoWah: AutoWah! = nil
    var autoWahDryWet: AKDryWetMixer! = nil

    var maximumBend: Double = 2.0

    var master: AKMixer! = nil
    
    init() {
        AKSettings.audioInputEnabled = true
        
        compressor = AKCompressor(delay)
        compressor.dryWetMix = 0
        
        delay = VariableDelay(compressor)
        delayDryWet = AKDryWetMixer(compressor, delay, balance: 0)
        
        lowPassFilter = LowPass(delayDryWet)
        lpDryWet = AKDryWetMixer(delayDryWet, lowPassFilter, balance: 0)
        
        highPassFilter = HighPass(lpDryWet)
        hpDryWet = AKDryWetMixer(lpDryWet, highPassFilter, balance: 0)
    
        reverb = AKCostelloReverb(hpDryWet)
        reverbDryWet = AKDryWetMixer(hpDryWet, reverb, balance: 0)
        
        autoWah = AutoWah(reverbDryWet)
        autoWahDryWet = AKDryWetMixer(reverbDryWet, autoWah, balance: 0)
        
        master = AKMixer(compressor, lpDryWet, hpDryWet, reverbDryWet, autoWahDryWet)
        
        AudioKit.output = generator
        
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
