//: # Networking with `NSURLSession`, Part 2

import Foundation
import XCPlayground

XCPSetExecutionShouldContinueIndefinitely()

enum RequestBin {
    case GET
    case DELETE
    case PUT(NSData)
    case POST(NSData)
    
    case Search(String)
    case Authenticate(String, String)
}

extension RequestBin {
    var path: String {
        let baseURL = "http://requestb.in/1jk2vpl1"
        
        switch self {
        default:
            return baseURL
        }
    }
}

typealias QueryParameters = [String: String]

extension RequestBin {
    
    func request() -> NSURLRequest {
        switch self {
        case .GET:
            let url = NSURL(string: self.path)
            return NSURLRequest(URL: url!)
        case .PUT(let data):
            let url = NSURL(string: self.path)
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "PUT"
            request.HTTPBody = data
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
            
        case .POST(let data):
            let url = NSURL(string: self.path)
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.HTTPBody = data
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            return request
        case .DELETE:
            let url = NSURL(string: self.path)
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "DELETE"
            return request
            
        case .Search(let string):
            let path = self.path + "?" + queryStringWithParameters(["search": string])
            let url = NSURL(string: path)
            
            return NSURLRequest(URL: url!)
            
        case .Authenticate(let username, let password):
            let token = "\(username):\(password)"
            let data = token.dataUsingEncoding(NSUTF8StringEncoding)
            let auth = "Basic \(data!.base64EncodedDataWithOptions(nil))"
            
            let url = NSURL(string: self.path)
            let request = NSMutableURLRequest(URL: url!)
            
            request.addValue(auth, forHTTPHeaderField: "Authorization")
            
            return request
        default:
            return NSURLRequest()
        }
    }
    
    private func queryStringWithParameters(parameters: QueryParameters) -> String {
        var query = ""
        for p in parameters {
            if query != "" {
                query = query + "&"
            }
            query = query + p.0 + "=" + p.1
        }
        
        return query
    }
}

func stringResult(result: Result<NSData>) -> String {
    switch result {
    case .Success(let data):
        let string = NSString(data: data.unbox, encoding: NSUTF8StringEncoding)
        return "success \(string!)"
    case .Failure(let reason):
        return "failure"
    }
}

NetworkTaskBuilder.task(RequestBin.GET.request(), result: { (result) -> Void in
    println("GET result: \(stringResult(result))")
}).resume()

NetworkTaskBuilder.task(RequestBin.DELETE.request(), result: { (result) -> Void in
    println("DELETE result: \(stringResult(result))")
}).resume()

let json = ["name": "Fred", "age": 21]
let data = NSJSONSerialization.dataWithJSONObject(json, options: nil, error: nil)

NetworkTaskBuilder.task(RequestBin.PUT(data!).request(), result: { (result) -> Void in
    println("PUT result: \(stringResult(result))")
}).resume()

NetworkTaskBuilder.task(RequestBin.POST(data!).request(), result: { (result) -> Void in
    println("POST result: \(stringResult(result))")
}).resume()

NetworkTaskBuilder.task(RequestBin.Search("hammer").request(), result: { (result) -> Void in
    println("Search result: \(stringResult(result))")
}).resume()

NetworkTaskBuilder.task(RequestBin.Authenticate("jack", "$ecr3t").request(), result: { (result) -> Void in
    println("Search result: \(stringResult(result))")
}).resume()
