import Foundation
import SQLite

class GeneratorTable {
    static let generatorTable: Table = Table("Generators")
    
    let id = Expression<Int64>("id")
    
    // audiokit oscillator type
    let type = Expression<String?>("type")
    
    // users name
    let name = Expression<String?>("name")
    
    let frequency = Expression<Double?>("frequency")
    
    let createdAt = Expression<Date?>("created_at")
    
    let updatedAt = Expression<Date?>("updated_at")
    
    init(db: Connection) {
        do {
            try db.run(GeneratorTable.generatorTable.create { t in
                t.column(id, primaryKey: true)
                t.column(type)
                t.column(name)
                t.column(frequency)
                t.column(createdAt)
                t.column(updatedAt)
            })
        } catch {
            print("Failed to create generator table: \(error)")
        }
    }
}
