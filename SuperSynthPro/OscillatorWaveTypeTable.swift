import Foundation
import SQLite

class OscillatorWaveTypeTable {
    static let oscillatorWaveTypeTable: Table = Table("OscillatorWaveTypes")
    
    let id = Expression<Int64>("id")
    
    // row id of the generator the amplitude belongs to
    let generatorId = Expression<Int64>("generator_id")
    
    // the harmonic the amplitude belongs to
    let harmonicNumber = Expression<Int?>("harmonic_number")
    
    // the wave type number see Wave class which corresponds to
    // AudioKit TableType enum list
    let waveType = Expression<Int?>("wave_type")
    
    init(db: Connection) {
        do {
            try db.run(OscillatorWaveTypeTable.oscillatorWaveTypeTable.create { t in
                t.column(id, primaryKey: true)
                t.column(
                    generatorId,
                    references: GeneratorTable.generatorTable,
                    GeneratorTable(db: DatabaseConnector.connection!).id
                )
                t.column(harmonicNumber)
                t.column(waveType)
            })
        } catch {
            print("Failed to create oscillator amplitude table: \(error)")
        }
    }
    
}
