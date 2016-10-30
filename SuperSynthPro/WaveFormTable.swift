import Foundation
import SQLite

class WaveFormTable {
    let waveFormTable: Table
    
    init(db: Connection) {
        waveFormTable = Table("WaveForm")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let fundamentalFrequency = Expression<Double?>("FundamentalFrequency")
        
        do {
            try db.run(waveFormTable.create { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(fundamentalFrequency)
            })
        } catch {
            print("Failed to create wave form table")
        }
    }
}
