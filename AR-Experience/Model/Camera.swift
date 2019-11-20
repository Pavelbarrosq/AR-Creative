//
//  Camera.swift
//  AR-Experience
//
//  Created by Pavel Barros Quintanilla on 2019-11-20.
//  Copyright © 2019 Pavel Barros Quintanilla. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class Camera {
    
    class func getCurrentCamPos(sceneView: ARSCNView) -> SCNVector3 {
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
    
}
