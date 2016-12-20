import UIKit
import SQLite
import AudioKit

class SoundCustomisationViewController: UIViewController, AKKeyboardDelegate {
    let db = DatabaseConnector()
    
    static var plot: AKNodeOutputPlot! = nil
    
    var keyboard: AKKeyboardView?
    @IBOutlet weak var effectsKeyboardPlaceholder: UIView!
    
    @IBOutlet weak var effectsKeyboard: UIView!
    static var viewInitialised = false
    
    @IBOutlet var rolandCutoffKnobPlaceholder: UIView!
    @IBOutlet var rolandResonanceKnobPlaceholder: UIView!
    @IBOutlet var rolandDistortionKnobPlaceholder: UIView!
    @IBOutlet var rolandResonanceAsymetryKnobPlaceholder: UIView!
    @IBOutlet var rolandDryWetKnobPlaceholder: UIView!
    
    @IBOutlet var delayTimeKnobPlaceholder: UIView!
    @IBOutlet var delayFeedbackKnobPlaceholder: UIView!
    @IBOutlet var delayLfoRateKnobPlaceholder: UIView!
    @IBOutlet var delayLfoAmplitudeKnobPlaceholder: UIView!
    @IBOutlet var delayDryWetKnobPlaceholder: UIView!
    
    @IBOutlet var lowPassHalfPowerKnobPlaceholder: UIView!
    @IBOutlet var lowPassLfoRateKnobPlaceholder: UIView!
    @IBOutlet var lowPassLfoAmplitudeKnobPlaceholder: UIView!
    @IBOutlet var lowPassDryWetKnobPlaceholder: UIView!
    
    @IBOutlet var highPassHalfPowerKnobPlaceholder: UIView!
    @IBOutlet var highPassLfoRateKnobPlaceholder: UIView!
    @IBOutlet var highPassLfoAmplitudeKnobPlaceholder: UIView!
    @IBOutlet var highPassDryWetKnobPlaceholder: UIView!
    
    @IBOutlet var reverbFeedbackKnobPlaceholder: UIView!
    @IBOutlet var reverbCuttoffKnobPlaceholder: UIView!
    @IBOutlet var reverbDryWetKnobPlaceholder: UIView!
    
    @IBOutlet var wahKnobPlaceholder: UIView!
    @IBOutlet var wahRateKnobPlaceholder: UIView!
    @IBOutlet var wahDryWetKnobPlaceholder: UIView!
    
    @IBOutlet var globalBendKnobPlaceholder: UIView!
    @IBOutlet var masterVolumeKnobPlaceholder: UIView!
    
    var audioHandler = AudioHandler.sharedInstance
    
    @IBOutlet var startStopSwitch: UISwitch!
    @IBOutlet var bitCrusherTrigger: UISwitch!

    @IBOutlet var rolandOnOffButton: UIButton!
    @IBOutlet var delayOnOffButton: UIButton!
    @IBOutlet var lowPassOnOffButton: UIButton!
    
    var rolandCutoffKnob: Knob!
    var rolandResonanceKnob: Knob!
    var rolandDistortionKnob: Knob!
    var rolandResonanceAsymetryKnob: Knob!
    var rolandDryWetKnob: Knob!
    
    var delayTimeKnob: Knob!
    var delayFeedbackKnob: Knob!
    var delayLfoRateKnob: Knob!
    var delayLfoAmplitudeKnob: Knob!
    var delayDryWetKnob: Knob!
    
    var lowPassHalfPowerKnob: Knob!
    var lowPassLfoRateKnob: Knob!
    var lowPassLfoAmplitudeKnob: Knob!
    var lowPassDryWetKnob: Knob!
    
    var highPassHalfPowerKnob: Knob!
    var highPassLfoRateKnob: Knob!
    var highPassLfoAmplitudeKnob: Knob!
    var highPassDryWetKnob: Knob!
    
