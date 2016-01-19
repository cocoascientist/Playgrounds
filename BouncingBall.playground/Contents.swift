//: # Bouncing Ball Animation
//:
//: This playground examines how to build an bouncing animation
//:
//: The examples are based on [this stackoverflow post](http://stackoverflow.com/a/25931981) by [@BCBlanka](http://stackoverflow.com/users/2768282/bcblanka).

import UIKit
import XCPlayground

//: Define three animations

let translation = CAKeyframeAnimation(keyPath: "transform.translation.y")
translation.values = [-600, 20, 0]
translation.keyTimes = [0.0, 0.85, 1.0]
translation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
translation.autoreverses = true
translation.duration = 1.0
translation.repeatCount = Float.infinity

let scaleX = CAKeyframeAnimation(keyPath: "transform.scale.x")
scaleX.values = [0.75, 0.75, 1.0]
scaleX.keyTimes = [0.0, 0.85, 1.0]
scaleX.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
scaleX.autoreverses = true
scaleX.duration = 1.0
scaleX.repeatCount = Float.infinity

let scaleY = CAKeyframeAnimation(keyPath: "transform.scale.y")
scaleY.values = [0.75, 1.0, 0.85]
scaleY.keyTimes = [0.1, 0.5, 1.0]
scaleY.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
scaleY.autoreverses = true
scaleY.duration = 1.0
scaleY.repeatCount = Float.infinity

//: Create container view and ball view

let containerView = UIView(frame: CGRectMake(0, 0, 150.0, 760.0))
let ballView = UIView(frame: CGRectMake(0, 0, 50, 50))

containerView.addSubview(ballView)

containerView.backgroundColor = UIColor.blackColor()
ballView.backgroundColor = UIColor.redColor()

ballView.center = CGPointMake(CGRectGetMidX(containerView.frame), CGRectGetMaxY(containerView.frame) - CGRectGetHeight(ballView.frame))
ballView.layer.cornerRadius = 25.0

ballView.layer.addAnimation(translation, forKey: "translation")
ballView.layer.addAnimation(scaleX, forKey: "scaleX")
ballView.layer.addAnimation(scaleY, forKey: "scaleY")

//: Mark the `containerView` as the `liveView` for the current playground page and `needsIndefiniteExecution` to `true.

XCPlaygroundPage.currentPage.liveView = containerView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
