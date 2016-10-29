import Foundation
import AudioKit

protocol GeneratorProtocol {
    var waveNode: AKMixer { get }
    var fundamentalFrequency: Double { get set }
    var harmonics: Int { get set }
    
    // Audio controls for the generator
    func startWaveNode()
    func stopWaveNode()
    
    func changeAmplitude(harmonic: Int, amplitude: Double)
    func updateFrequency()
    func setWaveType(harmonic: Int, waveType: Int)
    
    func addHarmonic(waveType: Int)
    func deleteHarmonic(harmonic: Int)

    // CRUD database operations
    
    // func loadConfiguration()
    // func saveConfiguration()
    // func updateConfiguration()
    // func deleteConfiguration()
}
