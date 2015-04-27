// http://five.agency/solving-the-binding-problem-with-swift/

class Dynamic<T> {
    var value: T {
        didSet {
            // inform parties about change
            
            for bondBox in bonds {
                bondBox.bond?.listener(value)
            }
        }
    }
    
    var bonds: [BondBox<T>] = []
    
    init(_ value: T) {
        self.value = value
    }
}

public class Bond<T> {
    public typealias Listener = T -> Void
    
    var listener: Listener
    
    init(_ listener: Listener) {
        self.listener = listener
    }
    
    func bind(dynamic: Dynamic<T>) {
        // bind to the dynamic
        dynamic.bonds.append(BondBox(self))
    }
}

class BondBox<T> {
    weak var bond: Bond<T>?
    
    init(_ bond: Bond<T>) {
        self.bond = bond
    }
}

//

var name: Dynamic<String>? = Dynamic("")

let observer = { (name: String) -> Void in
    println("name is now \(name)")
}

let nameBond = Bond(observer)
nameBond.bind(name!)

name?.value = "Robert"
name?.value = "Mary"
name?.value = "Martha"
