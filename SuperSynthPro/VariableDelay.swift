/**
 * A Variable delay node with an lfo which can produce some predator esque sounds
 */
import Foundation
import AudioKit

class VariableDelay: AKNode {
    // Parameters array
    var parameters: [Double] = [1.0, 0.0, 0.1, 0.1]
    
    /*
     * When set the node properties are passed into the parameters array
     * which is kept track of by the operation effect closure allowing dynamic
     * changes to operation values
     */
    
    // Delay time
    var time: Double = 1.0 {
        didSet {
            parameters[0] = time
            output.parameters = parameters
        }
    }
    
    // Delay Feedback
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
        // initialise operation effect with closure
        output = AKOperationEffect(input) { input, parameters in
            let time = parameters[0]
            let feedback = parameters[1]
            let oscRate = parameters[2]
            let oscAmp = parameters[3]
            
            // create lfo
            let lfo = AKOperation.sineWave(
                frequency: oscRate,
                amplitude: oscAmp
            )
            
            // Vary the feedback with the lfo value
            return input.variableDelay(
                time: time,
                feedback: feedback + lfo
            )
        }
        
        // Link parameters array to closure params of operation effect
        output.parameters = parameters
        
        // Route through mixer to prevent type errors when connecting node
        let mixer = AKMixer(output)
        
        super.init()
        
        // Set AKNode output
        self.avAudioNode = mixer.avAudioNode
        
        // Set AKNode input
        input.addConnectionPoint(self)
    }
}

