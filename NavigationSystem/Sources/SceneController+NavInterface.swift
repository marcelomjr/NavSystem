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
        skScene.controlDelegate = self
        self.scnView.overlaySKScene = skScene
        
        self.setupSensors()
        
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
        self.car.removeAllActions()
        let trueSpeed = speed / 18 //km/h
        
        // velocidade atual pretendida
        self.systemSpeed = trueSpeed
      
        let setSpeedAction = SCNAction.run({ (node) in
            
            let goalSpeedX = self.systemSpeed * sin(self.carDirection)
            let goalSpeedZ = -self.systemSpeed * cos(self.carDirection)

            let currentSpeed = self.getSpeed()
            
            let deltaSpeedX = -(goalSpeedX - currentSpeed.x)
            let deltaSpeedZ = goalSpeedZ - currentSpeed.z
            
            
            
            if abs(deltaSpeedX) < 0.4 {
                self.car.physicsBody?.velocity.x = goalSpeedX
            }
            else {
                self.car.physicsBody?.velocity.x += goalSpeedX / (2 * abs(goalSpeedX))
                print(self.car.physicsBody?.velocity.x)
            }
            
            
            if abs(deltaSpeedZ) < 0.4 {
                self.car.physicsBody?.velocity.z = goalSpeedZ
            }
            else {
                self.car.physicsBody?.velocity.z += deltaSpeedZ / (2 * abs(deltaSpeedZ))
            }
        })
        
        let sequence = [setSpeedAction, SCNAction.wait(duration: 0.05)]
        
        self.car.runAction(SCNAction.repeatForever(SCNAction.sequence(sequence)))
    }
    
    public func brakeTheCar() {
        self.car.removeAllActions()
        let brakingAction = SCNAction.run({ (node) in
            if let speed = self.car.physicsBody?.velocity.z {
                
                if abs(speed) < 0.5 {
                    self.car.physicsBody?.velocity.z = 0
                    self.car.removeAllActions()
                }
                else {
                    
                    self.car.physicsBody?.velocity.z = speed * 0.97
                }
            }
        })
        let sequence = [brakingAction, SCNAction.wait(duration: 0.1)]
        
        self.car.runAction(SCNAction.repeatForever(SCNAction.sequence(sequence)))
    }
    
    public func routine(block: (() -> Void)?) {
        self.routineBlock = block
    }
    
    public func turnCar(degreeAngle: Float) {
        let angle = degreeAngle * Float.pi / 180
       
        self.carDirection = angle
        let mesh = self.car.childNodes[0]
        mesh.runAction(SCNAction.rotateTo(x: 0, y: CGFloat(-angle), z: 0, duration: 0.5))
    }
}

