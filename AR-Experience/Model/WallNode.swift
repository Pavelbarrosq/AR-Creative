//
//  WallNode.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-13.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class WallNode {
    
    class func createWall(withAnchor anchor: ARPlaneAnchor) -> SCNNode {
        let radian = Extensions.deg2rad(90)
        let wallNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)))
        wallNode.name = "wall"
        wallNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
        wallNode.eulerAngles = SCNVector3(radian, 0, 0)
        wallNode.geometry?.firstMaterial?.isDoubleSided = true
        return wallNode
        }
}
