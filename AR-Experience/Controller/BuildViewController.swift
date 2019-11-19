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
    var zOffset: Float?
    var currentCameraPosition: SCNVector3?
    var stoppedPressed = false
    
    @IBOutlet weak var markButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [])
        arView.debugOptions = [.showFeaturePoints, .showPhysicsShapes, .showPhysicsFields ]
        arView.autoenablesDefaultLighting = true
        arView.delegate = self
        arView.scene.physicsWorld.contactDelegate = self
        
//        addGestureRecogniser(inView: arView)
        addLongPressRecogniser(button: markButton)
        
    }
    
    // MARK: - IBActions
//        arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]

    
    @IBAction func addNodeButtonPressed(_ sender: UIButton) {
        addCube()
    }
    
    @IBAction func deleteSceneButtonPressed(_ sender: UIButton) {
        resetScene()
    }
    
    @IBAction func markButtonPressed(_ sender: UIButton) {
        

        switch sender.state {
        case .highlighted:

            print("BUTTON PRESSED")
            let centerMark = arView.center
            let hitTest = arView.hitTest(centerMark, options: nil)
            
           if !hitTest.isEmpty && hitTest.first!.node.name == "cube" {
                nodeTouched = hitTest.first?.node
                print("NODE FOUND: \(nodeTouched?.name)")
                nodeTouched?.position = currentCameraPosition!
            }

        case .normal:
            nodeTouched = nil

        default:
            return
        }
 
    }
    
    
    // MARK: - Functions
    
    func addLongPressRecogniser(button: UIButton) {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        button.addGestureRecognizer(longPress)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {

        switch gesture.state {
            
        case .began:
            nodeTouched = nil

        case .changed:
            print("BUTTON PRESSED")
             let centerMark = arView.center
             let hitTest = arView.hitTest(centerMark, options: nil)
             
            if !hitTest.isEmpty && hitTest.first!.node.name == "cube" {
                 nodeTouched = hitTest.first?.node
                nodeTouched?.physicsBody = .static()
                 print("NODE FOUND: \(nodeTouched?.name)")
                 nodeTouched?.position = currentCameraPosition!
             }
            
        case .ended:
            nodeTouched?.physicsBody = .dynamic()
            
        default:
            return
        }
        
    }
//
//    func addGestureRecogniser(inView view: ARSCNView) {
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(BuildViewController.didTap(_:)))
//        view.addGestureRecognizer(pan)
//    }
//
//    @objc func didTap(_ sender: UIPanGestureRecognizer) {
//
//        var locationTapped: CGPoint
//
//        let locationOrigin: SCNVector3
//
//        guard let currentCapPosZ = currentCameraPosition?.z else {return}
//
//
//        switch sender.state {
//        case .began:
//
//            if nodeTouched == nil {
//                locationTapped = sender.location(in: arView)
//                let results = arView.hitTest(locationTapped, types: .featurePoint)
//                let hitTest = arView.hitTest(locationTapped, options: nil)
//
//                if hitTest.first?.node.name == "cube" {
//
//                    nodeTouched = hitTest.first?.node
////                    nodeTouched?.position = SCNVector3Zero
//
//                    zOffset = nodeTouched?.position.z
//
//                    print("NODE TOUCHED: \(nodeTouched?.name)")
//
////                    if let result = results.first {
////                        locationOrigin = SCNVector3(result.worldTransform.columns.3.x,
////                                                  result.worldTransform.columns.3.y,
////                                                  result.worldTransform.columns.3.z)
////
////                        print("Location is!: \(locationOrigin)")
////
////                        zOffset = locationOrigin.z
////
////                        isMoved = true
//
//                   // }
//                }
//            }
                        
//        case .changed:
//            if nodeTouched != nil  {
////                let locationMoved = sender.location(in: sender.view)
//                sender.minimumNumberOfTouches = 1
//
//                let results = arView.hitTest(sender.location(in: sender.view), types: .featurePoint)
//
//                guard let result = results.first else {return}
//
//                let hits = arView.hitTest(sender.location(in: sender.view), options: nil)
//
//                if hits.first?.node.name == "cube" {
//                    let position = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
//                    nodeTouched?.position = position
//                }
//
//
//        }
//
//
//        case .ended:
//            nodeTouched = nil
//            return
//
//        default:
//            return
//        }
//    }
    
    
    func getCurrentCamPos(sceneView: ARSCNView) -> SCNVector3 {
        if let pow = sceneView.pointOfView {
            let transform = pow.transform
            let orientation = SCNVector3(-transform.m31, -transform.m32, -transform.m33)
            let location = SCNVector3(transform.m41, transform.m42, transform.m43)
            
            let currentCameraPosition = SCNVector3Make(orientation.x + location.x,
                                                       orientation.y + location.y,
                                                       orientation.z + location.z)
            
            return currentCameraPosition
        }
        
        return SCNVector3Zero
    }
    
    func addCube() {
//        let camPos = getCameraPos(sceneView: arView)
        guard let currentPos = currentCameraPosition else {return}
        
        CubeNode.createCubeNode(inSceneView: arView, position: currentPos, withColor: .cyan)

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
    
    //Updating camera pos when rendering scene
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        currentCameraPosition = getCurrentCamPos(sceneView: arView)
        
        DispatchQueue.main.async {
        
            let pointer = SphereNode.createSphere(atPosition: self.currentCameraPosition!, withcolor: .white)
            pointer.name = "pointer"
            
            self.removeNodeWithString(named: "pointer")
            
            self.arView.scene.rootNode.addChildNode(pointer)
            pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            
        }
        
    }
    
    
    // MARK: - ScenePhysicsDelegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//        print("Contact happened!")
        
    }
    
    

}


