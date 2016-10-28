import Foundation
import AudioKit

class OscillatorCollection {
    var waveCollection: Array<AKOscillator> = []
    let waveNode: AKMixer
    
    init(fundamentalFrequency: Double, waveType: Array<AKTable>) {
        // mix the oscillators together into one node
        waveNode = AKMixer()
        
        for i in 0 ... waveType.count - 1 {
            var frequency = fundamentalFrequency
            
            waveCollection.append(AKOscillator(waveform: waveType[i]))
            
            waveCollection[i].frequency = frequency
            
            // Set the frequency of next harmonic oscillator
            frequency = frequency * 2
            
            // connect the oscillator waves together
            waveNode.connect(waveCollection[i])
        }
    }
    
    // Start all the oscillators in the collection
    func startOscillatorCollection() {
        for oscillator in self.waveCollection {
            oscillator.start()
        }
    }
}
