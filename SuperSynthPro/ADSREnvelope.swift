import Foundation
import AudioKit

class ADSREnvelope {
 
    var envelope: AKAmplitudeEnvelope! = nil
    
    init (node: AKMixer) {
        envelope = AKAmplitudeEnvelope(
            node,
            attackDuration: 0.1,
            decayDuration: 0.1,
            sustainLevel: 0,
            releaseDuration: 0.1
        )
        
        // envelope.start()
    }
    
    // then can write get setting function for data 
    // persistence 
    
}
