import Foundation
import AudioKit

class Wobble: AKNode {
    
    var parameters: [Double] = [1000, 0.1]
    
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
            
            let lfo = AKOperation.sineWave(
                frequency: oscRate,
                amplitude: 1
            )
            
            return input.lowPassFilter(
                halfPowerPoint: halfPower + lfo
            )
        }
        
        output.parameters = parameters
        
        let mixer = AKMixer(output)
        
        super.init()
        
        self.avAudioNode = mixer.avAudioNode
        
        input.addConnectionPoint(self)
    }
}
