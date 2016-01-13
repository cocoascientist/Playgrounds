// https://possiblemobile.com/2015/03/prototyping-uiview-animations-swift-playground/

import UIKit
import XCPlayground

let containerView = UIView(frame: CGRectMake(0, 0, 360.0, 360.0))
let circle = UIView(frame: CGRectMake(0, 0, 50.0, 50.0))
let rectangle = UIView(frame: CGRectMake(0, 0, 50.0, 50.0))

containerView.addSubview(circle)
containerView.addSubview(rectangle)

circle.center = containerView.center
circle.layer.cornerRadius = 25.0
circle.backgroundColor = [#Color(colorLiteralRed: 1, green: 0.2126724069189567, blue: 0.8447192364441408, alpha: 1)#]

rectangle.center = containerView.center
rectangle.layer.cornerRadius = 5.0
rectangle.backgroundColor = [#Color(colorLiteralRed: 0.2434146727967332, green: 0.5452465497627277, blue: 1, alpha: 1)#]

let duration = 2.0
let delay = 0.0
let options: UIViewAnimationOptions = [.Repeat, .CurveEaseInOut, .Autoreverse]

let animations: () -> Void = {
    let color = [#Color(colorLiteralRed: 1, green: 0.1538507638473798, blue: 0.1736739791556865, alpha: 1)#]
    let scaleTransform = CGAffineTransformMakeScale(5.0, 5.0)
    let rotationTransform = CGAffineTransformMakeRotation(3.14)
    
    circle.backgroundColor = color
    circle.transform = scaleTransform
    rectangle.transform = rotationTransform
}

UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations, completion: nil)

XCPlaygroundPage.currentPage.liveView = containerView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
