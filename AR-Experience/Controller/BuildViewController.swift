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



enum SetSize: String {
    case height = "Height"
    case width = "Width"
    case depth = "Depth"
}

class BuildViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate, UITextFieldDelegate {

    @IBOutlet var sizeTextFields: [UITextField]!
    @IBOutlet weak var arView: ARSCNView!
    @IBOutlet weak var addButton: UIButton!
    
    var grids = [FloorNode]()
    
    var configuration = ARWorldTrackingConfiguration()
    var nodeTouched: SCNNode?
    var zOffset: Float?
    var currentCameraPosition: SCNVector3?
    var firstPress = true
    var haptikFeedback: UIImpactFeedbackGenerator? = nil
    var height: Float?
    var width: Float?
    var depth: Float?
    var rotation: Float = 0.0
    var nodeToRotate: SCNNode?
    var isNodeTouched: Bool = false
//    var setlocationToNode: SCNVector3 = SCNVector3Zero
    var floor: SCNNode?
    
    
    let dividedBy: Float = 100.0
    
    
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
        
        sizeTextFields.forEach { (field) in
            field.isHidden = true
            field.delegate = self as UITextFieldDelegate
        }
        addRotationGestureRecogniser(view: arView)
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
    
    @IBAction func handleSizeBarButton(_ sender: UIBarButtonItem) {
        if firstPress == true {
            sizeTextFields.forEach { (field) in
                UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
                    field.isHidden = false
//                    self.view.layoutIfNeeded()
                    self.firstPress = false
                }, completion: nil)
                
            }
        } else {
            sizeTextFields.forEach { (field) in
                UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseInOut, animations: {
                    field.isHidden = true
//                    self.view.layoutIfNeeded()
                    self.firstPress = true
                    
                    guard let text = field.text ,let name = field.placeholder, let type = SetSize(rawValue: name) else {return}
                    
                    switch type {
                    case .height:
                        
                        guard let input = Float(text) as Float? else {return}
                        self.height = input / self.dividedBy
                        
                    case .width:
                        
                        guard let input = Float(text) as Float? else {return}
                        self.width = input / self.dividedBy
                    case .depth:
                        
                        guard let input = Float(text) as Float? else {return}
                        self.depth = input / self.dividedBy
                    default:
                        break
                    }
                }, completion: nil)
            }
            
        }
        
    }
    

    
    // MARK: - Functions

    func addRotationGestureRecogniser(view: ARSCNView) {
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(gesture:)))
        view.addGestureRecognizer(rotation)
    }
    
    func addLongPressRecogniser(button: UIButton) {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        button.addGestureRecognizer(longPress)
    }
    
    @objc func didRotate(gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .changed:
            print("ROTATION!!!!")
            nodeToRotate?.physicsBody = .static()
            nodeToRotate?.eulerAngles.y = Float(gesture.rotation)
            rotation = Float(gesture.rotation)
        case .ended:
            nodeToRotate?.eulerAngles.y = rotation
        default:
            return
        }
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        haptikFeedback = HapticFeedback.createImpactFeedback()
        haptikFeedback?.prepare()
        
        var desiredPosition = currentCameraPosition
        
        switch gesture.state {
               case .began:
                if isNodeTouched == false {
                    haptikFeedback?.prepare()
                    nodeTouched = nil
                    
                    let results = arView.hitTest(arView.center, options: nil)
                        if results.first?.node.name == "cube" {
                        haptikFeedback?.impactOccurred()
                        isNodeTouched = true
                        }
                    
                    }
               case .changed:
                    if isNodeTouched == true {
                        let centerMark = arView.center
                        let hitTest = arView.hitTest(centerMark, options: nil)
                        
                        if let cube = hitTest.first?.node {
                           if cube.name == "cube" {
                               nodeTouched = hitTest.first?.node
                               nodeTouched?.physicsBody = .static()
                               nodeTouched?.position = desiredPosition ?? SCNVector3Zero
                            }
                        }
                    }
                    
                    
               case .ended:
                    desiredPosition = nil
                    haptikFeedback = nil
                    nodeTouched?.physicsBody = .dynamic()
                    isNodeTouched = false
            
               default:
                   break
               }

    }

    
    func addCube() {
        let node = CubeNode.createCubeNode(width: width ?? 0.3, height: height ?? 0.3, length: depth ?? 0.3, inSceneView: arView, position: currentCameraPosition!, withColor: .cyan)
        arView.scene.rootNode.addChildNode(node)
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
        let grid = FloorNode(anchor: anchor as! ARPlaneAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
        
//        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
//        print("New Planeanchor found with extent \(anchorPlane.extent)")

//        floor = FloorNode.createFloor(anchor: anchorPlane)
//        node.addChildNode(floor!)
    }


    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == anchor.identifier
            }.first
        
        guard let foundGrid = grid else {
            return
        }
        
        foundGrid.update(anchor: anchor as! ARPlaneAnchor)
        
//        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
//        print("Planeanchor updated with extent \(anchorPlane.extent)")
//        removeNodeWithString(named: "floor")
//        let floor = FloorNode.createFloor(anchor: anchorPlane)
//        node.addChildNode(floor)
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        guard let anchorPlane = anchor as? ARPlaneAnchor else {return}
//        let floor  = FloorNode.createFloor(anchor: anchorPlane)
//        node.addChildNode(floor)
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
//        currentCameraPosition = getCurrentCamPos(sceneView: arView)
        
        
        DispatchQueue.main.async {
            
            self.currentCameraPosition = Camera.getCurrentCamPos(sceneView: self.arView)
        
            let pointer = SphereNode.createSphere(atPosition: self.currentCameraPosition!, withcolor: .white)
            pointer.name = "pointer"
            
            self.removeNodeWithString(named: "pointer")
            
            self.arView.scene.rootNode.addChildNode(pointer)
            pointer.geometry?.firstMaterial?.diffuse.contents = UIColor.white
            
        }
        
    }
    
    
    // MARK: - ScenePhysicsDelegate
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    
    }
    
    // MARK: - TextfieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sizeTextFields.forEach { (field) in
            field.resignFirstResponder()
            
        }
        return true
    }
    
    // MARK: - TouchDelegate
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touchLocation = touches.first?.location(in: arView) else {return}
        
        let hitTest = arView.hitTest(touchLocation, options: nil)
        
        if hitTest.first?.node.name == "cube" {
            let node = hitTest.first?.node
            nodeToRotate = node
        }
    }
    
    

}


