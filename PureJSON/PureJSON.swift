//
//  PureJSON.swift
//  PureJSON
//
//  Created by Adam Dann on 2015-06-09.
//  Copyright (c) 2015 Adam Dann. All rights reserved.
//

import Foundation

// - MARK: Creation Functions
// These creation functions hide the private subclasses of JSONAny as well as making the code that uses them more readable.

/// Create an empty JSON Object (Dictionary). This is used at a starting point for adding data.
public func jsonEmptyObject() -> JSONAny {
    return JSONObject()
}

/// Create an empty JSON Array. This is used at a starting point for adding data.
public func jsonEmptyArray() -> JSONAny {
    return JSONArray()
}

/// Create a JSON Object (Dictionary) initialized with "object".
public func json(object: [String:JSONAny]) -> JSONAny {
    return JSONObject(object)
}

/// Create a JSON Array initialized with "array".
public func json(array: [JSONAny]) -> JSONAny {
    return JSONArray(array)
}

/// Create a JSON String initialized with "string".
public func json(string: String) -> JSONAny {
    return JSONString(string)
}

/// Create a JSON Number initialized with "number".
public func json(integer: Int) -> JSONAny {
    return JSONNumber(integer)
}

/// Create a JSON Number initialized with "double".
public func json(double: Double) -> JSONAny {
    return JSONNumber(double)
}

/// Create a JSON Boolean initialized with "boolean".
public func json(boolean: Bool) -> JSONAny {
    return JSONBool(boolean)
}

/// Create a JSON Null.
public func json() -> JSONAny {
    return JSONNull()
}

// MARK: - Type Extensions
/// Extensions to some standard types.

extension String {
    public var json: JSONAny {
        return JSONString(self)
    }
}

extension Int {
    public var json: JSONAny {
        return JSONNumber(self)
    }
}

extension Double {
    public var json: JSONAny {
        return JSONNumber(self)
    }
}

extension Bool {
    public var json: JSONAny {
        return JSONBool(self)
    }
}

/// The basic types contained within JSON
public enum JSONType {
    case None
    case Object
    case Array
    case String
    case Number
    case Boolean
    case Null
}

/// Errors
// Errors that are thrown when accessing the JSON structure. See the extension below for the English descriptions.
public enum JSONError: ErrorType {
    case TypeError(expectedType: JSONType, actualType: JSONType) // thrown by get or set methods
    
    case NotObjectAt(key: String, actualType: JSONType) // thrown by subscripts
    case NotArrayAt(index: Int, actualType: JSONType) // thrown by subscripts

    case InvalidKey(key: String) // thrown by Object subscripts
    case InvalidIndex(index: Int) // thrown by Array subscripts
}

// MARK: -
/// Base class to all the JSON types
// The base class contains all the methods to access any/all types of JSON nodes. Only the methods that apply to any
//  specific type are overriden, the leftovers are not overriden and throw TypeErrors.

public class JSONAny: CustomStringConvertible {
    
    var _error: JSONError?
    
    // Nothing else should instantiate this class. Ever.
    private init(error: JSONError? = nil) {
        _error = error
    }
    
    /**
    - Parameter expectedType: The type that was expected (instead of self.type)
    - Returns: An error.
    */
    private func error(expectedType: JSONType) -> JSONError {
        guard _error != nil else { // this seems like an example of when not to use guard, but it's new, so...
            return .TypeError(expectedType: expectedType, actualType: type) // type is overriden
        }
        return _error!
    }
    
    // All subclasses should override this, I wish Swift had pure virtual functions classes, but I get where they are going with Protocols.
    /**
    - Returns: The type of the JSON item.
    */
    public var type: JSONType {
        return .None
    }
    
    // These just throw the stored error (from a subscript) or a TypeError for when they are not overriden.
    //  When they are overriden they don't throw anything.
    //  ... They're kind of an eyesore.
    
    // MARK: Object Override Stubs
    /**
    - Returns: A Dictoinary of type [String:JSONAny].
    - Throws: JSONError
    */
    public func object() throws -> [String:JSONAny]  {
        throw error(.Object)
    }

