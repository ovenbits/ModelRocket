// ModelRocket.swift
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

public class ModelRocket: NSObject, NSCoding {
    
    private var JSONMappings: [PropertyDescription] {
        let mirror = reflect(self)
        return inspect(mirror)
    }
    
    private func inspect(mirror: MirrorType, var _ mappings: [PropertyDescription] = []) -> [PropertyDescription] {
        for i in 0..<mirror.count {
            let (name, childMirror) = mirror[i]
            if name == "super" {
                mappings += inspect(childMirror, mappings)
            }
            else if let property = childMirror.value as? PropertyDescription {
                mappings += [property]
            }
        }
        
        return mappings
    }
    
    // MARK: Initialization
    
    public required override init() {
        super.init()
    }
    
    public required convenience init(json: JSON) {
        self.init()
        for map in JSONMappings {
            map.fromJSON(json)
        }
        
        for map in JSONMappings {
            map.initPostProcess()
        }
    }
    
    public required convenience init?(strictJSON: JSON) {
        self.init()

        if strictJSON == nil {
            return nil
        }
        
        var valid = true
        
        var debugString = "Initializing object of type: \(self.dynamicType)"
        
        for map in JSONMappings {
            let validObject = map.fromJSON(strictJSON)
            
            if map.required && !validObject {
                valid = false
                
                #if DEBUG
                    debugString += "\n\tProperty failed for key: \(map.key), type: \(map.type)"
                #else
                    break
                #endif
            }
        }
        
        if !valid {
            #if DEBUG
                println(debugString)
            #endif
            return nil
        }
        
        for map in JSONMappings {
            map.initPostProcess()
        }
    }
    
    public class func modelForJSON(json: JSON) -> ModelRocket {
        return ModelRocket(json: json)
    }
    
    public class func modelForStrictJSON(json: JSON) -> ModelRocket? {
        return ModelRocket(strictJSON: json)
    }
    
    // MARK: JSON
    
    private func subKeyPathDictionary(#value: AnyObject, keys: ArraySlice<String>, index: Int, previousDictionary: AnyObject?) -> [String : AnyObject] {
        if index == 0 {
            let key = keys[index]
            if let previousDictionary = previousDictionary as? [String : AnyObject] {
                return mergeDictionaries(previousDictionary, [key : value])
            }
            return [key : value]
        }
        return subKeyPathDictionary(value: [keys[index] : value], keys: keys, index: index-1, previousDictionary: previousDictionary)
    }
    
    /// Create JSON representation of object
    public func json() -> (dictionary: [String : AnyObject], json: JSON?, data: NSData?) {
        
        var dictionary: [String : AnyObject] = [:]
        
        for map in JSONMappings {
            let components = map.key.componentsSeparatedByString(".")
            if components.count > 1 {
                if let value: AnyObject = map.toJSON() {
                    
                    let firstKeyPath = components[0]
                    let subKeyPaths = components[1..<components.count]
                    let previousDictionary: AnyObject? = dictionary[firstKeyPath]
                    let subDictionary = subKeyPathDictionary(value: value, keys: subKeyPaths, index: subKeyPaths.count-1, previousDictionary: previousDictionary)

                    dictionary[firstKeyPath] = subDictionary
                }
            }
            else {
                if let value: AnyObject = map.toJSON() {
                    dictionary[map.key] = value
                }
            }
        }
        
        if let jsonData = NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted, error: nil) {
            let json = JSON(data: jsonData)
            
            return (dictionary: dictionary, json: json, data: jsonData)
        }
        
        return (dictionary: dictionary, json: nil, data: nil)
    }
    
    // MARK: NSCoding
    
    public required convenience init(coder aDecoder: NSCoder) {
        self.init()
        
        for map in JSONMappings {
            map.decode(aDecoder)
        }
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        for map in JSONMappings {
            map.encode(aCoder)
        }
    }
    
    // MARK: Copying
    
    public override func copy() -> AnyObject {
        if let json = json().json {
            return self.dynamicType(json: json)
        }
        return self.dynamicType()
    }
    
    // MARK: Private
    
    private func mergeDictionaries(left: [String : AnyObject], _ right: [String : AnyObject]) -> [String : AnyObject] {
        
        var map: [String : AnyObject] = [:]
        for (k, v) in left {
            map[k] = v
        }
        
        for (k, v) in right {
            if let previousValue = map[k] as? [String : AnyObject] {
                if let value = v as? [String : AnyObject] {
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
