import Foundation
import SQLite

class PresetSoundTable {
    static let presetSoundTable: Table = Table("PresetSoundTable")
    
    let id = Expression<Int64>("id")
    
    let soundName = Expression<String>("sound_name")
    
    let soundSerialisation = Expression<String>("sound_json")
    
    init(db: Connection) {
        do {
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