    var reverbFeedbackKnob: Knob!
    var reverbCuttoffKnob: Knob!
    var reverbDryWetKnob: Knob!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Compressor Knobs
        rolandCutoffKnob = Knob(frame: rolandCutoffKnobPlaceholder.bounds)
        rolandCutoffKnob.addTarget(self, action: #selector(SoundCustomisationViewController.rolandCutoffValueChanged), for: .valueChanged)
        rolandCutoffKnobPlaceholder.addSubview(rolandCutoffKnob)
        
        rolandResonanceKnob = Knob(frame:rolandResonanceKnobPlaceholder.bounds)
        rolandResonanceKnob.addTarget(self, action: #selector(SoundCustomisationViewController.rolandResonanceValueChanged), for: .valueChanged)
        rolandResonanceKnobPlaceholder.addSubview(rolandResonanceKnob)
        
        rolandDistortionKnob = Knob(frame:rolandDistortionKnobPlaceholder.bounds)
        rolandDistortionKnob.addTarget(self, action: #selector(SoundCustomisationViewController.rolandDistortionValueChanged), for: .valueChanged)
        rolandDistortionKnobPlaceholder.addSubview(rolandDistortionKnob)
        
        rolandResonanceAsymetryKnob = Knob(frame:rolandResonanceAsymetryKnobPlaceholder.bounds)
        rolandResonanceAsymetryKnob.addTarget(self, action: #selector(SoundCustomisationViewController.rolandResonanceAsymetryValueChanged), for: .valueChanged)
        rolandResonanceAsymetryKnobPlaceholder.addSubview(rolandResonanceAsymetryKnob)
        
        rolandDryWetKnob = Knob(frame:rolandDryWetKnobPlaceholder.bounds)
        rolandDryWetKnob.addTarget(self, action: #selector(SoundCustomisationViewController.rolandDryWetValueChanged), for: .valueChanged)
        rolandDryWetKnobPlaceholder.addSubview(rolandDryWetKnob)
        
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
        
        delayDryWetKnob = Knob(frame: delayDryWetKnobPlaceholder.bounds)
        delayDryWetKnob.addTarget(self, action: #selector(SoundCustomisationViewController.delayDryWetValueChanged), for: .valueChanged)
        delayDryWetKnobPlaceholder.addSubview(delayDryWetKnob)
        
        // Low pass filter knob
        lowPassHalfPowerKnob = Knob(frame: lowPassHalfPowerKnobPlaceholder.bounds)
        lowPassHalfPowerKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPassHalfPowerValueChanged), for: .valueChanged)
        lowPassHalfPowerKnobPlaceholder.addSubview(lowPassHalfPowerKnob)
        
        lowPassLfoRateKnob = Knob(frame: lowPassLfoRateKnobPlaceholder.bounds)
        lowPassLfoRateKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPassLfoRateValueChanged), for: .valueChanged)
        lowPassLfoRateKnobPlaceholder.addSubview(lowPassLfoRateKnob)
        
        lowPassLfoAmplitudeKnob = Knob(frame: lowPassLfoAmplitudeKnobPlaceholder.bounds)
        lowPassLfoAmplitudeKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPassLfoAmplitudeValueChanged), for: .valueChanged)
        lowPassLfoAmplitudeKnobPlaceholder.addSubview(lowPassLfoAmplitudeKnob)
        
