// JSONTests.swift
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

import UIKit
import XCTest
import ModelRocket

class JSONTests: XCTestCase {
    
    let json: JSON = [
        "string" : "Test string",
        "date" : "2015-02-04T18:30:15.000Z",
        "color" : "#00FF00",
        "bool" : true,
        "url" : "http://ovenbits.com",
        "number": 3,
        "double" : 7.5,
        "float" : 4.75,
        "int" : -23,
        "u_int" : 25,
        "array" : [1, 2, 3, 4, 5],
        "dictionary" : [
            "string1" : "String 1",
            "string2" : "String 2",
            "string3" : "String 3"
        ]
    ]
    
    // MARK: - Data
    
    func testJSONData() {
        
        let path = NSBundle(forClass: JSONTests.self).pathForResource("Tests", ofType: "json")!
        let data = NSData(contentsOfFile: path)
        let vehicleJSON = JSON(data: data)
        
        // No data
        let emptyJSON = JSON(data: nil)
        XCTAssertFalse(emptyJSON.hasKey, "JSON is not nil")
        XCTAssertFalse(emptyJSON.hasValue, "JSON has a value")
        
        // String
        XCTAssertEqual(vehicleJSON["make"].stringValue, "BMW")
        XCTAssertEqual(vehicleJSON["manufacturer"]["company_name"].stringValue, "Bayerische Motoren Werke AG")
        XCTAssertNil(vehicleJSON["year"].string)
        
        // Number
        XCTAssertEqual(vehicleJSON["year"].numberValue, 2015)
        XCTAssertEqual(vehicleJSON["purchased_trims"]["sedan"].numberValue, 1024)
        XCTAssertNil(vehicleJSON["model"].number)
        
        // Float
        XCTAssertEqual(vehicleJSON["zero_to_sixty_time"].floatValue, 4.7)
        XCTAssertEqual(vehicleJSON["year"].floatValue, 2015)
        XCTAssertNil(vehicleJSON["model"].float)
        
        // Double
        XCTAssertEqual(vehicleJSON["zero_to_sixty_time"].doubleValue, 4.7)
        XCTAssertEqual(vehicleJSON["year"].doubleValue, 2015)
        XCTAssertNil(vehicleJSON["model"].double)
        
        // Int
        XCTAssertEqual(vehicleJSON["year"].intValue, 2015)
        XCTAssertEqual(vehicleJSON["zero_to_sixty_time"].intValue, 4)
        XCTAssertNil(vehicleJSON["model"].int)
        
        // UInt
        XCTAssertEqual(vehicleJSON["year"].uIntValue, 2015)
        XCTAssertEqual(vehicleJSON["zero_to_sixty_time"].uIntValue, 4)
        XCTAssertNil(vehicleJSON["model"].uInt)
        
        // Bool
        XCTAssertEqual(vehicleJSON["nav_system_standard"].boolValue, true)
        XCTAssertNil(vehicleJSON["model"].bool)
        
        // URL
        XCTAssertEqual(vehicleJSON["manufacturer"]["website"].URL!, NSURL(string: "http://www.bmw.com")!)
        XCTAssertNil(vehicleJSON["model"].int)
        
        // Array
        XCTAssertEqual(vehicleJSON["available_colors"].arrayValue[0].stringValue, "#00304C")
        XCTAssertEqual(vehicleJSON["available_colors"].arrayValue[1].stringValue, "#1C2127")
        XCTAssertEqual(vehicleJSON["available_colors"].arrayValue[2].stringValue, "#D8D8D8")
        XCTAssertEqual(vehicleJSON["available_colors"].arrayValue[3].stringValue, "#820F0F")
        XCTAssertEqual(vehicleJSON["available_colors"].arrayValue.count, 4)
        
        // Dictionary
        XCTAssertEqual(vehicleJSON["purchased_trims"].dictionaryValue["sedan"]!.intValue, 1024)
        XCTAssertEqual(vehicleJSON["purchased_trims"].dictionaryValue["gran_coupe"]!.intValue, 512)
        XCTAssertEqual(vehicleJSON["purchased_trims"].dictionaryValue.count, 2)
    }
    
    // MARK: - Create
    
