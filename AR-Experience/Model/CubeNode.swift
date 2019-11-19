//
//  Nodes.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-13.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class CubeNode {
    class func createCubeNode(inSceneView view: ARSCNView, position pos: SCNVector3, withColor color: UIColor){
        
        let cubeNode = SCNNode()
        cubeNode.geometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.002)
        cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.cyan
        
        cubeNode.position = pos
//        cubeNode.position = SCNVector3(pos.x, pos.y, pos.z)
        cubeNode.name = "cube"
        
        cubeNode.physicsBody?.restitution = 0.8
        cubeNode.physicsBody?.mass = 1
        cubeNode.physicsBody?.rollingFriction = 0
        let cubeBodyShape = SCNPhysicsShape(geometry: cubeNode.geometry!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        cubeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: cubeBodyShape)
        cubeNode.physicsBody?.categoryBitMask = Extensions.BodyType.box.rawValue
        cubeNode.physicsBody?.collisionBitMask = Extensions.BodyType.floor.rawValue | Extensions.BodyType.box.rawValue
        cubeNode.physicsBody?.contactTestBitMask = Extensions.BodyType.floor.rawValue | Extensions.BodyType.box.rawValue
        
        view.scene.rootNode.addChildNode(cubeNode)
    }
}