    /**
    - Parameter newItem: JSON item to add to the Dictionary.
    - Parameter forKey: The key in the Dictionary.
    - Returns: A Dictoinary of type [Sring:JSONAny].
    - Throws: JSONError
    */
    public func addToObject(newItem: JSONAny, forKey: String) throws -> JSONAny {
        throw error(.Object)
    }
    
    // MARK: Array Override Stubs
    /**
    - Returns: An Array of type [JSONAny].
    - Throws: JSONError
    */
    public func array() throws -> [JSONAny] {
        throw error(.Array)
    }
    
    /**
    - Returns: newItem for chaining.
    - Parameter newItem: Item to add to the Array.
    */
    public func appendArray(newItem: JSONAny) throws -> JSONAny {
        throw error(.Array)
    }
    
    // MARK: String Override Stubs
    /**
    - Returns: The String value of this JSON item.
    */
    public func string() throws -> String {
        throw error(.String)
    }
    
    public func setString(newValue: String) throws {
        throw error(.String)
    }
    
    // MARK: Number Override Stubs
    public func integer() throws -> Int {
        throw error(.Number)
    }
    
    public func setInteger(newValue: Int) throws {
        throw error(.Number)
    }
    
    public func double() throws -> Double {
        throw error(.Number)
    }
    
    public func setDouble(newValue: Double) throws {
        throw error(.Number)
    }
    
    // MARK: Boolean Override Stubs
    public func bool() throws -> Bool {
        throw error(.Boolean)
    }
    
    public func setBool(newValue: Bool) throws {
        throw error(.Boolean)
    }
    
    // MARK: Null Override Stub
    public func null() throws -> Int? {
        throw error(.Null)
    }

    // Subscripts
    // When not overriden they store an error which gets passed on to the final action
    //  which should be one of the overrides above
    
    public subscript(index: Int) -> JSONAny {
        return _error != nil ? self : JSONAny(error: .NotArrayAt(index: index, actualType: type))
    }
    
    public subscript(key: String) -> JSONAny {
        return _error != nil ? self : JSONAny(error: .NotObjectAt(key: key, actualType: type))
    }

    // MARK: CustomStringConvertible
    
    public var description: String {
        return _error != nil ? _error!.description : "\n"
    }
}

// MARK: -
// Object (Dictionary)

private class JSONObject: JSONAny {
    
    private var _object: [String:JSONAny]

    init(_ args: [String:JSONAny] = [:]) {
        _object = args
    }
    
    override var type: JSONType {
        return .Object
    }
    
    // MARK: Object Overrides
    
    override func object() throws -> [String:JSONAny] {
        return _object
    }

    override func addToObject(newItem: JSONAny, forKey: String) throws -> JSONAny {
        _object[forKey] = newItem
        return newItem
    }
    
    // Subscript

    override subscript(key: String) -> JSONAny {
        if let result = _object[key] {
            return result
        }
        //return JSONSubscriptError(error: .InvalidKey(key: key))
        return JSONAny(error: .InvalidKey(key: key))
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {
        var result = "{"
        var i = 0, count = _object.count
        for (key,value) in _object {
            result += "\"\(key.jsonEscape)\": \(value)"
            if ++i != count {
                result += ", "
            }
        }
        
        return result + "}"
    }
}

// MARK: -
// Array

private class JSONArray: JSONAny {
    
    private var _array: [JSONAny]
    
    init(_ args: [JSONAny] = []) {
        _array = args
    }
    
    override var type: JSONType {
        return .Array
    }
    
    // MARK: Array Overrides
    
    override func array() throws -> [JSONAny] {
        return _array
    }
    
    override func appendArray(newItem: JSONAny) throws -> JSONAny {
        _array.append(newItem)
        return newItem
    }

    // Subscript

