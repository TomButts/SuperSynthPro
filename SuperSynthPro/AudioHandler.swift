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
    
    var panner: Panning! = nil
    
    // EQ filters
    var low: AKEqualizerFilter! = nil
    var middle: AKEqualizerFilter! = nil
    var high: AKEqualizerFilter! = nil
    
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
        
        // Add subtle panning
        panner = Panning(filterMixer)
        
        let clipper = AKClipper(panner)
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
        
        // EQ
        low = AKEqualizerFilter(lowPara, centerFrequency: 50, bandwidth: 100, gain: 1.0)
        middle = AKEqualizerFilter(low, centerFrequency: 350, bandwidth: 300, gain: 1.0)
        high = AKEqualizerFilter(middle, centerFrequency: 5000, bandwidth: 1000, gain: 1.0)
        
        master = AKMixer(high)
        
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
        
        // Also this breaks xcode indexing if its all in one array declaration
        var settings: [String:Any] = ["waveform1": generator.waveform1]
        
        settings["waveform2"] = generator.waveform2
        settings["globalbend"] = generator.globalbend
        settings["offset1"] = Double(generator.offset1)
        settings["offset2"] = Double(generator.offset2)
        settings["morph1"] = generator.morph1
        settings["morph2"] = generator.morph2
        settings["detune"] = generator.morphingOscillatorBank2.detuningOffset
        settings["attackDuration"] = generator.attackDuration
        settings["decayDuration"] = generator.decayDuration
        settings["sustainLevel"] = generator.sustainLevel
        settings["releaseDuration"] = generator.releaseDuration
        settings["mob1Mixer"] = generator.mob1Mixer.volume
        settings["mob2Mixer"] = generator.mob2Mixer.volume
        settings["pwmobMixer"] = generator.pwmobMixer.volume
        settings["fmobMixer"] = generator.fmobMixer.volume
        settings["noiseMixer"] = generator.noiseMixer.volume
        settings["mobDryWet"] = generator.mobDryWet.balance
        settings["generatorMaster"] = generator.generatorMaster.volume
        settings["bitCrusherOn"] = bitCrusher.isStarted
        settings["lp1Attack"] = lowPassFilter.attack
        settings["lp1Decay"] = lowPassFilter.decay
        settings["lp1Sustain"] = lowPassFilter.sustain
        settings["lp1Release"] = lowPassFilter.rel
        settings["lp1Cutoff"] = lowPassFilter.cutOff
        settings["lp1Resonance"] = lowPassFilter.resonance
        settings["lp1Mixer"] = lowPassFilterMixer.volume
        settings["lp1On"] = lowPassFilter.output.isStarted
        settings["lp2Attack"] = lowPassFilter2.attack
        settings["lp2Decay"] = lowPassFilter2.decay
        settings["lp2Sustain"] = lowPassFilter2.sustain
        settings["lp2Release"] = lowPassFilter2.rel
        settings["lp2Cutoff"] = lowPassFilter2.cutOff
        settings["lp2Resonance"] = lowPassFilter2.resonance
        settings["lp2Mixer"] = lowPassFilter2Mixer.volume
        settings["lp2On"] = lowPassFilter2.output.isStarted
        settings["hpfCutoff"] = highPassFilter.cutoffFrequency
        settings["hpfResonance"] = highPassFilter.resonance
        settings["hpfOn"] = highPassFilter.isStarted
        settings["wobblePower"] = wobble.halfPowerFrequency
        settings["wobbleRate"] = wobble.lfoRate
        settings["wobbleOn"] = wobble.output.isStarted
        settings["delayTime"] = delay.time
        settings["delayFeedback"] = delay.feedback
        settings["delayRate"] = delay.lfoRate
        settings["delayAmplitude"] = delay.lfoAmplitude
        settings["delayOn"] = delay.output.isStarted
        settings["reverbDuration"] = reverb.reverbDuration
        settings["reverbOn"] = reverb.isStarted
        settings["wahRate"] = autoWah.lfoRate
        settings["wahAmount"] = autoWah.wahAmount
        settings["wahOn"] = autoWah.output.isStarted
        settings["low"] = low.gain
        settings["middle"] = middle.gain
        settings["high"] = high.gain
        settings["master"] = master.volume
        
        let data = try? JSONSerialization.data(withJSONObject: settings, options: [])
        
        return String(data: data!, encoding: .utf8)!
    }
    
    func settingsFromJson(settingsJson: String) {
        let data = settingsJson.data(using: .utf8)!
        
        let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        
        generator.waveform1 = parsedData?["waveform1"] as! Double
        generator.waveform2 = parsedData?["waveform2"] as! Double
        generator.globalbend = parsedData?["globalbend"] as! Double
        generator.offset1 = Int((parsedData?["offset1"])! as! NSNumber)
        generator.offset2 = Int((parsedData?["offset2"])! as! NSNumber)
        generator.morph1 = parsedData?["morph1"] as! Double
        generator.morph2 = parsedData?["morph2"] as! Double
        generator.morphingOscillatorBank2.detuningOffset = parsedData?["detune"] as! Double
        generator.attackDuration = parsedData?["attackDuration"] as! Double
        generator.decayDuration = parsedData?["decayDuration"] as! Double
        generator.sustainLevel = parsedData?["sustainLevel"] as! Double
        generator.releaseDuration = parsedData?["releaseDuration"] as! Double
        generator.mob1Mixer.volume = parsedData?["mob1Mixer"] as! Double
        generator.mob2Mixer.volume = parsedData?["mob2Mixer"] as! Double
        generator.pwmobMixer.volume = parsedData?["pwmobMixer"] as! Double
        generator.fmobMixer.volume = parsedData?["fmobMixer"] as! Double
        generator.noiseMixer.volume = parsedData?["noiseMixer"] as! Double
        generator.mobDryWet.balance = parsedData?["mobDryWet"] as! Double
        generator.generatorMaster.volume = parsedData?["generatorMaster"] as! Double
        
        bitCrusher.stop()
        
        if (parsedData?["bitCrusherOn"] as! Bool) {
            bitCrusher.start()
        }
        
        lowPassFilter.attack = parsedData?["lp1Attack"] as! Double
        lowPassFilter.decay = parsedData?["lp1Decay"] as! Double
        lowPassFilter.sustain = parsedData?["lp1Sustain"] as! Double
        lowPassFilter.rel = parsedData?["lp1Release"] as! Double
        lowPassFilter.cutOff = parsedData?["lp1Cutoff"] as! Double
        lowPassFilter.resonance = parsedData?["lp1Resonance"] as! Double
        lowPassFilterMixer.volume = parsedData?["lp1Mixer"] as! Double
        
        lowPassFilter.output.stop()
        
        if (parsedData?["lp1On"] as! Bool) {
            lowPassFilter.output.start()
        }
        
        lowPassFilter2.attack = parsedData?["lp2Attack"] as! Double
        lowPassFilter2.decay = parsedData?["lp2Decay"] as! Double
        lowPassFilter2.sustain = parsedData?["lp2Sustain"] as! Double
        lowPassFilter2.rel = parsedData?["lp2Release"] as! Double
        lowPassFilter2.cutOff = parsedData?["lp2Cutoff"] as! Double
        lowPassFilter2.resonance = parsedData?["lp2Resonance"] as! Double
        lowPassFilter2Mixer.volume = parsedData?["lp2Mixer"] as! Double
        
        lowPassFilter2.output.stop()
        
        if (parsedData?["lp2On"] as! Bool) {
            lowPassFilter2.output.start()
        }

        highPassFilter.cutoffFrequency = parsedData?["hpfCutoff"] as! Double
        highPassFilter.resonance = parsedData?["hpfResonance"] as! Double
        
        highPassFilter.stop()
        
        if (parsedData?["hpfOn"] as! Bool) {
            highPassFilter.start()
        }
        
        wobble.halfPowerFrequency = parsedData?["wobblePower"] as! Double
        wobble.lfoRate = parsedData?["wobbleRate"] as! Double
        
        wobble.output.stop()
        
        if (parsedData?["wobbleOn"] as! Bool) {
            wobble.output.start()
        }
        
        delay.time = parsedData?["delayTime"] as! Double
        delay.feedback = parsedData?["delayFeedback"] as! Double
        delay.lfoRate = parsedData?["delayRate"] as! Double
        delay.lfoAmplitude = parsedData?["delayAmplitude"] as! Double
        
        delay.output.stop()
        
        if (parsedData?["delayOn"] as! Bool) {
            delay.output.start()
        }
        
        reverb.reverbDuration = parsedData?["reverbDuration"] as! Double
        
        reverb.stop()
        
        if (parsedData?["reverbOn"] as! Bool) {
            reverb.start()
        }
        
        autoWah.lfoRate = parsedData?["wahRate"] as! Double
        autoWah.wahAmount = parsedData?["wahAmount"] as! Double
        
        autoWah.output.stop()
        
        if (parsedData?["wahOn"] as! Bool) {
            autoWah.output.start()
        }
        
        low.gain = parsedData?["low"] as! Double
        middle.gain = parsedData?["middle"] as! Double
        high.gain = parsedData?["high"] as! Double
        
        master.volume = parsedData?["master"] as! Double
    }
}
