import Foundation
import AudioKit

class VariableDelay: AKNode {
    
    var parameters: [Double] = [1.0, 0.0, 0.1, 0.1]
    
    var time: Double = 1.0 {
        didSet {
            parameters[0] = time
            output.parameters = parameters
        }
    }
    
    var feedback: Double = 0.0 {
        didSet {
            parameters[1] = feedback
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
    
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        output = AKOperationEffect(input) { input, parameters in
            let time = parameters[0]
            let feedback = parameters[1]
            let oscRate = parameters[2]
            let oscAmp = parameters[3]
            
            let lfo = AKOperation.sineWave(
                frequency: oscRate,
                amplitude: oscAmp
            )
            
            return input.variableDelay(
                time: time + lfo,
                feedback: feedback
            )
        }
        
        output.parameters = parameters
        
        // Connect the input and output to this node
        super.init()
        
        self.avAudioNode = output.avAudioNode
        
        input.addConnectionPoint(self)
    }
}

