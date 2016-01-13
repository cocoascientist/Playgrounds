//: # Multithreading with GCD

import Cocoa
import XCPlayground
//: First we define a function do perform some simulated work. In the real world, this could be parsing a complex JSON file, compressing a file to disk, or some other long running task.

func countTo(limit: Int) -> Int {
    var total = 0
    for _ in 1...limit {
        total += 1
    }
    return total
}

//: Next we grab a reference to a global dispatch queue for running tasks.

let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

//: A block is function that has no parmaters and returns nothing. In GCD terms, this is defined as the `dispatch_block_t` type. Blocks are typically declaring inline when a call to GCD is made.

let block: dispatch_block_t = { () -> Void in
    countTo(100)
    print("done with single block")
}

dispatch_async(queue, block)

//: Multiple tasks be arranged together in a group. This makes it possible to wait for the result of multiple asynchronous tasks.

let group = dispatch_group_create()

dispatch_group_enter(group)
dispatch_group_enter(group)

dispatch_async(queue, { () -> Void in
    countTo(10)
    print("finished first grouped task")
    dispatch_group_leave(group)
})

dispatch_async(queue, { () -> Void in
    countTo(20)
    print("finished second grouped task")
    dispatch_group_leave(group)
})

dispatch_group_notify(group, queue) { () -> Void in
    print("finished ALL grouped tasks")
}

//: Queues can have differnt priority levels.

let high = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
let low = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
let background = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

//: The playground needs to continue to run indefinitely. It doesn't matter if we put this statement at the top or bottom of the playground. I prefer it at the bottom.

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

