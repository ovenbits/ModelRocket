// ModelRocketTests.swift
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

class ModelRocketTests: XCTestCase {
    
    var testModel = TestModel()
    var testArrayModel = TestArrayModel()
    var testDictionaryModel = TestDictionaryModel()
    var testSimpleNestedModel = TestSimpleNestedModel()
    var testComplexNestedModel = TestComplexNestedModel()
    var testVeryComplexNestedModel = TestVeryComplexNestedModel()
    var testSubclassModel = TestSubclassModel()
    var testRequiredModel: TestRequiredModel?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // Setup test model
        var jsonString = "{\"string\" : \"Test string\", \"date\" : \"2015-02-04T18:30:15.000Z\", \"color\" : \"#00FF00\", \"bool\" : true, \"url\" : \"http://ovenbits.com\", \"number\": 3, \"double\" : 7.5, \"float\" : 4.75, \"int\" : -23, \"u_int\" : 25}"
        var jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var json = JSON(data: jsonData!)
        testModel = TestModel(json: json)
        
        // Setup test array model
        jsonString = "{\"strings\" : [ \"string1\", \"string2\", \"string3\", \"string4\" ]}"
        jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        json = JSON(data: jsonData!)
        testArrayModel = TestArrayModel(json: json)
        
        // Setup test dictionary model
        jsonString = "{\"ints\" : {\"int1\" : 1, \"int2\" : 2, \"int3\" : 3}}"
        jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        json = JSON(data: jsonData!)
        testDictionaryModel = TestDictionaryModel(json: json)
        
        // Setup test simple nested model
        jsonString = "{\"nest1\" : {\"nest2\" : { \"nestedString\" : \"string1\" }, \"nestedInt\": 2}}"
        jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        json = JSON(data: jsonData!)
        testSimpleNestedModel = TestSimpleNestedModel(json: json)
        
        // Setup test complex nested model
        jsonString = "{ \"int1\" : 1, \"nest1\" : { \"nest2\" : { \"nest3\" : { \"nest4\" : { \"string1\" : \"string1\" }}, \"int2\" : 2 }, \"string2\" : \"string2\" }}"
        jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        json = JSON(data: jsonData!)
        testComplexNestedModel = TestComplexNestedModel(json: json)
        
        // Setup test very complex nested model
        jsonString = "{ \"nest1\" : { \"nest2\" : { \"nest3\" : { \"nest4\" : { \"string1\" : \"string1\" }, \"nest5\" : { \"string2\" : \"string2\" } }, \"nest6\" : { \"nest7\" : { \"string3\" : \"string3\" } } }, \"string4\" : \"string4\" } }"
        jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        json = JSON(data: jsonData!)
        testVeryComplexNestedModel = TestVeryComplexNestedModel(json: json)
        
        // Setup test subclass model
        jsonString = "{\"string\" : \"Test string\", \"date\" : \"2015-02-04T18:30:15.000Z\", \"color\" : \"#00FF00\", \"bool\" : true, \"url\" : \"http://ovenbits.com\", \"number\": 3, \"double\" : 7.5, \"float\" : 4.75, \"int\" : -23, \"u_int\" : 25, \"string2\" : \"Test string 2\"}"
        jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        json = JSON(data: jsonData!)
        testSubclassModel = TestSubclassModel(json: json)
        
        // Setup test strict JSON model
        jsonString = "{\"unrequired_int\" : 1}"
        jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        json = JSON(data: jsonData!)
        testRequiredModel = TestRequiredModel(strictJSON: json)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testString() {
        if let string = testModel.string.value {
            XCTAssertEqual(string, "Test string", "Strings not equal")
        }
        else {
            XCTAssert(false, "Test string should not be nil")
        }
    }
    
