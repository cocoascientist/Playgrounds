import Foundation

public class Box<T> {
    public let unbox: T
    public init(_ value: T) {
        self.unbox = value
    }
}

public enum Reason {
    case BadResponse
    case NoData
    case NoSuccessStatusCode(statusCode: Int)
    case Other(NSError)
}

public enum Result<T> {
    case Success(Box<T>)
    case Failure(Reason)
}

typealias JSON = [String: AnyObject]
typealias JSONResult = Result<JSON>

extension NSData {
    func toJSON() -> JSONResult {
        var error : NSError?
        if let jsonObject = NSJSONSerialization.JSONObjectWithData(self, options: nil, error: &error) as? JSON {
            return Result.Success(Box(jsonObject))
        }
        else if error != nil {
            return Result.Failure(Reason.Other(error!))
        }
        else {
            return Result.Failure(Reason.NoData)
        }
    }
}

public typealias TaskResultHandler = (result: Result<NSData>) -> Void

public struct NetworkTaskBuilder {
    
    private class SessionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
        func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust))
        }
        
        func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
            completionHandler(request)
        }
    }
    
    /**
    Creates an NSURLSessionTask for the request
    
    :param: request A reqeust object to return a task for
    :param: completion
    
    :returns: An NSURLSessionTask associated with the request
    */
    
    public static func task(request:NSURLRequest, result: TaskResultHandler) -> NSURLSessionTask {
        
        // handle the task completion job on the main thread
        let finished: TaskResultHandler = {(taskResult) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                result(result: taskResult)
            })
        }
        
        let sessionDelegate = SessionDelegate()
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: sessionDelegate, delegateQueue: NSOperationQueue.mainQueue())
        
        // return a basic NSURLSession for the request, with basic error handling
        let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
            if (err == nil && data != nil) {
                if let httpResponse = response as? NSHTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200...204:
                        finished(result: Result.Success(Box(data)))
                    default:
                        let reason = Reason.NoSuccessStatusCode(statusCode: httpResponse.statusCode)
                        finished(result: Result.Failure(reason))
                    }
                } else {
                    finished(result: Result.Failure(Reason.BadResponse))
                }
            }
            else if data == nil {
                finished(result: Result.Failure(Reason.NoData))
            }
            else {
                finished(result: Result.Failure(Reason.Other(err)))
            }
        })
        
        return task;
    }
}
