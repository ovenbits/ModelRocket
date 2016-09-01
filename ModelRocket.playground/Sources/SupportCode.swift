//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to ModelRocket.playground.
//

import Foundation

public func dataFromResource() -> Data {
    let path = Bundle.main.path(forResource: "TestJSON", ofType: "json")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: path))
    
    return data
}
