//
//  Extensions.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-06.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import Foundation

class Extensions {
    
    enum BodyType: Int {
        case box = 1
        case floor = 2
    }
    
    struct myCameraPos {
        var x = Float()
        var y = Float()
        var z = Float()
    }
    
    class func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
}