    func testDate() {
        if let date = testModel.date.value {
            
            let calendar = NSCalendar.currentCalendar()
            let units: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second, .Nanosecond]
            let components = calendar.components(units, fromDate: date)
            
            XCTAssertEqual(components.year, 2015, "Date: years not equal")
            XCTAssertEqual(components.month, 2, "Date: months not equal")
            XCTAssertEqual(components.day, 4, "Date: days not equal")
            XCTAssertEqual(components.hour, 18, "Date: hours not equal")
            XCTAssertEqual(components.minute, 30, "Date: minutes not equal")
            XCTAssertEqual(components.second, 15, "Date: seconds not equal")
        }
        else {
            XCTAssert(false, "Test date should not be nil")
        }
    }
    
    func testColor() {
        if let color = testModel.color.value {
            XCTAssertEqual(color, UIColor.greenColor(), "Colors not equal")
        }
        else {
            XCTAssert(false, "Test color should not be nil")
        }
    }
    
    func testBool() {
        if let bool = testModel.bool.value {
            XCTAssertEqual(bool, true, "Bools not equal")
        }
        else {
            XCTAssert(false, "Test bool should not be nil")
        }
    }
    
    func testURL() {
        if let url = testModel.url.value {
            XCTAssertEqual(url, NSURL(string: "http://ovenbits.com")!, "URLs not equal")
        }
        else {
            XCTAssert(false, "Test URL should not be nil")
        }
    }
    
    func testNumber() {
        if let number = testModel.number.value {
            XCTAssertEqual(number, NSNumber(int: 3), "Numbers not equal")
        }
        else {
            XCTAssert(false, "Test number should not be nil")
        }
    }
    
    func testDouble() {
        if let double = testModel.double.value {
            XCTAssertEqual(double, 7.5, "Doubles not equal")
        }
        else {
            XCTAssert(false, "Test double should not be nil")
        }
    }
    
    func testFloat() {
        if let float = testModel.float.value {
            XCTAssertEqual(float, Float(4.75), "Floats not equal")
        }
        else {
            XCTAssert(false, "Test float should not be nil")
        }
    }
    
    func testInt() {
        if let int = testModel.int.value {
            XCTAssertEqual(int, -23, "Ints not equal")
        }
        else {
            XCTAssert(false, "Test int should not be nil")
        }
    }
    
    func testUInt() {
        if let uInt = testModel.uInt.value {
            XCTAssertEqual(uInt, UInt(25), "UInts not equal")
        }
        else {
            XCTAssert(false, "Test uInt should not be nil")
        }
    }
    
    func testJSON() {
        if let json = testModel.json().json {
            XCTAssertEqual(json["string"].stringValue, "Test string", "Strings not equal")
            XCTAssertEqual(json["date"].stringValue, "2015-02-04T18:30:15.000Z", "Dates not equal")
            XCTAssertEqual(json["color"].stringValue, "#00FF00", "Colors not equal")
            XCTAssertEqual(json["bool"].boolValue, true, "Bools not equal")
            
            if let url = json["url"].URL {
                XCTAssertEqual(url, NSURL(string: "http://ovenbits.com")!, "URLs not equal")
            }
            else {
                XCTAssert(false, "URL should not be nil")
            }
            
            XCTAssertEqual(json["number"].numberValue, NSNumber(int: 3), "Numbers not equal")
            XCTAssertEqual(json["double"].doubleValue, 7.5, "Doubles not equal")
            XCTAssertEqual(json["float"].floatValue, Float(4.75), "Floats not equal")
            XCTAssertEqual(json["int"].intValue, -23, "Ints not equal")
            XCTAssertEqual(json["u_int"].uIntValue, UInt(25), "UInts not equal")
        }
        else {
            XCTAssert(false, "JSON should not be nil")
        }
    }
    
    func testCoding() {
        
        let archived = NSKeyedArchiver.archivedDataWithRootObject(testModel)
        if let unarchived = NSKeyedUnarchiver.unarchiveObjectWithData(archived) as? TestModel {
            
            if let string = unarchived.string.value { XCTAssertEqual(string, "Test string", "Strings not equal") }
            else { XCTAssert(false, "Coding: string should not be nil") }
            
            if let date = unarchived.date.value {
                let calendar = NSCalendar.currentCalendar()
                let units: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second, .Nanosecond]
                let components = calendar.components(units, fromDate: date)
                
                XCTAssertEqual(components.year, 2015, "Date: years not equal")
                XCTAssertEqual(components.month, 2, "Date: months not equal")
                XCTAssertEqual(components.day, 4, "Date: days not equal")
                XCTAssertEqual(components.hour, 18, "Date: hours not equal")
                XCTAssertEqual(components.minute, 30, "Date: minutes not equal")
                XCTAssertEqual(components.second, 15, "Date: seconds not equal")
            }
            else {
                XCTAssert(false, "Coding: date should not be nil")
            }
            
            if let color = unarchived.color.value { XCTAssertEqual(color, UIColor.greenColor(), "Colors not equal") }
            else { XCTAssert(false, "Coding: color should not be nil") }
            
            if let bool = unarchived.bool.value { XCTAssertEqual(bool, true, "Bools not equal") }
            else { XCTAssert(false, "Coding: bool should not be nil") }
            
            if let url = unarchived.url.value { XCTAssertEqual(url, NSURL(string: "http://ovenbits.com")!, "URLs not equal") }
            else { XCTAssert(false, "Coding: url should not be nil") }
            
            if let number = unarchived.number.value { XCTAssertEqual(number, NSNumber(int: 3), "Numbers not equal") }
            else { XCTAssert(false, "Coding: number should not be nil") }
            
            if let double = unarchived.double.value { XCTAssertEqual(double, 7.5, "Doubles not equal") }
            else { XCTAssert(false, "Coding: double should not be nil") }
            
            if let float = unarchived.float.value { XCTAssertEqual(float, Float(4.75), "Floats not equal") }
            else { XCTAssert(false, "Coding: float should not be nil") }
            
            if let int = unarchived.int.value { XCTAssertEqual(int, -23, "Ints not equal") }
            else { XCTAssert(false, "Coding: int should not be nil") }
            
            if let uInt = unarchived.uInt.value { XCTAssertEqual(uInt, UInt(25), "UInts not equal") }
            else { XCTAssert(false, "Coding: uInt should not be nil") }
            
        }
        else {
            XCTAssert(false, "Unarchived object should not be nil")
        }
    }
    
    func testArray() {
        XCTAssertEqual(testArrayModel.strings.values[0], "string1", "Strings not equal")
        XCTAssertEqual(testArrayModel.strings.values[1], "string2", "Strings not equal")
        XCTAssertEqual(testArrayModel.strings.values[2], "string3", "Strings not equal")
        XCTAssertEqual(testArrayModel.strings.values[3], "string4", "Strings not equal")
    }
    
    func testArrayJSON() {
        if let json = testArrayModel.json().json {
            let jsonArray = json["strings"].array
            
            for i in 0...3 {
                let string = "string\(i + 1)"
                
                if let jsonString = jsonArray?[i].string {
                    XCTAssertEqual(jsonString, string, "Strings not equal")
                }
                else {
                    XCTAssert(false, "Array JSON: \(string) should not be nil")
                }
            }
        }
    }
    
    func testArrayCoding() {
        let archived = NSKeyedArchiver.archivedDataWithRootObject(testArrayModel)
        if let unarchived = NSKeyedUnarchiver.unarchiveObjectWithData(archived) as? TestArrayModel {
            XCTAssertEqual(unarchived.strings.values[0], "string1", "Strings not equal")
            XCTAssertEqual(unarchived.strings.values[1], "string2", "Strings not equal")
            XCTAssertEqual(unarchived.strings.values[2], "string3", "Strings not equal")
            XCTAssertEqual(unarchived.strings.values[3], "string4", "Strings not equal")
        }
    }
    
    func testCopy() {
        if let testModelCopy = testModel.copy() as? TestModel {
            testModelCopy.string.value = "Test string 2"
            
            if let originalString = testModel.string.value, modifiedString = testModelCopy.string.value {
                XCTAssertNotEqual(originalString, modifiedString, "Objects point to same reference")
            }
            else {
                XCTAssert(false, "Copy: strings should not be nil")
            }
        }
        else {
            XCTAssert(false, "Object copy: failed")
        }
    }
    
    func testArrayCopy() {
        if let testArrayCopy = testArrayModel.copy() as? TestArrayModel {
            testArrayCopy.strings.values[0] = "string5"
            XCTAssertNotEqual(testArrayModel.strings.values[0], testArrayCopy.strings.values[0], "Objects point to same reference")
        }
        else {
            XCTAssert(false, "Array copy: failed")
        }
    }
    
    func testDictionary() {
        if let int1 = testDictionaryModel.ints.values["int1"] { XCTAssertEqual(int1, 1, "Ints not equal") }
        else { XCTAssert(false, "Dictionary: int1 should not be nil") }
        
        if let int2 = testDictionaryModel.ints.values["int2"] { XCTAssertEqual(int2, 2, "Ints not equal") }
        else { XCTAssert(false, "Dictionary: int1 should not be nil") }
        
        if let int3 = testDictionaryModel.ints.values["int3"] { XCTAssertEqual(int3, 3, "Ints not equal") }
        else { XCTAssert(false, "Dictionary: int1 should not be nil") }
    }
    
    func testDictionaryJSON() {
        if let json = testDictionaryModel.json().json {
            let jsonDictionary = json["ints"].dictionary
            
            if let int1 = jsonDictionary?["int1"]?.int { XCTAssertEqual(int1, 1, "Ints not equal") }
            else { XCTAssert(false, "Dictionary JSON: int1 should not be nil") }
            
            if let int2 = jsonDictionary?["int2"]?.int { XCTAssertEqual(int2, 2, "Ints not equal") }
            else { XCTAssert(false, "Dictionary JSON: int2 should not be nil") }
            
            if let int3 = jsonDictionary?["int3"]?.int { XCTAssertEqual(int3, 3, "Ints not equal") }
            else { XCTAssert(false, "Dictionary JSON: int3 should not be nil") }
        }
    }
    
    func testDictionaryCoding() {
        let archived = NSKeyedArchiver.archivedDataWithRootObject(testDictionaryModel)
        if let unarchived = NSKeyedUnarchiver.unarchiveObjectWithData(archived) as? TestDictionaryModel {
            if let int1 = unarchived.ints.values["int1"] { XCTAssertEqual(int1, 1, "Ints not equal") }
            else { XCTAssert(false, "Dictionary coding: int1 should not be nil") }
            
            if let int2 = unarchived.ints.values["int2"] { XCTAssertEqual(int2, 2, "Ints not equal") }
            else { XCTAssert(false, "Dictionary coding: int2 should not be nil") }
            
            if let int3 = unarchived.ints.values["int3"] { XCTAssertEqual(int3, 3, "Ints not equal") }
            else { XCTAssert(false, "Dictionary coding: int3 should not be nil") }
        }
    }
    
    func testDictionaryCopy() {
        if let testDictionaryCopy = testDictionaryModel.copy() as? TestDictionaryModel {
            testDictionaryCopy.ints.values["int1"] = 4
            
            if let modelInt1 = testDictionaryModel.ints.values["int1"], testInt1 = testDictionaryCopy.ints.values["int1"] {
                XCTAssertNotEqual(modelInt1, testInt1, "Objects point to same reference")
            }
            else {
                XCTAssert(false, "Dictionary copy: int1 should not be nil")
            }
        }
        else {
            XCTAssert(false, "Dictionary copy: failed")
        }
    }
    
    func testSimpleNestedJSON() {
        if let json = testSimpleNestedModel.json().json {
            XCTAssertEqual(json["nest1"]["nestedInt"].intValue, 2, "Ints not equal")
            XCTAssertEqual(json["nest1"]["nest2"]["nestedString"].stringValue, "string1", "Strings not equal")
        }
        else {
            XCTAssert(false, "JSON should not be nil")
        }
    }
    
    func testComplexNestedJSON() {
        if let json = testComplexNestedModel.json().json {
            XCTAssertEqual(json["int1"].intValue, 1, "Ints not equal")
            XCTAssertEqual(json["nest1"]["nest2"]["int2"].intValue, 2, "Ints not equal")
            XCTAssertEqual(json["nest1"]["nest2"]["nest3"]["nest4"]["string1"].stringValue, "string1", "Strings not equal")
            XCTAssertEqual(json["nest1"]["string2"].stringValue, "string2", "Strings not equal")
        }
        else {
            XCTAssert(false, "JSON should not be nil")
        }
    }
    
    func testVeryComplexNestedJSON() {
        if let json = testVeryComplexNestedModel.json().json {
            XCTAssertEqual(json["nest1"]["nest2"]["nest3"]["nest4"]["string1"].stringValue, "string1", "Strings not equal")
            XCTAssertEqual(json["nest1"]["nest2"]["nest3"]["nest5"]["string2"].stringValue, "string2", "String not equal")
            XCTAssertEqual(json["nest1"]["nest2"]["nest6"]["nest7"]["string3"].stringValue, "string3", "Strings not equal")
            XCTAssertEqual(json["nest1"]["string4"].stringValue, "string4", "Strings not equal")
        }
        else {
            XCTAssert(false, "JSON should not be nil")
        }
    }
    
    func testSubclassJSON() {
        if let json = testSubclassModel.json().json {
            XCTAssertEqual(json["string"].stringValue, "Test string", "Strings not equal")
            XCTAssertEqual(json["date"].stringValue, "2015-02-04T18:30:15.000Z", "Dates not equal")
            XCTAssertEqual(json["color"].stringValue, "#00FF00", "Colors not equal")
            XCTAssertEqual(json["bool"].boolValue, true, "Bools not equal")
            
            if let jsonURL = json["url"].URL {
                XCTAssertEqual(jsonURL, NSURL(string: "http://ovenbits.com")!, "URLs not equal")
            }
            else {
                XCTAssert(false, "URL should not be nil")
            }
            
            XCTAssertEqual(json["number"].numberValue, NSNumber(int: 3), "Numbers not equal")
            XCTAssertEqual(json["double"].doubleValue, 7.5, "Doubles not equal")
            XCTAssertEqual(json["float"].floatValue, Float(4.75), "Floats not equal")
            XCTAssertEqual(json["int"].intValue, -23, "Ints not equal")
            XCTAssertEqual(json["u_int"].uIntValue, UInt(25), "UInts not equal")
            XCTAssertEqual(json["string2"].stringValue, "Test string 2", "Strings not equal")
        }
        else {
            XCTAssert(false, "JSON should not be nil")
        }
    }
    
    func testRequired() {
        // JSON missing required properties
        if testRequiredModel != nil {
            XCTAssert(false, "Object not nil")
        }
        
        var jsonString = "{\"required_string\" : \"string\"}"
        var jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        var json = JSON(data: jsonData!)
        testRequiredModel = TestRequiredModel(strictJSON: json)
        
        // JSON missing unrequired properties
        if let requiredString = testRequiredModel?.requiredString.value {
            XCTAssertEqual(requiredString, "string", "Strings not equal")
        }
        else {
            XCTAssert(false, "String should not be nil")
        }
        
        jsonString = "{\"required_string\" : \"string\", \"unrequired_int\" : 1}"
        jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        json = JSON(data: jsonData!)
        testRequiredModel = TestRequiredModel(strictJSON: json)
        
        // JSON missing no properties
        if let requiredString = testRequiredModel?.requiredString.value {
            XCTAssertEqual(requiredString, "string", "Strings not equal")
        }
        else {
            XCTAssert(false, "String should not be nil")
        }
        
        if let unrequiredInt = testRequiredModel?.unrequiredInt.value {
            XCTAssertEqual(unrequiredInt, 1, "Ints not equal")
        }
        else {
            XCTAssert(false, "Int should not be nil")
        }
    }
    
}

