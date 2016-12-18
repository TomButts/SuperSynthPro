import UIKit
import SQLite
import AudioKit

class SoundCustomisationViewController: UIViewController {
    let db = DatabaseConnector()
    
    var plot: AKNodeOutputPlot! = nil
    
    var audioHandler = AudioHandler.sharedInstance
    
    @IBOutlet var startStopSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let plotFrame = CGRect(x: 100.0, y: 100.0, width: 820.0, height: 220.0)
        // TODO change
        plot = AKNodeOutputPlot(audioHandler.generator, frame: plotFrame)
        plot.color = UIColor.blue
        plot.layer.borderWidth = 0.8
        plot.layer.borderColor = UIColor.blue.cgColor
        view.addSubview(plot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        AudioKit.stop()
//        
//        // audioHandler.compressor.dryWetMix = 0.5
//        
        AudioKit.output = audioHandler.generator
//       
        AudioKit.start()
        
        //audioHandler.compressor.start()
        
        
//        audioHandler.delay.output.start()
//        audioHandler.lowPassFilter.output.start()
//        audioHandler.highPassFilter.output.start()
//        audioHandler.reverb.start()
//        audioHandler.autoWah.output.start()
        
        // audioHandler.master.volume = 1
        
        // plot.node = audioHandler.generator
        
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
}
