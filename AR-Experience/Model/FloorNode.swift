//
//  FloorNode.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-13.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class FloorNode {
    class func createFloor(anchor: ARPlaneAnchor) -> SCNNode {

            let floorNode = SCNNode()
            let radian = Extensions.deg2rad(90)
            floorNode.name = "floor"
            floorNode.eulerAngles = SCNVector3(radian, 0, 0)
            floorNode.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
            floorNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            floorNode.geometry?.firstMaterial?.isDoubleSided = true
            floorNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
    //        let floorBodyShape = SCNPhysicsShape(geometry: floorNode.geometry!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
            floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil) // or shape floorbodyshape
            floorNode.physicsBody?.categoryBitMask = Extensions.BodyType.floor.rawValue

            return floorNode
        }
}
