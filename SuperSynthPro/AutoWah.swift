import Foundation
import AudioKit

class AutoWah: AKNode {
    
    var parameters: [Double] = [0.0, 0.0, 0.0, 0.0]
    
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
    
    var lfoRate: Double = 0.0 {
        didSet {
            parameters[2] = lfoRate
            output.parameters = parameters
        }
    }
    
    var lfoAmplitude: Double = 0.0 {
        didSet {
            parameters[3] = lfoAmplitude
            output.parameters = parameters
        }
    }
    
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        output = AKOperationEffect(input) { input, parameters in
            let wah = parameters[0]
            let amp = parameters[1]
            let oscRate = parameters[2]
            let oscAmp = parameters[3]
            
            let lfo = AKOperation.sineWave(
                frequency: oscRate,
                amplitude: oscAmp
            )
            
            return input.autoWah(
                wah: wah + lfo,
                amplitude: amp
            )
        }
        
        output.parameters = parameters
        
        // Connect the input and output to this node
        super.init()
        
        self.avAudioNode = output.avAudioNode
        
        input.addConnectionPoint(self)
    }
}
