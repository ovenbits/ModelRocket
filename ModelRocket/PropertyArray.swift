// PropertyArray.swift
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

final public class PropertyArray<T : JSONTransformable>: PropertyDescription {
    typealias PropertyType = T
    
    /// Backing store for property data
    public var values: [PropertyType] = []
    
    /// Post-processing closure.
    public var postProcess: (([PropertyType]) -> Void)?

    /// JSON parameter key
    public var key: String
    
    /// Type information
    public var type: String {
        return "\(PropertyType.self)"
    }
    
    /// Specify whether value is required
    public var required = false

    public var count: Int {
        return values.count
    }
    
    public var isEmpty: Bool {
        return values.isEmpty
    }
    
    public var first: PropertyType? {
        return values.first
    }
    
    public var last: PropertyType? {
        return values.last
    }
    
    // MARK: Initialization
    
    /// Initialize with JSON property key
    public init(key: String, defaultValues: [PropertyType] = [], required: Bool = false, postProcess: (([PropertyType]) -> Void)? = nil) {
        self.key = key
        self.values = defaultValues
        self.required = required
        self.postProcess = postProcess
    }
    
    // MARK: Transform
    
    /// Extract object from JSON and return whether or not the value was extracted
    public func fromJSON(json: JSON) -> Bool {
        var jsonValue: JSON = json
        let keyPaths = key.componentsSeparatedByString(".")
        for key in keyPaths {
            jsonValue = jsonValue[key]
        }
        
        values.removeAll(keepCapacity: false)
        for object in jsonValue.array ?? []  {
            if let property = PropertyType.fromJSON(object) as? PropertyType {
                values.append(property)
            }
        }
        
        return !values.isEmpty
    }
    
    /// Convert object to JSON
    public func toJSON() -> AnyObject? {
        var jsonArray: [AnyObject] = []
        for value in values {
            jsonArray.append(value.toJSON())
        }
        return jsonArray
    }
    
    /// Perform initialization post-processing
    public func initPostProcess() {
        postProcess?(values)
    }
    
    // MARK: Coding
    
    /// Encode
    public func encode(coder: NSCoder) {
        let objectArray = values.map { $0 as? AnyObject }.filter { $0 != nil }.map { $0! }
        coder.encodeObject(objectArray, forKey: key)
    }
    
    public func decode(decoder: NSCoder) {
        let decodedObjects = decoder.decodeObjectForKey(key) as? [AnyObject]
        values.removeAll(keepCapacity: false)
        for object in decodedObjects ?? [] {
            if let value = object as? PropertyType {
                values.append(value)
            }
        }
    }
}

// MARK:- Printable

extension PropertyArray: Printable {
    public var description: String {
        return "PropertyArray<\(type)> (key: \(key), count: \(values.count), required: \(required))"
    }
}

// MARK:- DebugPrintable

extension PropertyArray: DebugPrintable {
    public var debugDescription: String {
        return description
    }
}

// MARK:- CollectionType

extension PropertyArray: CollectionType {
    public func generate() -> IndexingGenerator<[PropertyType]> {
        return values.generate()
    }
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return values.count
    }
    
    public subscript(index: Int) -> PropertyType {
        return values[index]
    }
}

// MARK:- Sliceable

extension PropertyArray: Sliceable {
    public subscript (subRange: Range<Int>) -> ArraySlice<PropertyType> {
        return values[subRange]
    }
}

// MARK:- Hashable

extension PropertyArray: Hashable {
    public var hashValue: Int {
        return key.hashValue
    }
}

// MARK:- Equatable

extension PropertyArray: Equatable {}

public func ==<T>(lhs: PropertyArray<T>, rhs: PropertyArray<T>) -> Bool {
    return lhs.key == rhs.key
}
