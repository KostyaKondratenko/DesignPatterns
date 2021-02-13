/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Factory
 - - - - - - - - - -
 ![Factory Diagram](Factory_Diagram.png)
 
 The factory pattern provides a way to create objects without exposing creation logic. It involves two types:
 
 1. The **factory** creates objects.
 2. The **products** are the objects that are created.
 
 ## Code Example
 */
import Foundation

// MARK: - Structs

struct JobApplicant {
    enum Status {
        case new, interview, hired, rejected
    }
    
    var name: String
    var emailAddress: String
    var status: Status
}

struct Email {
    var subject: String
    var message: String
    var recipientEmail: String
    var senderEmail: String
}

// MARK: - Factory

struct EmailFactory {
    let senderEmail: String
    
    func createEmail(to recipient: JobApplicant) -> Email {
        let subject: String
        let messageBody: String
        
        switch recipient.status {
        case .new:
            subject = "We Received Your Application"
            messageBody =
                "Thanks for applying for a job here! " +
                "You should hear from us in 17-42 business days."
        case .interview:
            subject = "We Want to Interview You"
            messageBody =
                "Thanks for your resume, \(recipient.name)! " +
                "Can you come in for an interview in 30 minutes?"
        case .hired:
            subject = "We Want to Hire You"
            messageBody =
                "Congratulations, \(recipient.name)! " +
                "We liked your code, and you smelled nice. " +
                "We want to offer you a position! Cha-ching! $$$"
        case .rejected:
            subject = "Thanks for Your Application"
            messageBody =
                "Thank you for applying, \(recipient.name)! " +
                "We have decided to move forward " +
                "with other candidates. " +
                "Please remember to wear pants next time!"
        }
        
        return Email(subject: subject,
                     message: messageBody,
                     recipientEmail: recipient.emailAddress,
                     senderEmail: senderEmail)
    }
}

// MARK: - Usage

var jackson = JobApplicant(name: "Jackson",
                           emailAddress: "jacksonadams@gmail.com",
                           status: .new)

let factory = EmailFactory(senderEmail: "hr@yourcompany.com")

// New
print(factory.createEmail(to: jackson), "\n")

// Interview
jackson.status = .interview
print(factory.createEmail(to: jackson), "\n")

// Hired
jackson.status = .hired
print(factory.createEmail(to: jackson), "\n")

// MARK: - Abstract Factory

enum Direction {
    case north, south, east, west
}

protocol MapSite {
    func enter()
}

class Room: MapSite {
    private var mapSides: [Direction: MapSite] = [:]
    private var roomNo: Int
    
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
}

// MARK: - Abstract Maze Factory

class MazeFactory {
    func makeMaze() -> Maze {
        Maze()
    }
    
    func makeWall() -> Wall {
        Wall()
    }
    
    func makeRoom(with number: Int) -> Room {
        Room(number)
    }
    
    func makeDoor(firstRoom: Room, secondRoom: Room) -> Door {
        Door(firstRoom: firstRoom, secondRoom: secondRoom)
    }
}

// MARK: - Enchanted Maze Factory

class Spell { }

class EnchantedRoom: Room {
    private var spell: Spell
    
    init(_ roomNo: Int, spell: Spell) {
        self.spell = spell
        super.init(roomNo)
    }
}

class DoorNeedingSpell: Door { }

class EnchantedMazeFactory: MazeFactory {
    override func makeRoom(with number: Int) -> Room {
        EnchantedRoom(number, spell: spellCast())
    }
    
    override func makeDoor(firstRoom: Room, secondRoom: Room) -> Door {
        DoorNeedingSpell(firstRoom: firstRoom, secondRoom: secondRoom)
    }
    
    private func spellCast() -> Spell {
        Spell()
    }
}

class MazeGame {
    func createMaze(factory: MazeFactory) -> Maze {
        let maze = factory.makeMaze()
        let firstRoom = factory.makeRoom(with: 1)
        let secondRoom = factory.makeRoom(with: 2)
        let door = factory.makeDoor(firstRoom: firstRoom, secondRoom: secondRoom)

        maze.addRoom(firstRoom)
        maze.addRoom(secondRoom)
        
        firstRoom.setSide(for: .north, side: factory.makeWall())
        firstRoom.setSide(for: .east, side: door)
        firstRoom.setSide(for: .south, side: factory.makeWall())
        firstRoom.setSide(for: .west, side: factory.makeWall())
        
        secondRoom.setSide(for: .north, side: factory.makeWall())
        secondRoom.setSide(for: .east, side: factory.makeWall())
        secondRoom.setSide(for: .south, side: factory.makeWall())
        secondRoom.setSide(for: .west, side: door)
        
        return maze
    }
}

// MARK: - Usage

let mazeFactory = MazeFactory()
let game = MazeGame()
let maze = game.createMaze(factory: mazeFactory)

let enchantFactory = EnchantedMazeFactory()
let enchantMaze = game.createMaze(factory: enchantFactory)





