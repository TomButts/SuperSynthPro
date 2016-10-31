import Foundation
import SQLite

class Generator {
    let generatorTable: GeneratorTable
    let oscillatorAmplitudeTable:OscillatorAmplitudeTable
    let oscillatorWaveTypeTable: OscillatorWaveTypeTable
    
    let db: Connection
    
    init(db: Connection) {
        self.db = db
        
        // create the tables
        generatorTable = GeneratorTable(db: db)
        oscillatorAmplitudeTable = OscillatorAmplitudeTable(db: db)
        oscillatorWaveTypeTable = OscillatorWaveTypeTable(db: db)
    }
    
    func saveGenerator(generator: GeneratorStructure) {
        // TODO select latest created and take row number to put on the end of default
        // add generator record
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let currentDate = NSDate()
//        let date = formatter.date(from: currentDate)
        
        var insert = GeneratorTable.generatorTable.insert(
            generatorTable.name <- generator.name,
            generatorTable.type <- generator.type,
            generatorTable.frequency <- generator.frequency,
            generatorTable.createdAt <- NSDate() as Date,
            generatorTable.updatedAt <- NSDate() as Date
        )
        
        var generatorRowId: Int64? = nil
        
        do {
            generatorRowId = try self.db.run(insert)
        } catch {
            print("Error with inserting generator record")
        }
        
        // add amplitudes
        
        if (generatorRowId != nil) {
            for harmonicIndex in 0 ... generator.waveAmplitudes.count - 1 {
                insert = OscillatorAmplitudeTable.oscillatorAmplitudeTable.insert(
                    oscillatorAmplitudeTable.amplitude <- generator.waveAmplitudes[harmonicIndex],
                    oscillatorAmplitudeTable.generatorId <- generatorRowId,
                    oscillatorAmplitudeTable.harmonicNumber <- harmonicIndex
                )
            }
            
            do {
                _ = try self.db.run(insert)
            } catch {
                print("Failed to save generator amplitude values")
            }
            
            for harmonicIndex in 0 ... generator.waveTypes.count - 1 {
                insert = OscillatorWaveTypeTable.oscillatorWaveTypeTable.insert(
                    oscillatorWaveTypeTable.waveType <- generator.waveTypes[harmonicIndex],
                    oscillatorWaveTypeTable.generatorId <- generatorRowId!,
                    oscillatorWaveTypeTable.harmonicNumber <- harmonicIndex
                )
            }
            
            
            do {
                _ = try self.db.run(insert)
            } catch {
                print("Failed to save generator amplitude values")
            }
        }
    }
    
    func loadGenerator(id: Int64) {
        
    }
    
    func deleteGenerator(id: Int64) {
        
    }
}
