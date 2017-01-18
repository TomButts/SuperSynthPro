/**
 * The main view controller contains the UI elements needed for wave generation. 
 * It also includes links to other parts of the app such as sound cutosmisation
 * and the help page.
 */
import UIKit
import AudioKit
import SQLite

class ViewController: UIViewController, AKKeyboardDelegate {
    // This initialises a singleton database connection which can then be accesed
    // statically from any class which requires it.
    let db = DatabaseConnector()
    
    // Initialise the preset sound model that controls database interaction
    let presetSoundModel = PresetSound()
    
    // Initialise the singleton containing the synths audio circuit
    var audioHandler = AudioHandler.sharedInstance

    // Link to the UIView that the keyboard will be placed in
    @IBOutlet var keyboardPlaceholder: UIView!

    // Keyboard UI view
    var keyboard: AKKeyboardView?
    
    // Live waveform plot
    var plot: AKNodeOutputPlot! = nil
    
    /*
     * The UI Knobs are drawn in UIViews placed in the storyboard
     * These placeholder variables represent these UIViews.
     * The Knobs will be intialised on load and added to these 
     * placeholder views as subviews.
     */
    
    // Morphing Ocillator Bank 1
    @IBOutlet var mob1WaveTypeKnobPlaceholder: UIView!
    @IBOutlet var mob1MorphKnobPlaceholder: UIView!
    @IBOutlet var mob1OffsetKnobPlaceholder: UIView!
    @IBOutlet var mob1VolumeKnobPlaceholder: UIView!
    
    // MOB1 MOB2 Dry Wet Mixer
    @IBOutlet var mobBalancerKnobPlaceholder: UIView!
    
    // Morphing Ocillator Bank 2
    @IBOutlet var mob2WaveTypeKnobPlaceholder: UIView!
    @IBOutlet var mob2MorphKnobPlaceholder: UIView!
    @IBOutlet var mob2OffsetKnobPlaceholder: UIView!
    @IBOutlet var mob2DetuneKnobPlaceholder: UIView!
    @IBOutlet var mob2VolumeKnobPlaceholder: UIView!
    
    // Pulse Width Modulator
    @IBOutlet var pulseWidthKnobPlaceholder: UIView!
    @IBOutlet var pulseWidthOffsetKnobPlaceholder: UIView!
    @IBOutlet var pulseWidthVolumeKnobPlaceholder: UIView!
    
    // FM Oscillator
    @IBOutlet var fmModulationKnobPlaceholder: UIView!
    @IBOutlet var fmVolumeKnobPlaceholder: UIView!
    
    // Amplitude ADSR Envelope
    @IBOutlet var attackKnobPlaceholder: UIView!
    @IBOutlet var decayKnobPlaceholder: UIView!
    @IBOutlet var sustainKnobPlaceholder: UIView!
    @IBOutlet var releaseKnobPlaceholder: UIView!
    
    // Noise
    @IBOutlet var noiseVolumeKnobPlaceholder: UIView!
    
    // Custom drawn envelope
    @IBOutlet var adsrPlaceholder: UIView!
    
    // Bend and Master volume
    @IBOutlet var globalBendKnobPlaceholder: UIView!
    @IBOutlet var masterVolumeKnobPlaceholder: UIView!
  
    // Switch for holding a continuous note (middle C)
    @IBOutlet var startStopSwitch: UISwitch!
    
    /*
     * The Knob variables that will be drawn and added to the placeholder
     * views
     */
    
    // Morphing Ocillator Bank 1
    var mob1WaveTypeKnob: Knob!
    var mob1MorphKnob: Knob!
    var mob1OffsetKnob: Knob!
    var mob1VolumeKnob: Knob!
    
    // Morphing Ocillator Bank 2
    var mob2WaveTypeKnob: Knob!
    var mob2MorphKnob: Knob!
    var mob2OffsetKnob: Knob!
    var mob2DetuneKnob: Knob!
    var mob2VolumeKnob: Knob!
    
    // Pulse Width
    var pulseWidthKnob: Knob!
    var pulseWidthOffsetKnob: Knob!
    var pulseWidthVolumeKnob: Knob!
    
    // FM Oscillator
    var fmModulationKnob: Knob!
    var fmVolumeKnob: Knob!
    
    // MOB1 MOB2 Dry Wet
    var mobBalancerKnob: Knob!
    
