//: Futures

import Foundation
import XCPlayground

enum Result<T> {
    case Success(T)
    case Failure(ErrorType)
}

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

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
