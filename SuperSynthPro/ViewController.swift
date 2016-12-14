import UIKit
import AudioKit

class ViewController: UIViewController {
    var selectedHarmonic: Int = 1
    var rateChanger: AKVariSpeed! = nil
    
    let db = DatabaseConnector()
    var wave = Wave()
    var generatorModel = Generator()
    var generator: GeneratorProtocol! = nil
    
    @IBOutlet var totalHarmonicsLabel: UILabel!
    @IBOutlet var selectedHarmonicLabel: UILabel!
    @IBOutlet var waveTypeSegment: UISegmentedControl!
    @IBOutlet var selectedHarmonicStepper: UIStepper!
    @IBOutlet var amplitudeSlider: UISlider!
    @IBOutlet var totalHarmonicStepper: UIStepper!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var startStopSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let initialGenerator = GeneratorStructure(
            name: "config",
            type: "AKOscillator",
            frequency: 330.0,
            waveTypes: [0, 0, 0],
            waveAmplitudes: [0.4, 0.2, 0.1]
        )
        
        generator = GeneratorFactory.createGenerator(generator: initialGenerator)
        
        selectedHarmonicStepper.maximumValue = Double(generator.harmonics)
        selectedHarmonicStepper.minimumValue = 1.0
        
        totalHarmonicStepper.minimumValue = 1.0
        totalHarmonicStepper.maximumValue = 9.0
        
        totalHarmonicsLabel.text = String(format: "%d", generator.harmonics)
        selectedHarmonicLabel.text = String(format: "%d", selectedHarmonic)
        
        amplitudeSlider.setValue(
            Float(generator.waveCollection[selectedHarmonic - 1]!.oscillator.amplitude),
            animated: true
        )
        
        rateChanger = AKVariSpeed(generator.waveNode)
        rateChanger.rate = 1.0
        
        AudioKit.output = rateChanger
        AudioKit.start()
        
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
        
        AudioKit.stop()
        AudioKit.output = rateChanger
        AudioKit.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeAmplitude(_ sender: UISlider) {
        if (selectedHarmonic <= generator.harmonics) {
            generator.changeAmplitude(harmonic: selectedHarmonic - 1, amplitude: Double(sender.value))
        }
    }
    
    @IBAction func startStopGenerator(_ sender: AnyObject) {
        if (startStopSwitch .isOn) {
            generator.startWaveNode()
            startStopSwitch.setOn(true, animated: true)
        } else {
            generator.stopWaveNode()
            startStopSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func changeFrequency(_ sender: UISlider) {
        generator.fundamentalFrequency = Double(sender.value)
        generator.updateFrequency()
    }
    
    @IBAction func changeRate(_ sender: UISlider) {
        rateChanger.rate = Double(sender.value)
    }
    
    @IBAction func addSubtractHarmonics(_ sender: UIStepper) {
        if (Int(sender.value) > generator.waveCollection.count) {
            generator.addHarmonic(waveType: wave.sine)
        } else {
            generator.deleteHarmonic(harmonic: Int(sender.value))
            
            // reset to 1
            selectedHarmonic = 1
            selectedHarmonicLabel.text = String(format: "%d", 1)
            selectedHarmonicStepper.value = 1.0
        }
        
        // the maximum you can select is the value of the total harmonics stepper
        selectedHarmonicStepper.maximumValue = Double(sender.value)
        
        totalHarmonicsLabel.text = String(format: "%d", Int(sender.value))
        
        printConfig(function: "add subtract harmonic stepper")
        printWaveCollection()
    }
    
    @IBAction func selectedWaveStepper(_ sender: UIStepper) {
        selectedHarmonicLabel.text = String(format: "%d", Int(sender.value))

        waveTypeSegment.selectedSegmentIndex = generator.getWaveType(harmonic: Int(sender.value) - 1)
        
        selectedHarmonic = Int(sender.value)
        
        amplitudeSlider.setValue(
            Float(generator.waveCollection[selectedHarmonic - 1]!.oscillator.amplitude),
            animated: true
        )
        
        printConfig(function: "selectedWaveStepper")
        printWaveCollection()
    }
    
    @IBAction func selectedWaveTypeSegment(_ sender: UISegmentedControl) {
        generator.setWaveType(harmonic: selectedHarmonic - 1, waveType: waveTypeSegment.selectedSegmentIndex)
    
        if (startStopSwitch .isOn) {
            generator.startWaveNode()
            startStopSwitch.setOn(true, animated: true)
        }
    }
    
    @IBAction func saveGenerator(_ sender: AnyObject) {
        if (nameTextField.text == "" || (nameTextField.text?.characters.count)! < 3) {
            let alert = UIAlertController(
                title: "Woa there friend..",
                message: "Please enter a name at least 3 characters long",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            let generatorStruct = GeneratorStructure(
                name: nameTextField.text!,
                type: generator.type,
                frequency: generator.fundamentalFrequency,
                waveTypes: generator.getAllWaveTypes(),
                waveAmplitudes: generator.getAllAmplitudes()
            )
            
            generatorModel.save(generator: generatorStruct)
            
            print("Save Generator")
        }
    }
    
    @IBAction func loadGenerator(_ sender: AnyObject) {
        AudioKit.stop()
        
        generator = GeneratorFactory.createGenerator(generator: generatorModel.load(id: 1))
        
        rateChanger = AKVariSpeed(generator.waveNode)
        rateChanger.rate = 1.0
        
        AudioKit.output = rateChanger
        AudioKit.start()
        
        selectedHarmonic = 0
        selectedHarmonicStepper.value = 0.0
        selectedHarmonicStepper.maximumValue = Double(generator.harmonics)
        
        totalHarmonicsLabel.text = String(format: "%d", generator.harmonics)
        selectedHarmonicLabel.text = String(format: "%d", selectedHarmonic + 1)
        
        generator.stopWaveNode()
        startStopSwitch.setOn(false, animated: true)
        
        print("Load Generator")
    }
    
    func printConfig(function: String) {
        print(function)
        
        print("Select Label Value:")
        print(selectedHarmonicLabel.text)
        
        print("Selected harmonic variable:")
        print(selectedHarmonic)
        
        print("\ntotal harmonics in generator object:")
        print(generator.harmonics)
        
        print("harmonic number label:")
        print(totalHarmonicsLabel.text)
        
        print("harmonic stepper value:")
        print(totalHarmonicStepper.value)
    }
    
    func printWaveCollection() {
        for (key, value) in generator.waveCollection {
            print("key:")
            print(key)
            
            print("Value amplitude")
            print(value.amplitude)
            
            print("Value wave type:")
            print(value.waveType)
        }
    }
}

