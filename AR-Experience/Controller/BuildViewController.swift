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

class BuildViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet weak var arView: ARSCNView!
    @IBOutlet weak var addButton: UIButton!
    var configuration = ARWorldTrackingConfiguration()
    var nodeTouched: SCNNode?
    var locationTapped: CGPoint?
    var desiredPosition: SCNVector3?
    var isMoved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [])
        arView.debugOptions = [.showFeaturePoints, .showPhysicsShapes, .showPhysicsFields ]
        arView.autoenablesDefaultLighting = true
        arView.delegate = self
        arView.scene.physicsWorld.contactDelegate = self
        
        addGestureRecogniser(inView: arView)
        
    }
    
    // MARK: - IBActions
//        arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]

    
    @IBAction func addNodeButtonPressed(_ sender: UIButton) {
        addCube()
    }
    
    @IBAction func deleteSceneButtonPressed(_ sender: UIButton) {
        resetScene()
    }

    // MARK: - Functions
    
    
    func addGestureRecogniser(inView view: ARSCNView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(BuildViewController.didTap(_:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func didTap(_ sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began, .changed:
            let positionTapped = sender.location(in: arView)
            let results = arView.hitTest(positionTapped, types: .featurePoint)
            let hitTest = arView.hitTest(positionTapped, options: nil)
            
            if let result = results.first {
                let location = SCNVector3(result.worldTransform.columns.3.x,
                                          result.worldTransform.columns.3.y,
                                          result.worldTransform.columns.3.z)
                
                desiredPosition = location
            }
            
            
            if let node = hitTest.first?.node {

                if node.name == "cube" {
                    nodeTouched = node
                    nodeTouched?.position = desiredPosition!
                }

            }
            
        case .ended:
            
            return
            
        default:
            return
        }
    }
    

    
    
    func getCameraPos(sceneView: ARSCNView) -> Extensions.myCameraPos {
        let cameraTransform = arView.session.currentFrame?.camera.transform
        let cameraPos = MDLTransform(matrix: cameraTransform!)
        
        var pos = Extensions.myCameraPos()
        pos.x = cameraPos.translation.x
        pos.y = cameraPos.translation.y
        pos.z = cameraPos.translation.z
        
        return pos
    }
    
    func addCube() {
        let camPos = getCameraPos(sceneView: arView)
        
        CubeNode.createCubeNode(inSceneView: arView, position: camPos, withColor: .cyan)

    }

    func resetScene() {
        arView.session.pause()
        removeNodeWithString(named: "cube")
        removeNodeWithString(named: "floor")
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
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
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//
//        if let touch = touches.first {
//            locationTapped = touch.location(in: arView)
//            let results = arView.hitTest(locationTapped!, options: nil)
//
//            if let hitResult = results.first?.node {
//                let node = hitResult
//                nodeTouched = node
//                print(nodeTouched?.name)
//
//                isMoved = true
//            }
//        }
//
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if isMoved {
//            if let touch = touches.first {
//                let position = touch.location(in: arView)
//                let results = arView.hitTest(position, options: nil)
//
//                if let result = results.first?.node {
//                    let desiredPosition = result.position
//                    nodeTouched?.position = desiredPosition
//
//                    print("Node Moved!!!")
//                }
//            }
//        }
//    }
    
    
    
    

    // MARK: - SceneRendererDelegate
    
    //Find a set anchor to node and then addnode to scene
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
//        print("New Planeanchor found with extent \(anchorPlane.extent)")

        let floor = FloorNode.createFloor(anchor: anchorPlane)
        node.addChildNode(floor)
    }

    //Deleted the node and add another while moving
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
//        print("Planeanchor updated with extent \(anchorPlane.extent)")
        removeNodeWithString(named: "floor")
        let floor = FloorNode.createFloor(anchor: anchorPlane)
        node.addChildNode(floor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
//        print("Planeanchor removed with extent \(anchorPlane.extent)")
        removeNodeWithString(named: "floor")
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
    
    
    // MARK: - ScenePhysicsDelegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        print("Contact happened!")
    }
    
    

}


