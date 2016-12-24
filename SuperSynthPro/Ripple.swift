import Foundation
import AudioKit

class Ripple: AKNode {
    
    var parameters: [Double] = [1000, 1.0, 0.1, 0.1, 0.0]
    
    var cutOff: Double = 1000 {
        didSet {
            parameters[0] = cutOff
            output.parameters = parameters
        }
    }
    
    var sweepDuration: Double = 1.0 {
        didSet {
            parameters[1] = lfoRate
            output.parameters = parameters
        }
    }
    
    
    var lfoRate: Double = 0.1 {
        didSet {
            parameters[2] = lfoRate
            output.parameters = parameters
        }
    }
    
    var lfoAmplitude: Double = 0.1 {
        didSet {
            parameters[3] = lfoAmplitude
            output.parameters = parameters
        }
    }
    
    var gate: Double = 0.0 {
        didSet {
            parameters[4] = gate
            output.parameters = parameters
        }
    }
    
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        output = AKOperationEffect(input) { input, parameters in
            let cutOff = parameters[0]
            let sweep = parameters[1]
            let oscRate = parameters[2]
            let oscAmp = parameters[3]
            let gate = parameters[4]
            
            let frequency = oscRate.gatedADSREnvelope(
                gate: gate,
                attack: sweep,
                decay: 0,
                sustain: 0.6,
                release: 0.1
            )
            
            let lfo = AKOperation.sineWave(
                frequency: frequency,
                amplitude: oscAmp
            )
            
            return input.moogLadderFilter(cutoffFrequency: cutOff + lfo, resonance: 1)
        }
        
        output.parameters = parameters
        
        let mixer = AKMixer(output)
        
        super.init()
        
        self.avAudioNode = mixer.avAudioNode
        
        input.addConnectionPoint(self)
    }
}
