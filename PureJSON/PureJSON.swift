//
//  PureJSON.swift
//  PureJSON
//
//  Created by Adam Dann on 2015-06-09.
//  Copyright (c) 2015 Adam Dann. All rights reserved.
//

import Foundation

/// The basic types contained within JSON and the methods to create each type
public enum JSONType {
    case Object // Dictionary
    case Array
    case String
    case Number // Double
    case Boolean
    case Null
    
    public static func object(object: [Swift.String:JSONConvertible] = [:]) -> JSONAny {
        return JSONObject(object)
    }
    
    public static func array(array: [JSONConvertible] = []) -> JSONAny {
        return JSONArray(array)
    }
    
    /*static func string(string: Swift.String) -> JSONAny {
        return JSONString(string)
    }
    
    static func number(number: Double) -> JSONAny {
        return JSONNumber(number)
    }
    
    static func boolean(boolean: Bool) -> JSONAny {
        return JSONBool(boolean)
    }*/
    
    static func null() -> JSONAny {
        return JSONNull()
    }
}

// MARK: - Protocol
/// Protocol that makes any type JSON compatible
public protocol JSONConvertible {
    var jsonType: JSONType { get }
    var json: JSONAny { get }
}

// MARK: - Type Extensions
/// Extensions to standard types.

/*extension Dictionary where Value: JSONConvertible {
    public var jsonType: JSONType { return .Object }
    public var json: JSONAny {
        //return JSONObject(self.map { ("\($0)",$1.json)} )
    }
}*/

extension Array where Element: JSONConvertible {
    // But how to conform to JSONConvertible in the extension?
    public var jsonType: JSONType { return .Array }
    public var json: JSONAny { return JSONArray(self.map { $0.json }) }
}

extension String: JSONConvertible {
    public var jsonType: JSONType { return .String }
    public var json: JSONAny { return JSONString(self) }
}

extension Int: JSONConvertible {
    public var jsonType: JSONType { return .Number }
    public var json: JSONAny { return JSONNumber(Double(self)) }
}

extension UInt: JSONConvertible {
    public var jsonType: JSONType { return .Number }
    public var json: JSONAny { return JSONNumber(Double(self)) }
}

extension Float: JSONConvertible {
    public var jsonType: JSONType { return .Number }
    public var json: JSONAny { return JSONNumber(Double(self)) }
}

extension Double: JSONConvertible {
    public var jsonType: JSONType { return .Number }
    public var json: JSONAny { return JSONNumber(self) }
}

extension Bool: JSONConvertible {
    public var jsonType: JSONType { return .Boolean }
    public var json: JSONAny { return JSONBool(self) }
}

/// Errors
// Errors that are thrown when accessing the JSON structure. See the extension below for the English descriptions.
public enum JSONError: ErrorType {
    case None
    case TypeError(expectedType: JSONType, actualType: JSONType) // thrown by get methods
    
    case NotObjectAt(key: String, actualType: JSONType) // thrown by subscripts
    case NotArrayAt(index: Int, actualType: JSONType) // thrown by subscripts

    case InvalidKey(key: String) // thrown by Object subscripts
    case InvalidIndex(index: Int) // thrown by Array subscripts
}

// MARK: -
/// Base class to all the JSON types
// The base class contains all the methods to access any/all types of JSON nodes. Only the methods that apply to any
//  specific type are overriden, the leftovers are not overriden and throw TypeErrors.

public class JSONAny: JSONConvertible, CustomStringConvertible, Equatable {
    
    var _error: JSONError?
    
    // Nothing else should instantiate this class. Ever.
    private init(error: JSONError? = nil) {
        _error = error
    }

    /**
    This just uses the internal error if it exists or else throws a type error.
    - Parameter expectedType: The type that was expected (instead of self.type)
    - Returns: An error.
    */
    private func error(expectedType: JSONType) -> JSONError {
        guard _error == nil else {
            return _error!
        }
        guard expectedType == jsonType else {
            return .TypeError(expectedType: expectedType, actualType: jsonType) // type is overriden
        }
        return .None
    }
    
