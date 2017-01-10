import Foundation
import UIKit

class ADSRView: UIView {
    // variable to determine rendering
    var attack: Double? = nil
    var decay: Double? = nil
    var sustain: Double? = nil
    var rel: Double? = nil
    
    var viewFrame: CGRect
    
    override init(frame: CGRect) {
        viewFrame = frame
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    public override func draw(_ frame: CGRect) {
        drawContainer()
    }
    
    func initialiseADSR(nodeAttack: Double, nodeDecay: Double, nodeSustain: Double, nodeRelease: Double) {
        attack = nodeAttack
        decay = nodeDecay
        sustain = nodeSustain
        rel = nodeRelease
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func renderView() {
        draw(viewFrame)
    }
    
    func drawContainer() {
        let colour: UIColor = UIColor.blue
        let viewHeight = viewFrame.height
        let viewWidth = viewFrame.width
        
        let containerFrame = CGRect(x: 0, y: 1, width: viewWidth, height: (viewHeight * 0.98))
        let container: UIBezierPath = UIBezierPath(rect: containerFrame)
        
        colour.set()
        container.stroke()
    }
    
    func drawAttack() {
        
    }
}
