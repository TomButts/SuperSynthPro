import Foundation
import AudioKit

class OscillatorCollection: GeneratorProtocol {
    var waveNode: AKMixer = AKMixer()
    
    // why not store the generator setup here as a structure
    // keep it up to date after every operation then its easy to save it
    // needs to be updated when change amp freq and wavetype add del harmonic
    var fundamentalFrequency: Double
    let type = "AKOscillator"
    
    // this should be a method getHarmonicCount
    var harmonics: Int = 1
    var waveCollection: [ Int: OscillatorStructure ] = [:]
    
    let wave = Wave()
    
    init(generator: GeneratorStructure) {
        fundamentalFrequency = generator.frequency
        harmonics = generator.waveTypes.count
        
        var frequency = fundamentalFrequency
        
        for i in 0 ... generator.waveTypes.count - 1 {
            let waveformTable = wave.makeWave(wave: generator.waveTypes[i])
            
            waveCollection[i] = OscillatorStructure(
                oscillator: AKOscillator(waveform: waveformTable),
                waveType: generator.waveTypes[i],
                amplitude: generator.waveAmplitudes[i]
            )
            
            print("wave types")
            print(generator.waveTypes)
            
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
        waveCollection[harmonic]?.amplitude = amplitude
    }
    
    func updateFrequency() {
        var frequency = fundamentalFrequency
        
        for wave in waveCollection {
            wave.value.oscillator.frequency = frequency
            
            frequency = frequency * 2
        }
    }
    
    func setWaveType(harmonic: Int, waveType: Int) {
        stopWaveNode()
        
        let frequency = waveCollection[harmonic]?.oscillator.frequency
        
        waveCollection[harmonic]?.oscillator = AKOscillator(waveform: wave.makeWave(wave: waveType))
        
        waveCollection[harmonic]?.oscillator.frequency = frequency!
        
        waveCollection[harmonic]?.oscillator.amplitude = (waveCollection[harmonic]?.amplitude)!
        
        waveCollection[harmonic]?.waveType = waveType
        
        waveNode.connect((waveCollection[harmonic]?.oscillator)!)
    }
    
    /**
     * keeps throwing errors, fix this
     */
    func getWaveType(harmonic: Int) -> Int {
        return waveCollection[harmonic]!.waveType
    }
    
    func addHarmonic(waveType: Int) {
        stopWaveNode()
        
        waveCollection[waveCollection.count] = OscillatorStructure(
            oscillator: AKOscillator(waveform: wave.makeWave(wave: waveType)),
            waveType: waveType,
            amplitude: 0.2
        )
        
        waveCollection[waveCollection.count]?.oscillator.frequency = (waveCollection[waveCollection.count - 1]?.oscillator.frequency)! * 2
        
        waveCollection[waveCollection.count]?.oscillator.amplitude = 0.2
        
        harmonics = waveCollection.count
        
        waveNode.connect((waveCollection[harmonics - 1]?.oscillator)!)
        
        startWaveNode()
    }
    
    func deleteHarmonic(harmonic: Int) {
        stopWaveNode()
        
        waveCollection.removeValue(forKey: harmonic)
    
        harmonics = waveCollection.count
    
        startWaveNode()
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
