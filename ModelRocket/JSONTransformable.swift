// JSONTransformable.swift
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
import UIKit

public protocol JSONTransformable {
    typealias T
    
    /// Extract object from JSON
    static func fromJSON(json: JSON) -> T?
    
    /// Convert object to JSON
    func toJSON() -> AnyObject
}

// MARK: Default implementation for Model subclasses

extension JSONTransformable where Self: Model {
    public static func fromJSON(json: JSON) -> Self? {
        return Self.init(strictJSON: json)
    }
    public func toJSON() -> AnyObject {
        return json().dictionary
    }
}

// MARK: Default implementation for RawRepresentable types

extension JSONTransformable where Self: RawRepresentable, Self.RawValue == String {
    public static func fromJSON(json: JSON) -> Self? {
        return Self(rawValue: json.stringValue)
    }
    public func toJSON() -> AnyObject {
        return rawValue
    }
}

extension JSONTransformable where Self: RawRepresentable, Self.RawValue == Int {
    public static func fromJSON(json: JSON) -> Self? {
        return Self(rawValue: json.intValue)
    }
    public func toJSON() -> AnyObject {
        return rawValue
    }
}

// MARK: String

extension String: JSONTransformable {
    public static func fromJSON(json: JSON) -> String? {
        return json.string
    }
    public func toJSON() -> AnyObject {
        return self
    }
}

// MARK: NSDate

extension NSDate: JSONTransformable {
    private class var JSONTransformableDateFormatter: NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }
    public class func fromJSON(json: JSON) -> NSDate? {
        if let dateString = json.string {
            return JSONTransformableDateFormatter.dateFromString(dateString)
        }
        return nil
    }
    public func toJSON() -> AnyObject {
        return NSDate.JSONTransformableDateFormatter.stringFromDate(self)
    }
}

// MARK: UIColor

extension UIColor: JSONTransformable {
    public class func fromJSON(json: JSON) -> UIColor? {
        if var hexString = json.string {
            if (hexString.hasPrefix("#")) {
                hexString = (hexString as NSString).substringFromIndex(1)
            }
            
            let scanner = NSScanner(string: hexString)
            var hex: UInt32 = 0
            scanner.scanHexInt(&hex)

            let r = (hex >> 16) & 0xFF
            let g = (hex >> 8) & 0xFF
            let b = hex & 0xFF
            
            return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
        }
        return nil
    }
    public func toJSON() -> AnyObject {
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let hexString = NSString(format: "#%02x%02x%02x", Int(255*r),Int(255*g),Int(255*b)).uppercaseString
        
        return hexString
    }
}

// MARK: Bool

extension Bool: JSONTransformable {
    public static func fromJSON(json: JSON) -> Bool? {
        return json.bool
    }
    public func toJSON() -> AnyObject {
        return self
    }
}

// MARK: NSURL

extension NSURL: JSONTransformable {
    public class func fromJSON(json: JSON) -> NSURL? {
        return json.URL
    }
    public func toJSON() -> AnyObject {
        return absoluteString
    }
}

// MARK: NSNumber

extension NSNumber: JSONTransformable {
    public class func fromJSON(json: JSON) -> NSNumber? {
        return json.number
    }
    public func toJSON() -> AnyObject {
        return self
    }
}

// MARK: Double

extension Double: JSONTransformable {
    public static func fromJSON(json: JSON) -> Double? {
        return json.double
    }
    public func toJSON() -> AnyObject {
        return self
    }
}

// MARK: Float

extension Float: JSONTransformable {
    public static func fromJSON(json: JSON) -> Float? {
        return json.float
    }
    public func toJSON() -> AnyObject {
        return self
    }
}


// MARK: Int

extension Int: JSONTransformable {
    public static func fromJSON(json: JSON) -> Int? {
        return json.int
    }
    public func toJSON() -> AnyObject {
        return self
    }
}

// MARK: UInt

extension UInt: JSONTransformable {
    public static func fromJSON(json: JSON) -> UInt? {
        return json.uInt
    }
    public func toJSON() -> AnyObject {
        return self
    }
}
