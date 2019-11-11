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
    var configuaration = ARWorldTrackingConfiguration()
    let defaultColor = UIColor.white
    var colorChoosen = UIColor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        arView.delegate = self
        configuaration.planeDetection = .vertical
        arView.debugOptions = [.showFeaturePoints]
        arView.session.run(configuaration, options: [])
        arView.autoenablesDefaultLighting = true
        
        colorChoosen = defaultColor

    }
    
    // MARK: - IBActions
    
    @IBAction func chooseColor(_ sender: UIBarButtonItem) {
        colorChoosen = sender.tintColor!
    }
    
    @IBAction func refreshScene(_ sender: UIBarButtonItem) {
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
    
    func deg2rad(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    //MARK: - Managing Nodes
    
    func createWall(withAnchor anchor: ARPlaneAnchor) -> SCNNode {
        let radian = deg2rad(90)
        let wallNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z)))
        wallNode.name = "wall"
        wallNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
//        wallNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        wallNode.eulerAngles = SCNVector3(radian, 0, 0)
        wallNode.geometry?.firstMaterial?.isDoubleSided = true
        return wallNode
    }
    
    func removeNodeWithString(named: String) {
        arView.scene.rootNode.enumerateChildNodes { (node, _) in
            if node.name == named {
                node.removeFromParentNode()
            }
        }
    }
    
    // MARK: - RendererDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
        print("Anchorplane detected!")
        let wall = createWall(withAnchor: anchorPlane)
        node.addChildNode(wall)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
        removeNodeWithString(named: "wall")
        let wall = createWall(withAnchor: anchorPlane)
        node.addChildNode(wall)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
        removeNodeWithString(named: "wall")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {

        let currentCameraPosition = getCurrentCamPos(sceneView: arView)
        
        DispatchQueue.main.async {
            if self.drawButton.isHighlighted {
                
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.01))
                sphereNode.geometry?.firstMaterial?.diffuse.contents = self.colorChoosen
                sphereNode.position = currentCameraPosition
                
                self.arView.scene.rootNode.addChildNode(sphereNode)
                
            }   else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.01))
                pointer.position = currentCameraPosition
                pointer.name = "pointer"
                
                self.arView.scene.rootNode.enumerateChildNodes { (node, _) in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                }
                
                self.arView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = self.colorChoosen
                
            }
        }
    }
   
}
