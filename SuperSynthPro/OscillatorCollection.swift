import Foundation
import AudioKit

class OscillatorCollection: GeneratorProtocol {
    var waveNode: AKMixer
    var fundamentalFrequency: Double
    
    var waveCollection: Array<AKOscillator> = []
    
    init(frequency: Double, waveType: Array<AKTable>) {
        self.fundamentalFrequency = frequency
        
        // mix the oscillators together into one node
        waveNode = AKMixer()
        
        
        var harmonicFrequency = self.fundamentalFrequency
        
        for i in 0 ... waveType.count - 1 {
            waveCollection.append(AKOscillator(waveform: waveType[i]))
            
            waveCollection[i].frequency = harmonicFrequency
            
            // Set the frequency of next harmonic oscillator
            harmonicFrequency = harmonicFrequency * 2
            
            // connect the oscillator waves together
            waveNode.connect(waveCollection[i])
        }
    }

    func startWaveNode() {
        for oscillator in self.waveCollection {
            oscillator.start()
        }
    }
    
    func stopWaveNode() {
        for oscillator in self.waveCollection {
            oscillator.stop()
        }
    }
    
    func changeAmplitude(harmonic: Int, amplitude: Double) {
        waveCollection[harmonic].amplitude = amplitude
    }
    
}
