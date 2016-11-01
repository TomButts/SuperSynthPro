import Foundation
import AudioKit

class OscillatorCollection: GeneratorProtocol {
    let type = "AKOscillator"
    
    var waveNode: AKMixer = AKMixer()
    var fundamentalFrequency: Double = 330.0
    var harmonics: Int = 1
    var waveCollection: [ Int: OscillatorStructure ] = [:]
    
    // wave class
    let wave = Wave()
    
    init(generator: GeneratorStructure) {
        fundamentalFrequency = generator.frequency
        harmonics = generator.waveTypes.count
        
        var frequency = generator.frequency
        
        for i in 0 ... generator.waveTypes.count - 1 {
            let waveformTable = wave.makeWave(wave: generator.waveTypes[i])
            
            waveCollection[i] = OscillatorStructure(
                oscillator: AKOscillator(waveform: waveformTable),
                waveType: generator.waveTypes[i]
            )
            
            waveCollection[i]?.oscillator.frequency = frequency
            waveCollection[i]?.oscillator.amplitude = generator.waveAmplitudes[i]
            
            frequency = frequency * 2
            
            waveNode.connect((waveCollection[i]?.oscillator)!)
        }
    }

    func startWaveNode() {
        for wave in self.waveCollection {
            wave.value.oscillator.start()
        }
    }
    
    func stopWaveNode() {
        for wave in self.waveCollection {
            wave.value.oscillator.stop()
        }
    }
    
    func changeAmplitude(harmonic: Int, amplitude: Double) {
        waveCollection[harmonic]?.oscillator.amplitude = amplitude
    }
    
    func updateFrequency() {
        var frequency = self.fundamentalFrequency
        
        for wave in waveCollection {
            wave.value.oscillator.frequency = frequency
            
            frequency = frequency * 2
        }
    }
    
    func setWaveType(harmonic: Int, waveType: Int) {
        self.stopWaveNode()
        // reset oscillator
        let frequency = self.waveCollection[harmonic]?.oscillator.frequency
        let amplitude = self.waveCollection[harmonic]?.oscillator.amplitude
        
        self.waveCollection[harmonic]?.oscillator = AKOscillator(waveform: wave.makeWave(wave: waveType))
        self.waveCollection[harmonic]?.oscillator.frequency = frequency!
        self.waveCollection[harmonic]?.oscillator.amplitude = amplitude!
        
        // reset wave type
        self.waveCollection[harmonic]?.waveType = waveType
        
        waveNode.connect((self.waveCollection[harmonic]?.oscillator)!)
        
        self.startWaveNode()
    }
    
    /**
     * keeps throwing errors, fix this
     */
    func getWaveType(harmonic: Int) -> Int {
        return self.waveCollection[harmonic]!.waveType
    }
    
    func addHarmonic(waveType: Int) {
        waveCollection[waveCollection.count] = OscillatorStructure(
            oscillator: AKOscillator(waveform: wave.makeWave(wave: waveType)),
            waveType: waveType
        )
        
        let penultimateWave = self.waveCollection.count - 1
        
        waveCollection[waveCollection.count]?.oscillator.frequency = (self.waveCollection[penultimateWave]?.oscillator.frequency)! * 2
        
        waveCollection[waveCollection.count]?.oscillator.amplitude = 0.2
        
        self.stopWaveNode()
        waveNode.connect((self.waveCollection[waveCollection.count - 1]?.oscillator)!)
        self.startWaveNode()
    }
    
    func deleteHarmonic(harmonic: Int) {
        AudioKit.stop()
        
        self.waveCollection.removeValue(forKey: harmonic)
        
        AudioKit.start()
    }
    
    func getAllWaveTypes() -> Array<Int> {
        var waveTypes: Array<Int> = []
        
        for wave in waveCollection {
            waveTypes.append(wave.value.waveType)
        }
        
        return waveTypes
    }
    
    func getAllAmplitudes() -> Array<Double> {
        var amplitudes: Array<Double> = []
        
        for wave in waveCollection {
            amplitudes.append(wave.value.oscillator.amplitude)
        }
        
        return amplitudes
    }
}
