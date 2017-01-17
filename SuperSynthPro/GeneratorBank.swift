/**
 * The structure of the generator bank is inspired by the AK examples
 * generator class.
 */
import Foundation
import AudioKit

class GeneratorBank: AKPolyphonicNode {
    // Sine is the base wave form
    var waveform1 = 0.0 {
        didSet {
            // If the wave table base wave value is changed update setup
            updateMob1WaveSetup()
        }
    }
    
    var waveform2 = 0.0 {
        didSet {
            // If the wave table base wave value is changed update setup
            updateMob2WaveSetup()
        }
    }
    
    // Applies detuning to all oscillators
    var globalbend: Double = 1.0 {
        didSet {
            morphingOscillatorBank1.detuningMultiplier = globalbend
            morphingOscillatorBank2.detuningMultiplier = globalbend
            pulseWidthModulationOscillatorBank.detuningMultiplier = globalbend
            frequencyModulationOscillatorBank.detuningMultiplier = globalbend
        }
    }
    
    // mob1 detuning offset constant
    var offset1 = 0 {
        willSet {
            for noteNumber in onNotes {
                morphingOscillatorBank1.stop(noteNumber: noteNumber + offset1)
                morphingOscillatorBank1.play(noteNumber: noteNumber + newValue, velocity: 127)
            }
        }
    }
    
    // mob2 detuning offset constant
    var offset2 = 0 {
        willSet {
            for noteNumber in onNotes {
                morphingOscillatorBank2.stop(noteNumber: noteNumber + offset2)
                morphingOscillatorBank2.play(noteNumber: noteNumber + newValue, velocity: 127)
            }
        }
    }
    
    // Takes a ADSR envelope view so values of the view can be synced with component values
    var adsrEnvelope: ADSRView? = nil
    
    // Update mob1 if the waveform or morph index is changed
    func updateMob1WaveSetup() {
        // New wave form index
        var newWaveformIndex = waveform1 + morph1
        
        // Apply bounds
        if newWaveformIndex < 0 {
            newWaveformIndex = 0
        }
        
        if newWaveformIndex > 4 {
            newWaveformIndex = 4
        }
        
        // Set the wave index
        morphingOscillatorBank1.index = newWaveformIndex
    }
    
    // Updates mob2 if the waveform or morph index is changed
    func updateMob2WaveSetup() {
        // New wave form index
        var newWaveformIndex = waveform2 + morph2
        
        // Apply bounds
        if newWaveformIndex < 0 {
            newWaveformIndex = 0
        }
        
        if newWaveformIndex > 3 {
            newWaveformIndex = 3
        }
        
        // Set the wave index
        morphingOscillatorBank2.index = newWaveformIndex
    }
    
    // Amount of wave type morphing
    var morph1: Double = 0 {
        didSet {
            // Need to update setup when morph changes
            updateMob1WaveSetup()
        }
    }
    
    // Amount of wave type morphing
    var morph2: Double = 0 {
        didSet {
            // Need to update setup when morph changes
            updateMob2WaveSetup()
        }
    }
    
    
    /*
     * Global attack for all generators
     *
     * Also sync ADSR view
     *
     */
    var attackDuration: Double = 0.1 {
        didSet {
            if attackDuration < 0.02 { attackDuration = 0.02 }
            morphingOscillatorBank1.attackDuration = attackDuration
            morphingOscillatorBank2.attackDuration = attackDuration
            pulseWidthModulationOscillatorBank.attackDuration = attackDuration
            frequencyModulationOscillatorBank.attackDuration = attackDuration
            noiseADSR.attackDuration = attackDuration
            adsrEnvelope?.attack = attackDuration
        }
    }
   
    /*
     * Global decay for all generators
     *
     * Also sync ADSR view
     *
     */
    var decayDuration: Double = 0.1 {
        didSet {
            if decayDuration < 0.02 { decayDuration = 0.02 }
            morphingOscillatorBank1.decayDuration = decayDuration
            morphingOscillatorBank2.decayDuration = decayDuration
            pulseWidthModulationOscillatorBank.decayDuration = decayDuration
            frequencyModulationOscillatorBank.decayDuration = decayDuration
            noiseADSR.decayDuration = decayDuration
            adsrEnvelope?.decay = decayDuration
        }
    }
    
    /*
     * Global sustain for all generators
     *
     * Also sync ADSR view
     *
     */
    var sustainLevel: Double = 0.66 {
        didSet {
            morphingOscillatorBank1.sustainLevel = sustainLevel
            morphingOscillatorBank2.sustainLevel = sustainLevel
            pulseWidthModulationOscillatorBank.sustainLevel = sustainLevel
            frequencyModulationOscillatorBank.sustainLevel = sustainLevel
            noiseADSR.sustainLevel = sustainLevel
            adsrEnvelope?.sustain = sustainLevel
        }
    }
    
