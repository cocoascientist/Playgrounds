//: # Futures
//:
//: Explores an implemention of the `Future` type based on the presentation by Javier Soto titled [Back to the Futures](https://realm.io/news/swift-summit-javier-soto-futures/).

import Foundation
import XCPlayground

//: First define a `Result` type.

enum Result<T> {
    case Success(T)
    case Failure(ErrorType)
}

//: Then define the `Future` type. A `struct` is used because...

struct Future<T> {
    typealias ResultType = Result<T>
    typealias Completion = ResultType -> ()
    typealias AsyncOperation = Completion -> ()
    
    private let operation: AsyncOperation
    
    init(result: ResultType) {
        self.init(operation: { completion in
            completion(result)
        })
    }
    init(operation: AsyncOperation) {
        self.operation = operation
    }
    
    func start(completion: Completion) {
        self.operation() { result in
            completion(result)
        }
    }
}

//: Afterwards, define some additional types for working with `Result` and `Future`.

typealias TaskResult = Result<NSData>
typealias TaskFuture = Future<NSData>
typealias TaskCompletion = (NSData?, NSURLResponse?, NSError?) -> Void

enum TaskError: ErrorType {
    case Offline
    case NoData
    case BadResponse
    case BadStatusCode(Int)
    case Other(NSError)
}

//: Build a simple `NetworkController` for returning `TaskFuture` types associated with some `NSURLRequest`.

struct NetworkController {

    private let session = NSURLSession.sharedSession()

    func dataForRequest(request: NSURLRequest) -> TaskFuture {
        
        let future: TaskFuture = Future() { completion in
            
            let fulfill: (result: TaskResult) -> Void = {(taskResult) in
                switch taskResult {
                case .Success(let data):
                    completion(.Success(data))
                case .Failure(let error):
                    completion(.Failure(error))
                }
            }
            
            let completion: TaskCompletion = { (data, response, err) in
                guard let data = data else {
                    guard let err = err else {
                        return fulfill(result: .Failure(TaskError.NoData))
                    }
                    
                    return fulfill(result: .Failure(TaskError.Other(err)))
                }
                
                guard let response = response as? NSHTTPURLResponse else {
                    return fulfill(result: .Failure(TaskError.BadResponse))
                }
                
                switch response.statusCode {
                case 200...204:
                    fulfill(result: .Success(data))
                default:
                    fulfill(result: .Failure(TaskError.BadStatusCode(response.statusCode)))
                }
            }
            
            let task = self.session.dataTaskWithRequest(request, completionHandler: completion)
            
            task.resume()
        }
        
        return future
    }
}

//: Use the controller to make a simple network request. Log the bytes received or an error.

let controller = NetworkController()
let request = NSURLRequest(URL: NSURL(string: "https://www.apple.com")!)

let future = controller.dataForRequest(request)

future.start { (result) -> () in
    switch result {
    case .Success(let data):
        print("success, \(data.length) bytes received.")
    case .Failure(let error):
        print("failure: \(error)")
    }
}

//: Run the playground forever.

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
