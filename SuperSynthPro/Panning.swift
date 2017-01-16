import Foundation
import AudioKit

class Panning: AKNode {
    var parameters: [Double] = [1.0, 1.0]
    
    var rate: Double = 1.0 {
        didSet {
            parameters[0] = rate
            output.parameters = parameters
        }
    }
    
    var amplitude: Double = 1.0 {
        didSet {
            parameters[1] = amplitude
        }
    }
    
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        output = AKOperationEffect(input) { input, parameters in
            let rate = parameters[0]
            let amp = parameters[1]
            
            let lfo = AKOperation.sineWave(
                frequency: rate,
                amplitude: amp
            )
            let delay = input.delay(time: 0.08)
            
            return delay.pan(lfo)
        }
        
        output.parameters = parameters
        
        let mixer = AKMixer(output)
        
        super.init()
        
        self.avAudioNode = mixer.avAudioNode
        
        input.addConnectionPoint(self)
    }
}
