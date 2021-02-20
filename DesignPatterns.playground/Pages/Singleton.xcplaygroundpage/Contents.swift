/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Singleton
 - - - - - - - - - -
 ![Singleton Diagram](Singleton_Diagram.png)
 
 The singleton pattern restricts a class to have only _one_ instance.
 
 The "singleton plus" pattern is also common, which provides a "shared" singleton instance, but it also allows other instances to be created too.
 
 ## Code Example
 */
class Singleton {
    static var shared = Singleton()
    private init() { }
}

let s = Singleton.shared
// Error:
// let s2 = Singleton()

class SingletonPlus {
    static var shared = SingletonPlus()
    init() { }
}

let sp = SingletonPlus.shared
// Valid
// Used for testing
let sp2 = SingletonPlus()
