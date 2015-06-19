/*:
### PureJSON
PureJSON uses throw/catch error handling introduced in Swift 2.0. All of the JSON types are hidden behind (and derived from) the JSONAny class. The JSONAny class has all the methods for every type, but only the right ones are overridden in each subclass. This leaves the super class implementations to handle errors. All data is stored as Swift types and not NS types (why I named it PureJSON).
*/

import PureJSON

//: To create a JSON tree you use the json() functions or .json extensions. As well as jsonEmptyObject() and jsonEmptyArray() to create empty starting points.

var data = jsonEmptyObject()

do {
    try data.addToObject(jsonEmptyArray(), forKey: "rules")
    try data["rules"].appendArray("You do not talk about Fight Club".json) // one way to create a JSON string
    try data["rules"].appendArray(json("You do not talk about Cheeseburgers")) // another way to create a JSON string
    try data["rules"][1].setString("You do not talk about Fight Club") // just an extra example to change a value
    
    print(data)
    
    data = json([
        "rules" : json(
            ["You do not talk about Fight Club".json, // String using the type extension
            json("You do not talk about Fight Club")  // String using the creation functio
        ])
    ])
    
} catch {
    print(error)
}

//: For objects and arrays subscripts are used and for other types accessor methods are used. (Methods were use because they can throw, where computed properties can’t)

do {
    let name = try data["rules"][1].string() // assuming "name" is a String
    let nothing = try data["rules"][1].integer() // this is an error

} catch {
    print(error)
}


//var yts = try JSONParseNS.parseURL("https://yts.to/api/v2/list_movies.json")
//print(yts)