// MARK: - Models

class TestModel: Model {
    let string  = Property<String>(key: "string")
    let date    = Property<NSDate>(key: "date")
    let color   = Property<UIColor>(key: "color")
    let bool    = Property<Bool>(key: "bool")
    let url     = Property<NSURL>(key: "url")
    let number  = Property<NSNumber>(key: "number")
    let double  = Property<Double>(key: "double")
    let float   = Property<Float>(key: "float")
    let int     = Property<Int>(key: "int")
    let uInt    = Property<UInt>(key: "u_int")
}

class TestArrayModel: Model {
    let strings = PropertyArray<String>(key: "strings")
}

class TestDictionaryModel: Model {
    let ints = PropertyDictionary<Int>(key: "ints")
}

class TestSimpleNestedModel: Model {
    let nestedInt = Property<Int>(key: "nest1.nestedInt")
    let nestedString = Property<String>(key: "nest1.nest2.nestedString")
}

class TestComplexNestedModel: Model {
    let int1 = Property<Int>(key: "int1")
    let int2 = Property<Int>(key: "nest1.nest2.int2")
    let string1 = Property<String>(key: "nest1.nest2.nest3.nest4.string1")
    let string2 = Property<String>(key: "nest1.string2")
}

class TestVeryComplexNestedModel: Model {
    let string1 = Property<String>(key: "nest1.nest2.nest3.nest4.string1")
    let string2 = Property<String>(key: "nest1.nest2.nest3.nest5.string2")
    let string3 = Property<String>(key: "nest1.nest2.nest6.nest7.string3")
    let string4 = Property<String>(key: "nest1.string4")
}

class TestSubclassModel: TestModel {
    let string2 = Property<String>(key: "string2")
}

class TestRequiredModel: Model {
    let requiredString = Property<String>(key: "required_string", required: true)
    let unrequiredInt = Property<Int>(key: "unrequired_int")
}
