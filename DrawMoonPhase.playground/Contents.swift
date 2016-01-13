//: # Drawing the Moon using Core Graphics
//:
//: We'll examine a basic algorithm for determining the current moon phase and create a custom view to draw the phase using Core Graphics. The phase algorithm draws the illuminated portion of the moon using a line-by-line approach.
//:
//:
//: To get started, we'll import the module for UIKit.

import UIKit
import XCPlayground

//: We need to convert between the current date and the [Julian date](http://en.wikipedia.org/wiki/Julian_day). From the Julian date will determine a fractional value for the Moon phase. Declare some constants up front to make the conversion math clearer.

private let kEpochJulianDate = 2440587.5
private let kLunarSynodicPeriod = 29.53059
private let kSecondsPerDay = 86400.0

//: Next add an extension onto NSDate to return the current moon phase. The math for calculating the Julian Date can be found on [Stack Overflow](http://stackoverflow.com/a/27709317) and the calculations for the Moon phase and age are detrived from a similar [example in Visual Basic](http://www.codeproject.com/Articles/100174/Calculate-and-Draw-Moon-Phase).

extension NSDate {
    
    public func moonPhase() -> Double {
        let julianDate = kEpochJulianDate + self.timeIntervalSince1970 / kSecondsPerDay
        let phase = (julianDate + 4.867) / kLunarSynodicPeriod
        return (phase - floor(phase))
    }
    
    public func moonAge() -> Double {
        let phase = moonPhase()
        let period = kLunarSynodicPeriod
        
        if phase < 0.5 {
            return floor(phase * period + period / 2) + 1
        }
        else {
            return floor(phase * period - period / 2) + 1
        }
    }
}

//: With this extension we can find the moon phase and age for any given `NSDate`.

//: Create a `UIView` subclass to represent a moon phase view. The subclass will declare a private `date` instance variable. The date can be specified when the view is created. If left unspecified, then date will default to today.

class MoonView: UIView {
    
    private let date: NSDate
    
    init(frame: CGRect, date: NSDate) {
        self.date = date
        super.init(frame: frame)
    }
    
    override init(frame: CGRect) {
        self.date = NSDate()
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        self.date = NSDate()
        super.init(coder: aDecoder)!
    }
    
//: Next override and implement `drawRect:` to perform the drawing. The code drawing is port from a [Visual Basic example](http://www.codeproject.com/Articles/100174/Calculate-and-Draw-Moon-Phase) and modified to use Core Graphics. 
    
//: The moon is drawn in two parts, for the illuminated and darkened portitions. Each portition itself is also drawn in two parts, for a top and bottom half.
//: ![drawing.gif](Resources/draw2.gif)
    
    override func drawRect(rect: CGRect) {
        
        // fill background
        let path = UIBezierPath(rect: rect)
        UIColor.darkGrayColor().setFill()
        path.fill()
        
        // determine circle (moon) size
        let phase = self.date.moonPhase()
        let diameter = Double(CGRectGetWidth(rect))
        let radius = Int(diameter / 2)
        
        for Ypos in 0...radius {
            let Xpos = sqrt(Double((radius * radius) - Ypos*Ypos))
            
            let pB1 = CGPointMake(CGFloat(Double(radius)-Xpos), CGFloat(Double(Ypos)+Double(radius)))
            let pB2 = CGPointMake(CGFloat(Xpos+Double(radius)), CGFloat(Double(Ypos)+Double(radius)))
            let pB3 = CGPointMake(CGFloat(Double(radius)-Xpos), CGFloat(Double(radius)-Double(Ypos)))
            let pB4 = CGPointMake(CGFloat(Xpos+Double(radius)), CGFloat(Double(radius)-Double(Ypos)))
            
            let path = UIBezierPath()
            
            path.moveToPoint(pB1)
            path.addLineToPoint(pB2)
            path.moveToPoint(pB3)
            path.addLineToPoint(pB4)
            
            UIColor.blackColor().setStroke()
            path.stroke()
            
            let Rpos = 2 * Xpos
            var Xpos1 = 0.0
            var Xpos2 = 0.0
            if (phase < 0.5) {
                Xpos1 = Xpos * -1
                Xpos2 = Double(Rpos) - (2.0 * phase * Double(Rpos)) - Double(Xpos)
            }
            else {
                Xpos1 = Xpos;
                Xpos2 = Double(Xpos) - (2.0 * phase * Double(Rpos)) + Double(Rpos)
            }
            
            let pW1 = CGPointMake(CGFloat(Xpos1+Double(radius)), CGFloat(Double(radius)-Double(Ypos)))
            let pW2 = CGPointMake(CGFloat(Xpos2+Double(radius)), CGFloat(Double(radius)-Double(Ypos)))
            let pW3 = CGPointMake(CGFloat(Xpos1+Double(radius)), CGFloat(Double(Ypos)+Double(radius)))
            let pW4 = CGPointMake(CGFloat(Xpos2+Double(radius)), CGFloat(Double(Ypos)+Double(radius)))
            
            let path2 = UIBezierPath()
            
            path2.moveToPoint(pW1)
            path2.addLineToPoint(pW2)
            path2.moveToPoint(pW3)
            path2.addLineToPoint(pW4)
            
            UIColor.whiteColor().setStroke()
            path2.lineWidth = 2.0
            path2.stroke()
        }
    }
}

//: Finally, draw the Moon. We can draw the current moon by creating a `MoonView` without a date.

let todaysMoon = MoonView(frame: CGRectMake(0, 0, 200, 200))

//: Or we pass in a date on creation and draw then moon phase for any `NSDate` in time. Using an `NSDateFormatter` makes it easy to create a specific date.

let dateFormatter = NSDateFormatter()
dateFormatter.dateFormat = "M/d/yyyy"

let date = dateFormatter.dateFromString("10/05/2023")
let futureMoon = MoonView(frame: CGRectMake(0, 0, 200, 200), date: date!)

//: That's it!
XCPlaygroundPage.currentPage.liveView = todaysMoon

