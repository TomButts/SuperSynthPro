import UIKit
import AudioKit

class ViewController: UIViewController {
    let db = DatabaseConnector()
    var wave = Wave()
    
 
    @IBOutlet var waveTypeSegment: UISegmentedControl!
  
    @IBOutlet var startStopSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Add waveform plot
        let rect = CGRect(x: 100.0, y: 100.0, width: 820.0, height: 220.0)
        let plot = AKRollingOutputPlot(frame: rect)
        plot.color = UIColor.blue
        plot.layer.borderWidth = 0.8
        plot.layer.borderColor = UIColor.blue.cgColor
        view.addSubview(plot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func startStopGenerator(_ sender: AnyObject) {
        if (startStopSwitch .isOn) {
          
            startStopSwitch.setOn(true, animated: true)
        } else {
            
            startStopSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func selectedWaveTypeSegment(_ sender: UISegmentedControl) {
       
    }
    
    @IBAction func saveGenerator(_ sender: AnyObject) {
        
    }
    
    @IBAction func loadGenerator(_ sender: AnyObject) {
        
    }
}

