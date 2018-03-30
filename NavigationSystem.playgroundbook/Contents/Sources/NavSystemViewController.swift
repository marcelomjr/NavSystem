//
//  GameViewController.swift
//  WWDC
//
//  Created by Marcelo Martimiano Junior on 20/03/2018.
//  Copyright © 2018 Marcelove. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

public class NavSystemViewController: UIViewController {
    public var systemInterface: NaveInterface!
    private var sceneName: String!
    var sceneController: SceneController!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //================================================================================
                let frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 600, height: 800))
                self.view = SCNView(frame: frame)
        
        //==================================================================================
        
        let scnView = self.view as! SCNView
        
        self.sceneController = SceneController(scnView: scnView)
        
        scnView.showsStatistics = true
        //        scnView.allowsCameraControl = true
//        scnView.debugOptions = SCNDebugOptions.showPhysicsShapes
        
        self.systemInterface = self.sceneController
        
//        self.playground()
    }
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    public func foo() {
        self.systemInterface.routine {
            self.systemInterface.changeCamera(type: .upper)
            self.systemInterface.setSpeed(speed: 10)
            //self.systemInterface.turnCar(degreeAngle: 45)
            self.systemInterface.setupFrontalRadars(limitDistance: 7)
            self.systemInterface.showRadars()
            
            func obstacleDetectedHandler() {
                self.systemInterface.brakeTheCar()
            }
            
            self.systemInterface.obstacleDetected(handler: obstacleDetectedHandler)
        }
    }
    public func playground() {
        foo()
        self.systemInterface.createScene(named: "art.scnassets/Chapter1.scn")
        
    }
    
}

