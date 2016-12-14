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
    
    enum ControlTag: Int {
        case attackKnob = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        AudioKit.output = adsr.envelope
        
        plot.node = adsr.envelope
        
        AudioKit.start()
        
        adsr.envelope.stop()
        
    }
    
    func setupUI() {
        // draw envelope element
        
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
}
