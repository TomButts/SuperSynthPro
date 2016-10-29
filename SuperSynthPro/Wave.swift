import Foundation
import AudioKit

class Wave {
    let sine = 0
    let triangle = 1
    let square = 2
    let sawtooth = 3
    
    let waveType = ["sine", "triangle", "square", "sawtooth"]
    
    func makeWave(wave: Int) -> AKTable {
        return AKTable(AKTableType(rawValue: waveType[wave])!)
    }
    
}

