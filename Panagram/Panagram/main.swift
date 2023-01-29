//
//  main.swift
//  Panagram
//
//  Created by student on 2023-01-10.
//

import Foundation

//Enumerable object for ShipType
enum ShipType{
    case Submarine
    case AirCraft
    case TugBoat
}

//Declare a new class for Position having col and row as properties
class Position: Equatable, Hashable {
    var col: Int
    var row: Character
    //Initialize function for Position class
    //to set up the default value for row and col
    init() {
        self.row = "\u{0000}"
        self.col = 0
    }
    //Initialize function to set row and col
    init(row: Character, col: Int) {
        self.row = row
        self.col = col
    }
    //Method to compare 2 position
    static func == (p1: Position, p2: Position) -> Bool {
        return p1.col == p2.col && p1.row == p2.row
    }
    //Initial hashable for the Position object
    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(col)
    }
}

//Function to get a position of a character from a string using the distance function
func getPos(charList: String, row: Character) -> Int{
    let pos = charList.firstIndex(of: row)!
    return charList.distance(from: charList.startIndex, to: pos)
}

//Declare a new class for Ship having shipType, size, pos, type as properties
class Ship{
    var shipType: ShipType
    var size: Int
    var pos: [Position]
    var type: Character
    var dimension = "V"
    //Initialize function for the Ship class
    //to set up the size, default position and type for each ShipType
    init(shipType: ShipType) {
        self.shipType = shipType
        switch shipType{
            case .Submarine: size = 3
                             type = "\u{04E8}"
                             pos = [Position(), Position(), Position()]
            case .AirCraft: size = 4
                            type = "\u{0428}"
                            pos = [Position(), Position(), Position(), Position()]
            case .TugBoat: size = 2
                           type = "\u{04DC}"
                           pos = [Position(), Position()]
        }
    }
}

//Function to create a table for the game
func createTable() -> [String:[String]]{
    //Declare a horizonal and vertival array object to contain the title for each row and column
    let vertical = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    //Declare table object as 2 dimension array of String
    var table = [String:[String]]()
    //Loop to create each element for the table
    //Setup the title for each row and column
    //The content for each row will be appended "*"
    for i in 0...9{
        var temp = [String]()
        for _ in 0...9{
            temp.append("*")
        }
        table[vertical[i]] = temp
    }
    return table
}

//Function to print the table  - 2 dimension array
func printTable (table: [String:[String]]){
    let vertical = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    //Print the number of column to the screen
    for i in 0...10{
        print(i, terminator: "\t")
    }
    print("")
    //Print each element of the table to the screen
    for letter in vertical{
        let elements = table[letter]
        print(letter, terminator: "\t")
        elements!.forEach{
            element in print(element, terminator: "\t")
        }
        print("")
    }
}

//Function to create a number of a particular ship
func createShips(shipType: ShipType, shipNo: Int) -> [Ship]{
    //Array to add new ship
    var shipList: [Ship] = []
    //If number of ship is greater than 0, then create ship and add array
    if(shipNo > 0) {
        for _ in 1...shipNo {
            let newShip = Ship(shipType: shipType)
            shipList.append(newShip)
        }
    }
    return shipList
}

//Initial list of ship for the game with specific number of ship for each type
func initializeShips(subMarineNo: Int, airCraftNo: Int, tugBoatNo: Int) -> [Ship] {
    let subMarines = createShips(shipType: .Submarine, shipNo: subMarineNo)
    let airCrafts = createShips(shipType: .AirCraft, shipNo: airCraftNo)
    let tugBoats = createShips(shipType: .TugBoat, shipNo: tugBoatNo)
    let listShip = subMarines + airCrafts + tugBoats
    return listShip
}

//Function to set the position ships randomly
func setRandomPosition(shipList: inout [Ship]) -> [Position]{
    var count = 0
    //Arrays contains all position of ship in the table
    var allPos: [Position] = []
    //Charlist contain the title of each row
    let charList = "ABCDEFGHIJ"
    while(count < shipList.count){
        //Randomly generate interger for col and a character from the charlist for row
        var row = charList.randomElement()!
        var col = Int.random(in: 1...10)
        //Get the ship at count position
        let ship = shipList[count]
        //The ship at even position will have horizontal dimension
        //The ship at odd position will have vertical dimension
        if(count % 2 == 0){
            ship.dimension = "H"
            //if the horizonal position left are not enough for the whole size of ship
            //set the position of ship backward from col position
            //Otherwise, set them forwarding
            if(col + (ship.size - 1) > 10){
                for i in 1...ship.size{
                    ship.pos[i-1].row = row
                    ship.pos[i-1].col = col
                    col-=1
                }
            } else {
                for i in 1...ship.size{
                    ship.pos[i-1].row = row
                    ship.pos[i-1].col = col
                    col+=1
                }
            }
        } else {
            //Get ascii value of character of the row
            let rowPos = Int(row.asciiValue!)
            //if the vertical position left are not enough for the whole size of ship which exceeds J letter
            //set the position of ship backward from row position
            //Otherwise, set them forwarding
            if(rowPos + ship.size > 74){
                for i in 1...ship.size{
                    ship.pos[i-1].row = row
                    ship.pos[i-1].col = col
                    let rowInAscii = row.asciiValue!
                    row = Character(UnicodeScalar(rowInAscii - 1))
                }
            } else {
                for i in 1...ship.size{
                    ship.pos[i-1].row = row
                    ship.pos[i-1].col = col
                    let rowInAscii = row.asciiValue!
                    row = Character(UnicodeScalar(rowInAscii + 1))
                }
            }
        }
        allPos+=ship.pos
        count+=1
    }
    
    //Print the position of each ship to the console
    for ship in shipList{
        for pos in ship.pos{
            print("It is \(pos.row) and \(pos.col)")
        }
    }
    return allPos
}

