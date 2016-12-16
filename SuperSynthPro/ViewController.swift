import UIKit
import AudioKit

class ViewController: UIViewController {
    let db = DatabaseConnector()
    
    let generator: GeneratorBank = GeneratorBank()
    
    // Knob Placeholders
    @IBOutlet weak var mob1MorphKnobPlaceholder: UIView!
    @IBOutlet weak var mob1OffsetKnobPlaceholder: UIView!
    @IBOutlet weak var mob1VolumeKnobPlaceholder: UIView!
    
    @IBOutlet weak var mobBalancerKnobPlaceholder: UIView!
    
    @IBOutlet weak var mob2MorphKnobPlaceholder: UIView!
    @IBOutlet weak var mob2OffsetKnobPlaceholder: UIView!
    @IBOutlet weak var mob2DetuneKnobPlaceholder: UIView!
    @IBOutlet weak var mob2VolumeKnobPlaceholder: UIView!
    
    @IBOutlet weak var pulseWidthKnobPlaceholder: UIView!
    @IBOutlet weak var pulseWidthOffsetKnobPlaceholder: UIView!
    @IBOutlet weak var pulseWidthVolumeKnobPlaceholder: UIView!
    
    @IBOutlet weak var fmModulationKnobPlaceholder: UIView!
    @IBOutlet weak var fmVolumeKnobPlaceholder: UIView!
    
    @IBOutlet weak var attackKnobPlaceholder: UIView!
    @IBOutlet weak var decayKnobPlaceholder: UIView!
    @IBOutlet weak var sustainKnobPlaceholder: UIView!
    @IBOutlet weak var releaseKnobPlaceholder: UIView!
    
    @IBOutlet weak var globalBendKnobPlaceholder: UIView!
    @IBOutlet weak var masterVolumeKnobPlaceholder: UIView!
    
    @IBOutlet var waveTypeSegment: UISegmentedControl!
  
    @IBOutlet var startStopSwitch: UISwitch!
    
    var mob1MorphKnob: Knob!
    var mob1OffsetKnob: Knob!
    var mob1VolumeKnob: Knob!
    
    var mob2MorphKnob: Knob!
    var mob2OffsetKnob: Knob!
    var mob2DetuneKnob: Knob!
    var mob2VolumeKnob: Knob!
    
    var pulseWidthKnob: Knob!
    var pulseWidthOffsetKnob: Knob!
    var pulseWidthVolumeKnob: Knob!
    
    var fmModulationKnob: Knob!
    var fmVolumeKnob: Knob!
    
    var mobBalancerKnob: Knob!
    
