/**
 * Auto Wah node with an lfo attached
 */
import Foundation
import AudioKit

class AutoWah: AKNode {
    // Parameters array
    var parameters: [Double] = [0.0, 0.0, 0.1]
    
    /*
     * When set the node properties are passed into the parameters array
     * which is kept track of by the operation effect closure allowing dynamic
     * changes to operation values
     */
    
    var wahAmount: Double = 0 {
        didSet {
            parameters[0] = wahAmount
            output.parameters = parameters
        }
    }
    
    var amplitude: Double = 0.0 {
        didSet {
            parameters[1] = amplitude
            output.parameters = parameters
        }
    }
    
    var lfoRate: Double = 0.1 {
        didSet {
            parameters[2] = lfoRate
            output.parameters = parameters
        }
    }
    
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        output = AKOperationEffect(input) { input, parameters in
            let wah = parameters[0]
            let amp = parameters[1]
            let oscRate = parameters[2]
            
            // Set up LFO
            let lfo = AKOperation.sineWave(
                frequency: oscRate,
                amplitude: 1
            )
            
            // Vary the wah amount with the lfo value
            return input.autoWah(
                wah: wah + lfo,
                amplitude: amp
            )
        }
        
        // Link parameters array to closure params of operation effect
        output.parameters = parameters
        
        // Route through mixer to prevent connection problems
        let mixer = AKMixer(output)
        
        super.init()
        
        // Set output of AKNode
        self.avAudioNode = mixer.avAudioNode
        
        // Set input of AKNode
        input.addConnectionPoint(self)
    }
}
