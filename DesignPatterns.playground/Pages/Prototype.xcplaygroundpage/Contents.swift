/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Prototype
 - - - - - - - - - -
 ![Prototype Diagram](Prototype_Diagram.png)
 
 The prototype pattern is a creational pattern that allows an object to copy itself. It involves two types:
 
 1. A **copying** protocol declares copy methods.
 
 2. A **prototype** is a class that conforms to the copying protocol.
 
 ## Code Example
 */

// MARK: - Copying

protocol Copying: class {
    init(_ prototype: Self)
}

extension Copying {
    func copy() -> Self {
        type(of: self).init(self)
    }
}

// MARK: - Prototype

class Monser: Copying {
    var health: Int
    var level: Int
    
    init(health: Int, level: Int) {
        self.health = health
        self.level = level
    }
    
    required convenience init(_ prototype: Monser) {
        self.init(health: prototype.health, level: prototype.level)
    }
}

class EyeballMonster: Monser {
    var redness = 0
    
    init(health: Int, level: Int, redness: Int) {
        self.redness = redness
        super.init(health: health, level: level)
    }
    
    @available(*, unavailable, message: "Call copy() instead")
    required convenience init(_ prototype: Monser) {
        let eyeball = prototype as! EyeballMonster
        self.init(health: eyeball.health,
                  level: eyeball.level,
                  redness: eyeball.redness)
    }
}

// MARK: - Usage

let monster = Monser(health: 700, level: 37)
let newMonster = monster.copy()
print("Watch out! That monster's level is \(newMonster.level)!")

let eyeball = EyeballMonster(health: 3002,
                             level: 60,
                             redness: 999)
let newEyeball = eyeball.copy()

// MARK - Another Example

enum Direction {
    case north, south, east, west
}

protocol MapSite {
    func enter()
}

class Room: MapSite, Copying {
    private var mapSides: [Direction: MapSite] = [:]
    private var roomNo: Int = 0
    
    init() { }
    
    required convenience init(_ prototype: Room) {
        self.init(prototype.roomNo,
                  mapSides: prototype.mapSides)
    }
    
    init(_ roomNo: Int, mapSides: [Direction: MapSite] = [:]) {
        self.roomNo = roomNo
        self.mapSides = mapSides
    }
    
    func getSide(for direction: Direction) -> MapSite? {
        mapSides[direction]
    }
    
    func setSide(for direction: Direction, side: MapSite) {
        mapSides[direction] = side
    }
    
    func setRoomNo(_ no: Int) {
        roomNo = no
    }
    
    func enter() { }
}

class Wall: MapSite, Copying {
    init() { }
    required init(_ prototype: Wall) { }
    
    func enter() { }
}

class BombedWall: Wall {
    private var bomb = false
    
    init(bomb: Bool) {
        self.bomb = bomb
        super.init()
    }
    
    required convenience init(_ prototype: Wall) {
        let bombed = prototype as! BombedWall
        self.init(bomb: bombed.bomb)
    }
}

class Door: MapSite, Copying {
    private var firstRoom: Room
    private var secondRoom: Room
    
    init() {
        firstRoom = Room()
        secondRoom = Room()
    }
    
    required convenience init(_ prototype: Door) {
        self.init(firstRoom: prototype.firstRoom,
                  secondRoom: prototype.secondRoom)
    }
    
    init(firstRoom: Room, secondRoom: Room) {
        self.firstRoom = firstRoom
        self.secondRoom = secondRoom
    }
    
    func enter() { }
    
    func addRooms(_ firstRoom: Room, _ secondRoom: Room) {
        self.firstRoom = firstRoom
        self.secondRoom = secondRoom
    }
}

class Maze: Copying {
    private var rooms: [Room] = []
    
    init() { }
    required init(_ prototype: Maze) {
        rooms = prototype.rooms
    }
    
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

class MazePrototypeFactory: MazeFactory {
    private var mazePrototype: Maze
    private var roomPrototype: Room
    private var wallPrototype: Wall
    private var doorPrototype: Door
    
    init(maze: Maze, room: Room, wall: Wall, door: Door) {
        mazePrototype = maze
        roomPrototype = room
        wallPrototype = wall
        doorPrototype = door
    }
    
    override func makeMaze() -> Maze {
        mazePrototype.copy()
    }
    
    override func makeWall() -> Wall {
        wallPrototype.copy()
    }
    
    override func makeRoom(with number: Int) -> Room {
        let room = roomPrototype.copy()
        room.setRoomNo(number)
        return room
    }
    
    override func makeDoor(firstRoom: Room, secondRoom: Room) -> Door {
        let door = doorPrototype.copy()
        door.addRooms(firstRoom, secondRoom)
        return door
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

let simpleFactory = MazePrototypeFactory(maze: Maze(),
                                         room: Room(),
                                         wall: Wall(),
                                         door: Door())
let game = MazeGame()
let maze = game.createMaze(factory: simpleFactory)

let bombedMazeFactory = MazePrototypeFactory(maze: Maze(),
                                             room: Room(),
                                             wall: BombedWall(bomb: true),
                                             door: Door())
let bombedMaze = game.createMaze(factory: bombedMazeFactory)
