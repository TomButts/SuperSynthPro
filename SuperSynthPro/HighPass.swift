import Foundation
import AudioKit

class HighPass: AKNode {
    
    var parameters: [Double] = [1000, 0.1, 0.1]
    
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
    
    var lfoAmplitude: Double = 0.1 {
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
            
            return input.highPassFilter(
                halfPowerPoint: max(halfPower + lfo, 0)
            )
        }
        
        output.parameters = parameters
        
        // Apple avf audio doesnt breaks when you put a node with AKOperationEffect output
        // into a drywetmixer. Passing it through a mixer fixes this.
        let mixer = AKMixer(output)
        
        super.init()
        
        self.avAudioNode = mixer.avAudioNode
        
        input.addConnectionPoint(self)
    }
}
