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
        
        let clipper = AKClipper(filterMixer)
        clipper.limit = 0.2
        
        // Wobble
        wobble = Wobble(clipper)
    
        // Delay
        delay = VariableDelay(wobble)

        // Reverb
        reverb = AKFlatFrequencyResponseReverb(delay)

        // Wah
        autoWah = AutoWah(reverb)
        
        effects = AKDryWetMixer(expander, autoWah, balance: 0.0)
        
        let compressor = AKCompressor(
            effects,
            threshold: -20,
            headRoom: 2.0,
            masterGain: -10
        )
        
        let lowPara = AKLowShelfParametricEqualizerFilter(compressor)
        lowPara.cornerFrequency = 200
        lowPara.q = 20
        
        master = AKMixer(lowPara)
        
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
    
    func serializeCurrentSettings() -> String {
        // Encoding all of these in a top level array as JSON deserialisation
        // only works on one levels so cant use nested dictionary
        let settings: [String:Any] = [
            "waveform1": generator.waveform1,
            "waveform2": generator.waveform2,
            "globalbend": generator.globalbend,
            "offset1": Double(generator.offset1),
            "offset2": Double(generator.offset2),
            "morph1": generator.morph1,
            "morph2": generator.morph2,
            "attackDuration": generator.attackDuration,
            "decayDuration": generator.decayDuration,
            "sustainLevel": generator.sustainLevel,
            "releaseDuration": generator.releaseDuration,
            "mob1Mixer": generator.mob1Mixer.volume,
            "mob2Mixer": generator.mob2Mixer.volume,
            "pwmobMixer": generator.pwmobMixer.volume,
            "fmobMixer": generator.fmobMixer.volume,
            "noiseMixer": generator.noiseMixer.volume,
            "mobDryWet": generator.mobDryWet.balance,
            "generatorMaster": generator.generatorMaster.volume,
            "bitcrusherOn": bitCrusher.isStarted,
            "lp1Attack": lowPassFilter.attack,
            "lp1Decay": lowPassFilter.decay,
            "lp1Sustain": lowPassFilter.sustain,
            "lp1Release": lowPassFilter.rel,
            "lp1Cutoff": lowPassFilter.cutOff,
            "lp1resonance": lowPassFilter.resonance,
            "lp1Mixer": lowPassFilterMixer.volume,
            "lp1On": lowPassFilter.output.isStarted,
            "lp2Attack": lowPassFilter2.attack,
            "lp2Decay": lowPassFilter2.decay,
            "lp2Sustain": lowPassFilter2.sustain,
            "lp2Release": lowPassFilter2.rel,
            "lp2Cutoff": lowPassFilter2.cutOff,
            "lp2resonance": lowPassFilter2.resonance,
            "lp2Mixer": lowPassFilter2Mixer.volume,
            "lp2On": lowPassFilter2.output.isStarted,
            "hpfCutoff": highPassFilter.cutoffFrequency,
            "hpfResonance": highPassFilter.resonance,
            "wobblePower": wobble.halfPowerFrequency,
            "wobbleRate": wobble.lfoRate,
            "wobbleOn": wobble.output.isStarted,
            "delayTime": delay.time,
            "delayFeedback": delay.feedback,
            "delayRate": delay.lfoRate,
            "delayAmplitude": delay.lfoAmplitude,
            "delayOn": delay.output.isStarted,
            "reverbDuration": reverb.reverbDuration,
            "reverbOn": reverb.isStarted,
            "wahRate": autoWah.lfoRate,
            "wahAmount": autoWah.wahAmount,
            "wahOn": autoWah.output.isStarted,
            "master": master.volume
        ]
    
        let data = try? JSONSerialization.data(withJSONObject: settings, options: [])
        
        return String(data: data!, encoding: .utf8)!
    }
    
    func settingsFromJson(settingsJson: String) {
        let data = settingsJson.data(using: .utf8)!
        
        let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
        
        print(parsedData)
        
        generator.waveform1 = parsedData?["waveform1"] as! Double
        generator.waveform2 = parsedData?["waveform2"] as! Double
        generator.
        
        print(mob1Wave)
    }
}
