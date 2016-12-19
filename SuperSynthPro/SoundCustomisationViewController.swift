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
    
    var rolandCutoffKnob: Knob!
    var rolandResonanceKnob: Knob!
    var rolandDistortionKnob: Knob!
    var rolandResonanceAsymetryKnob: Knob!
    var rolandDryWetKnob: Knob!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Compressor
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
        
        rolandCutoffKnob.minimumValue = 450
        rolandCutoffKnob.maximumValue = 550
        rolandCutoffKnob.value = Float(audioHandler.roland.cutoffFrequency)
        
        rolandResonanceKnob.value = Float(audioHandler.roland.resonance)
        
        rolandDistortionKnob.minimumValue = 1.9
        rolandDistortionKnob.maximumValue = 2.1
        rolandDistortionKnob.value = Float(audioHandler.roland.distortion)
        
        rolandResonanceAsymetryKnob.value = Float(audioHandler.roland.resonanceAsymmetry)
        
        rolandDryWetKnob.value = Float(audioHandler.rolandDryWetMixer.balance)
        
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
    
    func noteOn(note: MIDINoteNumber) {
        audioHandler.generator.play(noteNumber: note, velocity: 80)
    }
    
    func noteOff(note: MIDINoteNumber) {
        audioHandler.generator.stop(noteNumber: note)
    }
}
