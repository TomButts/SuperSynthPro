/**
 * Simply handles creating the preset sounds databse table
 */
import Foundation
import SQLite

class PresetSoundTable {
    // A static table variable
    static let presetSoundTable: Table = Table("PresetSoundTable")
    
    // Id
    let id = Expression<Int64>("id")
    
    // Sound name to use as identifier
    let soundName = Expression<String>("sound_name")
    
    // The serialised data representing the audio handler state
    let soundSerialisation = Expression<String>("sound_json")
    
    init(db: Connection) {
        do {
            // Create the table
            try db.run(PresetSoundTable.presetSoundTable.create { t in
                t.column(id, primaryKey: true)
                t.column(soundName, unique: true)
                t.column(soundSerialisation)
            })
        } catch {
            print("Failed to create synth sound table: \(error)")
        }
    }
}
