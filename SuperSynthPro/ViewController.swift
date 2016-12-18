import UIKit
import AudioKit

class ViewController: UIViewController, AKKeyboardDelegate {
    let db = DatabaseConnector()
    
    var audioHandler = AudioHandler.sharedInstance

    @IBOutlet var keyboardPlaceholder: UIView!
    
    var keyboard: AKKeyboardView?
    
    var plot: AKNodeOutputPlot! = nil
    
    // Knob Placeholders
    @IBOutlet var mob1WaveTypeKnobPlaceholder: UIView!
    @IBOutlet var mob1MorphKnobPlaceholder: UIView!
    @IBOutlet var mob1OffsetKnobPlaceholder: UIView!
    @IBOutlet var mob1VolumeKnobPlaceholder: UIView!
    
    @IBOutlet var mobBalancerKnobPlaceholder: UIView!
    
    @IBOutlet weak var mob2WaveTypeKnobPlaceholder: UIView!
    @IBOutlet var mob2MorphKnobPlaceholder: UIView!
    @IBOutlet var mob2OffsetKnobPlaceholder: UIView!
    @IBOutlet var mob2DetuneKnobPlaceholder: UIView!
    @IBOutlet var mob2VolumeKnobPlaceholder: UIView!
    
    @IBOutlet var pulseWidthKnobPlaceholder: UIView!
    @IBOutlet var pulseWidthOffsetKnobPlaceholder: UIView!
    @IBOutlet var pulseWidthVolumeKnobPlaceholder: UIView!
    
    @IBOutlet var fmModulationKnobPlaceholder: UIView!
    @IBOutlet var fmVolumeKnobPlaceholder: UIView!
    
    @IBOutlet var attackKnobPlaceholder: UIView!
    @IBOutlet var decayKnobPlaceholder: UIView!
    @IBOutlet var sustainKnobPlaceholder: UIView!
    @IBOutlet var releaseKnobPlaceholder: UIView!
    
    @IBOutlet var globalBendKnobPlaceholder: UIView!
    @IBOutlet var masterVolumeKnobPlaceholder: UIView!
    
    @IBOutlet var waveTypeSegment: UISegmentedControl!
  
    @IBOutlet var startStopSwitch: UISwitch!
    
    var mob1WaveTypeKnob: Knob!
    var mob1MorphKnob: Knob!
    var mob1OffsetKnob: Knob!
    var mob1VolumeKnob: Knob!
    
    var mob2WaveTypeKnob: Knob!
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
    
