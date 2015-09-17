// PropertyDescription.swift
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

public protocol PropertyDescription {
    
    /// JSON parameter key
    var key: String { get }
    
    /// Type information
    var type: String { get }
    
    /// Specify whether value is required
    var required: Bool { get }
    
    /// Extract object from JSON and return whether or not the value was extracted
    func fromJSON(json: JSON) -> Bool
    
    /// Convert object to JSON
    func toJSON() -> AnyObject?
    
    /// Encode object for NSCoder
    func encode(coder: NSCoder)
    
    /// Encode object from NSCoder
    func decode(decoder: NSCoder)
    
    /// After the whole Model object has been initialized and its Property properties initalized fromJSON(),
    /// invoked to permit further post-processing of the Property that may depend upon other information from the
    /// whole of the Model object.
    func initPostProcess()
}