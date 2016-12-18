import Foundation
import AudioKit

class AudioHandler: AKMIDIListener  {
    static let sharedInstance = AudioHandler()
    
    var generator = GeneratorBank()
    
    var compressor: AKCompressor! = nil
    
    var delay: VariableDelay! = nil
    var delayMixer: AKMixer! = nil
    
    var lowPassFilter: LowPass! = nil
    var lpMixer: AKMixer! = nil
    
    var highPassFilter: HighPass! = nil
    var hpMixer: AKMixer! = nil
    
    var reverb: AKCostelloReverb! = nil
    var reverbMixer: AKMixer! = nil
    
    var autoWah: AutoWah! = nil
    var autoWahMixer: AKMixer! = nil

    var maximumBend: Double = 2.0

    var master: AKMixer! = nil
    
    init() {
        AKSettings.audioInputEnabled = true
        
//        delay = VariableDelay(generator)
//        delay.output.stop()
//        delayMixer = AKMixer(delay)
//        delayMixer.volume = 0
//        
//        lowPassFilter = LowPass(delay)
//        lpMixer = AKMixer(lowPassFilter)
//        lpMixer.volume = 0
//        
//        compressor = AKCompressor(lowPassFilter)
//        compressor.dryWetMix = 0.5
//
//        highPassFilter = HighPass(compressor)
//        highPassFilter.output.stop()
//        hpMixer = AKMixer(highPassFilter)
//
//        reverb = AKCostelloReverb(highPassFilter)
//        reverb.stop()
//        reverbMixer = AKMixer(reverb)
//
//        autoWah = AutoWah(reverb)
//        autoWah.output.stop()
//        autoWahMixer = AKMixer(autoWah)
//        
//        master = AKMixer(delay, delayMixer, lpMixer, hpMixer, autoWahMixer)
        
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