    var globalBendKnob: Knob!
    var masterVolumeKnob: Knob!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MOB1
        mob1WaveTypeKnob = Knob(frame: mob1WaveTypeKnobPlaceholder.bounds)
        mob1WaveTypeKnob.addTarget(self, action: #selector(ViewController.mob1WaveTypeValueChanged), for: .valueChanged)
        mob1WaveTypeKnobPlaceholder.addSubview(mob1WaveTypeKnob)

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
        mob2WaveTypeKnob = Knob(frame: mob2WaveTypeKnobPlaceholder.bounds)
        mob2WaveTypeKnob.addTarget(self, action: #selector(ViewController.mob2WaveTypeValueChanged), for: .valueChanged)
        mob2WaveTypeKnobPlaceholder.addSubview(mob2WaveTypeKnob)

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

        // Bend
        globalBendKnob = Knob(frame: globalBendKnobPlaceholder.bounds)
        globalBendKnob.addTarget(self, action: #selector(ViewController.globalBendValueChanged), for: .valueChanged)
        globalBendKnobPlaceholder.addSubview(globalBendKnob)
        
        // Master Volume
        masterVolumeKnob = Knob(frame: masterVolumeKnobPlaceholder.bounds)
        masterVolumeKnob.addTarget(self, action: #selector(ViewController.masterVolumeValueChanged), for: .valueChanged)
        masterVolumeKnobPlaceholder.addSubview(masterVolumeKnob)
        
        //TODO: make ADSR view
        
        // Keyboard
        keyboard = AKKeyboardView(width: 820, height: 128)
        keyboard?.sizeThatFits(CGSize(width: CGFloat(820.0), height: CGFloat(128.0)))
        keyboard?.keyOnColor = UIColor.blue
        keyboard!.polyphonicMode = false
        keyboard!.delegate = self
        keyboardPlaceholder.addSubview(keyboard!)
        
        // Add waveform plot
        let rect = CGRect(x: 100.0, y: 100.0, width: 823.0, height: 220.0)
        plot = AKNodeOutputPlot(audioHandler.generator, frame: rect)
        plot.color = UIColor.blue
        plot.layer.borderWidth = 0.8
        plot.layer.borderColor = UIColor.blue.cgColor
        view.addSubview(plot)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // Knob values
        setDefaultGeneratorValues()
        
        mob1WaveTypeKnob.maximumValue = 4
        mob1WaveTypeKnob.value = Float(audioHandler.generator.waveform1)
        
        mob1MorphKnob.minimumValue = -4
        mob1MorphKnob.maximumValue = 4
        mob1MorphKnob.value = Float(audioHandler.generator.morph1)
        
        mob1OffsetKnob.minimumValue = -12
        mob1OffsetKnob.maximumValue = 12
        mob1OffsetKnob.value = Float(audioHandler.generator.offset1)
        
        mob1VolumeKnob.value = Float(audioHandler.generator.mob1Mixer.volume)
        
        mob2MorphKnob.minimumValue = -4
        mob2MorphKnob.maximumValue = 4
        mob2MorphKnob.value = Float(audioHandler.generator.morph2)
        
        mob2OffsetKnob.minimumValue = -12
        mob2OffsetKnob.maximumValue = 12
        mob2OffsetKnob.value = Float(audioHandler.generator.offset2)
        
        mob2DetuneKnob.minimumValue = -4
        mob2DetuneKnob.maximumValue = 4
        mob2DetuneKnob.value = Float(audioHandler.generator.morphingOscillatorBank2.detuningOffset)
        
        mob2VolumeKnob.value = Float(audioHandler.generator.mob2Mixer.volume)
        
        mobBalancerKnob.value = Float(audioHandler.generator.dryWet.balance)
        
        pulseWidthKnob.value = Float(audioHandler.generator.pulseWidthModulationOscillatorBank.pulseWidth)
        
        pulseWidthOffsetKnob.minimumValue = -12
        pulseWidthOffsetKnob.maximumValue = 12
        pulseWidthOffsetKnob.value = Float(audioHandler.generator.pulseWidthModulationOscillatorBank.detuningOffset)
        
        pulseWidthVolumeKnob.value = Float(audioHandler.generator.pwmobMixer.volume)
        
        fmModulationKnob.maximumValue = 15
        fmModulationKnob.value = Float(audioHandler.generator.frequencyModulationOscillatorBank.modulationIndex)
        
        fmVolumeKnob.value = Float(audioHandler.generator.fmobMixer.volume)
        
        // TODO ADSR
        attackKnob.value = Float(audioHandler.generator.attackDuration)
        decayKnob.value = Float(audioHandler.generator.decayDuration)
        sustainKnob.value = Float(audioHandler.generator.sustainLevel)
        releaseKnob.value = Float(audioHandler.generator.releaseDuration)
        
        globalBendKnob.maximumValue = 2.0
        globalBendKnob.value = Float(audioHandler.generator.globalbend)
        
        masterVolumeKnob.value = Float(audioHandler.generator.master.volume)
        
        audioHandler.effects.volume = 0.0
    }
    
    @IBAction func startStopGenerator(_ sender: AnyObject) {
        let middleC: MIDINoteNumber = 60
        let vel: MIDIVelocity = 127
        
        if (startStopSwitch .isOn) {
            audioHandler.generator.play(noteNumber: middleC, velocity: vel)
            startStopSwitch.setOn(true, animated: true)
        } else {
            audioHandler.generator.stop(noteNumber: middleC)
            startStopSwitch.setOn(false, animated: true)
        }
    }
    
    func setDefaultGeneratorValues() {
        audioHandler.generator.mob1Mixer.volume = 0.5
        audioHandler.generator.mob2Mixer.volume = 0.0
        audioHandler.generator.globalbend = 0
        audioHandler.generator.dryWet.balance = 0.5
        audioHandler.generator.master.volume = 1.0
    }
    
    @IBAction func saveGenerator(_ sender: AnyObject) {
        
    }
    
    @IBAction func loadGenerator(_ sender: AnyObject) {
        
    }
    
    func attackValueChanged() {
        audioHandler.generator.attackDuration = Double(attackKnob.value)
    }
    
    func decayValueChanged() {
        audioHandler.generator.decayDuration = Double(decayKnob.value)
    }
    
    func sustainValueChanged() {
        audioHandler.generator.sustainLevel = Double(sustainKnob.value)
    }
    
    func releaseValueChanged() {
        audioHandler.generator.releaseDuration = Double(releaseKnob.value)
    }
    
    func mob1WaveTypeValueChanged() {
        audioHandler.generator.waveform1 = Double(mob1WaveTypeKnob.value)
    }
    
    func mob1MorphValueChanged() {
        audioHandler.generator.morph1 = Double(mob1MorphKnob.value)
    }
    
    func mob1OffsetValueChanged() {
        audioHandler.generator.offset1 = Int(mob1OffsetKnob.value)
    }
    
    func mob1VolumeValueChanged() {
        audioHandler.generator.mob1Mixer.volume = Double(mob1VolumeKnob.value)
    }
    
    func mobBalancerValueChanged() {
        audioHandler.generator.dryWet.balance = Double(mobBalancerKnob.value)
    }
    
    func mob2WaveTypeValueChanged() {
        audioHandler.generator.waveform2 = Double(mob2WaveTypeKnob.value)
    }
    
    func mob2MorphValueChanged() {
        audioHandler.generator.morph2 = Double(mob2MorphKnob.value)
    }
    
    func mob2OffsetValueChanged() {
        audioHandler.generator.offset2 = Int(mob2OffsetKnob.value)
    }
    
    func mob2DetuneValueChanged() {
        audioHandler.generator.morphingOscillatorBank2.detuningOffset = Double(mob2DetuneKnob.value)
    }
    
    func mob2VolumeValueChanged() {
        audioHandler.generator.mob2Mixer.volume = Double(mob2VolumeKnob.value)
    }
    
    func pulseWidthValueChanged() {
        audioHandler.generator.pulseWidthModulationOscillatorBank.pulseWidth = Double(pulseWidthKnob.value)
    }
    
    func pulseWidthOffsetValueChanged() {
        audioHandler.generator.pulseWidthModulationOscillatorBank.detuningOffset = Double(pulseWidthOffsetKnob.value)
    }
    
    func pulseWidthVolumeValueChanged() {
        audioHandler.generator.pwmobMixer.volume = Double(pulseWidthVolumeKnob.value)
    }
    
    func fmModulationValueChanged() {
        audioHandler.generator.frequencyModulationOscillatorBank.modulationIndex = Double(fmModulationKnob.value)
    }
    
    func fmVolumeValueChanged() {
        audioHandler.generator.fmobMixer.volume = Double(fmVolumeKnob.value)
    }
    
    func globalBendValueChanged() {
        audioHandler.generator.globalbend = Double(globalBendKnob.value)
    }
    
    func masterVolumeValueChanged() {
        audioHandler.generator.master.volume = Double(masterVolumeKnob.value)
    }
    
    func noteOn(note: MIDINoteNumber) {
        audioHandler.generator.play(noteNumber: note, velocity: 80)
    }
    
    func noteOff(note: MIDINoteNumber) {
        audioHandler.generator.stop(noteNumber: note)
    }
}

