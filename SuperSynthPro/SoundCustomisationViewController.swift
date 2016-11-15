import UIKit
import SQLite
import AudioKit

class SoundCustomisationViewController: UIViewController {
    let db = DatabaseConnector()
    var generatorModel = Generator()
    var generator: GeneratorProtocol! = nil

    @IBOutlet var startStopSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // generator = GeneratorFactory.createGenerator(generator: generatorModel.loadLastUpdated())
        
            let initialGenerator = GeneratorStructure(
                name: "config",
                type: "AKOscillator",
                frequency: 330.0,
                waveTypes: [0, 0, 0],
                waveAmplitudes: [0.4, 0.2, 0.1]
            )
        
            generator = GeneratorFactory.createGenerator(generator: initialGenerator)
        
            AudioKit.stop()
            AudioKit.output = generator.waveNode
            AudioKit.start()
        
            let plotFrame = CGRect(x: 100.0, y: 100.0, width: 820.0, height: 220.0)
            let plot = AKNodeOutputPlot(generator.waveNode, frame: plotFrame)
            plot.color = UIColor.blue
            plot.layer.borderWidth = 0.8
            plot.layer.borderColor = UIColor.blue.cgColor
            view.addSubview(plot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        AudioKit.stop()
        AudioKit.output = generator.waveNode
        AudioKit.start()
    }
    
    @IBAction func startStopSwitchValueChanged(_ sender: UISwitch) {
        if (startStopSwitch .isOn) {
            generator.startWaveNode()
            startStopSwitch.setOn(true, animated: true)
        } else {
            generator.stopWaveNode()
            startStopSwitch.setOn(false, animated: true)
        }
    }
}
