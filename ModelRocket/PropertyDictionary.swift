// PropertyDictionary.swift
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

final public class PropertyDictionary<T : JSONTransformable>: PropertyDescription {
    typealias PropertyType = T
    
    /// Backing store for property data
    public var values: [String : PropertyType] = [:]
    
    /// Post-processing closure.
    public var postProcess: (([String : PropertyType]?) -> Void)?

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
    
    public var keys: LazyForwardCollection<MapCollectionView<[String : PropertyType], String>> {
        return values.keys
    }
    
    // MARK: Initialization
    
    /// Initialize with JSON property key and default value
    public init(key: String, defaultValues: [String : PropertyType] = [:], required: Bool = false, postProcess: (([String : PropertyType]?) -> Void)? = nil) {
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
        for object in jsonValue.dictionary ?? [:]  {
            if let property = PropertyType.fromJSON(object.1) as? PropertyType {
                values[object.0] = property
            }
        }
        
        return !values.isEmpty
    }
    
    /// Convert object to JSON
    public func toJSON() -> AnyObject? {
        var jsonDictionary: [String : AnyObject] = [:]
        for (key, value) in values {
            jsonDictionary[key] = value.toJSON()
        }
        return jsonDictionary
    }
    
    /// Perform initialization post-processing
    public func initPostProcess() {
        postProcess?(values)
    }

    // MARK: Coding
    
    /// Encode
    public func encode(coder: NSCoder) {
        var objectDictionary: [String : AnyObject] = [:]
        for (key, value) in values {
            if let object: AnyObject = value as? AnyObject {
                objectDictionary[key] = object
            }
        }
        coder.encodeObject(objectDictionary, forKey: key)
    }
    
    public func decode(decoder: NSCoder) {
        let decodedObjects = decoder.decodeObjectForKey(key) as? [String : AnyObject]
        values.removeAll(keepCapacity: false)
        for (key, value) in decodedObjects ?? [:] {
            if let value = value as? PropertyType {
                values[key] = value
            }
        }
    }
}

// MARK:- Printable

extension PropertyDictionary: Printable {
    public var description: String {
        return "PropertyDictionary<\(type)> (key: \(key), count: \(values.count), required: \(required))"
    }
}

// MARK:- DebugPrintable

extension PropertyDictionary: DebugPrintable {
    public var debugDescription: String {
        return description
    }
}

// MARK:- CollectionType

extension PropertyDictionary: CollectionType {
    public func generate() -> DictionaryGenerator<String, PropertyType> {
        return values.generate()
    }
    
    public var startIndex: DictionaryIndex<String, PropertyType> {
        return values.startIndex
    }
    
    public var endIndex: DictionaryIndex<String, PropertyType> {
        return values.endIndex
    }
    
    public subscript(position: DictionaryIndex<String, PropertyType>) -> (String, PropertyType) {
        return values[position]
    }
    
    public subscript(key: String) -> PropertyType? {
        return values[key]
    }
}

// MARK:- Hashable

extension PropertyDictionary: Hashable {
    public var hashValue: Int {
        return key.hashValue
    }
}

// MARK:- Equatable

extension PropertyDictionary: Equatable {}

public func ==<T>(lhs: PropertyDictionary<T>, rhs: PropertyDictionary<T>) -> Bool {
    return lhs.key == rhs.key
}
