import UIKit
import XCPlayground

func animate1(view: UIView) -> Void {
    let duration = 2.0
    let delay = 0.0
    let options: UIViewAnimationOptions = [.Repeat, .CurveEaseInOut, .Autoreverse]
    
    let animations: () -> Void = {
        view.alpha = 0.0
    }
    
    UIView.animateWithDuration(duration, delay: delay, options: options, animations: animations, completion: nil)
}

func animate2(view: UIView) -> Void {
    let fade = CABasicAnimation(keyPath: "opacity")
    fade.fromValue = 1.0
    fade.toValue = 0.0
    fade.duration = 2.0
    fade.autoreverses = true
    fade.repeatCount = Float.infinity
    fade.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    view.layer.addAnimation(fade, forKey: "fade")
}

let containerView = UIView(frame: CGRectMake(0, 0, 200.0, 200.0))
let circle = UIView(frame: CGRectMake(0, 0, 50.0, 50.0))
let rectangle = UIView(frame: CGRectMake(0, 0, 50.0, 50.0))

containerView.addSubview(rectangle)

rectangle.center = containerView.center
rectangle.backgroundColor = [#Color(colorLiteralRed: 0.2434146727967332, green: 0.5452465497627277, blue: 1, alpha: 1)#]

animate2(rectangle)

XCPlaygroundPage.currentPage.liveView = containerView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
