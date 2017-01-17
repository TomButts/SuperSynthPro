/**
 * A panning node made in an attempt to add some depth to the sound
 */
import Foundation
import AudioKit

class Panning: AKNode {
    // The parameters array property
    var parameters: [Double] = [1.0, 1.0]
    
    /*
     * When set the node properties are passed into the parameters array
     * which is kept track of by the operation effect closure allowing dynamic
     * changes to operation values
     */
    
    // Rate of lfo operation controlling panning
    var rate: Double = 1.0 {
        didSet {
            parameters[0] = rate
            output.parameters = parameters
        }
    }
    
    // Amplitude of operation controlling panning amount
    var amplitude: Double = 1.0 {
        didSet {
            parameters[1] = amplitude
        }
    }
    
    // output of operation effect
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        // Set output to equal this operation effect closure
        output = AKOperationEffect(input) { input, parameters in
            // pass in parameter array
            let rate = parameters[0]
            let amp = parameters[1]
            
            // Set up an lfo
            let lfo = AKOperation.sineWave(
                frequency: rate,
                amplitude: amp
            )
            
            // Slightly delay sound in an attempt to make the sound seem slightly deeper
            let delay = input.delay(time: 0.08)
            
            // pan from left to right according to the lfo
            return delay.pan(lfo)
        }
        
        // Link parameters array to closure params of operation effect
        output.parameters = parameters
        
        // route though mixer so the node can be connected to other nodes successfully
        let mixer = AKMixer(output)
        
        super.init()
        
        // set the AKNode output
        self.avAudioNode = mixer.avAudioNode
        
        // set the AKNode input
        input.addConnectionPoint(self)
    }
}
