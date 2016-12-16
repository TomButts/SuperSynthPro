import Foundation
import AudioKit

class GeneratorBank: AKPolyphonicNode {
    // Sine is the base wave form
    var waveform1 = 0.0 {
        didSet {
            updateMob1WaveSetup()
        }
    }
    var waveform2 = 0.0 {
        didSet {
            updateMob2WaveSetup()
        }
    }
    
    /** Applies detuning to all oscillators */
    var globalbend: Double = 1.0 {
        didSet {
            morphingOscillatorBank1.detuningMultiplier = globalbend
            morphingOscillatorBank2.detuningMultiplier = globalbend
            pulseWidthModulationOscillatorBank.detuningMultiplier = globalbend
            frequencyModulationOscillatorBank.detuningMultiplier = globalbend
        }
    }
    
    /** mob1 detuning offset constant */
    var offset1 = 0 {
        willSet {
            for noteNumber in onNotes {
                morphingOscillatorBank1.stop(noteNumber: noteNumber + offset1)
                morphingOscillatorBank1.play(noteNumber: noteNumber + newValue, velocity: 127)
            }
        }
    }
    
    /** mob2 detuning offset constant */
    var offset2 = 0 {
        willSet {
            for noteNumber in onNotes {
                morphingOscillatorBank2.stop(noteNumber: noteNumber + offset2)
                morphingOscillatorBank2.play(noteNumber: noteNumber + newValue, velocity: 127)
            }
        }
    }
    
    /** Update mob1 if the waveform or morph index is changed */
    func updateMob1WaveSetup() {
        var newWaveformIndex = waveform1 + morph
        
        if newWaveformIndex < 0 {
            newWaveformIndex = 0
        }
        
        if newWaveformIndex > 3 {
            newWaveformIndex = 3
        }
        
        morphingOscillatorBank1.index = newWaveformIndex
    }
    
    /** Updates mob2 if the waveform or morph index is changed */
    func updateMob2WaveSetup() {
        var newWaveformIndex = waveform2 + morph
        
        if newWaveformIndex < 0 {
            newWaveformIndex = 0
        }
        
        if newWaveformIndex > 3 {
            newWaveformIndex = 3
        }
        
        morphingOscillatorBank2.index = newWaveformIndex
    }
    
    /** amount of wave type morphing */
    var morph: Double = 0 {
        didSet {
            updateMob1WaveSetup()
            updateMob1WaveSetup()
        }
    }
    
    /** Equalise the attack duration for all oscillators */
    var attackDuration: Double = 0.1 {
        didSet {
            if attackDuration < 0.02 { attackDuration = 0.02 }
            morphingOscillatorBank1.attackDuration = attackDuration
            morphingOscillatorBank2.attackDuration = attackDuration
            pulseWidthModulationOscillatorBank.attackDuration = attackDuration
            frequencyModulationOscillatorBank.attackDuration = attackDuration
        }
    }
   
    var decayDuration: Double = 0.1 {
        didSet {
            if decayDuration < 0.02 { decayDuration = 0.02 }
            morphingOscillatorBank1.decayDuration = decayDuration
            morphingOscillatorBank2.decayDuration = decayDuration
            pulseWidthModulationOscillatorBank.decayDuration = decayDuration
            frequencyModulationOscillatorBank.decayDuration = decayDuration
        }
    }
    
    var sustainLevel: Double = 0.66 {
        didSet {
            morphingOscillatorBank1.sustainLevel = sustainLevel
            morphingOscillatorBank2.sustainLevel = sustainLevel
            pulseWidthModulationOscillatorBank.sustainLevel = sustainLevel
            frequencyModulationOscillatorBank.sustainLevel = sustainLevel
        }
    }
    
    var releaseDuration: Double = 0.5 {
        didSet {
            if releaseDuration < 0.02 { releaseDuration = 0.02 }
            morphingOscillatorBank1.releaseDuration = releaseDuration
            morphingOscillatorBank2.releaseDuration = releaseDuration
            pulseWidthModulationOscillatorBank.releaseDuration = releaseDuration
            frequencyModulationOscillatorBank.releaseDuration = releaseDuration
        }
    }
    
    var morphingOscillatorBank1: AKMorphingOscillatorBank
    var morphingOscillatorBank2: AKMorphingOscillatorBank
    var pulseWidthModulationOscillatorBank = AKPWMOscillatorBank()
    var frequencyModulationOscillatorBank = AKFMOscillatorBank()

    var mob1Mixer: AKMixer
    var mob2Mixer: AKMixer
    var pwmobMixer: AKMixer
    var fmobMixer: AKMixer
    
    var dryWet: AKDryWetMixer
    var master: AKMixer
    
    var onNotes = Set<Int>()
    
    override init() {
        let triangle = AKTable(.triangle)
        let square   = AKTable(.square)
        let sawtooth = AKTable(.sawtooth)
        
        // oscillators
        morphingOscillatorBank1 = AKMorphingOscillatorBank(waveformArray: [triangle, square, sawtooth])
        morphingOscillatorBank2 = AKMorphingOscillatorBank(waveformArray: [triangle, square, sawtooth])
        
        // mixers
        mob1Mixer = AKMixer(morphingOscillatorBank1)
        mob2Mixer = AKMixer(morphingOscillatorBank2)
        pwmobMixer = AKMixer(pulseWidthModulationOscillatorBank)
        fmobMixer = AKMixer(frequencyModulationOscillatorBank)
        
        // set bonus osc to off
        pwmobMixer.volume = 0.0
        fmobMixer.volume = 0.0
        
        dryWet = AKDryWetMixer(mob1Mixer, mob2Mixer)
        
        master = AKMixer(dryWet, pwmobMixer, fmobMixer)
        
        // set master as a playable MIDI node
        super.init()
        avAudioNode = master.avAudioNode
    }
    
    override func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity) {
        
        morphingOscillatorBank1.play(noteNumber: noteNumber + offset1, velocity: velocity)
        morphingOscillatorBank2.play(noteNumber: noteNumber + offset1, velocity: velocity)
        pulseWidthModulationOscillatorBank.play(noteNumber: noteNumber, velocity: velocity)
        frequencyModulationOscillatorBank.play(noteNumber: noteNumber - 12, velocity: velocity)
    
        onNotes.insert(noteNumber)
    }
    
    override func stop(noteNumber: MIDINoteNumber) {
        morphingOscillatorBank1.stop(noteNumber: noteNumber + offset1)
        morphingOscillatorBank2.stop(noteNumber: noteNumber + offset2)
        pulseWidthModulationOscillatorBank.stop(noteNumber: noteNumber)
        frequencyModulationOscillatorBank.stop(noteNumber: noteNumber - 12)
        
        onNotes.remove(noteNumber)
    }
}
