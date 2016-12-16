import UIKit
import SQLite
import AudioKit

class SoundCustomisationViewController: UIViewController {
    let db = DatabaseConnector()
    
    var plot: AKNodeOutputPlot! = nil
    
    // Nodes
    var adsr: ADSREnvelope! = nil
    var delay: VariableDelay! = nil
    var delayDryWet: DryWetMixer! = nil
    var reverb: Reverb! = nil
    var autoWah: AutoWah! = nil
    
    @IBOutlet var startStopSwitch: UISwitch!
    
    // UIViews for knob controls
    @IBOutlet var attackKnobPlaceholder: UIView!
    @IBOutlet var decayKnobPlaceholder: UIView!
    @IBOutlet var sustainKnobPlaceholder: UIView!
    @IBOutlet var releaseKnobPlaceholder: UIView!
    @IBOutlet var delayKnobPlaceholder: UIView!
    @IBOutlet var reverbKnobPlaceholder: UIView!
    @IBOutlet var wahRateKnobPlaceholder: UIView!
    @IBOutlet var wahAmpKnobPlaceholder: UIView!
 
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var decayLabel: UILabel!
    @IBOutlet weak var sustainLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    
    // Knob controls
    var attackKnob: Knob!
    var decayKnob: Knob!
    var sustainKnob: Knob!
    var releaseKnob: Knob!
    var delayKnob: Knob!
    var reverbKnob: Knob!
    var wahRateKnob: Knob!
    var wahAmpKnob: Knob!
    
    var generator: AKOscillator! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ADSR
        attackKnob = Knob(frame: attackKnobPlaceholder.bounds)
        attackKnob.addTarget(self, action: #selector(SoundCustomisationViewController.attackValueChanged), for: .valueChanged)
        attackKnobPlaceholder.addSubview(attackKnob)
        
        decayKnob = Knob(frame: decayKnobPlaceholder.bounds)
        decayKnob.addTarget(self, action: #selector(SoundCustomisationViewController.decayValueChanged), for: .valueChanged)
        decayKnobPlaceholder.addSubview(decayKnob)
    
        sustainKnob = Knob(frame: sustainKnobPlaceholder.bounds)
        sustainKnob.addTarget(self, action: #selector(SoundCustomisationViewController.sustainValueChanged), for: .valueChanged)
        sustainKnobPlaceholder.addSubview(sustainKnob)
        
        releaseKnob = Knob(frame: releaseKnobPlaceholder.bounds)
        releaseKnob.addTarget(self, action: #selector(SoundCustomisationViewController.releaseValueChanged), for: .valueChanged)
        releaseKnobPlaceholder.addSubview(releaseKnob)
        
        // Delay
        delayKnob = Knob(frame: delayKnobPlaceholder.bounds)
        delayKnob.addTarget(self, action: #selector(SoundCustomisationViewController.delayValueChanged), for: .valueChanged)
        delayKnobPlaceholder.addSubview(delayKnob)
        
        // Reverb
        reverbKnob = Knob(frame: reverbKnobPlaceholder.bounds)
        reverbKnob.addTarget(self, action: #selector(SoundCustomisationViewController.reverbValueChanged), for: .valueChanged)
        reverbKnobPlaceholder.addSubview(reverbKnob)
        
        // Wah
        wahRateKnob = Knob(frame: wahRateKnobPlaceholder.bounds)
        wahRateKnob.addTarget(self, action: #selector(SoundCustomisationViewController.wahRateValueChanged), for: .valueChanged)
        wahRateKnobPlaceholder.addSubview(wahRateKnob)

        wahAmpKnob = Knob(frame: wahAmpKnobPlaceholder.bounds)
        wahAmpKnob.addTarget(self, action: #selector(SoundCustomisationViewController.wahAmpValueChanged), for: .valueChanged)
        wahAmpKnobPlaceholder.addSubview(wahAmpKnob)
        
        view.tintColor = UIColor.blue
        
        let placeholder = AKOscillator(waveform: AKTable(.sine))
        let plotFrame = CGRect(x: 100.0, y: 100.0, width: 820.0, height: 220.0)
        plot = AKNodeOutputPlot(placeholder, frame: plotFrame)
        plot.color = UIColor.blue
        plot.layer.borderWidth = 0.8
        plot.layer.borderColor = UIColor.blue.cgColor
        view.addSubview(plot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        AudioKit.stop()
        
        generator = AKOscillator(waveform: AKTable(.sine))
        generator.frequency = 63.2
        generator.amplitude = 0.4
        generator.start()
        
        adsr = ADSREnvelope(
            generator,
            attackDuration: 0.1,
            decayDuration: 0.1,
            sustainLevel: 0,
            releaseDuration: 0.1
        )
        
        delay = VariableDelay(
            adsr,
            time: 0.5,
            feedback: 0.8,
            maximumDelayTime: 1.2
        )
        
        delayDryWet = DryWetMixer(
            adsr,
            delay,
            balance: 0.5
        )
        
        reverb = Reverb(delayDryWet)
        
        autoWah = AutoWah(reverb)
        
        // Set knob limits
        wahRateKnob.maximumValue = 4
        wahAmpKnob.maximumValue = 11
        
        // Set knob starting values
        attackKnob.value = Float(adsr.attackDuration)
        decayKnob.value = Float(adsr.decayDuration)
        sustainKnob.value = Float(adsr.sustainLevel)
        releaseKnob.value = Float(adsr.releaseDuration)
        delayKnob.value = Float(delayDryWet.balance)
        reverbKnob.value = Float(reverb.dryWetMix)
        wahRateKnob.value = Float(autoWah.lfoRate)
        wahAmpKnob.value = Float(autoWah.lfoAmplitude)
        
        AudioKit.output = autoWah.output
        
        plot.node = autoWah.output
        
        AudioKit.start()
        
        delay.start()
        reverb.start()
        autoWah.output.start()
        adsr.start()
    }
    
    @IBAction func startStopSwitchValueChanged(_ sender: UISwitch) {
        if (startStopSwitch .isOn) {
            generator.start()
            startStopSwitch.setOn(true, animated: true)
        } else {
            generator.stop()
            startStopSwitch.setOn(false, animated: true)
        }
    }

    @IBAction func delayTimeValueChanged(_ sender: UISlider) {
        delay.time = Double(sender.value)
    }

    func attackValueChanged() {
        adsr.attackDuration = Double(attackKnob.value)
        attackLabel.text = String(Double(adsr.attackDuration))
    }
    
    func decayValueChanged() {
        adsr.decayDuration = Double(decayKnob.value)
        decayLabel.text = String(Double(adsr.decayDuration))
    }
    
    func sustainValueChanged() {
        adsr.sustainLevel = Double(sustainKnob.value)
        sustainLabel.text = String(Double(adsr.sustainLevel))
    }
    
    func releaseValueChanged() {
        adsr.releaseDuration = Double(releaseKnob.value)
        releaseLabel.text = String(Double(adsr.releaseDuration))
    }
    
    func delayValueChanged() {
        delayDryWet.balance = Double(delayKnob.value)
    }
    
    func reverbValueChanged() {
        reverb.dryWetMix = Double(reverbKnob.value)
    }
    
    func wahRateValueChanged() {
        autoWah.lfoRate = Double(wahRateKnob.value)
    }
    
    func wahAmpValueChanged() {
        autoWah.lfoAmplitude = Double(wahAmpKnob.value)
    }
}
