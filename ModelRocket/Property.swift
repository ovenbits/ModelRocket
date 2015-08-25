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
        return value
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
    public func fromJSON(json: JSON) -> Bool {
        var jsonValue = json
        
        key.componentsSeparatedByString(".").forEach {
            jsonValue = jsonValue[$0]
        }
        
        if let newValue = PropertyType.fromJSON(jsonValue) as? PropertyType {
            value = newValue
        }
        
        return (value != nil)
    }
    
    /// Convert object to JSON
    public func toJSON() -> AnyObject? {
        return value?.toJSON()
    }
    
    /// Perform initialization post-processing
    public func initPostProcess() {
        postProcess?(value)
    }

    // MARK: Coding
    
    /// Encode
    public func encode(coder: NSCoder) {
        if let object: AnyObject = value as? AnyObject {
            coder.encodeObject(object, forKey: key)
        }
    }
    
    public func decode(decoder: NSCoder) {
        if let decodedValue = decoder.decodeObjectForKey(key) as? PropertyType {
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

extension Property: Hashable {
    public var hashValue: Int {
        return key.hashValue
    }
}

// MARK:- Equatable

extension Property: Equatable {}

public func ==<T>(lhs: Property<T>, rhs: Property<T>) -> Bool {
    return lhs.key == rhs.key
}
