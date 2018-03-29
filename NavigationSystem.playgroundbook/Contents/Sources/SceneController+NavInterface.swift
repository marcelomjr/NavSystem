//
//  SceneController+NavInterface.swift
//  NavigationSystem
//
//  Created by Marcelo Martimiano Junior on 25/03/2018.
//  Copyright © 2018 Marcelo. All rights reserved.
//
import SceneKit

extension SceneController: NaveInterface {
    
    public func createScene(named: String) {
        
        self.scene = SCNScene(named: named)
        self.scnView.scene = self.scene
        self.scene?.physicsWorld.contactDelegate = self
        
        self.car = self.scene?.rootNode.childNode(withName: "carModel", recursively: true)
        self.carBox = self.scene?.rootNode.childNode(withName: "carBox", recursively: true)
        
        if let cameras = self.scene?.rootNode.childNode(withName: "cameras", recursively: true)?.childNodes {
            self.cameras = cameras
        }
        if let extraCameras = self.scene?.rootNode.childNode(withName: "extraCameras", recursively: true)?.childNodes {
            self.cameras.append(contentsOf: extraCameras)
        }
        
        self.changeCamera(type: .initialCamera)
        
        
        let skScene = Overlay(fileNamed: "art.scnassets/overlay.sks")!
        skScene.scaleMode = .aspectFit
        self.scnView.overlaySKScene = skScene
        
        self.setupSensors()
        self.setupSounds()
        
        // need self.setupSounds() before
        self.setupActions()
        
        if self.routineBlock == nil {
            self.defaultInitialization()
        }
        else {
            self.routineBlock!()
        }
    }
    
   
    
    
    public func showRadars() {
        self.radarController.showFrontalRadars()
    }
    
    public func hideRadars() {
        self.radarController.hideFrontalRadars()
    }
    
    public func setupFrontalRadars(limitDistance: Float) {
        self.radarController.setLimitDistance(distance: limitDistance)
    }
    
    public func obstacleDetected(handler: @escaping () -> Void) {
        self.obstacleHandler = handler
    }
    
    
    public func changeCamera(type: CameraType) {
        
        for camera in self.cameras {
            if camera.name == type.rawValue {
                self.scnView.pointOfView = camera
            }
        }
    }
    
    public func setSpeed(speed: Float) {
        
        self.state = "running"
        self.car.removeAllActions()
        let trueSpeed = speed / 18
        let setSpeedAction = SCNAction.run({ (node) in
            
            let currentSpeed = self.getSpeed()
            
            let deltaV = -(trueSpeed - currentSpeed)
            
            if abs(deltaV) < 0.4 {
                self.car.physicsBody?.velocity.z = -trueSpeed
            }
            else {
                self.car.physicsBody?.velocity.z += deltaV / (2 * abs(deltaV))
            }
        })
        
        let sequence = [setSpeedAction, SCNAction.wait(duration: 0.05)]
        
        self.car.runAction(SCNAction.repeatForever(SCNAction.sequence(sequence)))
    }
    
    public func brakeTheCar() {
        
        if self.state == "braking" {
            return
        }
        
        self.state = "braking"
        self.car.removeAllActions()
        

        self.car.runAction(self.brakingAction)
    }
    
    public func routine(block: (() -> Void)?) {
        self.routineBlock = block
    }
    
    
}

