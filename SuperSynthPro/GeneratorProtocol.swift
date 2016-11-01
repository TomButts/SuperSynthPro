import Foundation
import AudioKit

protocol GeneratorProtocol {
    var type: String { get }
    
    var waveNode: AKMixer { get }
    var waveCollection: [ Int: OscillatorStructure ] { get set }
    var fundamentalFrequency: Double { get set }
    var harmonics: Int { get set }
    
    func startWaveNode()
    func stopWaveNode()
    
    func changeAmplitude(harmonic: Int, amplitude: Double)
    func updateFrequency()
    
    func getWaveType(harmonic: Int) -> Int
    func setWaveType(harmonic: Int, waveType: Int)
    
    func getAllWaveTypes() -> Array<Int>
    func getAllAmplitudes() -> Array<Double>
    
    func addHarmonic(waveType: Int)
    func deleteHarmonic(harmonic: Int)
}
