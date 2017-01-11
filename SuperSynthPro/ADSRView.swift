import Foundation
import UIKit

class ADSRView: UIView {
    // variable to determine rendering
    var attack: Double? = 0.2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var decay: Double? = 0.2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var sustain: Double? = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var rel: Double? = 0.8 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var viewFrame: CGRect
    
    override init(frame: CGRect) {
        viewFrame = frame
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    public override func draw(_ frame: CGRect) {
        drawContainer()
        drawEnvelope()
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
    
    func drawEnvelope() {
        let adsrLine = UIBezierPath()
        let attackLineHeight = (viewFrame.height * 0.2)
        
        let highestXCoordOfAttackLine = viewFrame.width * 0.25
        let lowestXCoordOfAttackLine = viewFrame.width * 0.02
        
        let highestXCoordOfDecayLine = viewFrame.width * 0.2
        let lowestXCoordOfDecayLine = viewFrame.width * 0.02
        
        let attackX = (highestXCoordOfAttackLine * (CGFloat(attack! / 2))) + lowestXCoordOfAttackLine
        let decayX = ((highestXCoordOfDecayLine * CGFloat(decay! / 2 )) + lowestXCoordOfDecayLine) + attackX
        
        let attackPoint = CGPoint(x: attackX, y: attackLineHeight)
        let sustainBounds = ((viewFrame.height * 0.98) - attackLineHeight)
        
        let releaseY = viewFrame.height * 0.98
        let releaseX = viewFrame.width
        
        let sustainY = (sustainBounds - (sustainBounds * CGFloat(sustain!))) + attackLineHeight
        
        let decayPoint = CGPoint(x: decayX, y: sustainY)
    
        let sustainX = (viewFrame.width - decayX) - ((viewFrame.width - decayX) * CGFloat(rel! / 3)) + decayX
        
        let sustainPoint = CGPoint(x: sustainX, y: sustainY)
        
        let releasePoint = CGPoint(x: releaseX, y: releaseY)
      
        adsrLine.move(to: CGPoint(x: 0, y: (viewFrame.height * 0.98)))
        
        adsrLine.addLine(to: attackPoint)
        adsrLine.move(to: attackPoint)
        
        adsrLine.addLine(to: decayPoint)
        adsrLine.move(to: decayPoint)
        
        adsrLine.addLine(to: sustainPoint)
        adsrLine.move(to: sustainPoint)
        
        adsrLine.addLine(to: releasePoint)
        
        adsrLine.close()
        
        UIColor.blue.set()
        adsrLine.lineWidth = 1.5
        adsrLine.stroke()
    }
}
