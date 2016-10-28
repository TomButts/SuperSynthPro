import Foundation
import AudioKit

class WaveformGenerator {
    var harmonics = 2
    var generatorType: String = "AKOscillator"
    var waveformNode: AKNode
    var frequency = 330.0
    
    // this looks shit
    var waveTypes = [AKTable(.sine), AKTable(.sawtooth), AKTable(.sine)]
    
    init(generatorType: String = "AKOscillator") {
        self.generatorType = generatorType
        
        switch generatorType {
            case "AKOscillator":
                let oscillatorCollection = OscillatorCollection(fundamentalFrequency: frequency, waveType: waveTypes)
                
                oscillatorCollection.startOscillatorCollection()
                
                waveformNode = oscillatorCollection.waveNode
            default:
                waveformNode = AKOscillator()
                print("No generator ")
        }
    }
}