    /*
     * Global release for all generators
     *
     * Also sync ADSR view
     *
     */
    var releaseDuration: Double = 0.5 {
        didSet {
            if releaseDuration < 0.02 { releaseDuration = 0.02 }
            morphingOscillatorBank1.releaseDuration = releaseDuration
            morphingOscillatorBank2.releaseDuration = releaseDuration
            pulseWidthModulationOscillatorBank.releaseDuration = releaseDuration
            frequencyModulationOscillatorBank.releaseDuration = releaseDuration
            noiseADSR.releaseDuration = releaseDuration
            adsrEnvelope?.rel = releaseDuration
        }
    }
    
    // Wave table constants
    let triangle = AKTable(.triangle)
    let square   = AKTable(.square)
    let sawtooth = AKTable(.sawtooth)
    let sine = AKTable(.sine)
    
    // Initialise generator bank components
    var morphingOscillatorBank1: AKMorphingOscillatorBank = AKMorphingOscillatorBank()
    var morphingOscillatorBank2: AKMorphingOscillatorBank = AKMorphingOscillatorBank()
    var pulseWidthModulationOscillatorBank = AKPWMOscillatorBank()
    var frequencyModulationOscillatorBank = AKFMOscillatorBank()
    var noise = AKPinkNoise()
    var noiseADSR: AKAmplitudeEnvelope

    // Mixers
    var mob1Mixer: AKMixer
    var mob2Mixer: AKMixer
    var pwmobMixer: AKMixer
    var fmobMixer: AKMixer
    var noiseMixer: AKMixer
    
    var mobDryWet: AKDryWetMixer
    var generatorMaster: AKMixer
    
    // A Set which stores the keyon variables sent from the view controller
    var onNotes = Set<Int>()
    
    override init() {
        // oscillators
        morphingOscillatorBank1 = AKMorphingOscillatorBank(waveformArray: [triangle, square, sawtooth, sine])
        morphingOscillatorBank2 = AKMorphingOscillatorBank(waveformArray: [triangle, square, sawtooth, sine])
        
        // Noise does not have a built in amplitude ADSR
        noiseADSR = AKAmplitudeEnvelope(noise)
        
        // mixers
        mob1Mixer = AKMixer(morphingOscillatorBank1)
        mob2Mixer = AKMixer(morphingOscillatorBank2)
        pwmobMixer = AKMixer(pulseWidthModulationOscillatorBank)
        fmobMixer = AKMixer(frequencyModulationOscillatorBank)
        noiseMixer = AKMixer(noiseADSR)
        
        // Set other generators off
        pwmobMixer.volume = 0.0
        fmobMixer.volume = 0.0
        noiseMixer.volume = 0.0
        
        // MOB1 MOB2 Dry Wet
        mobDryWet = AKDryWetMixer(mob1Mixer, mob2Mixer)
        
        generatorMaster = AKMixer(mobDryWet, pwmobMixer, fmobMixer, noiseMixer)
        
        // Set master as a playable MIDI node
        super.init()
        
        // Set output
        avAudioNode = generatorMaster.avAudioNode
    }
    
    // Plays a MIDI note on all generators
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        morphingOscillatorBank1.play(noteNumber: noteNumber + offset1, velocity: velocity)
        morphingOscillatorBank2.play(noteNumber: noteNumber + offset2, velocity: velocity)
        pulseWidthModulationOscillatorBank.play(noteNumber: noteNumber - 12, velocity: velocity)
        frequencyModulationOscillatorBank.play(noteNumber: noteNumber - 12, velocity: velocity)
        
        // Noise does not have a .play
        if onNotes.count == 0 {
            noise.start()
            noiseADSR.start()
        }
        
        // Set the key/note as on in the set
        onNotes.insert(noteNumber)
    }
    
    override func stop(noteNumber: MIDINoteNumber) {
        morphingOscillatorBank1.stop(noteNumber: noteNumber + offset1)
        morphingOscillatorBank2.stop(noteNumber: noteNumber + offset2)
        pulseWidthModulationOscillatorBank.stop(noteNumber: noteNumber - 12)
        frequencyModulationOscillatorBank.stop(noteNumber: noteNumber - 12)
    
        if onNotes.count == 0 {
            noiseADSR.stop()
        }
        
        // Release key record from set
        onNotes.remove(noteNumber)
    }
}
