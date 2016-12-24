import Foundation
import AudioKit

class AutoWah: AKNode {
    
    var parameters: [Double] = [0.0, 0.0, 0.1]
    
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
            
            let lfo = AKOperation.sineWave(
                frequency: oscRate,
                amplitude: 1
            )
            
            return input.autoWah(
                wah: wah + lfo,
                amplitude: amp
            )
        }
        
        output.parameters = parameters
        
        let mixer = AKMixer(output)
        
        super.init()
        
        self.avAudioNode = mixer.avAudioNode
        
        input.addConnectionPoint(self)
    }
}
