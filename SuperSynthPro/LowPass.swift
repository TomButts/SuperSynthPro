/**
 * A low pass filter with an ADSR controlled cutoff value in an attempt to make a funky sound
 */
import Foundation
import AudioKit

class LowPass: AKNode {
    // Parameters array
    var parameters: [Double] = [1000.0, 0.0, 0.2, 0.2, 0.5, 0.8, 1.0]
    
    /*
     * When set the node properties are passed into the parameters array
     * which is kept track of by the operation effect closure allowing dynamic
     * changes to operation values
     */
    var cutOff: Double = 1000.0 {
        didSet {
            parameters[0] = cutOff
            output.parameters = parameters
        }
    }
    
    // This gate controls when to trigger this classes ouput
    var gate: Double = 0.0 {
        didSet {
            parameters[1] = gate
            output.parameters = parameters
        }
    }
    
    var attack: Double = 0.2 {
        didSet {
            parameters[2] = attack
            output.parameters = parameters
            
            // Syncs attack with the ADSR Cutoff view
            ADSRView?.attack = attack
        }
    }
    
    var decay: Double = 0.2 {
        didSet {
            parameters[3] = decay
            output.parameters = parameters
            
            // Syncs decay with the ADSR Cutoff view
            ADSRView?.decay = decay
        }
    }
    
    var sustain: Double = 0.5 {
        didSet {
            parameters[4] = sustain
            output.parameters = parameters
            
            // Syncs sustain with the ADSR Cutoff view
            ADSRView?.sustain = sustain
        }
    }
    
    // Release is a keyword so used rel instead
    var rel: Double = 0.8 {
        didSet {
            parameters[5] = rel
            output.parameters = parameters
            
            // Syncs release with the ADSR Cutoff view
            ADSRView?.rel = rel
        }
    }
    
    var resonance: Double = 1.0 {
        didSet {
            parameters[6] = resonance
            output.parameters = parameters
        }
    }
    
    // Store a ADSR UI view instance so values can be updated
    var ADSRView: ADSRView? = nil
    
    var output: AKOperationEffect
    
    init(_ input: AKNode) {
        output = AKOperationEffect(input) { input, parameters in
            let cuttoff = parameters[0]
            let gate = parameters[1]
            let attack = parameters[2]
            let decay = parameters[3]
            let sustain = parameters[4]
            let rel = parameters[5]
            let res = parameters[6]
            
            let cuttoffFrequency = cuttoff.gatedADSREnvelope(
                gate: gate,
                attack: attack,
                decay: decay,
                sustain: sustain,
                release: rel
            )
            
            return input.moogLadderFilter(cutoffFrequency: cuttoffFrequency, resonance: res)
        }
        
        // Link parameters array to closure params of operation effect
        output.parameters = parameters
        
        let mixer = AKMixer(output)
        
        super.init()
        
        self.avAudioNode = mixer.avAudioNode
        
        input.addConnectionPoint(self)
    }
}
