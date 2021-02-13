/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Builder
 - - - - - - - - - -
 ![Builder Diagram](Builder_Diagram.png)
 
 The builder pattern allows complex objects to be created step-by-step instead of all-at-once via a large initializer.
 
 The builder pattern involves three parts:
 
 (1) The **product** is the complex object to be created.
 
 (2) The **builder** accepts inputs step-by-step and ultimately creates the product.
 
 (3) The **director** supplies the builder with step-by-step inputs and requests the builder create the product once everything has been provided.
 
 ## Code Example
 */
import Foundation

enum Meat: String {
    case beef
    case chicken
    case kitten
    case tofu
}

struct Sauces: OptionSet {
    public static let mayonnaise = Sauces(rawValue: 1 << 0)
    public static let mustard = Sauces(rawValue: 1 << 1)
    public static let ketchup = Sauces(rawValue: 1 << 2)
    public static let secret = Sauces(rawValue: 1 << 3)
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

struct Toppings: OptionSet {
    public static let cheese = Toppings(rawValue: 1 << 0)
    public static let lettuce = Toppings(rawValue: 1 << 1)
    public static let pickles = Toppings(rawValue: 1 << 2)
    public static let tomatoes = Toppings(rawValue: 1 << 3)
    
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

struct Hamburger {
    let meat: Meat
    let sauces: Sauces
    let toppings: Toppings
}

extension Hamburger: CustomStringConvertible {
    var description: String {
        meat.rawValue + " burger"
    }
}

// MARK: - Builder

enum HamburgerBuilderError: Error {
    case soldOut
}

class HamburgerBuilder {
    private var meat: Meat = .beef
    private var sauces: Sauces = []
    private var toppings: Toppings = []
    
    private var soldOutMeats: [Meat] = [.kitten]
    
    public func addSauce(_ sauce: Sauces) {
        sauces.insert(sauce)
    }
    
    public func removeSauce(_ sauce: Sauces) {
        sauces.remove(sauce)
    }
    
    public func addTopping(_ topping: Toppings) {
        toppings.insert(topping)
    }
    
    public func removeTopping(_ topping: Toppings) {
        toppings.remove(topping)
    }
    
    public func setMeat(_ meat: Meat) throws {
        guard !soldOutMeats.contains(meat) else {
            throw HamburgerBuilderError.soldOut
        }
        
        self.meat = meat
    }
    
    public func build() -> Hamburger {
        Hamburger(meat: meat, sauces: sauces, toppings: toppings)
    }
}

// MARK: - Director

class Employee {
    func createCombo1() throws -> Hamburger {
        let builder = HamburgerBuilder()
        try builder.setMeat(.beef)
        builder.addSauce(.secret)
        builder.addTopping([.lettuce, .tomatoes, .pickles])
        return builder.build()
    }
    public func createKittenSpecial() throws -> Hamburger {
        let builder = HamburgerBuilder()
        try builder.setMeat(.kitten)
        builder.addSauce(.mustard)
        builder.addTopping([.lettuce, .tomatoes])
        return builder.build()
    }
}

// MARK: - Usage

func tryConsume(_ burgerCreator: () throws -> Hamburger) {
    do {
       let burger = try burgerCreator()
        print("Om nom nom! Great \(burger).")
    }
    catch {
        print("Oops, there is nothing here because \(error).")
    }
}

let chef = Employee()
tryConsume(chef.createCombo1)
tryConsume(chef.createKittenSpecial)
