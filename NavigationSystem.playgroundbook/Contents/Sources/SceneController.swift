//
//  ScnView.swift
//  WWDC
//
//  Created by Marcelo Martimiano Junior on 20/03/2018.
//  Copyright © 2018 Marcelove. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

enum CategoryBitMask: Int {
    case obstacle = 1
    case radar = 2  
    case car = 4
    case floor = 8
    case barrier = 16
    case lateralLimit = 32
}

protocol control {
    func turnCar(radius: Float, side: Side, a: Float)
    func brake()
    func setSpeed(a: Float)
}
extension SceneController: control {
    func turnCar(radius: Float, side: Side, a: Float) {
        turnCar(radius: radius, side: side, angle: a)
    }
    func brake() {
        self.brakeTheCar()
    }
    func setSpeed(a: Float) {
        self.setSpeed(goalSpeed: a)
    }
}
public enum State {
    case turning
    case braking
    case running
}


public class SceneController: NSObject  {
    var simulationAngle: Float = 0
    let SpeedUnit: Float = 18 // (1 / SpeedUnit) m/s
    var definedSpeed: Float = 0
    var state: State = .running
    
    var previuosTime: TimeInterval = 0
    var updateVisorTime: TimeInterval = 0
    
    //    public var speed: Float = 0
    var obstacleHandler: () -> Void = {}
    var routineBlock: (() -> Void)?
    //=====================
    var radarController: RadarController!
    //====================
    var cameras: [SCNNode] = [SCNNode]()
    
    var sounds: [String: SCNAudioSource] =  [String: SCNAudioSource]()
    var brakingAction: SCNAction!
    
    var car: SCNNode!
    var carBox: SCNNode!
    
    
    public var scnView: SCNView!
    public var scene: SCNScene!
    public weak var sceneRenderer: SCNSceneRenderer?
    
    
    init(scnView: SCNView) {
        super.init()
        
        self.scnView = scnView
        

        self.createScene()
        self.routineBlock?()
    }
    
    public func createScene() {
        
        self.scene = SCNScene(named: "art.scnassets/city.scn")
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
        
        self.sceneRenderer = scnView
        self.sceneRenderer!.delegate = self
    }
    
    
    public func defaultInitialization() {
        
        
        self.scnView.pointOfView = self.scene.rootNode.childNode(withName: "initialCamera", recursively: true)
        if let obstacleNode = self.scene.rootNode.childNode(withName: "initialObstacle", recursively: true) {
            obstacleNode.isHidden = false
        }
        
        self.radarController.setLimitDistance(distance: 5)
        self.radarController.showFrontalRadars()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupSounds() {
        
        let soundsName = ["braking", "runninLoop"]
        for soundName in soundsName {
            guard let audioSource = SCNAudioSource(fileNamed: "art.scnassets/sounds/" + soundName + ".wav") else {
                fatalError("Error in find the sound \(soundName)")
            }
            
            // Volume default de reprodução
            audioSource.volume = 1
            
            // Varia com a posição
            audioSource.isPositional = true
            
            // Não vai precisar pq vai fazer pro-load na memória
            audioSource.shouldStream = false
            
            // Carrega o audio na memoria
            audioSource.load()
            
            // Adiciona o audioSource ao dicionário
            self.sounds[soundName] = audioSource
        }
        
        
    }
    
    func setupActions() {
        guard let sound = self.sounds["braking"] else {
            print("Error sound")
            return
        }
        let soundAction = SCNAction.playAudio(sound, waitForCompletion: false)
        
        let brakingAction = SCNAction.run({ _ in
            
            
            if let currentSpeed = self.car.physicsBody?.velocity {
                let speedModule = sqrt(currentSpeed.x * currentSpeed.x + currentSpeed.z * currentSpeed.z)
                
                if abs(speedModule) < 0.5 {
                    self.car.physicsBody?.velocity = SCNVector3(0, 0, 0)
                    self.car.removeAction(forKey: "braking")
                }
                else {
                    let brakingRate: Float = 0.9
                    
                    self.car.physicsBody?.velocity.x *= brakingRate
                    self.car.physicsBody?.velocity.z *= brakingRate
                }
                
            }
        })
        let sequence = [brakingAction, SCNAction.wait(duration: 0.1)]
        let repeateSequence = SCNAction.repeatForever(SCNAction.sequence(sequence))
        
        let group = [soundAction, repeateSequence]
        self.brakingAction = SCNAction.group(group)
        
    }
    
    
    
    
    
    func setupSensors() {
        guard let radarIndicators = self.scene?.rootNode.childNode(withName: "radarIndicators", recursively: true)?.childNodes,
            let radars = self.scene?.rootNode.childNode(withName: "radarPB", recursively: true)?.childNodes else {
                return
        }
        self.radarController = RadarController(radarIndicators: radarIndicators, radars: radars)
        
    }
    
    func getSpeed() -> SCNVector3 {
        guard let velocity = self.car.physicsBody?.velocity else {
            fatalError("Error getting speed")
        }
        return velocity
    }
    func followHandler(limit: SCNNode) {
        if let value = limit.childNodes[0].name,
        let distance = Float(value) {
            if distance < 0 {
                self.turnCar(radius: 10, side: .right, angle: 5)
            }
            else {
                self.turnCar(radius: 10, side: .left, angle: 5)
                self.car.runAction(SCNAction.wait(duration: 1), completionHandler: {
//                    self.setSpeed(goalSpeed: 40)
                    print("terminou")
                })
            }
        }
    }
    
}
extension SceneController: SCNSceneRendererDelegate {
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - previuosTime
        self.previuosTime = time
        
        self.updateVisorTime += deltaTime
        if updateVisorTime > 0.5 {
            let speed = self.getSpeed()
            let speedModule = sqrt(speed.x * speed.x + speed.z * speed.z)
            let formatedSpeed = String(format: "%.1f", speedModule * 18)
            
            let overlay = self.scnView.overlaySKScene as! Overlay
            overlay.speedLabel.text = formatedSpeed
            overlay.angle.text = String(self.car.eulerAngles.y * (180/Float.pi))
            
            self.updateVisorTime = 0
            
        }
        if self.state == .running && self.car.actionKeys.count == 0 {
            let speed = self.definedSpeed * self.SpeedUnit
            self.setSpeed(goalSpeed: speed)
        }
        self.carBox.position = self.car.presentation.position
        self.carBox.eulerAngles = self.car.eulerAngles
    }
}
extension SceneController: SCNPhysicsContactDelegate {
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if contact.nodeA.name == "lateralLimit"  {
            self.followHandler(limit: contact.nodeA)
        }
        else if contact.nodeB.name == "lateralLimit" {
            self.followHandler(limit: contact.nodeB)
        }
        else if contact.nodeA.name == "corner" || contact.nodeB.name == "corner" {
            self.turnCar(radius: 12, side: .right, angle: 90)
        }
        
    }
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        if contact.nodeA.name == "frontalRadar" || contact.nodeA.name == "frontalRadar" {
            
            self.radarController.obstacleDetected(radar: 0)
            self.obstacleHandler()
        }
    }
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if contact.nodeA.name == "frontalRadar" || contact.nodeA.name == "frontalRadar" {
            
            self.radarController.wayReleased(radar: 0)
        }
    }
}