    // ADSR controls
    var attackKnob: Knob!
    var decayKnob: Knob!
    var sustainKnob: Knob!
    var releaseKnob: Knob!
    
    // Noise
    var noiseVolumeKnob: Knob!
    
    // ADSR view
    var adsrView: ADSRView!
    
    // Bend and master volume
    var globalBendKnob: Knob!
    var masterVolumeKnob: Knob!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         * The following blocks initialise the Knob object by passing 
         * it the bounds information of the placeholder view it will be drawn in.
         * 
         * Next the addTarget method is used in order to specify where the value of the knob 
         * should be sent on change.
         *
         * Finally the Knobs are added to the placeholder view 
         * as subviews.
         */
        
        // MOB1
        mob1WaveTypeKnob = Knob(frame: mob1WaveTypeKnobPlaceholder.bounds)
        mob1WaveTypeKnob.addTarget(self, action: #selector(ViewController.mob1WaveTypeValueChanged), for: .valueChanged)
        mob1WaveTypeKnobPlaceholder.addSubview(mob1WaveTypeKnob)

        mob1MorphKnob = Knob(frame: mob1MorphKnobPlaceholder.bounds)
        mob1MorphKnob.addTarget(self, action: #selector(ViewController.mob1MorphValueChanged), for: .valueChanged)
        mob1MorphKnobPlaceholder.addSubview(mob1MorphKnob)
        
        mob1OffsetKnob = Knob(frame: mob1OffsetKnobPlaceholder.bounds)
        mob1OffsetKnob.addTarget(self, action: #selector(ViewController.mob1OffsetValueChanged), for: .valueChanged)
        mob1OffsetKnobPlaceholder.addSubview(mob1OffsetKnob)

        mob1VolumeKnob = Knob(frame: mob1VolumeKnobPlaceholder.bounds)
        mob1VolumeKnob.addTarget(self, action: #selector(ViewController.mob1VolumeValueChanged), for: .valueChanged)
        mob1VolumeKnobPlaceholder.addSubview(mob1VolumeKnob)
        
        // MOB2
        mob2WaveTypeKnob = Knob(frame: mob2WaveTypeKnobPlaceholder.bounds)
        mob2WaveTypeKnob.addTarget(self, action: #selector(ViewController.mob2WaveTypeValueChanged), for: .valueChanged)
        mob2WaveTypeKnobPlaceholder.addSubview(mob2WaveTypeKnob)

        mob2MorphKnob = Knob(frame: mob2MorphKnobPlaceholder.bounds)
        mob2MorphKnob.addTarget(self, action: #selector(ViewController.mob2MorphValueChanged), for: .valueChanged)
        mob2MorphKnobPlaceholder.addSubview(mob2MorphKnob)
        
        mob2OffsetKnob = Knob(frame: mob2OffsetKnobPlaceholder.bounds)
        mob2OffsetKnob.addTarget(self, action: #selector(ViewController.mob2OffsetValueChanged), for: .valueChanged)
        mob2OffsetKnobPlaceholder.addSubview(mob2OffsetKnob)
        
        mob2DetuneKnob = Knob(frame: mob2DetuneKnobPlaceholder.bounds)
        mob2DetuneKnob.addTarget(self, action: #selector(ViewController.mob2DetuneValueChanged), for: .valueChanged)
        mob2DetuneKnobPlaceholder.addSubview(mob2DetuneKnob)
        
        mob2VolumeKnob = Knob(frame: mob2VolumeKnobPlaceholder.bounds)
        mob2VolumeKnob.addTarget(self, action: #selector(ViewController.mob2VolumeValueChanged), for: .valueChanged)
        mob2VolumeKnobPlaceholder.addSubview(mob2VolumeKnob)
        
        // MOB Balancer
        mobBalancerKnob = Knob(frame: mobBalancerKnobPlaceholder.bounds)
        mobBalancerKnob.addTarget(self, action: #selector(ViewController.mobBalancerValueChanged), for: .valueChanged)
        mobBalancerKnobPlaceholder.addSubview(mobBalancerKnob)
        
        // PWOB
        pulseWidthKnob = Knob(frame: pulseWidthKnobPlaceholder.bounds)
        pulseWidthKnob.addTarget(self, action: #selector(ViewController.pulseWidthValueChanged), for: .valueChanged)
        pulseWidthKnobPlaceholder.addSubview(pulseWidthKnob)
        
        pulseWidthOffsetKnob = Knob(frame: pulseWidthOffsetKnobPlaceholder.bounds)
        pulseWidthOffsetKnob.addTarget(self, action: #selector(ViewController.pulseWidthOffsetValueChanged), for: .valueChanged)
        pulseWidthOffsetKnobPlaceholder.addSubview(pulseWidthOffsetKnob)
        
        pulseWidthVolumeKnob = Knob(frame: pulseWidthVolumeKnobPlaceholder.bounds)
        pulseWidthVolumeKnob.addTarget(self, action: #selector(ViewController.pulseWidthVolumeValueChanged), for: .valueChanged)
        pulseWidthVolumeKnobPlaceholder.addSubview(pulseWidthVolumeKnob)
        
        // FMOB
        fmModulationKnob = Knob(frame: fmModulationKnobPlaceholder.bounds)
        fmModulationKnob.addTarget(self, action: #selector(ViewController.fmModulationValueChanged), for: .valueChanged)
        fmModulationKnobPlaceholder.addSubview(fmModulationKnob)
        
        fmVolumeKnob = Knob(frame: fmVolumeKnobPlaceholder.bounds)
        fmVolumeKnob.addTarget(self, action: #selector(ViewController.fmVolumeValueChanged), for: .valueChanged)
        fmVolumeKnobPlaceholder.addSubview(fmVolumeKnob)
        
        // ADSR
        attackKnob = Knob(frame: attackKnobPlaceholder.bounds)
        attackKnob.addTarget(self, action: #selector(ViewController.attackValueChanged), for: .valueChanged)
        attackKnobPlaceholder.addSubview(attackKnob)
        
        decayKnob = Knob(frame: decayKnobPlaceholder.bounds)
        decayKnob.addTarget(self, action: #selector(ViewController.decayValueChanged), for: .valueChanged)
        decayKnobPlaceholder.addSubview(decayKnob)
        
        sustainKnob = Knob(frame: sustainKnobPlaceholder.bounds)
        sustainKnob.addTarget(self, action: #selector(ViewController.sustainValueChanged), for: .valueChanged)
        sustainKnobPlaceholder.addSubview(sustainKnob)
        
        releaseKnob = Knob(frame: releaseKnobPlaceholder.bounds)
        releaseKnob.addTarget(self, action: #selector(ViewController.releaseValueChanged), for: .valueChanged)
        releaseKnobPlaceholder.addSubview(releaseKnob)
        
        // Noise
        noiseVolumeKnob = Knob(frame: noiseVolumeKnobPlaceholder.bounds)
        noiseVolumeKnob.addTarget(self, action: #selector(ViewController.noiseVolumeValueChanged), for: .valueChanged)
        noiseVolumeKnobPlaceholder.addSubview(noiseVolumeKnob)

        // Bend
        globalBendKnob = Knob(frame: globalBendKnobPlaceholder.bounds)
        globalBendKnob.addTarget(self, action: #selector(ViewController.globalBendValueChanged), for: .valueChanged)
        globalBendKnobPlaceholder.addSubview(globalBendKnob)
        
        // Master Volume
        masterVolumeKnob = Knob(frame: masterVolumeKnobPlaceholder.bounds)
        masterVolumeKnob.addTarget(self, action: #selector(ViewController.masterVolumeValueChanged), for: .valueChanged)
        masterVolumeKnobPlaceholder.addSubview(masterVolumeKnob)
        
        // ADSR view
        adsrView = ADSRView(frame: adsrPlaceholder.bounds)
        
        // This makes sure the drawing reflects the values of the envelope in the audio handler
        adsrView.initialiseADSR(
            nodeAttack: audioHandler.generator.attackDuration,
            nodeDecay: audioHandler.generator.decayDuration,
            nodeSustain: audioHandler.generator.sustainLevel,
            nodeRelease: audioHandler.generator.releaseDuration
        )
        
        adsrPlaceholder.addSubview(adsrView)
        
        /* 
         * Keyboard
         *
         * This is part of a horrible hack. After redownloading and compiling AK for iOS 10.2
         * the AK Keyboard view cuts off early missing out the final line on the right key
         * 
         * So I have set the placholder view to have black backgrounds and sized the element
         * slightly smaller to give the illusion of borders.
         */
        
        // Get placeholder width and height
        let width = Int(keyboardPlaceholder.bounds.width) - 2
        let height = Int(keyboardPlaceholder.bounds.height) - 1
        
        // Initialise keyboard view
        keyboard = AKKeyboardView(width: width, height: height, firstOctave: 4, octaveCount: 2)
        
        // Keyboard settings
        keyboard?.keyOnColor = UIColor.blue
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        
        // Add view to placeholder
        keyboardPlaceholder.addSubview(keyboard!)
        
        // Add waveform plot
        let rect = CGRect(x: 100.0, y: 100.0, width: 823.0, height: 220.0)
        plot = AKNodeOutputPlot(audioHandler.generator, frame: rect)
        plot.color = UIColor.blue
        plot.layer.borderWidth = 0.8
        plot.layer.borderColor = UIColor.blue.cgColor
        view.addSubview(plot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        /*
         * The following blocks set the Knob settings
         * like maxiumum and minimum values and also intialise
         * the knob value to be the same as the audio component its
         * representing.
         *
         * When initially writing this part these were in view did load function
         * but for some reason AK threw an error so they are now in view did appear.
         */
        
        // MOB1
        mob1WaveTypeKnob.maximumValue = 4
        mob1WaveTypeKnob.value = Float(audioHandler.generator.waveform1)
        
        mob1MorphKnob.minimumValue = -4
        mob1MorphKnob.maximumValue = 4
        mob1MorphKnob.value = Float(audioHandler.generator.morph1)
        
        mob1OffsetKnob.minimumValue = -12
        mob1OffsetKnob.maximumValue = 12
        mob1OffsetKnob.value = Float(audioHandler.generator.offset1)
        
        mob1VolumeKnob.value = Float(audioHandler.generator.mob1Mixer.volume)
        
        // MOB 2
        mob2MorphKnob.minimumValue = -4
        mob2MorphKnob.maximumValue = 4
        mob2MorphKnob.value = Float(audioHandler.generator.morph2)
        
        mob2OffsetKnob.minimumValue = -12
        mob2OffsetKnob.maximumValue = 12
        mob2OffsetKnob.value = Float(audioHandler.generator.offset2)
        
        mob2DetuneKnob.minimumValue = -4
        mob2DetuneKnob.maximumValue = 4
        mob2DetuneKnob.value = Float(audioHandler.generator.morphingOscillatorBank2.detuningOffset)
        
        mob2VolumeKnob.value = Float(audioHandler.generator.mob2Mixer.volume)
        
        // MOB1 MOB2 DW Mixer
        mobBalancerKnob.value = Float(audioHandler.generator.mobDryWet.balance)
        
        // PW Modulation
        pulseWidthKnob.value = Float(audioHandler.generator.pulseWidthModulationOscillatorBank.pulseWidth)
        
        pulseWidthOffsetKnob.minimumValue = -12
        pulseWidthOffsetKnob.maximumValue = 12
        pulseWidthOffsetKnob.value = Float(audioHandler.generator.pulseWidthModulationOscillatorBank.detuningOffset)
        
        pulseWidthVolumeKnob.value = Float(audioHandler.generator.pwmobMixer.volume)
        
        // FM Oscillator
        fmModulationKnob.maximumValue = 15
        fmModulationKnob.value = Float(audioHandler.generator.frequencyModulationOscillatorBank.modulationIndex)
        
        fmVolumeKnob.value = Float(audioHandler.generator.fmobMixer.volume)
        
        // Noise
        noiseVolumeKnob.value = Float(audioHandler.generator.noiseMixer.volume)
        
        // ADSR
        attackKnob.value = Float(audioHandler.generator.attackDuration)
        decayKnob.value = Float(audioHandler.generator.decayDuration)
        sustainKnob.value = Float(audioHandler.generator.sustainLevel)
        releaseKnob.value = Float(audioHandler.generator.releaseDuration)
        
        // Envelope
        audioHandler.generator.adsrEnvelope = adsrView
        
        // Bend and Master
        globalBendKnob.maximumValue = 2.0
        globalBendKnob.value = Float(audioHandler.generator.globalbend)
        
        masterVolumeKnob.value = Float(audioHandler.generator.generatorMaster.volume)
        
        // This sets the volume of the effects to zero
        // which means you can focus on getting the perfect waveform
        // while in this view
        audioHandler.effects.balance = 0.0
    }
    
    /*
     * This switch plays a note continuously which
     * is really useful because you can play with the dials
     * while hearing the sound.
     */
    @IBAction func startStopGenerator(_ sender: AnyObject) {
        let middleC: MIDINoteNumber = 60
        let vel: MIDIVelocity = 127
        
        if (startStopSwitch .isOn) {
            audioHandler.generator.play(noteNumber: middleC, velocity: vel)
            startStopSwitch.setOn(true, animated: true)
        } else {
            audioHandler.generator.stop(noteNumber: middleC)
            startStopSwitch.setOn(false, animated: true)
        }
    }
    
    /*
     * The following functions handle the changing of knob values.
     * They all take the knob value and apply it to the relevant audio
     * component.
     */
    func attackValueChanged() {
        audioHandler.generator.attackDuration = Double(attackKnob.value)
    }
    
    func decayValueChanged() {
        audioHandler.generator.decayDuration = Double(decayKnob.value)
    }
    
    func sustainValueChanged() {
        audioHandler.generator.sustainLevel = Double(sustainKnob.value)
    }
    
    func releaseValueChanged() {
        audioHandler.generator.releaseDuration = Double(releaseKnob.value)
    }
    
    func mob1WaveTypeValueChanged() {
        audioHandler.generator.waveform1 = Double(mob1WaveTypeKnob.value)
    }
    
    func mob1MorphValueChanged() {
        audioHandler.generator.morph1 = Double(mob1MorphKnob.value)
    }
    
    func mob1OffsetValueChanged() {
        audioHandler.generator.offset1 = Int(mob1OffsetKnob.value)
    }
    
    func mob1VolumeValueChanged() {
        audioHandler.generator.mob1Mixer.volume = Double(mob1VolumeKnob.value)
    }
    
    func mobBalancerValueChanged() {
        audioHandler.generator.mobDryWet.balance = Double(mobBalancerKnob.value)
    }
    
    func mob2WaveTypeValueChanged() {
        audioHandler.generator.waveform2 = Double(mob2WaveTypeKnob.value)
    }
    
    func mob2MorphValueChanged() {
        audioHandler.generator.morph2 = Double(mob2MorphKnob.value)
    }
    
    func mob2OffsetValueChanged() {
        audioHandler.generator.offset2 = Int(mob2OffsetKnob.value)
    }
    
    func mob2DetuneValueChanged() {
        audioHandler.generator.morphingOscillatorBank2.detuningOffset = Double(mob2DetuneKnob.value)
    }
    
    func mob2VolumeValueChanged() {
        audioHandler.generator.mob2Mixer.volume = Double(mob2VolumeKnob.value)
    }
    
    func pulseWidthValueChanged() {
        audioHandler.generator.pulseWidthModulationOscillatorBank.pulseWidth = Double(pulseWidthKnob.value)
    }
    
    func pulseWidthOffsetValueChanged() {
        audioHandler.generator.pulseWidthModulationOscillatorBank.detuningOffset = Double(pulseWidthOffsetKnob.value)
    }
    
    func pulseWidthVolumeValueChanged() {
        audioHandler.generator.pwmobMixer.volume = Double(pulseWidthVolumeKnob.value)
    }
    
    func fmModulationValueChanged() {
        audioHandler.generator.frequencyModulationOscillatorBank.modulationIndex = Double(fmModulationKnob.value)
    }
    
    func fmVolumeValueChanged() {
        audioHandler.generator.fmobMixer.volume = Double(fmVolumeKnob.value)
    }
    
    func noiseVolumeValueChanged() {
        audioHandler.generator.noiseMixer.volume = Double(noiseVolumeKnob.value)
    }
    
    func globalBendValueChanged() {
        audioHandler.generator.globalbend = Double(globalBendKnob.value)
    }
    
    func masterVolumeValueChanged() {
        audioHandler.generator.generatorMaster.volume = Double(masterVolumeKnob.value)
    }
    
    // Called when an AKKeyboard key is pressed
    func noteOn(note: MIDINoteNumber) {
        audioHandler.generator.play(noteNumber: note, velocity: 80)
    }
    
    // Called when the key is released
    func noteOff(note: MIDINoteNumber) {
        audioHandler.generator.stop(noteNumber: note)
    }
}