    // All subclasses should override this, I wish Swift had pure virtual classes as well as Protocols
    /**
    - Returns: The type of the JSON item.
    */
    public var jsonType: JSONType { return .Null }
    public final var json: JSONAny { return self }
    
    // These just throw the stored error (from a subscript) or a TypeError for when they are not overriden.
    //  When they are overriden they don't throw anything.
    //  ... They're kind of an eyesore.
    
    // MARK: Object Override Stubs

    /**
    - Parameter newItem: JSON item to add to the Dictionary.
    - Parameter forKey: The key in the Dictionary.
    - Returns: A Dictoinary of type [Sring:JSONAny].
    - Throws: JSONError
    */
    public func updateObject(newItem: JSONConvertible, forKey: String) throws {
        throw error(.Object)
    }
    
    public func object() throws -> [String:JSONAny] {
        throw error(.Object)
    }
    
    // MARK: Array Override Stubs

    /**
    - Returns: newItem for chaining.
    - Parameter newItem: Item to add to the Array.
    */
    public func appendArray(newItem: JSONConvertible) throws {
        throw error(.Array)
    }
    
    public func updateArray(newItem: JSONConvertible, atIndex: Int) throws {
        throw error(.Array)
    }
    
    public func array() throws -> [JSONAny] {
        throw error(.Array)
    }
    
    // MARK: String Override Stubs
    /**
    - Returns: The String value of this JSON item.
    */
    public func string() throws -> String {
        throw error(.String)
    }

    public func number() throws -> Double {
        throw error(.Number)
    }
    
    // MARK: Boolean Override Stubs
    public func bool() throws -> Bool {
        throw error(.Boolean)
    }
    
    // MARK: Null Override Stub
    public func null() throws -> Any? {
        throw error(.Null)
    }

    // Subscripts
    // When not overriden they store an error which gets passed on to the final action
    //  which should be one of the overrides above
    
    public subscript(index: Int) -> JSONAny {
        return _error != nil ? self : JSONAny(error: .NotArrayAt(index: index, actualType: jsonType))
    }
    
    public subscript(key: String) -> JSONAny {
        return _error != nil ? self : JSONAny(error: .NotObjectAt(key: key, actualType: jsonType))
    }

    // MARK: CustomStringConvertible
    
    public var description: String {
        return _error != nil ? _error!.description : "\n"
    }
}

// MARK: -
// Object (Dictionary)

private class JSONObject: JSONAny {
    
    private var _object: [String:JSONAny] = [:]
    
    init() {}

    init(_ args: [String:JSONConvertible]) {
        for (key, value) in args {
            _object[key] = value.json
        }
    }
    
    override var jsonType: JSONType {
        return .Object
    }
    
    // MARK: Object Overrides

    override func updateObject(newItem: JSONConvertible, forKey: String) throws {
        _object[forKey] = newItem.json
    }
    
    override func object() throws -> [String: JSONAny] {
        return _object
    }
    
    // Subscript

    override subscript(key: String) -> JSONAny {
        if let result = _object[key] {
            return result
        }
        return JSONAny(error: .InvalidKey(key: key))
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {

        guard _object.count > 0 else {
            return "{}"
        }
        
        return "{" + _object.map({ (key, value) in "\"\(key.jsonEscape)\": \(value)"}).joinWithSeparator(",") + "}"
    }
}

// MARK: -
// Array

private class JSONArray: JSONAny {
    
    private var _array: [JSONAny]
    
    init(_ args: [JSONConvertible] = []) {
        _array = args.map { $0.json }
    }
    
    init(args: JSONAny...) {
        _array = args.map { $0.json }
    }
    
    override var jsonType: JSONType {
        return .Array
    }
    
    // MARK: Array Overrides
    
