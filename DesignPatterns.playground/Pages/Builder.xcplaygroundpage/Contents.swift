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

// MARK: - Example

enum Direction {
    case north, south, east, west
}

protocol MapSite {
    func enter()
}

class Room: MapSite {
    private var mapSides: [Direction: MapSite] = [:]
    private(set) var roomNo: Int
    
    init(_ roomNo: Int) {
        self.roomNo = roomNo
    }
    
    func getSide(for direction: Direction) -> MapSite? {
        mapSides[direction]
    }
    
    func setSide(for direction: Direction, side: MapSite) {
        mapSides[direction] = side
    }
    
    func enter() { }
}

class Wall: MapSite {
    func enter() { }
}

class Door: MapSite {
    private var firstRoom: Room
    private var secondRoom: Room
    
    init(firstRoom: Room, secondRoom: Room) {
        self.firstRoom = firstRoom
        self.secondRoom = secondRoom
    }
    
    func enter() { }
}

class Maze {
    private var rooms: [Room] = []
    
    func addRoom(_ room: Room) {
        rooms.append(room)
    }
    
    func getRoom(with number: Int) -> Room? {
        rooms.first { $0.roomNo == number }
    }
}

// MARK: - Builder

protocol MazeBuilder {
    func buildMaze()
    func buildRoom(number: Int)
    func buildDoor(from firstRoomNo: Int, to secondRoomNo: Int)
    func getMaze() -> Maze
}

class StandartMazeBuilder: MazeBuilder {
    private var currentMaze: Maze?
    
    func buildMaze() {
        currentMaze = Maze()
    }
    
    func buildRoom(number: Int) {
        guard let currentMaze = currentMaze,
            currentMaze.getRoom(with: number) == nil else { return }
        
        let room = Room(number)
        currentMaze.addRoom(room)
        
        room.setSide(for: .north, side: Wall())
        room.setSide(for: .east, side: Wall())
        room.setSide(for: .west, side: Wall())
        room.setSide(for: .south, side: Wall())
    }
    
    func buildDoor(from firstRoomNo: Int, to secondRoomNo: Int) {
        guard let fromRoom = currentMaze?.getRoom(with: firstRoomNo),
              let toRoom = currentMaze?.getRoom(with: secondRoomNo) else { return }
        
        let door = Door(firstRoom: fromRoom, secondRoom: toRoom)
        
        fromRoom.setSide(for: commonWall(fromRoom, toRoom),
                         side: door)
        toRoom.setSide(for: commonWall(toRoom, fromRoom),
                       side: door)
    }
    
    func getMaze() -> Maze {
        currentMaze ?? Maze()
    }
    
    private func commonWall(_ first: Room, _ second: Room) -> Direction { .east }
}

class CountingMazeBuilder: MazeBuilder {
    private(set) var doors: Int = 0
    private(set) var rooms: Int = 0
    
    func buildMaze() { }
    
    func buildRoom(number: Int) {
        rooms += 1
    }
    
    func buildDoor(from firstRoomNo: Int, to secondRoomNo: Int) {
        doors += 1
    }
    
    func getMaze() -> Maze {
        Maze()
    }
    
    func getCounts() -> (rooms: Int, doors: Int) {
        (rooms, doors)
    }
}

class MazeGame {
    func createMaze(builder: MazeBuilder) -> Maze {
        builder.buildMaze()
        
        builder.buildRoom(number: 1)
        builder.buildRoom(number: 2)
        builder.buildDoor(from: 1, to: 2)
        
        return builder.getMaze()
    }
    
    func createComplexMaze(builder: MazeBuilder) -> Maze {
        builder.buildMaze()
        
        builder.buildRoom(number: 1)
        // ...
        builder.buildRoom(number: 1001)
        
        return builder.getMaze()
    }
}

// MARK: - Usage

let game = MazeGame()
let builder = StandartMazeBuilder()
let maze = game.createMaze(builder: builder)


let countBuilder = CountingMazeBuilder()
let _ = game.createMaze(builder: countBuilder)
let (roomsCount, doorsCount) = countBuilder.getCounts()
print("Maze has \(roomsCount) rooms and \(doorsCount) doors")
