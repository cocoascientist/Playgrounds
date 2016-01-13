import Foundation
//import XCPlayground

func runAsyncTaskInGroup(group: dispatch_group_t) -> Void {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let session = NSURLSession(configuration: configuration)
    let url = NSURL(string: "http://www.apple.com")
    
    dispatch_group_enter(group)
    
    let task = session.dataTaskWithURL(url!) { (_, _, _) in
        print("finished")
        dispatch_group_leave(group)
    }
    
    task.resume()
}

let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
let group = dispatch_group_create()

runAsyncTaskInGroup(group)
runAsyncTaskInGroup(group)

dispatch_group_notify(group, queue) { () -> Void in
    print("all done!")
}

//XCPSetExecutionShouldContinueIndefinitely()