    override func appendArray(newItem: JSONConvertible) throws {
        _array.append(newItem.json)
    }
    
    override func updateArray(newItem: JSONConvertible, atIndex: Int) throws {
        guard atIndex < _array.count else {
            throw JSONError.InvalidIndex(index: atIndex)
        }
        _array[atIndex] = newItem.json
    }
    
    override func array() throws -> [JSONAny] {
        return _array
    }

    // Subscript

    override subscript(index: Int) -> JSONAny {
        // subscripts can't throw, but the error will be retained when you try to access a type
        return (index < _array.count) ? _array[index] : JSONAny(error: .InvalidIndex(index: index))
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {
        guard _array.count > 0 else {
            return "[]"
        }
        //return "[" + ",".join(_array.map {"\($0)"}) + "]"
        return "[" + _array.map({"\($0)"}).joinWithSeparator(",") + "]"
    }
}

// MARK: -
// String

private class JSONString: JSONAny {
    
    private let _string: String
    
    init(_ string: String) {
        _string = string
    }
    
    override var jsonType: JSONType {
        return .String
    }
    
    // MARK: String Overrides
    
    override func string() throws -> String {
        return _string
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {
        return "\"\(_string.jsonEscape)\""
    }
}

// MARK: -
// Number

private class JSONNumber: JSONAny {
    
    private let _number: Double
    
    init(_ double: Double) {
        _number = double
    }
    
    override var jsonType: JSONType {
        return .Number
    }
    
    // MARK: Number Overrides
    
    override func number() throws -> Double {
        return _number
    }

    // MARK: CustomStringConvertible
    
    override var description: String {
        return "\(_number)"
    }
}

// MARK: -
// Bool

private class JSONBool: JSONAny {
    
    private let _bool: Bool

    init(_ bool: Bool) {
        _bool = bool
    }
    
    override var jsonType: JSONType {
        return .Boolean
    }
    
    // MARK: Boolean Overrides
    
    override func bool() throws -> Bool {
        return _bool
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {
        return (_bool) ? "true" : "false"
    }
}

// MARK: -
// Null

private class JSONNull: JSONAny {
    
    override var jsonType: JSONType {
        return .Null
    }
    
    // MARK: Null Override
    
    override func null() throws -> Any? {
        return nil
    }
    
    // MARK: CustomStringConvertible
    
    override var description: String {
        return "null"
    }
}

// MARK: - String Escape
// String Escape
// This is kind of temporary...

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

// MARK: - Error Strings
/// Error Strings

extension JSONError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .None:
            return "No Error"
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

/// JSONAny Convertible
public func ==(left: JSONAny, right: JSONAny) -> Bool {
    if left.jsonType == right.jsonType {
        switch left.jsonType {
        case .Object:
            return false //(left as! JSONObject)._object == (right as! JSONObject)._object // forcing is dirty
        case .Array:
            return false //(left as! JSONArray)._array == (right as! JSONArray)._array // forcing is dirty
        case .String:
            if let result = try? left.string() == right.string() {
                return result
            }
        case .Number:
            if let result = try? left.number() == right.number() {
                return result
            }
        case .Boolean:
            if let result = try? left.bool() == right.bool() {
                return result
            }
        case .Null:
            return true
        }
    }

        
    return false
}

/// Compare JSONAny to JSONConverible
func == <T: JSONConvertible>(left: JSONAny, right: T) -> Bool {
    guard left.jsonType == right.jsonType else { // precheck to avoid right.json
        return false
    }
    return left == right.json
}

func == <T: JSONConvertible>(left: T, right: JSONAny) -> Bool {
    guard left.jsonType == right.jsonType else { // precheck to avoid left.json
        return false
    }
    return left.json == right
}

/* func == <T: JSONConvertible>(left: T, right: T) -> Bool {
    // Not a good idea because it meant you could compare almost anything, like 90 == "ninety"
    // It really breaks Swift's strict types, so I opted to only compare JSONAny to JSONConvertible
}*/
