/**
 * A node that oscillates a low pass cutoff for a wobble effect
 */
import Foundation
import AudioKit

class Wobble: AKNode {
    // Parameters array
    var parameters: [Double] = [1000, 0.1]
    
    /*
     * When set the node properties are passed into the parameters array
     * which is kept track of by the operation effect closure allowing dynamic
     * changes to operation values
     */
    var halfPowerFrequency: Double = 1000 {
        didSet {
            parameters[0] = halfPowerFrequency
            output.parameters = parameters
        }
    }
    
    var lfoRate: Double = 0.1 {
        didSet {
            parameters[1] = lfoRate
            output.parameters = parameters
        }
    }
    
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        output = AKOperationEffect(input) { input, parameters in
            let halfPower = parameters[0]
            let oscRate = parameters[1]
            
            // Set up lfo
            let lfo = AKOperation.sineWave(
                frequency: oscRate,
                amplitude: 500
            )
            
            // Apply the lfo value to the LP half power point
            return input.lowPassFilter(
                halfPowerPoint: halfPower + lfo
            )
        }
        
        // Link parameters array to closure params of operation effect
        output.parameters = parameters
        
        // Route through
        let mixer = AKMixer(output)
        
        super.init()
        
        // Set node output
        self.avAudioNode = mixer.avAudioNode
        
        // Set node input
        input.addConnectionPoint(self)
    }
}
