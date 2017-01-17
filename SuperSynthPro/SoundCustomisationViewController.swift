/**
 * This view controller is responsible for the effects page.
 */
import UIKit
import SQLite
import AudioKit

class SoundCustomisationViewController: UIViewController, AKKeyboardDelegate {
    // AudioKit Errors if too many 'taps' are being used
    // This is due to the AVF audio code that AK is built on
    // To avoid this breaking things once the plot is initialised
    // that instance is retained
    static var plot: AKNodeOutputPlot! = nil
    static var viewInitialised = false
    
    /*
     * The UI Knobs are drawn in UIViews placed in the storyboard
     * These placeholder variables represent these UIViews.
     * The Knobs will be intialised on load and added to these
     * placeholder views as subviews.
     */
    
    // Keyboard
    @IBOutlet var effectsKeyboardPlaceholder: UIView!
    
    // Live waveform plot
    @IBOutlet var waveformPlaceholder: UIView!
    
    // Low pass filter 1 controls
    @IBOutlet var lowPass1CuttoffKnobPlaceholder: UIView!
    @IBOutlet var lowPass1ResonanceKnobPlaceholder: UIView!
    
    // Low pass filter 1 controls
    @IBOutlet var lowPass2CuttoffKnobPlaceholder: UIView!
    @IBOutlet var lowPass2ResonanceKnobPlaceholder: UIView!
    
    // High pass
    @IBOutlet var highPassCuttoffKnobPlaceholder: UIView!
    @IBOutlet var highPassResonanceKnobPlaceholder: UIView!

    // Low pass filter 1's cutoff ADSR
    @IBOutlet var lowPass1AttackKnobPlaceholder: UIView!
    @IBOutlet var lowPass1DecayKnobPlaceholder: UIView!
    @IBOutlet var lowPass1SustainKnobPlaceholder: UIView!
    @IBOutlet var lowPass1ReleaseKnobPlaceholder: UIView!
    
    // LP1 Volume
    @IBOutlet var lowPass1VolumeKnobPlaceholder: UIView!
    
    // Low pass filter 2's cutoff ADSR
    @IBOutlet var lowPass2AttackKnobPlaceholder: UIView!
    @IBOutlet var lowPass2DecayKnobPlaceholder: UIView!
    @IBOutlet var lowPass2SustainKnobPlaceholder: UIView!
    @IBOutlet var lowPass2ReleaseKnobPlaceholder: UIView!
    
    // LP2 Volume
    @IBOutlet var lowPass2VolumeKnobPlaceholder: UIView!
    
    // Wobble control
    @IBOutlet var wobblePowerKnobPlaceholder: UIView!
    @IBOutlet var wobbleRateKnobPlaceholder: UIView!
    
    // Variable delay
    @IBOutlet var delayTimeKnobPlaceholder: UIView!
    @IBOutlet var delayFeedbackKnobPlaceholder: UIView!
    @IBOutlet var delayLfoRateKnobPlaceholder: UIView!
    @IBOutlet var delayLfoAmplitudeKnobPlaceholder: UIView!
    
    // Reverb
    @IBOutlet var reverbDurationKnobPlaceholder: UIView!
    
    // Wah
    @IBOutlet var wahKnobPlaceholder: UIView!
    @IBOutlet var wahRateKnobPlaceholder: UIView!
    
    // EQ
    @IBOutlet var lowKnobPlaceholder: UIView!
    @IBOutlet var midKnobPlaceholder: UIView!
    @IBOutlet var highKnobPlaceholder: UIView!
    
    // Bend and master volume
    @IBOutlet var globalBendKnobPlaceholder: UIView!
    @IBOutlet var masterVolumeKnobPlaceholder: UIView!
    
    // The custom ADSR envelopes for LP1 and LP2
    @IBOutlet weak var lp1ADSRPlaceholder: UIView!
    @IBOutlet weak var lp2ADSRPlaceholder: UIView!
    
    // The shared instance of the audio handler
    var audioHandler = AudioHandler.sharedInstance
    
    // Another useful middle C switch
    @IBOutlet var startStopSwitch: UISwitch!
    
