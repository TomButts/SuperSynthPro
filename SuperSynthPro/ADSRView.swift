/**
 * The ADSR view is a custom envelope drawing object made entirely by me.
 * It draws a representation of an envelope in a view based on ADSR values
 */
import Foundation
import UIKit

class ADSRView: UIView {
    /*
     * Every time an ADSR value is changed didSet is called
     * triggering the redrawing function (setNeedsDisplay)
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
    
    public override func draw(_ frame: CGRect) {
        // Draw the 'container' which is just a rectangle
        drawContainer()
        
        // Draw the actual envelope in the rectangle
        drawEnvelope()
    }
    
    /*
     * [@param Double] The attack value of the node being tracked
     * [@param Double] The decay value of the node being tracked
     * [@param Double] The sustain value of the node being tracked
     * [@param Double] The release value of the node being tracked
     *
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
        // Initialise line
        let adsrLine = UIBezierPath()
        
        // The height coordinate of the attack line
        let attackLineHeight = (viewFrame.height * 0.2)
        
        // The upper and lower limit of the attack point x coordinate
        let highestXCoordOfAttackLine = viewFrame.width * 0.25
        let lowestXCoordOfAttackLine = viewFrame.width * 0.02
        
        // The upper and lower limit of the decay point x coordinate
        let highestXCoordOfDecayLine = viewFrame.width * 0.2
        let lowestXCoordOfDecayLine = viewFrame.width * 0.02
        
        // The actual attack X coordinate based off the attack property taking into account bounds
        let attackX = (highestXCoordOfAttackLine * (CGFloat(attack! / 2))) + lowestXCoordOfAttackLine
        
        // The actual decay X coordinate based off the decay property taking into account bounds
        let decayX = ((highestXCoordOfDecayLine * CGFloat(decay! / 2 )) + lowestXCoordOfDecayLine) + attackX
        
        // The attack x,y point
        let attackPoint = CGPoint(x: attackX, y: attackLineHeight)
        
        /*
         * 98% of the frame minus the 'attack line height' which is actually the distance from the
         * top of the attack line to the top of the view.
         */
        let sustainYBounds = ((viewFrame.height * 0.98) - attackLineHeight)
        
        // Release x and y is the final destination of the line which will be the bottom right corner of the view
        let releaseY = viewFrame.height * 0.98
        let releaseX = viewFrame.width
        
        // The sustain y coordinate needs to stay within the attack lines height and not drop off the bottom of the view
        let sustainY = (sustainYBounds - (sustainYBounds * CGFloat(sustain!))) + attackLineHeight
        
        // The decay x,y point
        let decayPoint = CGPoint(x: decayX, y: sustainY)
    
        /*
         * The higher the release the longer the release line needs to be
         * so an (y-y*x)+z formula needs to be used where y is the total space left
         * available to the release line and x is the release value. Z ensures its drawn on 
         * the end of the decay line
         */
        let sustainX = (viewFrame.width - decayX) - ((viewFrame.width - decayX) * CGFloat(rel! / 3)) + decayX
        
        // Sustain x,y point
        let sustainPoint = CGPoint(x: sustainX, y: sustainY)
        
        // Release x,y point
        let releasePoint = CGPoint(x: releaseX, y: releaseY)
      
        // Draw all the lines between the points
        adsrLine.move(to: CGPoint(x: 0, y: (viewFrame.height * 0.98)))
        
        adsrLine.addLine(to: attackPoint)
        adsrLine.move(to: attackPoint)
        
        adsrLine.addLine(to: decayPoint)
        adsrLine.move(to: decayPoint)
        
        adsrLine.addLine(to: sustainPoint)
        adsrLine.move(to: sustainPoint)
        
        adsrLine.addLine(to: releasePoint)
        
        adsrLine.close()
        
        // Colour and stroke settings
        UIColor.blue.set()
        adsrLine.lineWidth = 1.5
        adsrLine.stroke()
    }
}
