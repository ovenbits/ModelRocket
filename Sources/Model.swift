// Model.swift
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

open class Model: NSObject, NSCoding {
    
    private var jsonMappings: [PropertyDescription] {
        let mirror = Mirror(reflecting: self)
        return inspect(mirror)
    }
    
    private func inspect(_ mirror: Mirror, _ mappings: [PropertyDescription] = []) -> [PropertyDescription] {
        
        var mappings = mappings
        
        if let parentMirror = mirror.superclassMirror, !parentMirror.children.isEmpty {
            mappings += inspect(parentMirror, mappings)
        }
        
        mappings += mirror.children.flatMap { $0.value as? PropertyDescription }
        
        return mappings
    }
    
    // MARK: Initialization
    
    public required override init() {
        super.init()
    }
    
    public required init(json: JSON) {
        super.init()
        jsonMappings.forEach { $0.from(json: json) }
        jsonMappings.forEach { $0.initPostProcess() }
    }
    
    public required init?(strictJSON: JSON) {
        super.init()
        
        var valid = true
        
        var debugString = "Initializing object of type: \(type(of: self))"
        
        for map in jsonMappings {
            let validObject = map.from(json: strictJSON)
            
            if map.required && !validObject {
                valid = false
                
                #if DEBUG
                    debugString += "\n\tProperty failed for key: \(map.key), type: \(map.type)"
                #else
                    break
                #endif
            }
        }
        
        guard valid else {
            #if DEBUG
                print(debugString)
            #endif
            return nil
        }
        
        jsonMappings.forEach { $0.initPostProcess() }
    }
    
    public class func modelForJSON(json: JSON) -> Model {
        return Model(json: json)
    }
    
    public class func modelForStrictJSON(json: JSON) -> Model? {
        return Model(strictJSON: json)
    }
    
    // MARK: JSON
    
    private func subKeyPathDictionary(value: Any, keys: [String], index: Int, previousDictionary: Any?) -> [String : Any] {
        
        if index == 0 {
            let key = keys[index]
            guard let previousDictionary = previousDictionary as? [String : Any] else { return [key : value] }
            
            return mergeDictionaries(previousDictionary, [key : value])
        }
        
        return subKeyPathDictionary(value: [keys[index] : value], keys: keys, index: index - 1, previousDictionary: previousDictionary)
    }
    
    /// Create JSON representation of object
    public var json: (dictionary: [String : Any], json: JSON?, data: Data?) {
        
        var dictionary: [String : Any] = [:]
        
        for map in jsonMappings {
            let components = map.key.components(separatedBy: ".")
            if components.count > 1 {
                if let value = map.toJSON() {
                    
                    let firstKeyPath = components[0]
                    let subKeyPaths = Array(components[1..<components.count])
                    let previousDictionary: Any? = dictionary[firstKeyPath]
                    let subDictionary = subKeyPathDictionary(value: value, keys: subKeyPaths, index: subKeyPaths.count-1, previousDictionary: previousDictionary)

                    dictionary[firstKeyPath] = subDictionary as AnyObject
                }
            }
            else if let value = map.toJSON() {
                dictionary[map.key] = value
            }
        }
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) {
            let json = JSON(data: jsonData)
            
            return (dictionary: dictionary, json: json, data: jsonData)
        }
        
        return (dictionary: dictionary, json: nil, data: nil)
    }
    
    // MARK: NSCoding
    
    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        jsonMappings.forEach { $0.decode(aDecoder) }
    }
    
    open func encode(with aCoder: NSCoder) {
        jsonMappings.forEach { $0.encode(aCoder) }
    }
    
    // MARK: Copying
    
    open override func copy() -> Any {
        if let json = json.json {
            return type(of: self).init(json: json)
        }
        return type(of: self).init()
    }
    
    // MARK: Private
    
    private func mergeDictionaries(_ left: [String : Any], _ right: [String : Any]) -> [String : Any] {
        
        var map: [String : Any] = [:]
        for (k, v) in left {
            map[k] = v
        }
        
        for (k, v) in right {
            if let previousValue = map[k] as? [String : Any] {
                if let value = v as? [String : Any] {
                    let replacement = mergeDictionaries(previousValue, value)
                    map[k] = replacement
                    continue
                }
            }
            map[k] = v
        }
        
        return map
    }
}
