//: # Networking
//:
//: Explore networking

import Foundation

//: Define a `Result` protocol and type.

protocol ResultType {
    typealias Value
    
    init(success: Value)
    init(failure: ErrorType)
}

public enum Result<T>: ResultType {
    case Success(T)
    case Failure(ErrorType)
    
    init(success value: T) {
        self = .Success(value)
    }
    
    init(failure error: ErrorType) {
        self = .Failure(error)
    }
}

//: Create a simple mechanism for handling JSON using Foundation APIs and returning a `Result`.

public enum JSONError: ErrorType {
    case BadJSON
    case NoJSON
}

typealias JSON = [String: AnyObject]
typealias JSONResult = Result<JSON>

extension NSData {
    func toJSON() -> JSONResult {
        do {
            let obj = try NSJSONSerialization.JSONObjectWithData(self, options: [])
            guard let json = obj as? JSON else { return .Failure(JSONError.NoJSON) }
            return .Success(json)
        }
        catch {
            return .Failure(JSONError.BadJSON)
        }
    }
}

func JSONResultFromData(data: NSData) -> JSONResult {
    return data.toJSON()
}

//: Create a Network Controller

public enum NetworkError: ErrorType {
    case BadResponse
    case NoData
    case BadStatusCode(statusCode: Int)
    case Other
}

public typealias TaskResult = (result: Result<NSData>) -> Void

public class NetworkController {
    
    public let configuration: NSURLSessionConfiguration
    private let session: NSURLSession
    
    public init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()) {
        self.configuration = configuration
        
        let delegate = SessionDelegate()
        let queue = NSOperationQueue.mainQueue()
        self.session = NSURLSession(configuration: configuration, delegate: delegate, delegateQueue: queue)
    }
    
    deinit {
        session.finishTasksAndInvalidate()
    }
    
    private class SessionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate {
        
        @objc func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
            completionHandler(.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!))
        }
        
        @objc func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
            completionHandler(request)
        }
    }
}

//: Create an function that accepts an `NSURLRequest` and returns an associated `TaskResult`.

extension NetworkController {
    
    /**
     Creates and starts an NSURLSessionTask for the request.
     
     - parameter request: A request object
     - parameter completion: Called when the task finishes.
     
     - returns: An NSURLSessionTask associated with the request
     */
    
    public func startRequest(request: NSURLRequest, result: TaskResult) {
        
        // handle the task completion job on the main thread
        let finished: TaskResult = {(taskResult) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                result(result: taskResult)
            })
        }
        
        // return a basic NSURLSession for the request, with basic error handling
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            guard let data = data else {
                guard let _ = err else {
                    return finished(result: .Failure(NetworkError.NoData))
                }
                
                return finished(result: .Failure(NetworkError.Other))
            }
            
            guard let response = response as? NSHTTPURLResponse else {
                return finished(result: .Failure(NetworkError.BadResponse))
            }
            
            switch response.statusCode {
            case 200...204:
                finished(result: .Success(data))
            default:
                let error = NetworkError.BadStatusCode(statusCode: response.statusCode)
                finished(result: .Failure(error))
            }
        })
        
        task.resume()
    }
}

//: Model the remote API using a protocol and enum.

protocol RemoteAPI {
    var path: String { get }
    var baseURL: String { get }
    
    func request() -> NSURLRequest
}

enum GitHubAPI {
    case Zen
}

extension GitHubAPI: RemoteAPI {
    var baseURL: String {
        return "https://api.github.com"
    }
    
    var path: String {
        switch self {
        case .Zen:
            return "\(baseURL)/zen"
        }
    }
    
    func request() -> NSURLRequest {
        let url = NSURL(string: self.path)
        return NSURLRequest(URL: url!)
    }
}

//: Use everything together.

let controller = NetworkController()
let request = GitHubAPI.Zen.request()

controller.startRequest(request) { (result) -> Void in
    switch result {
    case .Success(let data):
        let somethign = "test"
        print("success!")
    case .Failure(let reason):
        print("error!")
    }
}