    func testCreate() {
        var json = JSON()
        json["string"] = "Test String"
        json["int"] = 2
        json["uInt"] = 4
        json["float"] = 5.5
        json["bool"] = true
        json["array"] = [1, 2, 3, 4, 5]
        json["dictionary"] = ["string1" : "String 1", "string2" : "String 2", "string3" : "String 3"]
        
        XCTAssertEqual(json["string"].string!, "Test String")
        XCTAssertEqual(json["int"].int!, 2)
        XCTAssertEqual(json["uInt"].uInt!, 4)
        XCTAssertEqual(json["float"].float!, 5.5)
        XCTAssertEqual(json["bool"].bool!, true)
        XCTAssertEqual(json["array"].array!.map { $0.intValue }, [1, 2, 3, 4, 5])
        XCTAssertEqual(json["dictionary"].dictionary!, ["string1" : "String 1", "string2" : "String 2", "string3" : "String 3"])
    }
    
    // MARK: - Assignment
    
    func testAssignment() {
        
        var json: JSON = [
            "string" : "Test String",
            "int" : 2,
            "float" : 5.5,
            "bool" : true,
            "any_value" : "non-nil",
            "array" : [1, 2, 3, 4, 5],
            "dictionary" : [
                "string1" : "String 1",
                "string2" : "String 2",
                "string3" : "String 3"
            ]
        ]
        
        // Before assignment
        XCTAssertEqual(json["string"].string!, "Test String")
        XCTAssertEqual(json["int"].int!, 2)
        XCTAssertEqual(json["float"].float!, 5.5)
        XCTAssertEqual(json["bool"].bool!, true)
        XCTAssertEqual(json["any_value"].string!, "non-nil")
        XCTAssertEqual(json["array"].array!.map { $0.intValue }, [1, 2, 3, 4, 5])
        XCTAssertEqual(json["dictionary"].dictionary!, ["string1" : "String 1", "string2" : "String 2", "string3" : "String 3"])
        
        // Assignment
        json["string"] = "Test String 2"
        json["int"] = 5
        json["float"] = 15.25
        json["bool"] = false
        json["any_value"] = nil
        json["array"] = [6, 7, 8, 9, 10]
        json["dictionary"] = ["string4" : "String 4", "string5" : "String 5", "string6" : "String 6"]
        
        // After assignment
        XCTAssertEqual(json["string"].string!, "Test String 2")
        XCTAssertEqual(json["int"].int!, 5)
        XCTAssertEqual(json["float"].float!, 15.25)
        XCTAssertEqual(json["bool"].bool!, false)
        XCTAssertNil(json["any_value"].string)
        XCTAssertEqual(json["array"].array!.map { $0.intValue }, [6, 7, 8, 9, 10])
        XCTAssertEqual(json["dictionary"].dictionary!, ["string4" : "String 4", "string5" : "String 5", "string6" : "String 6"])
    }
    
    // MARK: - Equatable
    
    func testEquatable() {
        var lhs: JSON = [
            "string" : "Test String",
            "int" : 2,
            "float" : 5.5,
            "bool" : true,
            "url" : "http://ovenbits.com",
            "array" : [1, 2, 3, 4, 5],
            "dictionary" : [
                "string1" : "String 1",
                "string2" : "String 2",
                "string3" : "String 3"
            ]
        ]
        
        var rhs: JSON = [
            "string" : "Test String",
            "int" : 2,
            "float" : 5.5,
            "bool" : true,
            "url" : "http://ovenbits.com",
            "array" : [1, 2, 3, 4, 5],
            "dictionary" : [
                "string1" : "String 1",
                "string2" : "String 2",
                "string3" : "String 3"
            ]
        ]
        
        XCTAssertTrue(lhs["string"] == rhs["string"])
        XCTAssertTrue(lhs["int"] == rhs["int"])
        XCTAssertTrue(lhs["float"] == rhs["float"])
        XCTAssertTrue(lhs["bool"] == rhs["bool"])
        XCTAssertTrue(lhs["url"].URL == rhs["url"].URL)
        XCTAssertTrue(lhs["array"] == rhs["array"])
        XCTAssertTrue(lhs["dictionary"] == rhs["dictionary"])
        XCTAssertTrue(lhs == rhs)
    }
    
    // MARK: - String
    
    func testStringLiteralConvertible() {
        let json: JSON = "abcdefg"
        
        XCTAssertEqual(json.string!, "abcdefg")
        XCTAssertEqual(json.stringValue, "abcdefg")
    }
    
