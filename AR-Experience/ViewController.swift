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

class ViewController: UIViewController, ARSCNViewDelegate {

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
    
    
    func addCube() {
        let cubeNode = SCNNode()
        cubeNode.geometry = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0.002)
        cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        cubeNode.position = SCNVector3(0, 0, -0.3)
        cubeNode.name = "cube"
        arView.scene.rootNode.addChildNode(cubeNode)
        
    }
    
    
    func addFloor() {
        let floorNode = SCNNode()
        floorNode.name = "floor"
        floorNode.geometry = SCNBox(width: 1, height: 0.05, length: 1, chamferRadius: 0.002)
        floorNode.position = SCNVector3(0, -0.7, -0.5)
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        arView.scene.rootNode.addChildNode(floorNode)
        
    }
    
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
    
    
}

