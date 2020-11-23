//
//  GameViewController.swift
//  MDA Game
//
//  Created by Leonid Stefanenko on 23.10.2020.
//

import SceneKit

class GameViewController: UIViewController {
    // MARK: - Outlets
    // score label object
    let labelScore = UILabel()
    let labelHit  = UILabel()
    let labelOver  = UILabel()
    // restart button object
    let restart = UIButton()

    // MARK: - Properties
    // plane flight time
    var duration: TimeInterval = 5
    // missed shots cound
    var missedShots = 0
    // game score
    var score: Double = 0 {
        didSet {
            labelScore.text = "Score: \(score)"
        }
    }
    var hit: Int = 0 {
        didSet {
            labelHit.text = "Hit: \(hit)"
        }
    }
    // plane node object
    var ship: SCNNode!
    // side shot
    var sideShot = false
    
    // MARK: - Methods
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
            //Util.copyFile("Student.sqlite")
            return true
    }
    
    func addLabelHit() {
        let width: CGFloat   = round(scnView.frame.width * 0.3)
        let padding: CGFloat = round(scnView.frame.width * 0.05)
        
        scnView.addSubview(labelHit)
        labelHit.numberOfLines = 1
        
        labelHit.frame = CGRect(x: padding, y: 0, width: width, height: 40)
        labelHit.font = UIFont.systemFont(ofSize: 24)
        labelHit.textAlignment = .left
        hit = 0
    }
    
    func addLabelGameOver() {
        addLabel(label: labelOver, padX: 0.2, padY: 0.35, width: 0.6, fontSize: 30)
        labelOver.text = "Game Over!"
        labelOver.textColor = UIColor.red
        labelOver.textAlignment = .center
        labelOver.isHidden = true
        scnView.addSubview(labelOver)
    }
    
    func addLabelScore() {
        let width: CGFloat   = round(scnView.frame.width * 0.45)
        let padding: CGFloat = round(scnView.frame.width * 0.5)
        
        scnView.addSubview(labelScore)
        labelScore.numberOfLines = 1
        labelScore.frame = CGRect(x: padding, y: 0, width: width, height: 40)
        labelScore.font = UIFont.systemFont(ofSize: 24)
        labelScore.textAlignment = .right
        score = 0
    }
    
    func addLabel(label: UILabel, padX: Float, padY: Float, width: Float, fontSize: CGFloat) {
        let width: CGFloat    = round(scnView.frame.width * CGFloat(width))
        let paddingX: CGFloat = round(scnView.frame.width * CGFloat(padX))
        let paddingY: CGFloat = round(scnView.frame.width * CGFloat(padY))
        
        label.numberOfLines = 1
        label.frame = CGRect(x: paddingX, y: paddingY, width: width, height: 40)
        label.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    
    func addRestartButton() {
        let width: CGFloat   = round(scnView.frame.width * 0.7)
        let paddingX: CGFloat = round(scnView.frame.width * 0.15)
        let paddingY: CGFloat = round(scnView.frame.width * 0.35 + 70)
        
        restart.frame = CGRect(x: paddingX, y: paddingY, width: width, height: 50)
        restart.setTitle("Restart Game", for: .normal)
        restart.setTitleColor(UIColor.red, for: .normal)
        restart.titleLabel?.font =  UIFont.systemFont(ofSize: 30)
        restart.addTarget(self, action: #selector(restartAction), for: .touchUpInside)
        restart.isHidden = true
        restart.backgroundColor = .systemYellow
        restart.layer.cornerRadius = 20

        scnView.addSubview(restart)
    }
    
    // Restart button action
    @IBAction func restartAction() {
        // reset flight time
        duration = 5
        // set missed shots to zero
        missedShots = 0
        // reset score
        score = 0
        hit   = 0
        // hide restart button
        restart.isHidden = true
        labelOver.isHidden = true
        // get plane object
        ship = getShip()
        // add plane to the scene
        addShip()
        // set side shot flag to false
        sideShot = false
    }
    //
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
                self.sideShot = true
                self.restart.isHidden = false
                self.labelOver.isHidden = false
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
        scnView.allowsCameraControl = false
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        // configure the view
        scnView.backgroundColor = UIColor.black
        // add a tap gesture recognizer
        let tapGestureGame = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGestureGame)
        //remove ship
        removeShip()
        //Get ship
        ship = getShip()
        //Add ship
        addShip()
        //add label
        addLabelScore()
        addLabelHit()
        //add restart button
        addRestartButton()
        addLabelGameOver()
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if (hitResults.count > 0) {
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
                let score  = Double(1000 / (1 + self.missedShots))
                self.score += Double(round(score) / 1000)
                self.hit  += 1
                DispatchQueue.main.async {
                    self.labelScore.text = "Score: \(Double(round(self.score * 10) / 10))"
                }
                self.duration *= 0.9
                self.missedShots = 0
                if (!self.sideShot) {
                    self.ship = self.getShip()
                    self.addShip()
                }
            }
            material.emission.contents = UIColor.red
            SCNTransaction.commit()
        } else {
            missedShots += 1
        }
    }
    // MARK: - Computed properties
    var scnView: SCNView {
        return self.view as! SCNView
    }
    
    override var shouldAutorotate: Bool {
        return false
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
