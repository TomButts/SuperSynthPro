import Foundation
import AudioKit

class Wave {
    static let sine = 0
    static let triangle = 1
    static let square = 2
    static let sawtooth = 3
    
    let waveType = ["sine", "triangle", "square", "sawtooth"]
    
    func makeWave(wave: Int) -> AKTable {
        return AKTable(AKTableType(rawValue: waveType[wave])!)
    }
    
}

