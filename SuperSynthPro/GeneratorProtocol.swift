import Foundation
import AudioKit

protocol GeneratorProtocol {
    var waveNode: AKMixer { get }
    var fundamentalFrequency: Double { get set }
    
    // Audio controls for the generator
    func startWaveNode()
    func stopWaveNode()
    
    func changeAmplitude(harmonic: Int, amplitude: Double)
}