    // Bitcrusher on and off
    @IBOutlet var bitCrusherTrigger: UISwitch!

    // The on off button outlets for the audio components
    @IBOutlet var lowPass1OnOffButton: UIButton!
    @IBOutlet var lowPass2OnOffButton: UIButton!
    @IBOutlet var wobbleOnOffButton: UIButton!
    @IBOutlet var delayOnOffButton: UIButton!
    @IBOutlet var reverbOnOffButton: UIButton!
    @IBOutlet var wahOnOffButton: UIButton!
    @IBOutlet var highPassOnOffButton: UIButton!
    
    /*
     * The Knob variables that will be drawn and added to the placeholder
     * views
     */
    
    // LP1
    var lowPass1CuttoffKnob: Knob!
    var lowPass1ResonanceKnob: Knob!
    
    // LP2
    var lowPass2CuttoffKnob: Knob!
    var lowPass2ResonanceKnob: Knob!
    
    // LP1 Volume
    var lowPass1VolumeKnob: Knob!
    var lowPass2VolumeKnob: Knob!
    
    // LP1 Cutoff ADSR
    var lowPass1AttackKnob: Knob!
    var lowPass1DecayKnob: Knob!
    var lowPass1SustainKnob: Knob!
    var lowPass1ReleaseKnob: Knob!
    
    // LP2 Cutoff ADSR
    var lowPass2AttackKnob: Knob!
    var lowPass2DecayKnob: Knob!
    var lowPass2SustainKnob: Knob!
    var lowPass2ReleaseKnob: Knob!
    
    // Wobble
    var wobblePowerKnob: Knob!
    var wobbleRateKnob: Knob!
    
    // High Pass
    var highPassCuttoffKnob: Knob!
    var highPassResonanceKnob: Knob!
    
    // Delay
    var delayTimeKnob: Knob!
    var delayFeedbackKnob: Knob!
    var delayLfoRateKnob: Knob!
    var delayLfoAmplitudeKnob: Knob!
    
    // Reverb
    var reverbDurationKnob: Knob!
    
    // Wah
    var wahKnob: Knob!
    var wahRateKnob: Knob!
    
    // EQ
    var lowKnob: Knob!
    var midKnob: Knob!
    var highKnob: Knob!
    
    // Bend and master
    var globalBendKnob: Knob!
    var masterVolumeKnob: Knob!
    
    // LP1 and LP2 envelope views
    var lp1ADSR: ADSRView!
    var lp2ADSR: ADSRView!
    
