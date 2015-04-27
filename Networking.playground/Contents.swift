//: # Networking with `NSURLSession`
//:
//: Let's use `NSURLSession` to make some simple `GET` requests.

//: `NSURLSession` is part of Foundation.

import Foundation

//: We need `XCPlayground` to allow to playground execution of asynchronous tasks. Without it, the playground would make the network request and terminate before the request returned. By calling `XCPSetExecutionShouldContinueIndefinitely()`, we specify the playground should continue running so the request can be received.

import XCPlayground

XCPSetExecutionShouldContinueIndefinitely()

//: Next we begin creating some types for handling responses, starting with a generic `Box` type. With enums, associated values need a fixed sized. This means we cannot have generic parameters, which have an unknown size. To get around this, can create a `Box` class that wraps a generic value.

public class Box<T> {
    public let unbox: T
    public init(_ value: T) {
        self.unbox = value
    }
}

//: Define a Result enum to represent the result of some operation. Here we use the `Box` type to wrap a successful result.

public enum Result<T> {
    case Success(Box<T>)
    case Failure(Reason)
}

//: When it comes to modeling a result failure, we use a `Reason` type. The reasons for failure can be adapted for different use cases, with a `.Other` error case returning a general `NSError`.

public enum Reason {
    case BadResponse
    case NoData
    case NoSuccessStatusCode(statusCode: Int)
    case Other(NSError)
}

//: Define the OpenWeather API

enum OpenWeatherMap {
    case CityID(Int)
}

extension OpenWeatherMap {
    var path: String {
        let baseURL = "http://api.openweathermap.org/data/2.5"
        
        switch self {
        case .CityID(let id):
            return "\(baseURL)/weather?id=\(id)"
        }
    }
}

extension OpenWeatherMap {
    func request() -> NSURLRequest {
        let url = NSURL(string: self.path)
        return NSURLRequest(URL: url!)
    }
}

let seattleID = 5809844

//: Define a `Weather` model object and JSON transformation

struct Weather {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Weather {
    static func weatherFromJSON(json: JSON) -> Weather? {
        if let name = json["name"] as? String {
            let weather = Weather(name: name)
            return weather
        }
        
        return nil
    }
}

//: For handling JSON, define an extension on `NSData` and some typealiases.

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

//: define the Network Task Builder

typealias TaskResultHandler = (result: Result<NSData>) -> Void

struct NetworkTaskBuilder {
    
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
    
    static func task(request:NSURLRequest, result: TaskResultHandler) -> NSURLSessionTask {
        
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

//: Define helper function for to create weather object from JSON response

func createWeatherFromJSON(json: JSON) {
    let jsonString = json
    if let weather = Weather.weatherFromJSON(json) {
        println("created weather: \(weather.name)")
    }
}

//: Create a request, response handler, and make the network request.

let request = OpenWeatherMap.CityID(seattleID).request()

let task = NetworkTaskBuilder.task(request, result: { (result) -> Void in
    switch result {
        case .Success(let data):
            let jsonResult = data.unbox.toJSON()
            switch jsonResult {
                case .Success(let json):
                    createWeatherFromJSON(json.unbox)
                case .Failure(let reason):
                    println("failure found!")
            }
        case .Failure(let reason):
            println("error!")
    }
})

task.resume()
