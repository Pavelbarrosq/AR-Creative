//
//  SphereNode.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-13.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class SphereNode {
    class func createSphere(atPosition pos: SCNVector3, withcolor color: UIColor) -> SCNNode {
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
        sphereNode.geometry?.firstMaterial?.diffuse.contents = color
        sphereNode.position = pos
        
        return sphereNode
    }
}
