import Foundation
import AudioKit

class LowPass: AKNode {
    
    var parameters = [1000, 0.0, 0.0]
    
    var halfPowerFrequency: Double = 1000 {
        didSet {
            parameters[0] = halfPowerFrequency
            output.parameters = parameters
        }
    }
    
    var lfoRate: Double = 0.0 {
        didSet {
            parameters[1] = lfoRate
            output.parameters = parameters
        }
    }
    
    var lfoAmplitude: Double = 0.0 {
        didSet {
            parameters[2] = lfoAmplitude
            output.parameters = parameters
        }
    }
    
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        output = AKOperationEffect(input) { input, parameters in
            let halfPower = parameters[0]
            let oscRate = parameters[1]
            let oscAmp = parameters[2]
            
            let lfo = AKOperation.sineWave(
                frequency: oscRate,
                amplitude: oscAmp
            )
            
            return input.lowPassFilter(
                halfPowerPoint: max(halfPower + lfo, 0)
            )
        }
        
        output.parameters = parameters
        
        // Connect the input and output to this node
        super.init()
        
        self.avAudioNode = output.avAudioNode
        
        input.addConnectionPoint(self)
    }
}
