import Foundation
import SQLite
import AudioKit

class PresetSound {
    var db: Connection = DatabaseConnector.connection!
    var audioHandler = AudioHandler.sharedInstance
    
    let presetSoundTable: PresetSoundTable

    init () {
        presetSoundTable = PresetSoundTable(db: db)
        savePresetsFromCSV()
    }
    
    func printSettings() {
        print(audioHandler.serializeCurrentSettings())
    }
    
    func save(name: String) {
        let soundSettingsJson = audioHandler.serializeCurrentSettings()
        
        do {
            let _ = try db.run(PresetSoundTable.presetSoundTable.insert(
                or: .replace, presetSoundTable.soundName <- name,
                presetSoundTable.soundSerialisation <- soundSettingsJson)
            )
            print("\nSaved succesfully")
        } catch {
            print("Insertion into preset table failed: \(error)")
        }
    }
    
    func savePresetSound(name: String, soundSettingsJson: String) {
        do {
            let _ = try db.run(PresetSoundTable.presetSoundTable.insert(
                or: .replace, presetSoundTable.soundName <- name,
                presetSoundTable.soundSerialisation <- soundSettingsJson)
            )
            print("\nSaved preset succesfully")
        } catch {
            print("Insertion into preset table failed: \(error)")
        }

    }
    
    func loadAllPresetNames() -> [String] {
        var presetNames = ["none"]
        do {
            for preset in try db.prepare(PresetSoundTable.presetSoundTable.select(
                    presetSoundTable.id,
                    presetSoundTable.soundName
                )
            ) {
                presetNames.append(preset[presetSoundTable.soundName])
            }
        } catch {
            print("Selection of preset ids and names failed: \(error)")
        }
        
        return presetNames
    }
    
    func loadPreset(name: String) {
        do {
            for preset in try db.prepare(PresetSoundTable.presetSoundTable.select(
                    presetSoundTable.soundSerialisation
                ).filter(presetSoundTable.soundName == name)
            ) {
                audioHandler.settingsFromJson(settingsJson: preset[presetSoundTable.soundSerialisation])
                print("\nLoaded preset succesfully")
            }
        } catch {
            print("Selection preset serialised data from id failed: \(error)")
        }
    }
    
    func savePresetsFromCSV() {
        let content = readDataFromFile(file: "presets")
        
        let csv = CSwiftV(with: content!)
        
        for row in csv.keyedRows! {
            savePresetSound(name: row["name"]!, soundSettingsJson: row["soundJson"]!)
        }
    }
    
    func readDataFromFile(file:String)-> String! {
        guard let filepath = Bundle.main.path(forResource: file, ofType: "txt") else {
            return nil
        }
        
        do {
            let contents = try String(contentsOfFile: filepath)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
}
