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
        self.setupSounds()
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
        
        self.car.removeAllActions()
        let angle = self.car.eulerAngles.y
        print(angle * (180 / Float.pi))
        let setSpeedAction = SCNAction.run({ (node) in
            
            if let currentSpeed = self.car.physicsBody?.velocity {
                let speedModule = sqrt(currentSpeed.x * currentSpeed.x + currentSpeed.z * currentSpeed.z)
                let deltaV = speed - speedModule
                
                if abs(deltaV) < 0.5 {
                    let velocity = SCNVector3(speed * sin(angle), 0, speed * cos(angle))
                    self.car.physicsBody?.velocity = velocity
                }
                else {
                    let newSpeed = deltaV / (2 * abs(deltaV))
                    self.car.physicsBody?.velocity.x += newSpeed * sin(angle)
                    self.car.physicsBody?.velocity.z += newSpeed * cos(angle)
                    
                }
            }
        })
        
        let sequence = [setSpeedAction, SCNAction.wait(duration: 0.05)]
        let loopAction = SCNAction.repeatForever(SCNAction.sequence(sequence))
        self.car.runAction(loopAction, forKey: "moveForward")
    }
    
    public func brakeTheCar() {
        
        if self.car.actionKeys.contains("braking") {
            return
        }
        self.car.removeAction(forKey: "moveForward")
        
        self.car.runAction(self.brakingAction, forKey: "braking")
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
    private func positionFunction(radAngle: Float, radius: Float, correction: float2, side: Side) -> float2 {
        let angle = Float.pi - radAngle
        
        var x: Float
        
        // correcao de lado de virada
        if side == Side.right {
            x = -radius - (radius + radius * cos(angle))
        }
        else {
            x = radius * cos(angle)
        }
        x += correction.x
        
        let z = radius * sin(angle) + correction.y
        
        return float2(x, z)
    }
    
    private func rotateSimulation(radAngle: Float, point: float2, correction: float2) -> float2 {
        
        let x = (cos(radAngle) * point.x - sin(radAngle) * point.y) + correction.x
        let z = (sin(radAngle) * point.x + cos(radAngle) * point.y) + correction.y
        
        return float2(x, z)
    }
    
     public func turnCar(radius: Float, side: Side, angle: Float) {
        let loopTimes: Float = 100
        
        self.car.removeAction(forKey: "moveForward")
        
        // para o carro, ver se e necessario mesmo
//        self.car.physicsBody?.velocity = SCNVector3(0,0,0)
        
        
        
        let turnAngle = angle * (Float.pi / 180)
        
        // angulacao inicial do carro
        let carAngle = self.car.eulerAngles.y
        
        // start position
        let currentPosition = self.car.presentation.position
        
        let positionCorrection = float2((currentPosition.x  + radius), currentPosition.z)
//        print("positionCorrection: \(positionCorrection)")
        
        let origin = self.positionFunction(radAngle: 0, radius: radius, correction: positionCorrection, side: side)
        let rotatedOrigin = self.rotateSimulation(radAngle: -carAngle, point: origin, correction: float2(0,0))
//        print("origin: \(origin)")
//        print("rotatedOrigin: \(rotatedOrigin)")
        
        let deltaX = origin.x - rotatedOrigin.x
        let deltaZ = origin.y - rotatedOrigin.y
        
        let rotationCorrection = float2(deltaX, deltaZ)
//        print("rotationCorrection: \(rotationCorrection)")
        
        
        let turnTime: TimeInterval = 3
        self.simulationAngle = 0
        
        
        let turnAction = SCNAction.run { _ in
            
            var newPosition = self.positionFunction(radAngle: self.simulationAngle, radius: radius, correction: positionCorrection, side: side)
            
            let rotatedPosition = self.rotateSimulation(radAngle: -carAngle, point: newPosition, correction: rotationCorrection)

            
            self.car.position.x = rotatedPosition.x
            self.car.position.z = rotatedPosition.y
            
            if side == .left {
 
                print("\(self.car.eulerAngles.y)  \(self.car.presentation.eulerAngles.y)")
                self.car.eulerAngles.y += turnAngle * (1 / loopTimes)
            }
            else {
                self.car.eulerAngles.y += -turnAngle * (1 / loopTimes)
            }
            
            self.simulationAngle += turnAngle * (1 / loopTimes)
            
        }
        
        let waitTime = turnTime / TimeInterval(loopTimes)
        let sequence = SCNAction.sequence([turnAction, SCNAction.wait(duration: waitTime)])
        let turnSequenceLoop = SCNAction.repeat(sequence, count: Int(loopTimes))

        // para evitar resetar a aplicacao da forca
//        self.car.transform = self.car.presentation.transform
        
        self.car.runAction(turnSequenceLoop, forKey: "turnCar")
        
    }
}


