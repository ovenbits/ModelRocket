// Property.swift
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

final public class Property<T : JSONTransformable>: PropertyDescription {
    public typealias PropertyType = T
    
    /// Backing store for property data
    public var value: PropertyType?
    
    /// Post-processing closure.
    public var postProcess: ((PropertyType?) -> Void)?
    
    /// JSON parameter key
    public var key: String
    
    /// Type information
    public var type: String {
        return "\(PropertyType.self)"
    }
    
    /// Specify whether value is required
    public var required = false
    
    public subscript() -> PropertyType? {
        set { value = newValue }
        get { return value }
    }
    
    // MARK: Initialization
    
    /// Initialize with JSON property key
    public init(key: String, defaultValue: PropertyType? = nil, required: Bool = false, postProcess: ((PropertyType?) -> Void)? = nil) {
        self.key = key
        self.value = defaultValue
        self.required = required
        self.postProcess = postProcess
    }
    
    // MARK: Transform
    
    /// Extract object from JSON and return whether or not the value was extracted
    public func from(json: JSON) -> Bool {
        var jsonValue = json
        
        key.components(separatedBy: ".").forEach {
            jsonValue = jsonValue[$0]
        }
        
        if let newValue = PropertyType.from(json: jsonValue) {
            value = newValue
        }
        
        return (value != nil)
    }
    
    /// Convert object to JSON
    public func toJSON() -> Any? {
        return value?.toJSON()
    }
    
    /// Perform initialization post-processing
    public func initPostProcess() {
        postProcess?(value)
    }

    // MARK: Coding
    
    /// Encode
    public func encode(_ coder: NSCoder) {
        if let object = value as Any? {
            if (object as AnyObject).responds(to: #selector(NSCoding.encode(with:))) == true {
                coder.encode(object, forKey: key)
            }
            else if let object = object as? JSONTransformable {
                coder.encode(object.toJSON(), forKey: key)
            }
        }
    }
    
    private func encodeRawRepresentable<T: RawRepresentable>(value: T, key: String) -> PropertyType? {
        guard let compatible = value.rawValue as? PropertyType else {
            return nil
        }
        return compatible
    }
    
    public func decode(_ decoder: NSCoder) {
        if let decodedValue = decoder.decodeObject(forKey: key) as? PropertyType {
            value = decodedValue
        }
        else if let decodedValue = PropertyType.from(json: JSON(decoder.decodeObject(forKey: key) as Any)) {
            value = decodedValue
        }
    }
}

// MARK:- CustomStringConvertible

extension Property: CustomStringConvertible {
    public var description: String {
        
        var string = "Property<\(type)> (key: \(key), value: "
        if let value = value {
            string += "\(value)"
        }
        else {
            string += "nil"
        }
        string += ", required: \(required))"
        
        return string
    }
}

// MARK:- CustomDebugStringConvertible

extension Property: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK:- Hashable

extension Property/*: Hashable*/ {
    public var hashValue: Int {
        return key.hashValue
    }
}

// MARK:- Equatable

//extension Property: Equatable {}


public func ==<T: Equatable>(lhs: Property<T>, rhs: Property<T>) -> Bool {
    return lhs.key == rhs.key && lhs.value == rhs.value
}

//public static func ==<T>(lhs: Property<T>, rhs: Property<T>) -> Bool {
//    return lhs.key == rhs.key
//}
