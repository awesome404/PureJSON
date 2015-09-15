/*:
### PureJSON
PureJSON uses throw/catch error handling introduced in Swift 2.0. All of the JSON types are hidden behind (and derived from) the JSONAny class. The JSONAny class has all the methods for every type, but only the right ones are overridden in each subclass. This leaves the super class implementations to handle errors. All data is stored as Swift types and not NS types (why I named it PureJSON).
*/

import PureJSON

//: To create a JSON tree you use the json() functions or .json extensions. As well as jsonEmptyObject() and jsonEmptyArray() to create empty starting points.

var data = JSONType.object() // create an empty Object

do {
    try data.updateObject(JSONType.array(), forKey: "rules") // Create an empty Array in the Object
    try data["rules"].appendArray("You do not talk about Fight Club") // Add a string to the Array in the Object
    try data["rules"].appendArray("You do not talk about Cheeseburgers") // Add another string to the Array in the Object
    try data["rules"].updateArray("You do not talk about Fight Club", atIndex: 1) // Change the value
    
    print(data)
    
    data = JSONType.object([
        "rules" :
            JSONType.array(["You do not talk about Fight Club".json, // String using the type extension
                "You do not talk about Fight Club"  // String using the creation functio
                ])
        ])
    
} catch {
    print(error)
}

//: For objects and arrays subscripts are used and for other types accessor methods are used. (Methods were use because they can throw, where computed properties can’t)

do {
    print(try data["rules"][1].string()) // assuming "name" is a String
    print(try data["rules"][1].number()) // this is an error
    
} catch {
    print(error)
}


do {
    var yts = try JSONParseNS.parseURL("https://yts.to/api/v2/list_movies.json")
    print(yts)

} catch {
    print(error)
}
