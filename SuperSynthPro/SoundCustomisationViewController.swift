import UIKit
import SQLite
import AudioKit

class SoundCustomisationViewController: UIViewController {
    let db = DatabaseConnector()
    var generatorModel = Generator()
    var generator: GeneratorProtocol! = nil
    var plot: AKNodeOutputPlot! = nil
    
    // effects
    var adsr: ADSREnvelope! = nil

    @IBOutlet var startStopSwitch: UISwitch!
    
    @IBOutlet var attackKnobPlaceholder: UIView!
    @IBOutlet var decayKnobPlaceholder: UIView!
    @IBOutlet var sustainKnobPlaceholder: UIView!
    @IBOutlet var releaseKnobPlaceholder: UIView!
    
    @IBOutlet weak var attackLabel: UILabel!
    @IBOutlet weak var decayLabel: UILabel!
    @IBOutlet weak var sustainLabel: UILabel!
    @IBOutlet weak var releaseLabel: UILabel!
    
    var attackKnob: Knob!
    var decayKnob: Knob!
    var sustainKnob: Knob!
    var releaseKnob: Knob!
    
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
        
        let initialGenerator = GeneratorStructure(
            name: "config",
            type: "AKOscillator",
            frequency: 330.0,
            waveTypes: [0, 0, 0],
            waveAmplitudes: [0.4, 0.1, 0.2]
        )
        
        // generator = GeneratorFactory.createGenerator(generator: generatorModel.loadLastUpdated())
        
        generator = GeneratorFactory.createGenerator(generator: initialGenerator)
    
        AudioKit.stop()
        
        generator.startWaveNode()
        
        adsr = ADSREnvelope(node: generator.waveNode)
        
        attackKnob.value = Float(adsr.envelope.attackDuration)
        decayKnob.value = Float(adsr.envelope.decayDuration)
        sustainKnob.value = Float(adsr.envelope.sustainLevel)
        releaseKnob.value = Float(adsr.envelope.releaseDuration)
        
        AudioKit.output = adsr.envelope
        
        plot.node = adsr.envelope
        
        AudioKit.start()
        
        adsr.envelope.stop()
    }
    
    @IBAction func startStopSwitchValueChanged(_ sender: UISwitch) {
        if (startStopSwitch .isOn) {
            adsr.envelope.start()
            startStopSwitch.setOn(true, animated: true)
        } else {
            adsr.envelope.stop()
            startStopSwitch.setOn(false, animated: true)
        }
    }

    func attackValueChanged() {
        adsr.envelope.attackDuration = Double(attackKnob.value)
        attackLabel.text = String(Double(adsr.envelope.attackDuration))
    }
    
    func decayValueChanged() {
        adsr.envelope.decayDuration = Double(decayKnob.value)
        decayLabel.text = String(Double(adsr.envelope.decayDuration))
    }
    
    func sustainValueChanged() {
        adsr.envelope.sustainLevel = Double(sustainKnob.value)
        sustainLabel.text = String(Double(adsr.envelope.sustainLevel))
    }
    
    func releaseValueChanged() {
        adsr.envelope.releaseDuration = Double(releaseKnob.value)
        releaseLabel.text = String(Double(adsr.envelope.releaseDuration))
    }
    
}