    override subscript(index: Int) -> JSONAny {
        // subscripts can't throw, but the error will be retained when you try to access a type
        return (index < _array.count) ? _array[index] : JSONAny(error: .InvalidIndex(index: index))
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {
        var result = "["
        var i = 0, count = _array.count
        for value in _array {
            result += value.description
            if ++i != count {
                result += ", "
            }
        }
        return result + "]"
    }
}

// MARK: -
// String

private class JSONString: JSONAny {
    
    private var _string: String
    
    init(_ string: String = "") {
        _string = string
    }
    
    override var type: JSONType {
        return .String
    }
    
    // MARK: String Overrides
    
    override func string() throws -> String {
        return _string
    }
    
    override func setString(newValue: String) throws {
        _string = newValue
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {
        return "\"\(_string.jsonEscape)\""
    }
}

// MARK: -
// Number

private class JSONNumber: JSONAny {
    
    private var _number: Double
    
    init(_ double: Double = 0.0) {
        _number = double
    }
    
    init(_ integer: Int) {
        _number = Double(integer)
    }
    
    override var type: JSONType {
        return .Number
    }
    
    // MARK: Number Overrides
    
    override func integer() throws -> Int {
        return Int(_number)
    }
    
    override func setInteger(newValue: Int) throws {
        _number =  Double(newValue)
    }
    
    override func double() throws -> Double {
        return _number
    }
    
    override func setDouble(newValue: Double) throws {
        _number = newValue
    }

    // MARK: CustomStringConvertible
    
    override var description: String {
        return "\(_number)"
    }
}

// MARK: -
// Bool

private class JSONBool: JSONAny {
    
    private var _bool: Bool

    init(_ bool: Bool = false) {
        _bool = bool
    }
    
    override var type: JSONType {
        return .Boolean
    }
    
    // MARK: Boolean Overrides
    
    override func bool() throws -> Bool {
        return _bool
    }
    
    override func setBool(newValue: Bool) throws {
        _bool = newValue
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {
        return (_bool) ? "true" : "false"
    }
}

// MARK: -
// Null

private class JSONNull: JSONAny {
    
    override var type: JSONType {
        return .Null
    }
    
    // MARK: Null Override
    
    override func null() throws -> Int? {
        return nil
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {
        return "null"
    }
}

// MARK: - String Escape
// String Escape

private func jsonEscape(string: String) -> String {
    return string.jsonEscape
}

extension String {
    private var jsonEscape: String {
        var string = self
        let escapeCodes = ["\\":"\\\\", "\"":"\\\"", "\n": "\\n", "\t": "\\t", "\r": "\\r", "/": "\\/"]
        for (key,value) in escapeCodes {
            string = string.stringByReplacingOccurrencesOfString(key, withString: value)
        }
        return string
    }
}

// MARK: - Type Strings
/// Type Strings

extension JSONType: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .None:    return "None"
        case .Object:  return "Object"
        case .Array:   return "Array"
        case .String:  return "String"
        case .Number:  return "Number"
        case .Boolean: return "Boolean"
        case .Null:    return "Null"
        }
    }
}

// MARK: - Error Strings
/// Error Strings

extension JSONError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .TypeError(let expected, let actual):
            return "Expected \(expected) (Is \(actual))"
        case .NotObjectAt(let key, let actual):
            return "Not an Object at key [\"\(key)\"] (Is \(actual))"
        case .NotArrayAt(let index, let actual):
            return "Not an Array at index [\(index)] (Is \(actual))"
        case .InvalidKey(let key):
            return "Invalid key [\"\(key)\"]"
        case .InvalidIndex(let index):
            return "Invalid index [\(index)]"
        }
    }
}


/// More json() creation functions
public func json(uint: UInt) -> JSONAny {
    return JSONNumber(Double(uint))
}

public func json(float: Float) -> JSONAny {
    return JSONNumber(Double(float))
}

/// More extensions
extension UInt {
    public var json: JSONAny {
        return JSONNumber(Double(self))
    }
}

extension Float {
    public var json: JSONAny {
        return JSONNumber(Double(self))
    }
}