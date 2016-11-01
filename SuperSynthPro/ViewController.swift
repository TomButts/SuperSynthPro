import UIKit
import AudioKit

class ViewController: UIViewController {
    var selectedHarmonic: Int = 0
    var rateChanger: AKVariSpeed! = nil
    
    let db = DatabaseConnector()
    var wave = Wave()
    var generatorModel = Generator()
    var currentGenerator: GeneratorStructure! = nil
    var generator: GeneratorProtocol! = nil
    
    @IBOutlet var totalHarmonicsLabel: UILabel!
    @IBOutlet var selectedHarmonicLabel: UILabel!
    @IBOutlet var waveTypeSegment: UISegmentedControl!
    @IBOutlet var selectedHarmonicStepper: UIStepper!
    @IBOutlet var amplitudeSlider: UISlider!
    
    @IBOutlet var startStopSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentGenerator = GeneratorStructure(
            name: "config",
            type: "AKOscillator",
            frequency: 330.0,
            waveTypes: [0, 0, 0],
            waveAmplitudes: [0.4, 0.2, 0.1]
        )
        
        generator = GeneratorFactory.createGenerator(generator: currentGenerator)
        
        selectedHarmonicStepper.maximumValue = Double(generator.harmonics)
        selectedHarmonicStepper.minimumValue = 1.0
        
        totalHarmonicsLabel.text = String(format: "%d", generator.harmonics)
        selectedHarmonicLabel.text = String(format: "%d", selectedHarmonic + 1)
        
        rateChanger = AKVariSpeed(generator.waveNode)
        rateChanger.rate = 1.0
        
        AudioKit.output = rateChanger
        AudioKit.start()
        
        // Add waveform plot
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
            AudioKit.start()
            generator.startWaveNode()
            self.startStopSwitch.setOn(false, animated: true)
        } else {
            generator.stopWaveNode()
            AudioKit.stop()
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
        if (Int(sender.value) > generator.waveCollection.count) {
            generator.addHarmonic(waveType: wave.sine)
            
            selectedHarmonicStepper.maximumValue = Double(sender.value)
        } else {
            generator.deleteHarmonic(harmonic: Int(sender.value))
        }
        
        totalHarmonicsLabel.text = String(format: "%d", Int(sender.value))
    }
    
    @IBAction func selectedWaveStepper(_ sender: UIStepper) {
        selectedHarmonicLabel.text = String(format: "%d", Int(sender.value))

        waveTypeSegment.selectedSegmentIndex = generator.getWaveType(harmonic: Int(sender.value) - 1)
        
        selectedHarmonic = Int(sender.value) - 1
        
        amplitudeSlider.setValue(Float(generator.waveCollection[selectedHarmonic]!.oscillator.amplitude), animated: true)
    }
    
    @IBAction func selectedWaveTypeSegment(_ sender: UISegmentedControl) {
        generator.setWaveType(harmonic: selectedHarmonic, waveType: waveTypeSegment.selectedSegmentIndex)
    }
    
    @IBAction func saveGenerator(_ sender: AnyObject) {
        // TODO different names
        let generatorStruct = GeneratorStructure(
            name: "default",
            type: String(describing: generator.self),
            frequency: generator.fundamentalFrequency,
            waveTypes: generator.getAllWaveTypes(),
            waveAmplitudes: generator.getAllAmplitudes()
        )
        
        generatorModel.save(generator: generatorStruct)
        
        print("Save Generator")
    }
    
    @IBAction func loadGenerator(_ sender: AnyObject) {
        currentGenerator = generatorModel.load(id: 4)
        
        generator = GeneratorFactory.createGenerator(generator: currentGenerator)
        
        selectedHarmonic = 0
        selectedHarmonicStepper.value = 0.0
        selectedHarmonicStepper.maximumValue = Double(generator.harmonics)
        
        totalHarmonicsLabel.text = String(format: "%d", generator.harmonics)
        selectedHarmonicLabel.text = String(format: "%d", selectedHarmonic + 1)
        
        print("Load Generator")
    }
}

