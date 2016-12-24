import Foundation
import AudioKit

class LowPass: AKNode {
    
    var parameters: [Double] = [1000.0, 0.0, 0.2, 0.2, 0.0, 0.8, 1.0]
    
    var cutOff: Double = 1000.0 {
        didSet {
            parameters[0] = cutOff
            output.parameters = parameters
        }
    }
    
    var gate: Double = 0.0 {
        didSet {
            parameters[1] = gate
            output.parameters = parameters
        }
    }
    
    var attack: Double = 0.2 {
        didSet {
            parameters[2] = attack
            output.parameters = parameters
        }
    }
    
    var decay: Double = 0.2 {
        didSet {
            parameters[3] = decay
            output.parameters = parameters
        }
    }
    
    var sustain: Double = 0.0 {
        didSet {
            parameters[4] = sustain
            output.parameters = parameters
        }
    }
    
    var rel: Double = 0.8 {
        didSet {
            parameters[5] = rel
            output.parameters = parameters
        }
    }
    
    var resonance: Double = 1.0 {
        didSet {
            parameters[6] = resonance
            output.parameters = parameters
        }
    }
    
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        output = AKOperationEffect(input) { input, parameters in
            let cuttoff = parameters[0]
            let gate = parameters[1]
            let attack = parameters[2]
            let decay = parameters[3]
            let sustain = parameters[4]
            let rel = parameters[5]
            let res = parameters[6]
            
            let cuttoffFrequency = cuttoff.gatedADSREnvelope(
                gate: gate,
                attack: attack,
                decay: decay,
                sustain: sustain,
                release: rel
            )
            
            return input.moogLadderFilter(cutoffFrequency: cuttoffFrequency, resonance: res)
        }
        
        output.parameters = parameters
        
        let mixer = AKMixer(output)
        
        super.init()
        
        self.avAudioNode = mixer.avAudioNode
        
        input.addConnectionPoint(self)
    }
}