//Function will handle all collision of the ships
func handlePosCollision(shipList: inout [Ship], allPos: inout [Position]){
    //Examine each ship in the list
    for ship in shipList{
        var isCollision = true
        //While there is any collision in the position of a ship
        //Do the following action
        while(isCollision){
            //Get all the duplicate position in the all position array
            let duplicatePos = Dictionary(grouping: allPos, by: {$0}).filter{$1.count > 1}.keys
            //Set the collision to false
            isCollision = false
            //Loop through all posistion of the ship on the table
            //If there is any position in the colision position list
            //Set the collision to true and break the loop
            for pos in ship.pos{
                if(duplicatePos.contains(where: {$0 == pos})){
                    isCollision = true
                    break
                }
            }
            //If there is any collision
            //Examine the position of the ship
            if(isCollision){
                //If the ship position is horizontal
                //Change all the position of the ship to the other row from A to J based on the ascii value of the character
                if(ship.dimension == "H"){
                    for pos in ship.pos{
                        let nextRow = Character(UnicodeScalar((pos.row.asciiValue!+1)%(65+9)))
                        pos.row = nextRow
                    }
                } else {
                //If the ship position is vertical
                //Change all the position of the ship to the other column from 1 to 10.
                    for pos in ship.pos{
                        var nextCol = pos.col + 1
                        if(nextCol != 10){
                            nextCol = nextCol % 10
                        }
                        pos.col = nextCol
                    }
                }
            }
        }
    }
    print("Handled collision")
    //Print the position of each ship to the console
    for ship in shipList{
        for pos in ship.pos{
            print("It is \(pos.row) and \(pos.col)")
        }
    }
}

//Function to modify the table
func modifiedTable (position: Position, shipList: inout [Ship], table: inout [String:[String]], count: inout Int){
    //Boolean to determine if we found the ship or not
    var IsFoundShip = false
    //Variable for the found Ship
    var foundShip: Ship?
    //Loop in the ship list and determine if we found the ship or not
    //if we found, set boolean to true and assign the found ship to foundShip variable
    let posCheck = Position(row: position.row, col: position.col)
    for ship in shipList{
        if(ship.pos.contains(where: {$0 == posCheck})){
                IsFoundShip = true
                foundShip = ship
        }
    }
    //If we found ship at a specific position,
    //Loop in the table and replace "*" at that position with the ship's symbol
    //Count the number of found ship
    //If we could not found ship, replace "*" with the blank space
    if(IsFoundShip){
        let type = foundShip!.type
        table[String(position.row)]![position.col-1] = String(type)
        foundShip!.size-=1
        if(foundShip?.size == 0){
            print("You sunk a \(foundShip!.shipType)")
        } else {
            print("Good job!")
        }
        count+=1
    } else {
        table[String(position.row)]![position.col-1] = ""
    }
}

func handleInput() -> Position{
    let charList = "ABCDEFGHIJ"
    //Print out to require row input from user
    //Then uppercase all the letter
    //while the input has more than 1 letter or the input has 1 letter but
    //not in the char list from A to J, print out error and require new input
    //When the input is right, convert the input to character type by using .first function
    print("Please enter row:")
    var rawInput = readLine()!.uppercased()
    while(rawInput.count != 1 || !charList.contains(rawInput)){
        print("Please a valid character for row is a single character from A to J")
        print("Please enter row:")
        rawInput = readLine()!.uppercased()
    }
    let rowInput = rawInput.first!
    //Print out to require column input from user
    //Then convert the input to integer, if the input is not a number assign it as 0
    //while the input is larger than 10 or less than 1, print out error and require new input
    print("Please enter the column")
    var colInput = Int(readLine()!) ?? 0
    while(colInput > 10 || colInput < 1){
        print("Invalid column - use 1 to 10")
        print("Please enter the column")
        colInput = Int(readLine()!) ?? 0
    }
    return Position(row: rowInput, col: colInput)
}

//Function to recursively play the game
func playGame(subMarineNo: Int, airCraftNo: Int, tugBoatNo: Int){
    //Initialize ship list, charlist, table for the game, count number of ship, and guessing time
    var shipList = initializeShips(subMarineNo: subMarineNo, airCraftNo: airCraftNo, tugBoatNo: tugBoatNo)
    var allPos = setRandomPosition(shipList: &shipList)
    handlePosCollision(shipList: &shipList, allPos: &allPos)
    var gametable = createTable()
    var countShip = 0
    var guessTimes = 0
    //Print the table in the console
    printTable(table: gametable)
    //Loop to get the guessing input from the user
    while(guessTimes <= 100){
        let checkPos = handleInput()
        //Call modifiedTable function with row input and col input
        modifiedTable(position: checkPos, shipList: &shipList, table: &gametable, count: &countShip)
        //Print out new table
        printTable(table: gametable)
        //If user found all the ships, print out message and break the loop
        if(countShip == allPos.count){
            print("Consgratulation! You got all the ships")
            break
        }
        //Counting the guessing time
        guessTimes+=1
    }
    //Message to ask if user want to play again or not
    print("Would you like to play again? Yes/No")
    //Read the answer and transform to lowercase
    let answer = readLine()!.lowercased()
    //If answer is yes, recursively call the playGame function
    if(answer == "yes"){
        playGame(subMarineNo: subMarineNo, airCraftNo: airCraftNo, tugBoatNo: tugBoatNo)
    }
}
//Run the game
playGame(subMarineNo: 1, airCraftNo: 1, tugBoatNo: 3)
