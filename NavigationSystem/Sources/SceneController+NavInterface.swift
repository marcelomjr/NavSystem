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
        
        guard let car = self.scene?.rootNode.childNode(withName: "carModel", recursively: true),
        let carBox = self.scene?.rootNode.childNode(withName: "carBox", recursively: true) else
        {
            print("Error in get objects")
            return
        }
        self.car = car
        self.carBox = carBox
        
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
        let angle = -self.car.eulerAngles.y
        
        let setSpeedAction = SCNAction.run({ (node) in
            
            if let currentSpeed = self.car.physicsBody?.velocity {
                let speedModule = sqrt(currentSpeed.x * currentSpeed.x + currentSpeed.z * currentSpeed.z)
                let deltaV = speed - speedModule
                print(deltaV)
                
                if abs(deltaV) < 0.5 {
                    let velocity = SCNVector3(speed * sin(angle), 0, speed * cos(angle))
                    self.car.physicsBody?.velocity = velocity
                }
                else {
                    let newSpeed = deltaV / (2 * abs(deltaV))
                    self.car.physicsBody?.velocity.z += newSpeed * cos(angle)
                    self.car.physicsBody?.velocity.x += newSpeed * sin(angle)
                }
            }
        })
        
        let sequence = [setSpeedAction, SCNAction.wait(duration: 0.05)]
        let loopAction = SCNAction.repeatForever(SCNAction.sequence(sequence))
        self.scene.rootNode.runAction(loopAction, forKey: "moveForward")
    }
    
    public func brakeTheCar(goalSpeed: Float) {
        
        self.scene.rootNode.removeAction(forKey: "moveForward")
        self.scene.rootNode.removeAction(forKey: "turnCar")
        
        let torque: Float = 10
        
        let brakingAction = SCNAction.run({ (node) in
            
            //velocidade atual do carro
            if let currentSpeed = self.car.physicsBody?.velocity {
                // modulo da velocidade
                let speedModule = sqrt(currentSpeed.x * currentSpeed.x + currentSpeed.z * currentSpeed.z)
                // versor da velocidade atual
                let direction = float2((currentSpeed.x / speedModule), (currentSpeed.z / speedModule))
                
                
                if speedModule > goalSpeed {
                    if abs(speedModule) < 0.1 {
                        
                        self.car.physicsBody?.velocity = SCNVector3(0, 0, 0)
                        self.scene.rootNode.removeAction(forKey: "brake")
                    }
                    else {
                        let force = SCNVector3((torque * -direction.x), 0, (torque * -direction.y))
                        self.car.physicsBody?.applyForce(force, asImpulse: true)
                    }
                }
            }
        })
        let sequence = [brakingAction, SCNAction.wait(duration: 0.1)]
        
        self.scene.rootNode.runAction(SCNAction.repeatForever(SCNAction.sequence(sequence)), forKey: "brake")
    }
    
    public func routine(block: (() -> Void)?) {
        self.routineBlock = block
    }

    
    private func turnSimulation(radAngle: Float, radius: Float) -> float2 {
        let angle = Float.pi - radAngle
        
        let x = radius * sin(angle)
        let z = -radius * cos(angle)
        
        return float2(x, z)
    }
    
    private func rotateSimulation(radAngle: Float, point: float2, correction: float2) -> float2 {
        
        let x = (cos(radAngle) * point.x - sin(radAngle) * point.y)// + correction.x
        let z = (sin(radAngle) * point.x + cos(radAngle) * point.y)// + correction.y
        
        return float2(x, z)
    }
    
    public func turnCar(radius: Float, angle: Float) {
        let turnAngle = -angle * (Float.pi / 180)
        let carAngle = self.car.eulerAngles.y
        
        let origin = turnSimulation(radAngle: 0, radius: radius)
        let rotatedOrigin = self.rotateSimulation(radAngle: carAngle, point: origin, correction: float2(0,0))
        
        let deltaX = origin.x - rotatedOrigin.x
        let deltaZ = origin.y - rotatedOrigin.y
        
        let correction = float2(deltaX, deltaZ)
        print(correction)
        
        let turnTime: TimeInterval = 3
        let torque: Float = 2
        
        self.simulationAngle = 0
        
        let rotateAction = SCNAction.run { _ in
//            // para evitar resetar a aplicacao da forca
//            self.car.transform = self.car.presentation.transform
//            self.car.runAction(SCNAction.rotateBy(x: 0, y: CGFloat(turnAngle), z: 0, duration: turnTime))
        }
        
        let turnAction = SCNAction.run { (node) in
            
            let moved = self.turnSimulation(radAngle: self.simulationAngle, radius: radius)
            let rotated = self.rotateSimulation(radAngle: -carAngle, point: moved, correction: correction)
            print("carAngle: \((carAngle * 180) / Float.pi) | moved: \(moved) | rotated: \(rotated)")
            
            
            self.car.physicsBody?.applyForce(SCNVector3(torque * rotated.x, 0, torque * rotated.y), asImpulse: true)
            self.simulationAngle += turnAngle * (1/100)
            
        }
        let waitTime = TimeInterval(turnTime / 100)
        let sequence = SCNAction.sequence([turnAction, SCNAction.wait(duration: waitTime)])
        let turnSequenceLoop = SCNAction.repeat(sequence, count: 100)
        
        let turnGroup = SCNAction.group([turnSequenceLoop, rotateAction])
        
        self.scene.rootNode.removeAction(forKey: "moveForward")
        self.scene.rootNode.runAction(turnGroup, forKey: "turnCar")
        
    }
}