    func testString() {
        // Good value
        XCTAssertEqual(json["string"].string!, "Test string")
        XCTAssertEqual(json["string"].stringValue, "Test string")
        
        // Mistyped value
        XCTAssertNil(json["float"].string)
        XCTAssertEqual(json["float"].stringValue, "")
        
        // Missing value
        XCTAssertNil(json["string2"].string)
        XCTAssertEqual(json["string2"].stringValue, "")
        
        // CustomStringConvertible
        XCTAssertEqual(json["string"].description, "Test string")
        XCTAssertEqual(json["string"].debugDescription, "Test string")
    }
    
    // MARK: - NSNumber
    
    func testNumber() {
        // Good value
        XCTAssertEqual(json["number"].number!, 3)
        XCTAssertEqual(json["number"].numberValue, 3)
        
        // Mistyped value
        XCTAssertNil(json["string"].number)
        XCTAssertEqual(json["string"].numberValue, 0)
        
        // Missing value
        XCTAssertNil(json["number2"].number)
        XCTAssertEqual(json["number2"].numberValue, 0)
        
        // CustomStringConvertible
        XCTAssertEqual(json["number"].description, "3")
        XCTAssertEqual(json["number"].debugDescription, "3")
    }
    
    // MARK: - Float
    
    func testFloatLiteralConvertible() {
        let json: JSON = 1.234
        
        XCTAssertEqual(json.float!, 1.234)
        XCTAssertEqual(json.floatValue, 1.234)
    }
    
    func testFloat() {
        // Good value
        XCTAssertEqual(json["float"].float!, 4.75)
        XCTAssertEqual(json["float"].floatValue, 4.75)
        
        // Mistyped value
        XCTAssertNil(json["string"].float)
        XCTAssertEqual(json["string"].floatValue, 0)
        
        // Missing value
        XCTAssertNil(json["float2"].float)
        XCTAssertEqual(json["float2"].floatValue, 0)
        
        // CustomStringConvertible
        XCTAssertEqual(json["float"].description, "4.75")
        XCTAssertEqual(json["float"].debugDescription, "4.75")
    }
    
    // MARK: - Double
    
    func testDouble() {
        // Good value
        XCTAssertEqual(json["double"].double!, 7.5)
        XCTAssertEqual(json["double"].doubleValue, 7.5)
        
        // Mistyped value
        XCTAssertNil(json["string"].double)
        XCTAssertEqual(json["string"].doubleValue, 0)
        
        // Missing value
        XCTAssertNil(json["double2"].double)
        XCTAssertEqual(json["double2"].doubleValue, 0)
        
        // CustomStringConvertible
        XCTAssertEqual(json["double"].description, "7.5")
        XCTAssertEqual(json["double"].debugDescription, "7.5")
    }
    
    // MARK: - Int
    
    func testIntegerLiteralConvertible() {
        let json: JSON = -2
        
        XCTAssertEqual(json.int!, -2)
        XCTAssertEqual(json.intValue, -2)
    }
    
    func testInt() {
        // Good value
        XCTAssertEqual(json["int"].int!, -23)
        XCTAssertEqual(json["int"].intValue, -23)
        
        // Mistyped value
        XCTAssertNil(json["string"].int)
        XCTAssertEqual(json["string"].intValue, 0)
        
        // Missing value
        XCTAssertNil(json["int2"].int)
        XCTAssertEqual(json["int2"].intValue, 0)
        
        // CustomStringConvertible
        XCTAssertEqual(json["int"].description, "-23")
        XCTAssertEqual(json["int"].debugDescription, "-23")
    }
    
    // MARK: - UInt
    
    func testUInt() {
        XCTAssertEqual(json["u_int"].uInt!, 25)
        XCTAssertEqual(json["u_int"].uIntValue, 25)
        
        // Mistyped value
        XCTAssertNil(json["string"].uInt)
        XCTAssertEqual(json["string"].uIntValue, 0)
        
        // Missing value
        XCTAssertNil(json["u_int2"].uInt)
        XCTAssertEqual(json["u_int2"].uIntValue, 0)
        
        // CustomStringConvertible
        XCTAssertEqual(json["u_int"].description, "25")
        XCTAssertEqual(json["u_int"].debugDescription, "25")
    }
    
    // MARK: - Bool
    
    func testBooleanLiteralConvertible() {
        let json: JSON = true
        
        XCTAssertTrue(json.bool!)
        XCTAssertTrue(json.boolValue)
    }
    
