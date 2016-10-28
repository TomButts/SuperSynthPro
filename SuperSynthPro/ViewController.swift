import UIKit
import AudioKit

class ViewController: UIViewController {
    var waveHarmonic: Int = 0
    var generator: OscillatorCollection! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let waveTypes = [AKTable(.sine), AKTable(.square)]
        waveHarmonic = waveTypes.count
        
        generator = OscillatorCollection(fundamentalFrequency: 330.0, waveType: waveTypes)
        
        AudioKit.output = generator.waveNode
        
        AudioKit.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeAmplitude(_ sender: UISlider) {
        let currentVal = Double(sender.value)
        self.generator.changeAmplitude(harmonic: waveHarmonic, value: currentVal)
    }
}

