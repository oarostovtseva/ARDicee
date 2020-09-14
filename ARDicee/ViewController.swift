//
//  ViewController.swift
//  ARDicee
//
//  Created by Olena Rostovtseva on 30.08.2020.
//  Copyright © 2020 orost. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var diceArray = [SCNNode]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - DiceRenderingMethods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                addDicee(atLocation: hitResult)
            }
        }
    }
    
    func addDicee(atLocation location: ARHitTestResult) {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(diceNode)
            diceArray.append(diceNode)
        }
    }
    
    @IBAction func removeAllDicees(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for diceNode in diceArray {
                diceNode.removeFromParentNode()
            }
            diceArray = [SCNNode]()
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    private func rollAll() {
        if !diceArray.isEmpty {
            for diceNode in diceArray {
                roll(diceNode)
            }
        }
    }
    
    private func roll(_ diceNode: SCNNode) {
        let randomX = getRandomDegree()
        let randomZ = getRandomDegree()
        diceNode.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 5), y: 0, z: CGFloat(randomZ * 5), duration: 0.5))
    }
    
    func getRandomDegree() -> Float {
        return Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
    }
    
    // MARK: - ARSceneDelegateMethods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.extent.x, y: 0, z: planeAnchor.extent.y)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        return planeNode
    }
}
