import UIKit
import SQLite
import AudioKit

class SoundCustomisationViewController: UIViewController {
    let db = DatabaseConnector()
    
    static var plot: AKNodeOutputPlot! = nil
    
    static var viewInitialised = false
    
    var audioHandler = AudioHandler.sharedInstance
    
    @IBOutlet var startStopSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        audioHandler.effects.volume = 1.0
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
