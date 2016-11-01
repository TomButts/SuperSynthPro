import Foundation
import SQLite

class Generator {
    let generatorTable: GeneratorTable
    let oscillatorAmplitudeTable: OscillatorAmplitudeTable
    let oscillatorWaveTypeTable: OscillatorWaveTypeTable
    
    var db: Connection = DatabaseConnector.connection!
    
    init() {
        // create the tables
        generatorTable = GeneratorTable(db: db)
        oscillatorAmplitudeTable = OscillatorAmplitudeTable(db: db)
        oscillatorWaveTypeTable = OscillatorWaveTypeTable(db: db)
    }
    
    func save(generator: GeneratorStructure) {
        // TODO select latest created and take row number to put on the end of default
        // add generator record
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
        
        if (generatorRowId != nil) {
            // add amplitudes
            for harmonicIndex in 0 ... generator.waveAmplitudes.count - 1 {
                insert = OscillatorAmplitudeTable.oscillatorAmplitudeTable.insert(
                    oscillatorAmplitudeTable.amplitude <- generator.waveAmplitudes[harmonicIndex],
                    oscillatorAmplitudeTable.generatorId <- generatorRowId,
                    oscillatorAmplitudeTable.harmonicNumber <- harmonicIndex
                )
                
                do {
                    _ = try self.db.run(insert)
                } catch {
                    print("Failed to save generator amplitude values")
                }
            }
            
            // add wave types
            for harmonicIndex in 0 ... generator.waveTypes.count - 1 {
                insert = OscillatorWaveTypeTable.oscillatorWaveTypeTable.insert(
                    oscillatorWaveTypeTable.waveType <- generator.waveTypes[harmonicIndex],
                    oscillatorWaveTypeTable.generatorId <- generatorRowId!,
                    oscillatorWaveTypeTable.harmonicNumber <- harmonicIndex
                )
                
                do {
                    _ = try self.db.run(insert)
                } catch {
                    print("Failed to save generator wave type values")
                }
            }
        }
    }
    
    func load(id: Int64) -> GeneratorStructure {
        var name: String? = nil
        var type: String? = nil
        var frequency: Double? = nil
        var waveAmplitudes: Array<Double> = []
        var waveTypes: Array<Int> = []
        
        // select generator details
        do {
            // TODO: get the fucking join to work
            for generatorDetails in try db.prepare(
                GeneratorTable.generatorTable.select(
                    generatorTable.name,
                    generatorTable.frequency,
                    generatorTable.type
                ).filter(generatorTable.id == id)
            ) {
                name = generatorDetails[generatorTable.name]!
                type = generatorDetails[generatorTable.type]!
                frequency = generatorDetails[generatorTable.frequency]!
                
                print(name, type, frequency)
                print(generatorDetails)
            }
        } catch {
            print("Failed to retrieve generator details. \(error)")
        }
        
        // select amplitudes and insert into array
        do {
            for amplitudes in try db.prepare(
                OscillatorAmplitudeTable.oscillatorAmplitudeTable.select(
                    oscillatorAmplitudeTable.amplitude
                ).filter(oscillatorAmplitudeTable.generatorId == id)
                .order(oscillatorAmplitudeTable.harmonicNumber.asc)
            ) {
                waveAmplitudes.append(amplitudes[oscillatorAmplitudeTable.amplitude]!)
            }
        } catch {
            print("Failed to retrieve amplitude values: \(error)")
        }
        
        // select wavetypes and put into array
        do {
            for types in try db.prepare(
                OscillatorWaveTypeTable.oscillatorWaveTypeTable.select(
                    oscillatorWaveTypeTable.waveType
                    ).filter(oscillatorWaveTypeTable.generatorId == id)
                    .order(oscillatorWaveTypeTable.harmonicNumber.asc)
            ) {
                waveTypes.append(types[oscillatorWaveTypeTable.waveType]!)
            }
        } catch {
            print("Failed to retrieve amplitude values: \(error)")
        }
        
        return GeneratorStructure(
            name: name!,
            type: type!,
            frequency: frequency!,
            waveTypes: waveTypes,
            waveAmplitudes: waveAmplitudes
        )
    }
    
    func delete(id: Int) {
        
    }
}
