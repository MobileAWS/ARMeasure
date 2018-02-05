//
//  ViewController.swift
//  ARDistance
//
//  Created by Hans Ospina on 2/4/18.
//  Copyright © 2018 MobileAWS, LLC. All rights reserved.
//

import UIKit
import ARKit




class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var lblDistance: UILabel!
    
    let configuration  = ARWorldTrackingConfiguration()
    
    var startingPos:SCNNode?
    
    var unit:UnitLength = .meters
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        self.sceneView.addGestureRecognizer(tap)
        self.sceneView.delegate = self
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView,
            let frame = sceneView.session.currentFrame
            else {return}
        let camera = frame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -0.1
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        let sphere  = SCNNode(geometry: SCNSphere(radius: 0.025))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        sphere.simdTransform = modifiedMatrix
        self.sceneView.scene.rootNode.addChildNode(sphere)
        self.startingPos = sphere
        
        
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let startingPos = self.startingPos else {
            return
        }
        
        guard let pOfView = self.sceneView.pointOfView else {
            return
        }

        let transform = pOfView.transform
        
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let xDistance = location.x - startingPos.position.x
        let yDistance = location.y - startingPos.position.y
        let zDistance = location.z - startingPos.position.z
        
        let delta = (
            x:"x:\(String(format:"%.2f",xDistance))",
            y:"y:\(String(format:"%.2f",yDistance))",
            z:"z:\(String(format:"%.2f",zDistance))"
            )
        
        DispatchQueue.main.async {
            self.lblDistance.text = "Distance(mts): \(delta.x) \(delta.y) \(delta.z)"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onStartClicked(_ sender: Any) {
    }
    
}

extension SCNNode {
    
    
    func calculateDistance(to dest: SCNNode) -> Float {
        let dx = dest.position.x - self.position.x
        let dy = dest.position.y - self.position.y
        let dz = dest.position.z - self.position.z
        
        return Float(sqrt(dx*dx + dy*dy + dz*dz))
    }
    
    
}




