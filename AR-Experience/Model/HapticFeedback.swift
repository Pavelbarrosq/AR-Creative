//
//  HapticFeedback.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-20.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import Foundation
import UIKit

class HapticFeedback {
    
    class func createImpactFeedback() -> UIImpactFeedbackGenerator {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
 
        return impactFeedback
    }
    
}
