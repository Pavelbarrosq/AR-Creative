//
//  PaintViewController.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-10.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class PaintViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var arView: ARSCNView!
    var configuration = ARWorldTrackingConfiguration()
    let defaultColor = UIColor.white
    var colorChoosen = UIColor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView.delegate = self
        configuration.planeDetection = .vertical
        arView.debugOptions = [.showFeaturePoints]
        arView.session.run(configuration, options: [])
        
        colorChoosen = defaultColor

    }
    
    // MARK: - IBActions
    
    @IBAction func chooseColor(_ sender: UIBarButtonItem) {
        colorChoosen = sender.tintColor!
    }
    
    @IBAction func refreshScene(_ sender: UIBarButtonItem) {
        resetScene()
    }
    
    //MARK: - Funtions
    
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
    
    //MARK: - Managing Nodes
    
    func removeNodeWithString(named: String) {
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == named {
                node.removeFromParentNode()
            }
        }
    }
    
    func resetScene() {
        arView.session.pause()
        removeNodeWithString(named: "drawNode")
        removeNodeWithString(named: "pointer")
        arView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    // MARK: - RendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
        print("Anchorplane detected!")
        let wall = WallNode.createWall(withAnchor: anchorPlane)
        node.addChildNode(wall)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
        removeNodeWithString(named: "wall")
        let wall = WallNode.createWall(withAnchor: anchorPlane)
        node.addChildNode(wall)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
        removeNodeWithString(named: "wall")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {

        let currentCameraPosition = getCurrentCamPos(sceneView: arView)
        
        DispatchQueue.main.async {
            if self.drawButton.isHighlighted {
                
                let sphereNode = SphereNode.createSphere(atPosition: currentCameraPosition, withcolor: self.colorChoosen)
                sphereNode.name = "drawNode"
                
                self.arView.scene.rootNode.addChildNode(sphereNode)
                
            }   else {
                let pointer = SphereNode.createSphere(atPosition: currentCameraPosition, withcolor: self.colorChoosen)
                pointer.name = "pointer"
                
                self.removeNodeWithString(named: "pointer")
                
                self.arView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = self.colorChoosen
                
            }
        }
    }
   
}
