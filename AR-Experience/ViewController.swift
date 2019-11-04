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

enum BodyType: Int {
    case box = 1
    case floor = 2
}

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet weak var arView: ARSCNView!
    var configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [])
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        arView.autoenablesDefaultLighting = true
        arView.delegate = self
        arView.scene.physicsWorld.contactDelegate = self
        
        setDotMarker()
        addFloor()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
       
        addCube()
    }
    
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        resetScene()
    }
    
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        removeNodes()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        print("Contact happened!")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.arView.scene.rootNode.enumerateChildNodes { (nodes, _) in
            if (nodes.name == "cube") {
//                print(nodes.presentation.position.y)
                if (nodes.presentation.position.y < -1.7) {
                    nodes.removeFromParentNode()
                }
            }
        }
    }
    
    // RENDERER
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
//        print("New Planeanchor found with extent \(anchorPlane.extent)")
//
//        let floor = createFloor(anchor: anchorPlane)
//        node.addChildNode(floor)
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
//        print("Planeanchor updated with extent \(anchorPlane.extent)")
//        removeNodeWithString(named: "floor")
//        let floor = createFloor(anchor: anchorPlane)
//        node.addChildNode(floor)
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
//        print("Planeanchor removed with extent \(anchorPlane.extent)")
//        removeNodeWithString(named: "floor")
//    }
    
    
    func addCube() {
        let cubeNode = SCNNode()
        cubeNode.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.002)
        cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        
        cubeNode.position = SCNVector3(0, 0, -0.5)
        
        cubeNode.name = "cube"
        arView.scene.rootNode.addChildNode(cubeNode)
        
        cubeNode.physicsBody?.restitution = 0.8
        cubeNode.physicsBody?.mass = 0.5
        cubeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: cubeNode))
        cubeNode.physicsBody?.categoryBitMask = BodyType.box.rawValue
        cubeNode.physicsBody?.collisionBitMask = BodyType.floor.rawValue | BodyType.box.rawValue
        cubeNode.physicsBody?.contactTestBitMask = BodyType.floor.rawValue | BodyType.box.rawValue
        
    }
    
    func setDotMarker(){
        let dotNode = SCNNode()
        dotNode.geometry = SCNSphere(radius: 0.015)
        dotNode.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        dotNode.position = SCNVector3(0, 0, -0.5)
        arView.scene.rootNode.addChildNode(dotNode)
        
    }
    
    
    func addFloor() {
        let floorNode = SCNNode()
        floorNode.geometry = SCNFloor()
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
        floorNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: SCNPhysicsShape(geometry: SCNFloor(), options: nil))
        floorNode.position = SCNVector3(0, -0.7, -0.5)
        arView.scene.rootNode.addChildNode(floorNode)
        floorNode.physicsBody?.categoryBitMask = BodyType.floor.rawValue
        
    }
          
//    func createFloor(anchor: ARPlaneAnchor) -> SCNNode {
//        let floor = SCNNode()
//        let radian = deg2rad(90)
//        floor.name = "floor"
//        floor.eulerAngles = SCNVector3(radian, 0, 0)
//        floor.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//        floor.geometry?.firstMaterial?.diffuse.contents = UIColor.clear
//        floor.geometry?.firstMaterial?.isDoubleSided = true
//        floor.position = SCNVector3(anchor.center.x, anchor.center.y, anchor.center.z)
//        floor.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: floor))
//        floor.physicsBody?.categoryBitMask = BodyType.floor.rawValue
//        floor.physicsBody?.collisionBitMask = BodyType.box.rawValue
//        floor.physicsBody?.contactTestBitMask = BodyType.box.rawValue
//
//
//        return floor
//    }
    
    func resetScene() {
        arView.session.pause()
        arView.scene.rootNode.enumerateChildNodes { (nodes, _) in
            if nodes.name == "cube" || nodes.name == "floor" {
                nodes.removeFromParentNode()
            }
        }
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
        addFloor()
    }
    
    func removeNodes() {
        arView.scene.rootNode.enumerateChildNodes { (nodes, _) in
            if nodes.name == "cube" {
                nodes.removeFromParentNode()
            }
        }
    }
    
//    func removeNodeWithString(named: String) {
//        arView.scene.rootNode.enumerateChildNodes { (node, _) in
//            if node.name == named {
//                node.removeFromParentNode()
//            }
//        }
//    }
    
//    func deg2rad(_ number: Double) -> Double {
//        return number * .pi / 180
//    }
    

}