    func testBool() {
        // Good value
        XCTAssertTrue(json["bool"].bool!)
        XCTAssertTrue(json["bool"].boolValue)
        
        // Mistyped value
        XCTAssertNil(json["string"].bool)
        XCTAssertEqual(json["string"].boolValue, false)
        
        // Missing value
        XCTAssertNil(json["bool2"].bool)
        XCTAssertEqual(json["bool2"].boolValue, false)
        
        // CustomStringConvertible
        XCTAssertEqual(json["bool"].description, "1")
        XCTAssertEqual(json["bool"].debugDescription, "1")
    }
    
    // MARK: - NSURL
    
    func testURL() {
        // Good value
        XCTAssertEqual(json["url"].URL!, NSURL(string: "http://ovenbits.com")!)
        
        // Mistyped value
        XCTAssertNil(json["int"].URL)
        
        // Missing value
        XCTAssertNil(json["url2"].URL)
        
        // CustomStringConvertible
        XCTAssertEqual(json["url"].description, "http://ovenbits.com")
        XCTAssertEqual(json["url"].debugDescription, "http://ovenbits.com")
    }
    
    // MARK: - Array
    
    func testArrayLiteralConvertible() {
        let json: JSON = [1, 2, 3, 4, 5]
        
        XCTAssertEqual(json[0].intValue, 1)
        XCTAssertEqual(json[1].intValue, 2)
        XCTAssertEqual(json[2].intValue, 3)
        XCTAssertEqual(json[3].intValue, 4)
        XCTAssertEqual(json[4].intValue, 5)
        XCTAssertEqual(json.arrayValue.count, 5)
    }
    
    func testArray() {
        // Good values
        XCTAssertEqual(json["array"].arrayValue[0].intValue, 1)
        XCTAssertEqual(json["array"].arrayValue[1].intValue, 2)
        XCTAssertEqual(json["array"].arrayValue[2].intValue, 3)
        XCTAssertEqual(json["array"].arrayValue[3].intValue, 4)
        XCTAssertEqual(json["array"].arrayValue[4].intValue, 5)
        XCTAssertEqual(json["array"].arrayValue.count, 5)
        
        // Mistyped values
        XCTAssertNil(json["string"].arrayValue.first?.intValue)
        XCTAssertEqual(json["string"].arrayValue.count, 0)
        
        // Missing values
        XCTAssertNil(json["array2"].arrayValue.first?.intValue)
        XCTAssertEqual(json["array2"].arrayValue.count, 0)
        
        // CollectionType
        XCTAssertEqual(json["array"].startIndex, 0)
        XCTAssertEqual(json["array"].endIndex, 5)
        XCTAssertEqual(json["array"][0].intValue, 1)
    }
    
    // MARK: - NSNull (from loaded data)
    
    func testNSNull() {
        let jsonPath = NSBundle(forClass: self.dynamicType).pathForResource("Tests", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        let json = JSON(data: jsonData)
        
        XCTAssertFalse(json["driver"].hasValue)
    }
    
    // MARK: - Dictionary
    
    func testDictionaryLiteralConvertible() {
        var json: JSON = [
            "string1" : "String 1",
            "string2" : "String 2",
            "string3" : "String 3"
        ]
        
        XCTAssertEqual(json["string1"].stringValue, "String 1")
        XCTAssertEqual(json["string2"].stringValue, "String 2")
        XCTAssertEqual(json["string3"].stringValue, "String 3")
        XCTAssertEqual(json.dictionaryValue.count, 3)
    }
    
    func testDictionary() {
        // Good values
        XCTAssertEqual(json["dictionary"].dictionaryValue["string1"]!.stringValue, "String 1")
        XCTAssertEqual(json["dictionary"].dictionaryValue["string2"]!.stringValue, "String 2")
        XCTAssertEqual(json["dictionary"].dictionaryValue["string3"]!.stringValue, "String 3")
        XCTAssertEqual(json["dictionary"].dictionaryValue.count, 3)
        
        // Mistyped values
        XCTAssertEqual(json["string"].dictionaryValue.count, 0)
        
        // Missing values
        XCTAssertNil(json["dictionary2"].dictionaryValue["string1"]?.string)
        XCTAssertEqual(json["dictionary2"].dictionaryValue.count, 0)
        
        // Subscripts
        XCTAssertEqual(json["dictionary"]["string1"].stringValue, "String 1")
        XCTAssertEqual(json["dictionary"]["string2"].stringValue, "String 2")
        XCTAssertEqual(json["dictionary"]["string3"].stringValue, "String 3")
    }
}
