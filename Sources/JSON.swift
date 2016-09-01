// JSON.swift
//
// Copyright (c) 2015 Oven Bits, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

public struct JSON {
    
    internal var object: Any?
    
    public init() {
        self.object = nil
    }
    
    public init(_ object: Any?) {
        self.object = object
    }
    
    public init(data: Data?) {
        if let data = data, let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
            self.init(object)
        }
        else {
            self.init()
        }
    }
    
    public subscript(key: String) -> JSON {
        set {
            if let tempObject = object as? [String : Any] {
                var object = tempObject
                
                object[key] = newValue.object
                self.object = object as Any
            }
            else {
                var tempObject: [String : Any] = [:]
                tempObject[key] = newValue.object
                self.object = tempObject as Any
            }
        }
        get {
            if let dictionary = object as? NSDictionary {
                return JSON(dictionary[key] as Any)
            }
            
            return JSON()
        }
    }
    
    public var hasKey: Bool {
        return object != nil
    }
    
    public var hasValue: Bool {
        return object != nil && !(object is NSNull)
    }
}

// MARK: - CustomStringConvertible

extension JSON: CustomStringConvertible {
    public var description: String {
        if let object = object as AnyObject? {
            switch object {
            case is String, is Float, is Double, is Int, is UInt, is Bool: return "\(object)"
            case is [AnyObject], is [String : AnyObject]:
                if let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) {
                    return String(data: data, encoding: .utf8) ?? ""
                }
            default: return ""
            }
        }
        
        return "\(object)"
    }
}

// MARK: - CustomDebugStringConvertible

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - ExpressibleByNilLiteral

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init()
    }
}

// MARK: - ExpressibleByStringLiteral

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value as Any)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value as Any)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value as Any)
    }
}

// MARK: - ExpressibleByFloatLiteral

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value as Any)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value as Any)
    }
}

// MARK: - ExpressibleByBooleanLiteral

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value as Any)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(elements as Any)
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        var object: [String : Any] = [:]
        
        for (key, value) in elements {
            object[key] = value
        }
        
        self.init(object as Any)
    }
}

// MARK: - CollectionType

extension JSON: Sequence {
    public func makeIterator() -> IndexingIterator<[JSON]> {
        return arrayValue.makeIterator()
    }
    
    public var startIndex: Int {
        return arrayValue.startIndex
    }
    
    public var endIndex: Int {
        return arrayValue.endIndex
    }
    
    public subscript(position: Int) -> JSON {
        return arrayValue[position]
    }
}

// MARK: - String

extension JSON {
    public var string: String? { return object as? String }
    public var stringValue: String { return string ?? "" }
}

// MARK: - Float

extension JSON {
    public var float: Float? { return (object as? NSNumber)?.floatValue }
    public var floatValue: Float { return float ?? 0 }
}

// MARK: - Double

extension JSON {
    public var double: Double? { return (object as? NSNumber)?.doubleValue }
    public var doubleValue: Double { return double ?? 0 }
}

// MARK: - Int

extension JSON {
    public var int: Int? { return (object as? NSNumber)?.intValue }
    public var intValue: Int { return int ?? 0 }
}

// MARK: - UInt

extension JSON {
    public var uInt: UInt? { return (object as? NSNumber)?.uintValue }
    public var uIntValue: UInt { return uInt ?? 0 }
}

// MARK: - Bool

extension JSON {
    public var bool: Bool? { return object as? Bool }
    public var boolValue: Bool { return bool ?? false }
}

// MARK: - URL

extension JSON {
    public var url: URL? {
        if let urlString = string {
            return URL(string: urlString)
        }
        return nil
    }
}

// MARK: - Array

extension JSON {
    public var array: [JSON]? {
        if let array = object as? [AnyObject] {
            return array.map { JSON($0) }
        }
        return nil
    }
    public var arrayValue: [JSON] { return array ?? [] }
}

// MARK: - Dictionary

extension JSON {
    public var dictionary: [String : JSON]? {
        if let dictionary = object as? [String : AnyObject] {
            let map = dictionary.map { ($0, JSON($1 as AnyObject)) }
            var dictionary: [String : JSON] = [:]
            for (key, value) in map {
                dictionary[key] = value
            }
            return dictionary
        }
        return nil
    }
    public var dictionaryValue: [String : JSON] { return dictionary ?? [:] }
}

extension Dictionary {
    private init(pairs: [(Key, Value)]) {
        self.init()
        for (key, value) in pairs {
            self[key] = value
        }
    }
}

// MARK: - Raw

extension JSON: RawRepresentable {
    
    public enum DataError: Error {
        case missingObject
        case invalidObject
    }
    
    public init?(rawValue: Any) {
        guard JSONSerialization.isValidJSONObject(rawValue) else { return nil }
        
        self.init(rawValue)
    }
    
    public var rawValue: Any {
        return object ?? NSNull()
    }
    
    public func rawData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        guard let object = object else { throw DataError.missingObject }
        guard JSONSerialization.isValidJSONObject(object) else { throw DataError.invalidObject }
        
        return try JSONSerialization.data(withJSONObject: object, options: options)
    }
}

// MARK: - Equatable

extension JSON: Equatable {

    public static func ==(lhs: JSON, rhs: JSON) -> Bool {
        guard let lhsObject: Any = lhs.object, let rhsObject: Any = rhs.object else { return false }

        switch (lhsObject, rhsObject) {
        case (let left as String, let right as String):
            return left == right
        case (let left as Double, let right as Double):
            return left == right
        case (let left as Float, let right as Float):
            return left == right
        case (let left as Int, let right as Int):
            return left == right
        case (let left as UInt, let right as UInt):
            return left == right
        case (let left as Bool, let right as Bool):
            return left == right
        case (let left as URL, let right as URL):
            return left == right
        case (let left as [AnyObject], let right as [AnyObject]):
            return left.map { JSON($0) } == right.map { JSON ($0) }
        case (let left as [String : AnyObject], let right as [String : AnyObject]):
            let leftMap = left.map { ($0, JSON($1 as AnyObject)) }
            var leftDictionary: [String : JSON] = [:]
            for (key, value) in leftMap {
                leftDictionary[key] = value
            }
            
            let rightMap = right.map { ($0, JSON($1 as AnyObject)) }
            var rightDictionary: [String : JSON] = [:]
            for (key, value) in rightMap {
                rightDictionary[key] = value
            }
            
            return leftDictionary == rightDictionary
        default: return false
        }
    }
}
