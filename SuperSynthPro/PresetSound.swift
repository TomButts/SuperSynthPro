/**
 * A module to handle the preset sound database calls
 *
 * I have added the extra database layer which is currently redundant 
 * because at some point in the future I might want to send configurations to 
 * a server for some reason.  Possible sharing or cload saving.
 *
 * I am using stephen celis' SQLite connector module to perform these operations
 * found here: https://github.com/stephencelis/SQLite.swift
 */
import Foundation
import SQLite
import AudioKit

class PresetSound {
    // A database connection is required
    var db: Connection = DatabaseConnector.connection!
    
    // The shared instance of audiohandler
    var audioHandler = AudioHandler.sharedInstance
    
    // A variable representing the sqlite table
    let presetSoundTable: PresetSoundTable

    init () {
        // Initialse the table object
        presetSoundTable = PresetSoundTable(db: db)
        
        // On init save all the csv preset values into the database
        savePresetsFromCSV()
    }
    
    /*
     * During development hook this up to something in order to collect
     * the audio handler JSON so you can use it as a preset
     */
    func printSettings() {
        print(audioHandler.serializeCurrentSettings())
    }
    
    /*
     * [@param String] Name of sound to save
     * [@param String] JSON audio circuit data to save
     *
     * Save a single preset sound into the database
     */
    func savePresetSound(name: String, soundSettingsJson: String) {
        do {
            // INSERT INTO PresetSoundTable (`sound_name`, `sound_json` ) VALUES (?, ?)
            let _ = try db.run(PresetSoundTable.presetSoundTable.insert(
                or: .replace, presetSoundTable.soundName <- name,
                presetSoundTable.soundSerialisation <- soundSettingsJson)
            )
            print("\nSaved preset succesfully")
        } catch {
            print("Insertion into preset table failed: \(error)")
        }
    }
    
    /*
     * Load all the names of the preset sounds from the database
     * 
     * return [String] an array of string values
     */
    func loadAllPresetNames() -> [String] {
        // Initialise the array with blank entry so if they clicked by mistake nothing changes immediately in the picker view
        var presetNames = ["-----"]
        
        do {
            // SELECT `sound_name` FROM PresetSoundTable
            for preset in try db.prepare(PresetSoundTable.presetSoundTable.select(
                    presetSoundTable.soundName
                )
            ) {
                // Append all the preset names into an array
                presetNames.append(preset[presetSoundTable.soundName])
            }
        } catch {
            print("Selection of preset ids and names failed: \(error)")
        }
        
        return presetNames
    }
    
    /*
     * [@param String] Preset name to load
     *
     * Loads a db stored preset and passes it through the JSON -> audio handler settings function
     */
    func loadPreset(name: String) {
        do {
            for preset in try db.prepare(PresetSoundTable.presetSoundTable.select(
                    presetSoundTable.soundSerialisation
                ).filter(presetSoundTable.soundName == name)
            ) {
                // Set values in audio handler from JSON
                audioHandler.settingsFromJson(settingsJson: preset[presetSoundTable.soundSerialisation])
                
                print("\nLoaded preset succesfully")
            }
        } catch {
            print("Selection preset serialised data from id failed: \(error)")
        }
    }
    
    /*
     * Takes CSV sounds and stores in db
     */
    func savePresetsFromCSV() {
        // Get csv content
        let content = readDataFromFile(file: "presets")
        
        // Parse using the open source module that I take no credit for
        let csv = CSwiftV(with: content!)
        
        // Loop through the csv saving individual sounds
        for row in csv.keyedRows! {
            savePresetSound(name: row["name"]!, soundSettingsJson: row["soundJson"]!)
        }
    }
    
    /*
     * [@param String] The file path of the file to read from
     *
     * Handles grabbing the data from presets.txt
     *
     */
    func readDataFromFile(file: String)-> String! {
        // Get the filepath
        guard let filepath = Bundle.main.path(forResource: file, ofType: "txt") else {
            return nil
        }
        
        do {
            // Use filepath to create string
            let contents = try String(contentsOfFile: filepath)
            
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
}
