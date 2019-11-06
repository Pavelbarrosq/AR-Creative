//
//  ViewController.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-10-30.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

//enum BodyType: Int {
//    case box = 1
//    case floor = 2
//}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet weak var arView: ARSCNView!
    var configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [])
        arView.debugOptions = [.showFeaturePoints, .showPhysicsShapes, .showPhysicsFields ]
        arView.autoenablesDefaultLighting = true
        arView.delegate = self
        arView.scene.physicsWorld.contactDelegate = self
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
       
        addCube()
//        arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]

    }
    
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        resetScene()
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        removeNodes()
    }
    
    
    

    
    func getCameraPos(sceneView: ARSCNView) -> Extensions.myCameraPos {
        let cameraTransform = arView.session.currentFrame?.camera.transform
        let cameraPos = MDLTransform(matrix: cameraTransform!)
        
        var cp = Extensions.myCameraPos()
        cp.x = cameraPos.translation.x
        cp.y = cameraPos.translation.y
        cp.z = cameraPos.translation.z
        
        return cp
    }
    
    func addCube() {
        
        let cubeNode = SCNNode()
        cubeNode.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.002)
        cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        let CamPos = getCameraPos(sceneView: arView)
        cubeNode.position = SCNVector3(CamPos.x, CamPos.y, CamPos.z)
        cubeNode.name = "cube"
        cubeNode.physicsBody?.restitution = 0.8
        cubeNode.physicsBody?.mass = 0.5
        let cubeBodyShape = SCNPhysicsShape(geometry: cubeNode.geometry!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        cubeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: cubeBodyShape)
        cubeNode.physicsBody?.categoryBitMask = Extensions.BodyType.box.rawValue
        cubeNode.physicsBody?.collisionBitMask = Extensions.BodyType.floor.rawValue | Extensions.BodyType.box.rawValue
        cubeNode.physicsBody?.contactTestBitMask = Extensions.BodyType.floor.rawValue | Extensions.BodyType.box.rawValue
        
        arView.scene.rootNode.addChildNode(cubeNode)
    }

//    func addFloor() {
//        let floorNode = SCNNode()
//        floorNode.geometry = SCNFloor()
//        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
//        floorNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: SCNPhysicsShape(geometry: SCNFloor(), options: nil))
//        floorNode.position = SCNVector3(0, -0.7, -0.5)
//        arView.scene.rootNode.addChildNode(floorNode)
//        floorNode.physicsBody?.categoryBitMask = Extensions.BodyType.floor.rawValue
//
//    }
          
    func createFloor(anchor: ARPlaneAnchor) -> SCNNode {
        let floor = SCNNode()
        let radian = deg2rad(90)
        floor.name = "floor"
        floor.eulerAngles = SCNVector3(radian, 0, 0)
        floor.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        floor.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
        floor.geometry?.firstMaterial?.isDoubleSided = true
        floor.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
        let floorBodyShape = SCNPhysicsShape(geometry: floor.geometry!, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        floor.physicsBody = SCNPhysicsBody(type: .static, shape: floorBodyShape)
        floor.physicsBody?.categoryBitMask = Extensions.BodyType.floor.rawValue

        return floor
    }
    
    func resetScene() {
        arView.session.pause()
        removeNodeWithString(named: "cube")
        removeNodeWithString(named: "floor")
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
//        addFloor()
    }
    
    func removeNodes() {
        removeNodeWithString(named: "cube")
    }
    
    func removeNodeWithString(named: String) {
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == named {
                node.removeFromParentNode()
            }
        }
    }
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    
    //    Delegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
        print("New Planeanchor found with extent \(anchorPlane.extent)")

        let floor = createFloor(anchor: anchorPlane)
        node.addChildNode(floor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
        print("Planeanchor updated with extent \(anchorPlane.extent)")
        removeNodeWithString(named: "floor")
        let floor = createFloor(anchor: anchorPlane)
        node.addChildNode(floor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
        print("Planeanchor removed with extent \(anchorPlane.extent)")
        removeNodeWithString(named: "floor")
    }
    
    // on contact
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("Contact happened!")
    }
    
    //Deletes node if it is under 2.5 meters down
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.arView.scene.rootNode.enumerateChildNodes { (nodes, _) in
            if (nodes.name == "cube") {
                if (nodes.presentation.position.y < -2.5) {
                    nodes.removeFromParentNode()
                }
            }
        }
    }

}