        lowPassDryWetKnob = Knob(frame: lowPassDryWetKnobPlaceholder.bounds)
        lowPassDryWetKnob.addTarget(self, action: #selector(SoundCustomisationViewController.lowPassDryWetValueChanged), for: .valueChanged)
        lowPassDryWetKnobPlaceholder.addSubview(lowPassDryWetKnob)
        
        // High pass filter knobs
        highPassHalfPowerKnob = Knob(frame: highPassHalfPowerKnobPlaceholder.bounds)
        highPassHalfPowerKnob.addTarget(self, action: #selector(SoundCustomisationViewController.highPassHalfPowerValueChanged), for: .valueChanged)
        highPassHalfPowerKnobPlaceholder.addSubview(highPassHalfPowerKnob)
        
        highPassLfoRateKnob = Knob(frame: highPassLfoRateKnobPlaceholder.bounds)
        highPassLfoRateKnob.addTarget(self, action: #selector(SoundCustomisationViewController.highPassLfoRateValueChanged), for: .valueChanged)
        highPassLfoRateKnobPlaceholder.addSubview(highPassLfoRateKnob)
        
        highPassLfoAmplitudeKnob = Knob(frame: highPassLfoAmplitudeKnobPlaceholder.bounds)
        highPassLfoAmplitudeKnob.addTarget(self, action: #selector(SoundCustomisationViewController.highPassLfoAmplitudeValueChanged), for: .valueChanged)
        highPassLfoAmplitudeKnobPlaceholder.addSubview(highPassLfoAmplitudeKnob)
        
        highPassDryWetKnob = Knob(frame: highPassDryWetKnobPlaceholder.bounds)
        highPassDryWetKnob.addTarget(self, action: #selector(SoundCustomisationViewController.highPassDryWetValueChanged), for: .valueChanged)
        highPassDryWetKnobPlaceholder.addSubview(highPassDryWetKnob)
        
        // Reverb knobs
        reverbFeedbackKnob = Knob(frame: reverbFeedbackKnobPlaceholder.bounds)
        reverbFeedbackKnob.addTarget(self, action: #selector(SoundCustomisationViewController.reverbFeedbackValueChanged), for: .valueChanged)
        reverbFeedbackKnobPlaceholder.addSubview(reverbFeedbackKnob)
        
        reverbCuttoffKnob = Knob(frame: reverbCuttoffKnobPlaceholder.bounds)
        reverbCuttoffKnob.addTarget(self, action: #selector(SoundCustomisationViewController.reverbCuttoffValueChanged), for: .valueChanged)
        reverbCuttoffKnobPlaceholder.addSubview(reverbCuttoffKnob)
        
        reverbDryWetKnob = Knob(frame: reverbDryWetKnobPlaceholder.bounds)
        reverbDryWetKnob.addTarget(self, action: #selector(SoundCustomisationViewController.reverbDryWetValueChanged), for: .valueChanged)
        reverbDryWetKnobPlaceholder.addSubview(reverbDryWetKnob)
        
        // Keyboard
        keyboard = AKKeyboardView(width: 700, height: 128)
        keyboard?.sizeThatFits(CGSize(width: CGFloat(820.0), height: CGFloat(128.0)))
        keyboard?.keyOnColor = UIColor.blue
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        effectsKeyboardPlaceholder.addSubview(keyboard!)
        
        // Multiple Plotting nodes cause an error related to recording taps
        if (SoundCustomisationViewController.viewInitialised == false) {
            let plotFrame = CGRect(x: 100.0, y: 100.0, width: 820.0, height: 220.0)
            SoundCustomisationViewController.plot = AKNodeOutputPlot(audioHandler.master, frame: plotFrame)
            SoundCustomisationViewController.plot.color = UIColor.blue
            SoundCustomisationViewController.plot.layer.borderWidth = 0.8
            SoundCustomisationViewController.plot.layer.borderColor = UIColor.blue.cgColor
            
            SoundCustomisationViewController.viewInitialised = true
        }
        
        view.addSubview(SoundCustomisationViewController.plot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // Roland knob settings
        rolandCutoffKnob.minimumValue = 450
        rolandCutoffKnob.maximumValue = 550
        rolandCutoffKnob.value = Float(audioHandler.roland.cutoffFrequency)
        
        rolandResonanceKnob.value = Float(audioHandler.roland.resonance)
        
        rolandDistortionKnob.minimumValue = 1.9
        rolandDistortionKnob.maximumValue = 2.1
        rolandDistortionKnob.value = Float(audioHandler.roland.distortion)
        
        rolandResonanceAsymetryKnob.value = Float(audioHandler.roland.resonanceAsymmetry)
        
        rolandDryWetKnob.value = Float(audioHandler.rolandDryWetMixer.balance)
        
        // Delay Knob Settings
        delayTimeKnob.maximumValue = 1.5
        delayTimeKnob.value = Float(audioHandler.delay.time)
        
        delayFeedbackKnob.value = Float(audioHandler.delay.feedback)
        
        delayLfoRateKnob.maximumValue = 100.0
        delayLfoRateKnob.value = Float(audioHandler.delay.lfoRate)
        
        delayLfoAmplitudeKnob.value = Float(audioHandler.delay.lfoAmplitude)
        
        delayDryWetKnob.value = Float(audioHandler.delayDryWetMixer.balance)
        
        // Low pass filter knob settings
        lowPassHalfPowerKnob.maximumValue = 900.0
        lowPassHalfPowerKnob.value = Float(audioHandler.lowPassFilter.halfPowerFrequency)
        
        lowPassLfoRateKnob.maximumValue = 100.0
        lowPassLfoRateKnob.value = Float(audioHandler.lowPassFilter.lfoRate)
        
        lowPassLfoAmplitudeKnob.maximumValue = 500.0
        lowPassLfoAmplitudeKnob.value = Float(audioHandler.lowPassFilter.lfoAmplitude)
        
        lowPassDryWetKnob.value = Float(audioHandler.lpDryWetMixer.balance)
        
        // Make triggers reflect audio status
        if (audioHandler.bitCrusher.isStarted) {
            bitCrusherTrigger.setOn(true, animated: false)
        }
        
        if (audioHandler.roland.isStarted) {
            rolandOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            rolandOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        if (audioHandler.delay.output.isStarted) {
            delayOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            delayOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        if (audioHandler.lowPassFilter.output.isStarted) {
            lowPassOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
        } else {
            lowPassOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
        }
        
        // Effects on
        audioHandler.effects.volume = 1.0
    }
    
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
    
    @IBAction func rolandTriggerValueChanged(_ sender: UIButton) {
        if (audioHandler.roland.isStarted) {
            // Turn off
            rolandOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
            audioHandler.roland.stop()
        } else {
            // Turn on
            rolandOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
            audioHandler.roland.start()
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
    
    @IBAction func lowPassTriggerValueChange(_ sender: UIButton) {
        if (audioHandler.lowPassFilter.output.isStarted) {
            // Turn off
            lowPassOnOffButton.setImage(UIImage(named: "off.png"), for: .normal)
            audioHandler.lowPassFilter.output.stop()
        } else {
            // Turn on
            lowPassOnOffButton.setImage(UIImage(named: "on.png"), for: .normal)
            audioHandler.lowPassFilter.output.start()
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
    
    func rolandCutoffValueChanged() {
        audioHandler.roland.cutoffFrequency = Double(rolandCutoffKnob.value)
    }
    
    func rolandResonanceValueChanged() {
        audioHandler.roland.resonance = Double(rolandResonanceKnob.value)
    }
    
    func rolandDistortionValueChanged() {
        audioHandler.roland.distortion = Double(rolandDistortionKnob.value)
    }
    
    func rolandResonanceAsymetryValueChanged() {
        audioHandler.roland.resonanceAsymmetry = Double(rolandResonanceAsymetryKnob.value)
    }
    
    func rolandDryWetValueChanged() {
        audioHandler.rolandDryWetMixer.balance = Double(rolandDryWetKnob.value)
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
    
    func delayDryWetValueChanged() {
        audioHandler.delayDryWetMixer.balance = Double(delayDryWetKnob.value)
    }
    
    func lowPassHalfPowerValueChanged() {
        audioHandler.lowPassFilter.halfPowerFrequency = Double(lowPassHalfPowerKnob.value)
    }
    
    func lowPassLfoRateValueChanged() {
        audioHandler.lowPassFilter.lfoRate = Double(lowPassLfoRateKnob.value)
    }
    
    func lowPassLfoAmplitudeValueChanged() {
        audioHandler.lowPassFilter.lfoAmplitude = Double(lowPassLfoAmplitudeKnob.value)
    }
    
    func lowPassDryWetValueChanged() {
        audioHandler.lpDryWetMixer.balance = Double(lowPassDryWetKnob.value)
    }
    
    func highPassHalfPowerValueChanged() {
        
    }
    
    func highPassLfoRateValueChanged() {
        
    }
    
    func highPassLfoAmplitudeValueChanged() {
        
    }
    
    func highPassDryWetValueChanged() {
        
    }
    
    func reverbFeedbackValueChanged() {
        
    }
    
    func reverbCuttoffValueChanged() {
        
    }
    
    func reverbDryWetValueChanged() {
        
    }
    
    func noteOn(note: MIDINoteNumber) {
        audioHandler.generator.play(noteNumber: note, velocity: 80)
    }
    
    func noteOff(note: MIDINoteNumber) {
        audioHandler.generator.stop(noteNumber: note)
    }
}
