import UIKit


class PresetsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var presetsPicker: UIPickerView!
    
    var presets: [String] = []
    
    var presetSound: PresetSound = PresetSound()
    
    var audioHandler = AudioHandler.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presets = presetSound.loadAllPresetNames()
            
        self.presetsPicker.dataSource = self
        self.presetsPicker.delegate = self
        
    }
    
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return presets.count
    }
    
    // Delegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return presets[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        presetSound.loadPreset(name: presets[row])
    }
}
