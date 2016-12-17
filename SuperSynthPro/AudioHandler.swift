import Foundation
import AudioKit

class AudioHandler: AKMIDIListener  {
    static let sharedInstance = AudioHandler()
    
    var generator = GeneratorBank()
    
    var reverb: AKCostelloReverb! = nil
    
    var delay: VariableDelay! = nil
    
    var compressor: AKCompressor! = nil
    
    var lowPassFilter: LowPass! = nil
    var lpMixer: AKMixer! = nil
    
    var highPassFilter: HighPass! = nil
    var hpMixer: AKMixer! = nil
    
    var autoWah: AutoWah! = nil

    var maximumBend: Double = 2.0

    var master: AKMixer! = nil
    
    init() {
        AKSettings.audioInputEnabled = true
        
        // All effects turned off by default
        reverb = AKCostelloReverb(generator)
        reverb.stop()
        
        delay = VariableDelay(reverb)
        delay.time = 0
        
        compressor = AKCompressor(delay)
        compressor.stop()
        
        //TODO dry wet the filters
        lowPassFilter = LowPass(compressor)
        lpMixer = AKMixer(lowPassFilter)
        lpMixer.volume = 0
        
        highPassFilter = HighPass(lpMixer)
        hpMixer = AKMixer(highPassFilter)
        hpMixer.volume = 0
        
        autoWah = AutoWah(hpMixer)
        
        master = AKMixer(autoWah)
        
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
