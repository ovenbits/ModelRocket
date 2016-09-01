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

#if os(iOS)
import UIKit
#endif

public protocol JSONTransformable {
    /// Extract object from JSON
    static func from(json: JSON) -> Self?
    
    /// Convert object to JSON
    func toJSON() -> Any
}

// MARK: Default implementation for Model subclasses

extension JSONTransformable where Self: Model {
    public static func from(json: JSON) -> Self? {
        return Self.init(strictJSON: json)
    }
    public func toJSON() -> Any {
        return json.dictionary
    }
}

// MARK: Default implementation for RawRepresentable types

extension JSONTransformable where Self: RawRepresentable, Self.RawValue == String {
    public static func from(json: JSON) -> Self? {
        return Self(rawValue: json.stringValue)
    }
    public func toJSON() -> Any {
        return rawValue
    }
}

extension JSONTransformable where Self: RawRepresentable, Self.RawValue == Int {
    public static func from(json: JSON) -> Self? {
        return Self(rawValue: json.intValue)
    }
    public func toJSON() -> Any {
        return rawValue
    }
}

// MARK: String

extension String: JSONTransformable {
    public static func from(json: JSON) -> String? {
        return json.string
    }
    public func toJSON() -> Any {
        return self
    }
}

// MARK: Date

extension Date: JSONTransformable {
    private static var JSONTransformableDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }
    public static func from(json: JSON) -> Date? {
        if let dateString = json.string {
            return JSONTransformableDateFormatter.date(from: dateString)
        }
        return nil
    }
    public func toJSON() -> Any {
        return Date.JSONTransformableDateFormatter.string(from: self)
    }
}

// MARK: UIColor
#if os(iOS)
extension UIColor: JSONTransformable {
    public class func from(json: JSON) -> Self? {
        if let string = json.string {
            var hexString = string
            
            if (hexString.hasPrefix("#")) {
                hexString = hexString.substring(from: hexString.index(after: hexString.startIndex))
            }
            
            let scanner = Scanner(string: hexString)
            var hex: UInt32 = 0
            scanner.scanHexInt32(&hex)

            let r = (hex >> 16) & 0xFF
            let g = (hex >> 8) & 0xFF
            let b = hex & 0xFF
            
            return self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
        }
        return nil
    }
    public func toJSON() -> Any {
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let hexString = String(format: "#%02x%02x%02x", Int(255*r),Int(255*g),Int(255*b)).uppercased()
        
        return hexString
    }
}
#endif

// MARK: Bool

extension Bool: JSONTransformable {
    public static func from(json: JSON) -> Bool? {
        return json.bool
    }
    public func toJSON() -> Any {
        return self
    }
}

// MARK: URL

extension URL: JSONTransformable {
    public static func from(json: JSON) -> URL? {
        return json.url
    }
    public func toJSON() -> Any {
        return absoluteString
    }
}

// MARK: Double

extension Double: JSONTransformable {
    public static func from(json: JSON) -> Double? {
        return json.double
    }
    public func toJSON() -> Any {
        return self
    }
}

// MARK: Float

extension Float: JSONTransformable {
    public static func from(json: JSON) -> Float? {
        return json.float
    }
    public func toJSON() -> Any {
        return self
    }
}


// MARK: Int

extension Int: JSONTransformable {
    public static func from(json: JSON) -> Int? {
        return json.int
    }
    public func toJSON() -> Any {
        return self
    }
}

// MARK: UInt

extension UInt: JSONTransformable {
    public static func from(json: JSON) -> UInt? {
        return json.uInt
    }
    public func toJSON() -> Any {
        return self
    }
}
