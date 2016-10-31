import Foundation
import SQLite

class OscillatorAmplitudeTable {
    static let oscillatorAmplitudeTable: Table = Table("OscillatorAmplitudes")
    
    let id = Expression<Int64>("id")
    
    // row id of the generator the amplitude belongs to
    var generatorId = Expression<Int64?>("generator_id")
    
    // the harmonic the amplitude belongs to
    var harmonicNumber = Expression<Int?>("harmonic_number")
    
    var amplitude = Expression<Double?>("amplitude")
    
    init(db: Connection) {
        do {
            try db.run(OscillatorAmplitudeTable.oscillatorAmplitudeTable.create { t in
                t.column(id, primaryKey: true)
                t.column(
                    generatorId,
                    references: GeneratorTable.generatorTable,
                    GeneratorTable(db: DatabaseConnector.connection!).id
                )
                t.column(harmonicNumber)
                t.column(amplitude)
            })
        } catch {
            print("Failed to create oscillator amplitude table: \(error)")
        }
    }

}
