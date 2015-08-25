//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to ModelRocket.playground.
//

import Foundation

public func dataFromResource() -> NSData {
    let jsonPath = NSBundle.mainBundle().pathForResource("TestJSON", ofType: "json")
    let jsonData = NSData(contentsOfFile: jsonPath!)
    
    return jsonData!
}