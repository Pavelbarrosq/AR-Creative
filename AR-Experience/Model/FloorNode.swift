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

class FloorNode: SCNNode {
    
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.extent.x);
        planeGeometry.height = CGFloat(anchor.extent.z);
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        
        let planeNode = self.childNodes.first!
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
    }
    
    private func setup() {
        planeGeometry = SCNPlane(width: CGFloat(self.anchor.extent.x), height: CGFloat(self.anchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"art.scnassets/grid.png")
        
        planeGeometry.materials = [material]
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = Extensions.BodyType.floor.rawValue
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);

        addChildNode(planeNode)
    }
    
    
    
    
    
    
    
    
    
    
    
    
//    class func createFloor(anchor: ARPlaneAnchor) -> SCNNode {
//
//            let floorNode = SCNNode()
//            let radian = Extensions.deg2rad(90)
//            floorNode.name = "floor"
//            floorNode.eulerAngles = SCNVector3(radian, 0, 0)
//            floorNode.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//            floorNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
//            floorNode.geometry?.firstMaterial?.isDoubleSided = true
//            floorNode.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
//    //        let floorBodyShape = SCNPhysicsShape(geometry: floorNode.geometry!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
//            floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil) // or shape floorbodyshape
//            floorNode.physicsBody?.categoryBitMask = Extensions.BodyType.floor.rawValue
//
//            return floorNode
//        }
}
