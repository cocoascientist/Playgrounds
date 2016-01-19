//: # Easing Function and Animations
//:
//: This playground examines how to define easing functions to be utilized with key frame animations.
//:
//:
//: Timing functions are based on the code from the [AHEasing](https://github.com/warrenm/AHEasing)

import UIKit
import XCPlayground

//: First define a `typealias` for a timing function.

typealias TimingFunction = (time: Double) -> Double

//: Create extension on `CAKeyframeAnimation`.

extension CAKeyframeAnimation {
    
    class func animationWithKeyPath(path: String, from: Double, to: Double, timing: TimingFunction) -> CAKeyframeAnimation {
        
        let steps = 100
        let timeStep = 1.0 / Double(steps - 1)
        let values = (0...steps).map { (step: Int) -> Double in
            let time = (0.0 + timeStep) * Double(step)
            return from + timing(time: time) * (to - from)
        }
        
        let animation = CAKeyframeAnimation(keyPath: path)
        animation.calculationMode = kCAAnimationLinear
        animation.values = values
        
        return animation
    }
}

//: Define timing functions

let Linear: TimingFunction = { return $0 }
let SineEaseInOut: TimingFunction = { return 0.5 * (1 - cos($0 * M_PI)) }
let ExponentialEaseOut: TimingFunction = { return ($0 == 1.0) ? $0 : 1 - pow(2, -10 * $0) }
let ElasticEaseOut: TimingFunction = { return sin(-13 * M_PI_2 * ($0 + 1)) * pow(2, -10 * $0) + 1 }

let QuarticEaseInOut: TimingFunction = { (time p: Double) -> Double in
    if (p < 0.5) {
        return 8 * p * p * p * p
    } else {
        let f = (p - 1)
        return -8 * f * f * f * f + 1
    }
}

//: Create animations

let position = CAKeyframeAnimation.animationWithKeyPath("position.y", from: 70.0, to: 700.0, timing: SineEaseInOut)
position.autoreverses = true
position.duration = 1.0
position.repeatCount = Float.infinity

//: Create UI

let containerView = UIView(frame: CGRectMake(0, 0, 150.0, 760.0))
let ballView = UIView(frame: CGRectMake(0, 0, 50, 50))

containerView.addSubview(ballView)

containerView.backgroundColor = UIColor.blackColor()
ballView.backgroundColor = UIColor.redColor()

ballView.center = CGPointMake(CGRectGetMidX(containerView.frame), CGRectGetMaxY(containerView.frame) - CGRectGetHeight(ballView.frame))
ballView.layer.cornerRadius = 25.0

ballView.layer.addAnimation(position, forKey: "position")

XCPlaygroundPage.currentPage.liveView = containerView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
