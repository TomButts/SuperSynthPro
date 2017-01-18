/**
 * The view controller for the presets page
 */
import UIKit

class PresetsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var presetsPicker: UIPickerView!
    
    // Initialise empty array to hold preset names for picker view
    var presets: [String] = []
    
    // Initialise the preset sound model for preset database interactions
    var presetSound: PresetSound = PresetSound()
    
    // Shared instance of audio handler
    var audioHandler = AudioHandler.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the names of all presets in database
        presets = presetSound.loadAllPresetNames()
        
        // Attach picker view delegates
        self.presetsPicker.dataSource = self
        self.presetsPicker.delegate = self
        
    }
    
    /*
     * Picker view required functions
     */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Set picker view number of rows
        return presets.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Set the picker view row title from array
        return presets[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Load a preset on selection
        presetSound.loadPreset(name: presets[row])
    }
}
