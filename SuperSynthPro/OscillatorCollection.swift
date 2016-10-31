import Foundation
import AudioKit

class OscillatorCollection: GeneratorProtocol {
    var waveNode: AKMixer
    var fundamentalFrequency: Double
    var harmonics: Int
    var waveCollection: [ Int: OscillatorStructure ] = [:]
    
    // wave class
    let wave = Wave()
    
    init(frequency: Double, waveType: Array<Int>) {
        self.fundamentalFrequency = frequency
        self.harmonics = waveType.count
        
        // mix the oscillators together into one node
        waveNode = AKMixer()
        
        var harmonicFrequency = self.fundamentalFrequency
        
        // create the wave form by combining oscillators
        for i in 0 ... waveType.count - 1 {
            let waveformTable = wave.makeWave(wave: waveType[i])
            
            waveCollection[i] = OscillatorStructure(oscillator: AKOscillator(waveform: waveformTable), waveType: waveType[i])
            
            waveCollection[i]?.oscillator.frequency = harmonicFrequency
            
            harmonicFrequency = harmonicFrequency * 2
            
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
        if (harmonic > waveCollection.count) {
            return 10
        }
        
        return self.waveCollection[harmonic]!.waveType
    }
    
    func addHarmonic(waveType: Int) {
        self.waveCollection[waveCollection.count] = OscillatorStructure(oscillator: AKOscillator(waveform: wave.makeWave(wave: waveType)), waveType: waveType)
        
        let penultimateWave = self.waveCollection.count - 1
        
        self.waveCollection[waveCollection.count]?.oscillator.frequency = (self.waveCollection[penultimateWave]?.oscillator.frequency)! * 2
        
        self.waveCollection[waveCollection.count]?.oscillator.amplitude = 0.2
        
        self.stopWaveNode()
        waveNode.connect((self.waveCollection[waveCollection.count - 1]?.oscillator)!)
        self.startWaveNode()
    }
    
    func deleteHarmonic(harmonic: Int) {
        self.stopWaveNode()
        self.waveCollection.removeValue(forKey: harmonic)
        self.startWaveNode()
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
