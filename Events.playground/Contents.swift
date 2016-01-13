// http://blog.scottlogic.com/2015/02/05/swift-events.html

protocol Invocable: class {
    func invoke(data: Any)
}

protocol Disposable {
    func dispose()
}

public class Event<T> {
    public typealias Handler = T -> ()
    
    private var handlers: [Invocable] = []
    
    func addHandler<U: AnyObject>(target: U, handler: (U) -> Handler) -> Disposable {
        let bond = Bond(target: target, handler: handler, event: self)
        handlers.append(bond)
        return bond
    }
    
    func raise(data: T) {
        for handler in handlers {
            handler.invoke(data)
        }
    }
}

class Bond<T: AnyObject, U>: Invocable, Disposable {
    
    weak var target: T?
    let handler: T -> U -> ()
    let event: Event<U>
    
    init(target: T?, handler: T -> U -> (), event: Event<U>) {
        self.target = target
        self.handler = handler
        self.event = event
    }
    
    func invoke(data: Any) {
        if let t = target {
            handler(t)(data as! U)
        }
    }
    
    func dispose() {
        event.handlers = event.handlers.filter { $0 !== self }
    }
}

class SomeObserver {
    func someEventHandler(data: String) {
        let _ = "something"
        print(data)
    }
}

//

let observer = SomeObserver()
let event = Event<String>()

let handler = event.addHandler(observer, handler: SomeObserver.someEventHandler)

event.raise("Woot")
event.raise("Toot")

handler.dispose()

event.raise("Ferris?")
