//: #Interfacing with CoreLocation


import Cocoa
import CoreLocation
import XCPlayground

let tracker = LocationTracker()

tracker.addLocationChangeObserver { (result) -> () in
    switch result {
    case .Success(let location):
        let coordinate = location.physical.coordinate
        let locationString = "\(coordinate.latitude), \(coordinate.longitude)"
        println("location: \(locationString)")
    case .Failure(let reason):
        println("error")
    }
}

XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)
