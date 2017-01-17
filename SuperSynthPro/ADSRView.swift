/**
 * The ADSR view is a custom envelope drawing object made entirely by me.
 * It draws a representation of an envelope in a view based on ADSR values
 */
import Foundation
import UIKit

class ADSRView: UIView {
    /*
     * didSet allows rerendering of the envelope everytime an ADSR value is changed
     * by using the setNeedsDisplay function
     */
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
    
    /* 
     * A UIView takes a CGRect to init and when draw is called
     *
     * In this case the CGRect (frame) is the same so I set it as a property
     */
    var viewFrame: CGRect
    
    override init(frame: CGRect) {
        // Set the frame on initialisation
        viewFrame = frame
        
        // UIViews init
        super.init(frame: frame)
        
        // Need a clear background for the view
        self.backgroundColor = UIColor.clear
    }
    
    /*
     * UIView sub classes override draw in order to draw thing
     */
    public override func draw(_ frame: CGRect) {
        // Draw the 'container' which is just a rectangle
        drawContainer()
        
        // Draw the actual envelope in the rectangle
        drawEnvelope()
    }
    
    /*
     * Allows the ADSR properties to be set in 1 line rather than 4
     */
    func initialiseADSR(nodeAttack: Double, nodeDecay: Double, nodeSustain: Double, nodeRelease: Double) {
        attack = nodeAttack
        decay = nodeDecay
        sustain = nodeSustain
        rel = nodeRelease
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     * A wrapper for draw which means I don't have to pass draw another rect 
     * in a view controller
     */
    func renderView() {
        draw(viewFrame)
    }
    
    /*
     * Draws the container which is just a rectangle
     */
    func drawContainer() {
        let colour: UIColor = UIColor.blue
        let viewHeight = viewFrame.height
        let viewWidth = viewFrame.width
        
        let containerFrame = CGRect(x: 0, y: 1, width: viewWidth, height: (viewHeight * 0.98))
        let container: UIBezierPath = UIBezierPath(rect: containerFrame)
        
        colour.set()
        container.stroke()
    }
    
    /*
     * Draw the envelope.
     * 
     * This is a bit confusing because the x,y values start at the top left rather than bottom left.
     *
     * I've tried to make the variables fairly verbose to make things clearer.
     * 
     * Everything is done in relation to the view frame so that it should scale to whatever size frame you're 
     * using
     */
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
