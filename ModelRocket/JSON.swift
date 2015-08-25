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
    
    private var object: AnyObject?
    
    public init() {
        self.object = nil
    }
    
    public init(_ object: AnyObject?) {
        self.object = object
    }
    
    public init(data: NSData?) {
        if let data = data, let object: AnyObject = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
            self.init(object)
        }
        else {
            self.init()
        }
    }
    
    public subscript(key: String) -> JSON {
        set {
            if var tempObject = object as? [String : AnyObject] {
                tempObject[key] = newValue.object
                self.object = tempObject
            }
            else {
                var tempObject: [String : AnyObject] = [:]
                tempObject[key] = newValue.object
                self.object = tempObject
            }
        }
        get {
            /**
                NSDictionary is used because it currently performs better than a native Swift dictionary.
                The reason for this is that [String : AnyObject] is bridged to NSDictionary deep down the
                call stack, and this bridging operation is relatively expensive. Until Swift is ABI stable
                and/or doesn't require a bridge to Objective-C, NSDictionary will be used here
            */
            if let dictionary = object as? NSDictionary {
                return JSON(dictionary[key])
            }
            
            return JSON()
        }
    }
}

// MARK: - CustomStringConvertible

extension JSON: CustomStringConvertible {
    public var description: String {
        if let object: AnyObject = object {
            switch object {
            case is String, is NSNumber, is Float, is Double, is Int, is UInt, is Bool: return "\(object)"
            case is [AnyObject], is [String : AnyObject]:
                if let data = try? NSJSONSerialization.dataWithJSONObject(object, options: .PrettyPrinted) {
                    return NSString(data: data, encoding: NSUTF8StringEncoding) as? String ?? ""
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

// MARK: - NilLiteralConvertible

extension JSON: NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self.init()
    }
}

// MARK: - StringLiteralConvertible

extension JSON: StringLiteralConvertible {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(value)
    }
}

// MARK: - FloatLiteralConvertible

extension JSON: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

// MARK: - IntegerLiteralConvertible

extension JSON: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

// MARK: - BooleanLiteralConvertible

extension JSON: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

// MARK: - ArrayLiteralConvertible

extension JSON: ArrayLiteralConvertible {
    public init(arrayLiteral elements: AnyObject...) {
        self.init(elements)
    }
}

// MARK: - DictionaryLiteralConvertible

extension JSON: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, AnyObject)...) {
        var object: [String : AnyObject] = [:]
        
        for (key, value) in elements {
            object[key] = value
        }
        
        self.init(object)
    }
}

// MARK: - CollectionType

extension JSON: CollectionType {
    public func generate() -> IndexingGenerator<[JSON]> {
        return arrayValue.generate()
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return arrayValue.count
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

// MARK: - NSNumber

extension JSON {
    public var number: NSNumber? { return object as? NSNumber }
    public var numberValue: NSNumber { return number ?? 0 }
}

// MARK: - Float

extension JSON {
    public var float: Float? { return object as? Float }
    public var floatValue: Float { return float ?? 0 }
}

// MARK: - Double

extension JSON {
    public var double: Double? { return object as? Double }
    public var doubleValue: Double { return double ?? 0 }
}

// MARK: - Int

extension JSON {
    public var int: Int? { return object as? Int }
    public var intValue: Int { return int ?? 0 }
}

// MARK: - UInt

extension JSON {
    public var uInt: UInt? { return object as? UInt }
    public var uIntValue: UInt { return uInt ?? 0 }
}

// MARK: - Bool

extension JSON {
    public var bool: Bool? { return object as? Bool }
    public var boolValue: Bool { return bool ?? false }
}

// MARK: - NSURL

extension JSON {
    public var URL: NSURL? {
        if let urlString = string {
            return NSURL(string: urlString)
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
            return Dictionary(dictionary.map { ($0, JSON($1)) })
        }
        return nil
    }
    public var dictionaryValue: [String : JSON] { return dictionary ?? [:] }
}

extension Dictionary {
    private init(_ pairs: [Element]) {
        self.init()
        for (key, value) in pairs {
            self[key] = value
        }
    }
}

// MARK: - Equatable

extension JSON: Equatable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    if let lhsObject: AnyObject = lhs.object, rhsObject: AnyObject = rhs.object {
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
        case (let left as [AnyObject], let right as [AnyObject]):
            return left.map { JSON($0) } == right.map { JSON ($0) }
        case (let left as [String : AnyObject], let right as [String : AnyObject]):
            return Dictionary(left.map { ($0, JSON($1)) }) == Dictionary(right.map { ($0, JSON($1)) })
        default: return false
        }
    }

    return false
}
