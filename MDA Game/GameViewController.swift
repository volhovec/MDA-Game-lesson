//
//  GameViewController.swift
//  MDA Game
//
//  Created by Leonid Stefanenko on 23.10.2020.
//

//import UIKit
//import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    // MARK: - Outlets
    let lablel = UILabel()
    // MARK: - Properties
    var duration: TimeInterval = 5
    var ship: SCNNode!
    var score = 0
    
    // MARK: - Methods
    
    func addLabel() {
        
    }
    
    func getShip() -> SCNNode {
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!.clone()
        
        return ship
    }
    
    func addShip() {
        //move ship
        let x = Int.random(in: -25...25)
        let y = Int.random(in: -25...25)
        let z = -105
        ship.position = SCNVector3(x, y, z)
        
        ship.look(at: SCNVector3(2*x,2*y,2*z))
        // animate the 3d object
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0.5, z: 0, duration: 1)))
        ship.runAction(SCNAction.move(to: SCNVector3(), duration: duration)) {
            self.ship.removeFromParentNode()
            print(#line, #function, "Game over")
        }
        
        // retrieve the ship node
        scnView.scene?.rootNode.addChildNode(ship)
    }
    
    func removeShip() {
        // remove ship from the scene
        scnView.scene?.rootNode.childNode(withName: "ship", recursively: true)?.removeFromParentNode()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        //cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        //let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 0.5, z: 0, duration: 1)))
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        //remove ship
        removeShip()
        
        //Get ship
        ship = getShip()
        
        //Add ship
        addShip()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.ship.removeFromParentNode()
                self.score += 1
                print(#line, #function, "The ship \(self.score) has been shoted!")
                
                self.duration *= 0.95
                self.ship = self.getShip()
                self.addShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    // MARK: - Computed properties
    
    var scnView: SCNView {
        return self.view as! SCNView
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