    var attackKnob: Knob!
    var decayKnob: Knob!
    var sustainKnob: Knob!
    var releaseKnob: Knob!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MOB1
        mob1MorphKnob = Knob(frame: mob1MorphKnobPlaceholder.bounds)
        mob1MorphKnob.addTarget(self, action: #selector(ViewController.mob1MorphValueChanged), for: .valueChanged)
        mob1MorphKnobPlaceholder.addSubview(mob1MorphKnob)
        
        mob1OffsetKnob = Knob(frame: mob1OffsetKnobPlaceholder.bounds)
        mob1OffsetKnob.addTarget(self, action: #selector(ViewController.mob1OffsetValueChanged), for: .valueChanged)
        mob1OffsetKnobPlaceholder.addSubview(mob1OffsetKnob)

        mob1VolumeKnob = Knob(frame: mob1VolumeKnobPlaceholder.bounds)
        mob1VolumeKnob.addTarget(self, action: #selector(ViewController.mob1VolumeValueChanged), for: .valueChanged)
        mob1VolumeKnobPlaceholder.addSubview(mob1VolumeKnob)
        
        // MOB2
        mob2MorphKnob = Knob(frame: mob2MorphKnobPlaceholder.bounds)
        mob2MorphKnob.addTarget(self, action: #selector(ViewController.mob2MorphValueChanged), for: .valueChanged)
        mob2MorphKnobPlaceholder.addSubview(mob2MorphKnob)
        
        mob2OffsetKnob = Knob(frame: mob2OffsetKnobPlaceholder.bounds)
        mob2OffsetKnob.addTarget(self, action: #selector(ViewController.mob2OffsetValueChanged), for: .valueChanged)
        mob2OffsetKnobPlaceholder.addSubview(mob2OffsetKnob)
        
        mob2DetuneKnob = Knob(frame: mob2DetuneKnobPlaceholder.bounds)
        mob2DetuneKnob.addTarget(self, action: #selector(ViewController.mob2DetuneValueChanged), for: .valueChanged)
        mob2DetuneKnobPlaceholder.addSubview(mob2DetuneKnob)
        
        mob2VolumeKnob = Knob(frame: mob2VolumeKnobPlaceholder.bounds)
        mob2VolumeKnob.addTarget(self, action: #selector(ViewController.mob2VolumeValueChanged), for: .valueChanged)
        mob2VolumeKnobPlaceholder.addSubview(mob2VolumeKnob)
        
        // MOB Balancer
        mobBalancerKnob = Knob(frame: mobBalancerKnobPlaceholder.bounds)
        mobBalancerKnob.addTarget(self, action: #selector(ViewController.mobBalancerValueChanged), for: .valueChanged)
        mobBalancerKnobPlaceholder.addSubview(mobBalancerKnob)
        
        // PWOB
        pulseWidthKnob = Knob(frame: pulseWidthKnobPlaceholder.bounds)
        pulseWidthKnob.addTarget(self, action: #selector(ViewController.pulseWidthValueChanged), for: .valueChanged)
        pulseWidthKnobPlaceholder.addSubview(pulseWidthKnob)
        
        pulseWidthOffsetKnob = Knob(frame: pulseWidthOffsetKnobPlaceholder.bounds)
        pulseWidthOffsetKnob.addTarget(self, action: #selector(ViewController.pulseWidthOffsetValueChanged), for: .valueChanged)
        pulseWidthOffsetKnobPlaceholder.addSubview(pulseWidthOffsetKnob)
        
        pulseWidthVolumeKnob = Knob(frame: pulseWidthVolumeKnobPlaceholder.bounds)
        pulseWidthVolumeKnob.addTarget(self, action: #selector(ViewController.pulseWidthVolumeValueChanged), for: .valueChanged)
        pulseWidthVolumeKnobPlaceholder.addSubview(pulseWidthVolumeKnob)
        
        // FMOB
        fmModulationKnob = Knob(frame: fmModulationKnobPlaceholder.bounds)
        fmModulationKnob.addTarget(self, action: #selector(ViewController.fmModulationValueChanged), for: .valueChanged)
        fmModulationKnobPlaceholder.addSubview(fmModulationKnob)
        
        fmVolumeKnob = Knob(frame: fmVolumeKnobPlaceholder.bounds)
        fmVolumeKnob.addTarget(self, action: #selector(ViewController.fmVolumeValueChanged), for: .valueChanged)
        fmVolumeKnobPlaceholder.addSubview(fmVolumeKnob)
        
        // ADSR
        attackKnob = Knob(frame: attackKnobPlaceholder.bounds)
        attackKnob.addTarget(self, action: #selector(ViewController.attackValueChanged), for: .valueChanged)
        attackKnobPlaceholder.addSubview(attackKnob)
        
        decayKnob = Knob(frame: decayKnobPlaceholder.bounds)
        decayKnob.addTarget(self, action: #selector(ViewController.decayValueChanged), for: .valueChanged)
        decayKnobPlaceholder.addSubview(decayKnob)
        
        sustainKnob = Knob(frame: sustainKnobPlaceholder.bounds)
        sustainKnob.addTarget(self, action: #selector(ViewController.sustainValueChanged), for: .valueChanged)
        sustainKnobPlaceholder.addSubview(sustainKnob)
        
        releaseKnob = Knob(frame: releaseKnobPlaceholder.bounds)
        releaseKnob.addTarget(self, action: #selector(ViewController.releaseValueChanged), for: .valueChanged)
        releaseKnobPlaceholder.addSubview(releaseKnob)

        
        
        
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
        AudioKit.output = generator
        AudioKit.start()
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
    
    func attackValueChanged() {
        generator.attackDuration = Double(attackKnob.value)
    }
    
    func decayValueChanged() {
        generator.decayDuration = Double(decayKnob.value)
    }
    
    func sustainValueChanged() {
        generator.sustainLevel = Double(sustainKnob.value)
    }
    
    func releaseValueChanged() {
        generator.releaseDuration = Double(releaseKnob.value)
    }
    
    func mob1MorphValueChanged() {
        
    }
    
    func mob1OffsetValueChanged() {
        
    }
    
    func mob1VolumeValueChanged() {
        
    }
    
    func mobBalancerValueChanged() {
        
    }
    
    func mob2MorphValueChanged() {
        
    }
    
    func mob2OffsetValueChanged() {
        
    }
    
    func mob2DetuneValueChanged() {
        
    }
    
    func mob2VolumeValueChanged() {
        
    }
    
    func pulseWidthValueChanged() {
        
    }
    
    func pulseWidthOffsetValueChanged() {
        
    }
    
    func pulseWidthVolumeValueChanged() {
        
    }
    
    func fmModulationValueChanged() {
        
    }
    
    func fmVolumeValueChanged() {
        
    }
}

