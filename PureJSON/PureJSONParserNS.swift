//
//  PureJSONParserNS.swift
//  PureJSON
//
//  Created by Adam Dann on 2015-06-10.
//  Copyright © 2015 Adam Dann. All rights reserved.
//

import Foundation

public struct JSONParseNS {
    enum Error: ErrorType {
        case String
        case File
        case URL
        case Key
        case Content
    }
    
    /**
    - parameter string: String that contains JSON data
    - parameter encoding: Encoding of the string, defaults to NSUTF8StringEncoding
    - returns: A parsed JSON tree
    */
    public static func parseString(string: String, encoding: UInt = NSUTF8StringEncoding) throws -> JSONAny {
        guard let nsData = (string as NSString).dataUsingEncoding(encoding) else {
            throw Error.String
        }
        return try parseData(nsData)
    }
    
    /**
    - parameter path: Path to a file that contains JSON data
    - returns: A parsed JSON tree
    */
    public static func parseFile(path: String) throws -> JSONAny {
        guard let nsData = NSData(contentsOfFile: path) else {
            throw Error.File
        }
        return try parseData(nsData)
    }
    
    /**
    - parameter url: URL that contains JSON data
    - returns: A parsed JSON tree
    */
    public static func parseURL(url: String) throws -> JSONAny {
        guard let nsUrl = NSURL(string: url) else {
            throw Error.URL
        }
        return try parseData(try NSData(contentsOfURL: nsUrl, options: NSDataReadingOptions()))
    }
    
    /**
    - parameter data: JSON data
    - returns: A parsed JSON tree
    */
    public static func parseData(data: NSData) throws -> JSONAny {
        return try jsonFactory(NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()))
    }
    
    /**
    - Warning: Recursive!
    - Parameter item: An Object to be converted to a JSON value
    - Returns: A JSON object as JSONAny
    */
    private static func jsonFactory(item: AnyObject) throws -> JSONAny {
        switch item {
        case let dict as NSDictionary:
            let object = JSONType.object()
            for (key, item) in dict {
                guard let strKey = key as? String else {
                    throw Error.Key
                }
                try object.updateObject(jsonFactory(item), forKey: strKey)
            }
            return object
        case let narray as NSArray:
            let jarray = JSONType.array()
            for item in narray {
                try jarray.appendArray(jsonFactory(item))
            }
            return jarray
        case let bool as NSNumber where bool.isBool:
            return (bool as Bool).json
        case let number as NSNumber:
            return (number as Double).json
        case let string as NSString:
            return (string as String).json
        case _ as NSNull:
            return JSONType.null()
        default:
            throw Error.Content
        }
    }
    
    /* This crashes XCode 7 Beta 1

    extension enum Error: CustomDebugStringConvertible {
        var description: String {
            switch self {
            case .String:
                return "Could not convert string to data."
            case .URL:
                return "Malformed URL."
            case .File:
                return "Could not load file."
            case .Key:
                return "Dictionary key is not a string."
            case .Content:
                return "Ran into some bad content."
            }
        }
    }*/
}

/* This crashes XCode 7 Beta 1 too

extension enum JSONParseNS.Error: CustomDebugStringConvertible {
    var description: String {
        switch self {
        case .String:
            return "Could not convert string to data."
        case .URL:
            return "Malformed URL."
        case .File:
            return "Could not load file."
        case .Key:
            return "Dictionary key is not a string."
        case .Content:
            return "Ran into some bad content."
        }
    }
}*/

/// Test to see if an NSNumber is actually a Boolean
private extension NSNumber {
    var isBool: Bool { // Since we're using Objective-C we might was well use C too!
        assert(strcmp(NSNumber(bool: true).objCType, NSNumber(bool: false).objCType) == 0)
        return strcmp(self.objCType, NSNumber(bool: true).objCType) == 0
    }
}
