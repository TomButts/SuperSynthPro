import UIKit
import AudioKit

class ViewController: UIViewController {
    var selectedHarmonic: Int = 0
    var generator: OscillatorCollection! = nil
    var rateChanger: AKVariSpeed! = nil
    
    var wave = Wave()
    let db = DatabaseConnector()
    var generatorModel = Generator()
    
    @IBOutlet var totalHarmonicsLabel: UILabel!
    @IBOutlet var selectedHarmonicLabel: UILabel!
    @IBOutlet var waveTypeSegment: UISegmentedControl!
    @IBOutlet var selectedHarmonicStepper: UIStepper!
    @IBOutlet var amplitudeSlider: UISlider!
    
    // TODO
    // load default config straight out of db in future
    var waveTypes: Array<Int> = []
    
    @IBOutlet var startStopSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        waveTypes = [wave.sine, wave.sine]
        
        generator = OscillatorCollection(frequency: 330.0, waveType: waveTypes)
        
        selectedHarmonicStepper.maximumValue = Double(generator.harmonics)
        selectedHarmonicStepper.minimumValue = 1.0
        
        totalHarmonicsLabel.text = String(format: "%d", generator.harmonics)
        
        selectedHarmonicLabel.text = String(format: "%d", selectedHarmonic + 1)
        
        rateChanger = AKVariSpeed(generator.waveNode)
        
        rateChanger.rate = 1.0
        
        AudioKit.output = rateChanger
        AudioKit.start()
        
        // waveform plot
        let rect = CGRect(x: 70.0, y: 90.0, width: 820.0, height: 100.0)
        
        let plot = AKRollingOutputPlot(frame: rect)
        
        plot.color = UIColor.blue
        plot.layer.borderWidth = 0.8
        plot.layer.borderColor = UIColor.blue.cgColor
        
        view.addSubview(plot)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeAmplitude(_ sender: UISlider) {
        if (selectedHarmonic <= generator.harmonics) {
            self.generator.changeAmplitude(harmonic: selectedHarmonic, amplitude: Double(sender.value))
        }
    }
    
    @IBAction func startStopGenerator(_ sender: AnyObject) {
        if (self.startStopSwitch .isOn) {
            generator.startWaveNode()
            self.startStopSwitch.setOn(false, animated: true)
        } else {
            generator.stopWaveNode()
            self.startStopSwitch.setOn(true, animated: true)
        }
    }
    
    @IBAction func changeFrequency(_ sender: UISlider) {
        self.generator.fundamentalFrequency = Double(sender.value)
        self.generator.updateFrequency()
    }
    
    @IBAction func changeRate(_ sender: UISlider) {
        rateChanger.rate = Double(sender.value)
    }
    
    @IBAction func addSubtractHarmonics(_ sender: UIStepper) {
        if (Int(sender.value) > waveTypes.count) {
            generator.addHarmonic(waveType: wave.sine)
            
            selectedHarmonicStepper.maximumValue = Double(sender.value)
        } else {
            generator.deleteHarmonic(harmonic: Int(sender.value))
        }
        
        totalHarmonicsLabel.text = String(format: "%d", Int(sender.value))
    }
    
    @IBAction func selectedWaveStepper(_ sender: UIStepper) {
        selectedHarmonicLabel.text = String(format: "%d", Int(sender.value))

        // show the selected harmonics wave type of the segment controller
        waveTypeSegment.selectedSegmentIndex = generator.getWaveType(harmonic: Int(sender.value) - 1)
        
        selectedHarmonic = Int(sender.value) - 1
        
        amplitudeSlider.setValue(Float(generator.waveCollection[selectedHarmonic]!.oscillator.amplitude), animated: true)
    }
    
    @IBAction func selectedWaveTypeSegment(_ sender: UISegmentedControl) {
        generator.setWaveType(harmonic: selectedHarmonic, waveType: waveTypeSegment.selectedSegmentIndex)
    }
    
    @IBAction func saveGenerator(_ sender: AnyObject) {
        let generatorStruct = GeneratorStructure(
            name: "default",
            type: String(describing: generator.self),
            frequency: generator.fundamentalFrequency,
            waveTypes: generator.getAllWaveTypes(),
            waveAmplitudes: generator.getAllAmplitudes()
        )
        
        generatorModel.save(generator: generatorStruct)
        
        print("Saved Generator")
    }
}

