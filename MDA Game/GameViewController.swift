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
    let lablel  = UILabel()
    let restart = UIButton()

    // MARK: - Properties
    var duration: TimeInterval = 5
    var ship: SCNNode!
    var score = 0 {
        didSet {
            lablel.text = "Score: \(score)"
        }
    }
    var tapGestureGame: UITapGestureRecognizer? = nil
    
    // MARK: - Methods
    func addLabel() {
        scnView.addSubview(lablel)
        lablel.numberOfLines = 2
        lablel.frame = CGRect(x: 0, y: 0, width: scnView.frame.width, height: 80)
        lablel.font = UIFont.systemFont(ofSize: 30)
        lablel.textAlignment = .center
        score = 0
    }
    
    func addRestartButton() {
        restart.frame = CGRect(x: 0, y: 100, width: scnView.frame.width, height: 50)
        restart.setTitle("Restart Game", for: .normal)
        restart.setTitleColor(UIColor.red, for: .normal)
        restart.titleLabel?.font =  UIFont.systemFont(ofSize: 30)
        restart.addTarget(self, action: #selector(restartAction), for: .touchUpInside)
        restart.isHidden = true

        scnView.addSubview(restart)
    }
    
    @objc func buttonAction(_ sender: UIButton!) {
        print("Button pressed")
    }
    
    // Button Action:
    @objc func restartAction() {
        duration = 5
        score = 0
        restart.isHidden = true
        ship = getShip()
        addShip()
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
        let x = Int.random(in: -30...30)
        let y = Int.random(in: -50...50)
        let z = -105
        ship.position = SCNVector3(x, y, z)
        ship.look(at: SCNVector3(2*x,2*y,2*z))
        // animate the 3d object
        ship.runAction(SCNAction.move(to: SCNVector3(), duration: duration)) {
            self.ship.removeFromParentNode()
            DispatchQueue.main.async {
                self.lablel.text = "Game Over!\nFinal score: \(self.score)"
                self.restart.isHidden = false
            }
        }
        // retrieve the ship node
        scnView.scene?.rootNode.addChildNode(ship)
    }
    
    func removeShip() {
        // remove ship from the scene
        scnView.scene?.rootNode.childNode(withName: "ship", recursively: true)?.removeFromParentNode()
    }
    /**
     * Start class of the application
     * initialise base scene after the game was loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
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
        // set the scene to the view
        scnView.scene = scene
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        // configure the view
        scnView.backgroundColor = UIColor.black
        // add a tap gesture recognizer
        tapGestureGame = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGestureGame!)
        //remove ship
        removeShip()
        //Get ship
        ship = getShip()
        //Add ship
        addShip()
        //add label
        addLabel()
        //add restart button
        addRestartButton()
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
            SCNTransaction.animationDuration = 0.1
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.ship.removeFromParentNode()
                self.score += 1
                DispatchQueue.main.async {
                    self.lablel.text = "Score: \(self.score)"
                }
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