    // Keyboard
    var keyboard: AKKeyboardView?
    
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

        
        // Low pass 1 filter knobs
        lowPass1CuttoffKnob = Knob(frame: lowPass1CuttoffKnobPlaceholder.bounds)
        lowPass1CuttoffKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass1CuttoffValueChanged), for: .valueChanged)
        lowPass1CuttoffKnobPlaceholder.addSubview(lowPass1CuttoffKnob)
        
        lowPass1ResonanceKnob = Knob(frame: lowPass1ResonanceKnobPlaceholder.bounds)
        lowPass1ResonanceKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass1ResonanceValueChanged), for: .valueChanged)
        lowPass1ResonanceKnobPlaceholder.addSubview(lowPass1ResonanceKnob)
        
        lowPass1AttackKnob = Knob(frame: lowPass1AttackKnobPlaceholder.bounds)
        lowPass1AttackKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass1AttackValueChanged), for: .valueChanged)
        lowPass1AttackKnobPlaceholder.addSubview(lowPass1AttackKnob)
        
        lowPass1DecayKnob = Knob(frame: lowPass1DecayKnobPlaceholder.bounds)
        lowPass1DecayKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass1DecayValueChanged), for: .valueChanged)
        lowPass1DecayKnobPlaceholder.addSubview(lowPass1DecayKnob)
        
        lowPass1SustainKnob = Knob(frame: lowPass1SustainKnobPlaceholder.bounds)
        lowPass1SustainKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass1SustainValueChanged), for: .valueChanged)
        lowPass1SustainKnobPlaceholder.addSubview(lowPass1SustainKnob)
        
        lowPass1ReleaseKnob = Knob(frame: lowPass1ReleaseKnobPlaceholder.bounds)
        lowPass1ReleaseKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass1ReleaseValueChanged), for: .valueChanged)
        lowPass1ReleaseKnobPlaceholder.addSubview(lowPass1ReleaseKnob)
        
        lowPass1VolumeKnob = Knob(frame: lowPass1VolumeKnobPlaceholder.bounds)
        lowPass1VolumeKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass1VolumeValueChanged), for: .valueChanged)
        lowPass1VolumeKnobPlaceholder.addSubview(lowPass1VolumeKnob)
        
        // Low pass 2 filter knobs
        lowPass2CuttoffKnob = Knob(frame: lowPass2CuttoffKnobPlaceholder.bounds)
        lowPass2CuttoffKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass2CuttoffValueChanged), for: .valueChanged)
        lowPass2CuttoffKnobPlaceholder.addSubview(lowPass2CuttoffKnob)
        
        lowPass2ResonanceKnob = Knob(frame: lowPass2ResonanceKnobPlaceholder.bounds)
        lowPass2ResonanceKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass2ResonanceValueChanged), for: .valueChanged)
        lowPass2ResonanceKnobPlaceholder.addSubview(lowPass2ResonanceKnob)
        
        lowPass2AttackKnob = Knob(frame: lowPass2AttackKnobPlaceholder.bounds)
        lowPass2AttackKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass2AttackValueChanged), for: .valueChanged)
        lowPass2AttackKnobPlaceholder.addSubview(lowPass2AttackKnob)
        
        lowPass2DecayKnob = Knob(frame: lowPass2DecayKnobPlaceholder.bounds)
        lowPass2DecayKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass2DecayValueChanged), for: .valueChanged)
        lowPass2DecayKnobPlaceholder.addSubview(lowPass2DecayKnob)
        
        lowPass2SustainKnob = Knob(frame: lowPass2SustainKnobPlaceholder.bounds)
        lowPass2SustainKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass2SustainValueChanged), for: .valueChanged)
        lowPass2SustainKnobPlaceholder.addSubview(lowPass2SustainKnob)
        
        lowPass2ReleaseKnob = Knob(frame: lowPass2ReleaseKnobPlaceholder.bounds)
        lowPass2ReleaseKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass2ReleaseValueChanged), for: .valueChanged)
        lowPass2ReleaseKnobPlaceholder.addSubview(lowPass2ReleaseKnob)
        
        lowPass2VolumeKnob = Knob(frame: lowPass2VolumeKnobPlaceholder.bounds)
        lowPass2VolumeKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPass2VolumeValueChanged), for: .valueChanged)
        lowPass2VolumeKnobPlaceholder.addSubview(lowPass2VolumeKnob)
        
        // Wobble knobs
        wobblePowerKnob = Knob(frame: wobblePowerKnobPlaceholder.bounds)
        wobblePowerKnob.addTarget(self, action: #selector(SoundCustomisationViewController.wobblePowerValueChanged), for: .valueChanged)
        wobblePowerKnobPlaceholder.addSubview(wobblePowerKnob)
        
        wobbleRateKnob = Knob(frame: wobbleRateKnobPlaceholder.bounds)
        wobbleRateKnob.addTarget(self, action: #selector(SoundCustomisationViewController.wobbleRateValueChanged), for: .valueChanged)
        wobbleRateKnobPlaceholder.addSubview(wobbleRateKnob)
        
        // High pass knobs
        highPassCuttoffKnob = Knob(frame: highPassCuttoffKnobPlaceholder.bounds)
        highPassCuttoffKnob.addTarget(self, action: #selector(SoundCustomisationViewController.highPassCuttoffValueChanged), for: .valueChanged)
        highPassCuttoffKnobPlaceholder.addSubview(highPassCuttoffKnob)
        
        highPassResonanceKnob = Knob(frame: highPassResonanceKnobPlaceholder.bounds)
        highPassResonanceKnob.addTarget(self, action: #selector(SoundCustomisationViewController.highPassResonanceValueChanged), for: .valueChanged)
        highPassResonanceKnobPlaceholder.addSubview(highPassResonanceKnob)
        
        // Delay Knobs
        delayTimeKnob = Knob(frame: delayTimeKnobPlaceholder.bounds)
        delayTimeKnob.addTarget(self, action: #selector(SoundCustomisationViewController.delayTimeValueChanged), for: .valueChanged)
        delayTimeKnobPlaceholder.addSubview(delayTimeKnob)
        
        delayFeedbackKnob = Knob(frame: delayFeedbackKnobPlaceholder.bounds)
        delayFeedbackKnob.addTarget(self, action: #selector(SoundCustomisationViewController.delayFeedbackValueChanged), for: .valueChanged)
        delayFeedbackKnobPlaceholder.addSubview(delayFeedbackKnob)
        
        delayLfoRateKnob = Knob(frame: delayLfoRateKnobPlaceholder.bounds)
        delayLfoRateKnob.addTarget(self, action: #selector(SoundCustomisationViewController.delayLfoRateValueChanged), for: .valueChanged)
        delayLfoRateKnobPlaceholder.addSubview(delayLfoRateKnob)
        
        delayLfoAmplitudeKnob = Knob(frame: delayLfoAmplitudeKnobPlaceholder.bounds)
        delayLfoAmplitudeKnob.addTarget(self, action: #selector(SoundCustomisationViewController.delayLfoAmplitudeValueChanged), for: .valueChanged)
        delayLfoAmplitudeKnobPlaceholder.addSubview(delayLfoAmplitudeKnob)
        
        // Reverb knobs
        reverbDurationKnob = Knob(frame: reverbDurationKnobPlaceholder.bounds)
        reverbDurationKnob.addTarget(self, action: #selector(SoundCustomisationViewController.reverbDurationValueChanged), for: .valueChanged)
        reverbDurationKnobPlaceholder.addSubview(reverbDurationKnob)
        
        // Wah
        wahKnob = Knob(frame: wahKnobPlaceholder.bounds)
        wahKnob.addTarget(self, action: #selector(SoundCustomisationViewController.wahValueChanged), for: .valueChanged)
        wahKnobPlaceholder.addSubview(wahKnob)
        
        wahRateKnob = Knob(frame: wahRateKnobPlaceholder.bounds)
        wahRateKnob.addTarget(self, action: #selector(SoundCustomisationViewController.wahRateValueChanged), for: .valueChanged)
        wahRateKnobPlaceholder.addSubview(wahRateKnob)
        
        lowKnob = Knob(frame: lowKnobPlaceholder.bounds)
        lowKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowValueChanged), for: .valueChanged)
        lowKnobPlaceholder.addSubview(lowKnob)
        
        midKnob = Knob(frame: midKnobPlaceholder.bounds)
        midKnob.addTarget(self, action: #selector(SoundCustomisationViewController.midValueChanged), for: .valueChanged)
        midKnobPlaceholder.addSubview(midKnob)
        
        highKnob = Knob(frame: highKnobPlaceholder.bounds)
        highKnob.addTarget(self, action: #selector(SoundCustomisationViewController.highValueChanged), for: .valueChanged)
        highKnobPlaceholder.addSubview(highKnob)
        
        // Global bend
        globalBendKnob = Knob(frame: globalBendKnobPlaceholder.bounds)
        globalBendKnob.addTarget(self, action: #selector(SoundCustomisationViewController.globalBendValueChanged), for: .valueChanged)
        globalBendKnobPlaceholder.addSubview(globalBendKnob)
        
        // Master volume
        masterVolumeKnob = Knob(frame: masterVolumeKnobPlaceholder.bounds)
        masterVolumeKnob.addTarget(self, action: #selector(SoundCustomisationViewController.masterVolumeValueChanged), for: .valueChanged)
        masterVolumeKnobPlaceholder.addSubview(masterVolumeKnob)
        
        // Keyboard
        keyboard = AKKeyboardView(width: 680, height: 128)
        keyboard?.sizeToFit()
        keyboard?.keyOnColor = UIColor.blue
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        effectsKeyboardPlaceholder.addSubview(keyboard!)
        
        // ADSR lp1
        lp1ADSR = ADSRView(frame: lp1ADSRPlaceholder.bounds)
        
        // Sets the drawn envelope to use the same values as the component
        lp1ADSR.initialiseADSR(
            nodeAttack: audioHandler.lowPassFilter.attack,
            nodeDecay: audioHandler.lowPassFilter.decay,
            nodeSustain: audioHandler.lowPassFilter.sustain,
            nodeRelease: audioHandler.lowPassFilter.rel
        )
        
        lp1ADSRPlaceholder.addSubview(lp1ADSR)
        
        // ADSR lp2
        lp2ADSR = ADSRView(frame: lp2ADSRPlaceholder.bounds)
        
        // Sets the drawn envelope to use the same values as the component
        lp2ADSR.initialiseADSR(
            nodeAttack: audioHandler.lowPassFilter2.attack,
            nodeDecay: audioHandler.lowPassFilter2.decay,
            nodeSustain: audioHandler.lowPassFilter2.sustain,
            nodeRelease: audioHandler.lowPassFilter2.rel
        )
        
        lp2ADSRPlaceholder.addSubview(lp2ADSR)
        
        // Multiple Plotting nodes cause an error related to recording taps as mentioned above
        if (SoundCustomisationViewController.viewInitialised == false) {
            let plotFrame = CGRect(x: 8.0, y: 0.0, width: 235.0, height: 200.0)
            SoundCustomisationViewController.plot = AKNodeOutputPlot(audioHandler.master, frame: plotFrame)
            SoundCustomisationViewController.plot.color = UIColor.blue
            SoundCustomisationViewController.plot.layer.borderWidth = 0.8
            SoundCustomisationViewController.plot.layer.borderColor = UIColor.blue.cgColor
            
            SoundCustomisationViewController.viewInitialised = true
        }
        
        // The intialisation code is ran once then each time the view is loaded that
        // instance of the plot is added to the view here
        waveformPlaceholder.addSubview(SoundCustomisationViewController.plot)
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

        // Low Pass 1 Settings
        lowPass1CuttoffKnob.minimumValue = 24.0
        lowPass1CuttoffKnob.maximumValue = 4200.0
        
        lowPass1CuttoffKnob.value = Float(audioHandler.lowPassFilter.cutOff)
        
        // Set the lp resonance to a low value to prevent noisey woop sound
        // when intialised
        audioHandler.lowPassFilter.resonance = 0.6
        
        lowPass1ResonanceKnob.maximumValue = 2.0
        lowPass1ResonanceKnob.value = Float(audioHandler.lowPassFilter.resonance)
        
        lowPass1AttackKnob.maximumValue = 2.0
        lowPass1AttackKnob.value = Float(audioHandler.lowPassFilter.attack)
        
        lowPass1DecayKnob.maximumValue = 2.0
        lowPass1DecayKnob.value = Float(audioHandler.lowPassFilter.decay)
        
        lowPass1SustainKnob.value = Float(audioHandler.lowPassFilter.sustain)
        
        lowPass1ReleaseKnob.maximumValue = 3.0
        lowPass1ReleaseKnob.value = Float(audioHandler.lowPassFilter.rel)
        
        lowPass1VolumeKnob.value = Float(audioHandler.lowPassFilterMixer.volume)
        
        audioHandler.lowPassFilter.ADSRView = lp1ADSR
        
        // Low Pass 2 Settings
        lowPass2CuttoffKnob.minimumValue = 24.0
        lowPass2CuttoffKnob.maximumValue = 4200.0
        lowPass2CuttoffKnob.value = Float(audioHandler.lowPassFilter2.cutOff)
        
        // Set the lp resonance to a low value to prevent noisey woop sound
        // when intialised
        audioHandler.lowPassFilter2.resonance = 0.6
        
        lowPass2ResonanceKnob.maximumValue = 2.0
        lowPass2ResonanceKnob.value = Float(audioHandler.lowPassFilter2.resonance)
        
        lowPass2AttackKnob.maximumValue = 2.0
        lowPass2AttackKnob.value = Float(audioHandler.lowPassFilter2.attack)
        
        lowPass2DecayKnob.maximumValue = 2.0
        lowPass2DecayKnob.value = Float(audioHandler.lowPassFilter2.decay)
        
        lowPass2SustainKnob.value = Float(audioHandler.lowPassFilter2.sustain)
        
        lowPass2ReleaseKnob.maximumValue = 3.0
        lowPass2ReleaseKnob.value = Float(audioHandler.lowPassFilter2.rel)
        
        lowPass2VolumeKnob.value = Float(audioHandler.lowPassFilter2Mixer.volume)
        
        audioHandler.lowPassFilter2.ADSRView = lp2ADSR

        
        // Wobble settings
        wobblePowerKnob.maximumValue = 1000.0
        wobblePowerKnob.value = Float(audioHandler.wobble.halfPowerFrequency)
        
        wobbleRateKnob.maximumValue = 20.0
        wobbleRateKnob.value = Float(audioHandler.wobble.lfoRate)
        
        // High pass settings
        highPassCuttoffKnob.maximumValue = 4200.0
        highPassCuttoffKnob.value = Float(audioHandler.highPassFilter.cutoffFrequency)
        
        highPassResonanceKnob.value = Float(audioHandler.highPassFilter.resonance)
        
        // Delay Knob Settings
        delayTimeKnob.maximumValue = 1.5
        delayTimeKnob.value = Float(audioHandler.delay.time)
        
        delayFeedbackKnob.value = Float(audioHandler.delay.feedback)
        
        delayLfoRateKnob.maximumValue = 100.0
        delayLfoRateKnob.value = Float(audioHandler.delay.lfoRate)
        
        delayLfoAmplitudeKnob.value = Float(audioHandler.delay.lfoAmplitude)
        
        // Reverb
        reverbDurationKnob.maximumValue = 2.0
        reverbDurationKnob.value = Float(audioHandler.reverb.reverbDuration)
        
        // Wah
        wahKnob.value = Float(audioHandler.autoWah.wahAmount)
        
        wahRateKnob.maximumValue = 10.0
        wahRateKnob.value = Float(audioHandler.autoWah.lfoRate)
        
        // EQ
        lowKnob.maximumValue = 9.0
        lowKnob.value = Float(audioHandler.low.gain)
        
        midKnob.maximumValue = 9.0
        midKnob.value = Float(audioHandler.middle.gain)
        
        highKnob.maximumValue = 9.0
        highKnob.value = Float(audioHandler.high.gain)
        
        // Global bend
        globalBendKnob.value = Float(audioHandler.generator.globalbend)
        
        // Master volume
        masterVolumeKnob.value = Float(audioHandler.generator.generatorMaster.volume)
        
        
        /*
         * The following blocks check if a component in the audio handler is 
         * on or off and then change the button image to reflect that
         */
        if (audioHandler.bitCrusher.isStarted) {
            bitCrusherTrigger.setOn(true, animated: false)
        }
        
        // lp1 on off button reflect status
        if (audioHandler.lowPassFilter.output.isStarted) {
            lowPass1OnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            lowPass1OnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        // lp2 on off button reflect status
        if (audioHandler.lowPassFilter2.output.isStarted) {
            lowPass2OnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            lowPass2OnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        // wobble on off button reflect status
        if (audioHandler.wobble.output.isStarted) {
            wobbleOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            wobbleOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        // highpass on off button reflect status
        if (audioHandler.highPassFilter.isStarted) {
            highPassOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            highPassOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        // wah on off button reflect status
        if (audioHandler.autoWah.output.isStarted) {
            wahOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            wahOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        if (audioHandler.delay.output.isStarted) {
            delayOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            delayOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        if (audioHandler.reverb.isStarted) {
            reverbOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            reverbOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        // This sets the balance of the effects mixer allowing the full circuit to be 
        // heard (effects on)
        audioHandler.effects.balance = 1.0
    }
    
    /*
     * The following trigger methods are used to handle the component on off buttons
     *
     * If a component on off value is changed start or stop the component
     * and set the button status to reflect the change.
     */
    @IBAction func bitCrusherTriggerValueChanged(_ sender: UISwitch) {
        // Bitcrusher on / off
        if (bitCrusherTrigger .isOn) {
            audioHandler.bitCrusher.start()
            bitCrusherTrigger.setOn(true, animated: true)
        } else {
            audioHandler.bitCrusher.stop()
            bitCrusherTrigger.setOn(false, animated: true)
        }
    }
   
    @IBAction func lowPass1TriggerValueChanged(_ sender: UIButton) {
        if (audioHandler.lowPassFilter.output.isStarted) {
            // Turn off
            lowPass1OnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
            audioHandler.lowPassFilter.output.stop()
        } else {
            // Turn on
            lowPass1OnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
            audioHandler.lowPassFilter.output.start()
        }
    }
    
    @IBAction func lowPass2TriggerValueChanged(_ sender: UIButton) {
        if (audioHandler.lowPassFilter2.output.isStarted) {
            // Turn off
            lowPass2OnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
            audioHandler.lowPassFilter2.output.stop()
        } else {
            // Turn on
            lowPass2OnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
            audioHandler.lowPassFilter2.output.start()
        }
    }
    
    @IBAction func wobbleTriggerValueChanged(_ sender: UIButton) {
        if (audioHandler.wobble.output.isStarted) {
            // Turn off
            wobbleOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
            audioHandler.wobble.output.stop()
        } else {
            // Turn on
            wobbleOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
            audioHandler.wobble.output.start()
        }
    }
    
    @IBAction func delayTriggerValueChanged(_ sender: UIButton) {
        if (audioHandler.delay.output.isStarted) {
            // Turn off
            delayOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
            audioHandler.delay.output.stop()
        } else {
            // Turn on
            delayOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
            audioHandler.delay.output.start()
        }
    }
    
    @IBAction func highPassTriggerValueChanged(_ sender: UIButton) {
        if (audioHandler.highPassFilter.isStarted) {
            // Turn off
            highPassOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
            audioHandler.highPassFilter.stop()
        } else {
            // Turn on
            highPassOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
            audioHandler.highPassFilter.start()
        }
    }
    
    @IBAction func reverbTriggerValueChange(_ sender: UIButton) {
        if (audioHandler.reverb.isStarted) {
            // Turn off
            reverbOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
            audioHandler.reverb.stop()
        } else {
            // Turn on
            reverbOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
            audioHandler.reverb.start()
        }
    }
    
    @IBAction func wahTriggerValueChanged(_ sender: UIButton) {
        if (audioHandler.autoWah.output.isStarted) {
            // Turn off
            wahOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
            audioHandler.autoWah.output.stop()
        } else {
            // Turn on
            wahOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
            audioHandler.autoWah.output.start()
        }
    }
    
    @IBAction func startStopSwitchValueChanged(_ sender: UISwitch) {
        if (startStopSwitch .isOn) {
            audioHandler.generator.play(noteNumber: 60, velocity: 80)
            startStopSwitch.setOn(true, animated: true)
        } else {
            audioHandler.generator.stop(noteNumber: 60)
            startStopSwitch.setOn(false, animated: true)
        }
    }
    
    /*
     * The following value changed blocks handle the knob value changing
     * and assing the value to the component the knob is tracking
     */
    
    func lowPass1CuttoffValueChanged() {
        audioHandler.lowPassFilter.cutOff = Double(lowPass1CuttoffKnob.value)
    }
    
    func lowPass1ResonanceValueChanged() {
        audioHandler.lowPassFilter.resonance = Double(lowPass1ResonanceKnob.value)
    }
    
    func lowPass1AttackValueChanged() {
        audioHandler.lowPassFilter.attack = Double(lowPass1AttackKnob.value)
    }
    
    func lowPass1DecayValueChanged() {
        audioHandler.lowPassFilter.decay = Double(lowPass1DecayKnob.value)
    }
    
    func lowPass1SustainValueChanged() {
        audioHandler.lowPassFilter.sustain = Double(lowPass1SustainKnob.value)
    }
    
    func lowPass1ReleaseValueChanged() {
        audioHandler.lowPassFilter.rel = Double(lowPass1ReleaseKnob.value)
    }
    
    func lowPass1VolumeValueChanged() {
        audioHandler.lowPassFilterMixer.volume = Double(lowPass1VolumeKnob.value)
    }
    
    func lowPass2CuttoffValueChanged() {
        audioHandler.lowPassFilter2.cutOff = Double(lowPass2CuttoffKnob.value)
    }
    
    func lowPass2ResonanceValueChanged() {
        audioHandler.lowPassFilter2.resonance = Double(lowPass2ResonanceKnob.value)
    }
    
    func lowPass2AttackValueChanged() {
        audioHandler.lowPassFilter2.attack = Double(lowPass2AttackKnob.value)
    }
    
    func lowPass2DecayValueChanged() {
        audioHandler.lowPassFilter2.decay = Double(lowPass2DecayKnob.value)
    }
    
    func lowPass2SustainValueChanged() {
        audioHandler.lowPassFilter2.sustain = Double(lowPass2SustainKnob.value)
    }
    
    func lowPass2ReleaseValueChanged() {
        audioHandler.lowPassFilter2.rel = Double(lowPass2ReleaseKnob.value)
    }
    
    func lowPass2VolumeValueChanged() {
        audioHandler.lowPassFilter2Mixer.volume = Double(lowPass2VolumeKnob.value)
    }
    
    func wobblePowerValueChanged() {
        audioHandler.wobble.halfPowerFrequency = Double(wobblePowerKnob.value)
    }
    
    func wobbleRateValueChanged() {
        audioHandler.wobble.lfoRate = Double(wobbleRateKnob.value)
    }
    
    func highPassCuttoffValueChanged() {
        audioHandler.highPassFilter.cutoffFrequency = Double(highPassCuttoffKnob.value)
    }
    
    func highPassResonanceValueChanged() {
        audioHandler.highPassFilter.resonance = Double(highPassResonanceKnob.value)
    }
    
    func delayTimeValueChanged() {
        audioHandler.delay.time = Double(delayTimeKnob.value)
    }
    
    func delayFeedbackValueChanged() {
        audioHandler.delay.feedback = Double(delayFeedbackKnob.value)
    }
    
    func delayLfoRateValueChanged() {
        audioHandler.delay.lfoRate = Double(delayLfoRateKnob.value)
    }
    
    func delayLfoAmplitudeValueChanged() {
        audioHandler.delay.lfoAmplitude = Double(delayLfoAmplitudeKnob.value)
    }
    
    func reverbDurationValueChanged() {
        audioHandler.reverb.reverbDuration = Double(reverbDurationKnob.value)
    }
    
    func wahValueChanged() {
        audioHandler.autoWah.wahAmount = Double(wahKnob.value)
    }
    
    func wahRateValueChanged() {
        audioHandler.autoWah.lfoRate = Double(wahRateKnob.value)
    }
    
    func lowValueChanged() {
        audioHandler.low.gain = Double(lowKnob.value)
    }
    
    func midValueChanged() {
        audioHandler.middle.gain = Double(midKnob.value)
    }
    
    func highValueChanged() {
        audioHandler.high.gain = Double(highKnob.value)
    }
    
    func globalBendValueChanged() {
        audioHandler.generator.globalbend = Double(globalBendKnob.value)
    }
    
    func masterVolumeValueChanged() {
        audioHandler.generator.generatorMaster.volume = Double(masterVolumeKnob.value)
    }

    /* The keyboard note on function also needs to set LP1 and LP2 'gate'
     * values to 1 if they are switched on.  This is because the cutoff ADSR is gate triggered
     * to acheive that funky woop sound when a key is pressed
     */
    func noteOn(note: MIDINoteNumber) {
        audioHandler.generator.play(noteNumber: note, velocity: 80)
        if (audioHandler.lowPassFilter.output.isStarted) {
            audioHandler.lowPassFilter.gate = 1
        }
        
        if (audioHandler.lowPassFilter2.output.isStarted) {
            audioHandler.lowPassFilter2.gate = 1
        }
    }
    
    /*
     * When the keyboard key is released also set the LP gates to 0
     */
    func noteOff(note: MIDINoteNumber) {
        audioHandler.generator.stop(noteNumber: note)
        audioHandler.lowPassFilter.gate = 0
        audioHandler.lowPassFilter2.gate = 0
    }
}
