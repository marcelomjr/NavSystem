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
}

protocol control {
    func turn(a: Float)
}
extension SceneController: control {
    func turn(a: Float) {
        self.turnCar(radius: 12)
    }

}
public class SceneController: NSObject  {
    var simulationAngle: Float = 0
    var desiredSpeedModule: Float = 0
    var carDirection: Float = 0
    var carPivot: SCNNode!
    
    var previuosTime: TimeInterval = 0
    var updateVisorTime: TimeInterval = 0
    
    //    public var speed: Float = 0
    var obstacleHandler: () -> Void = {}
    var routineBlock: (() -> Void)?
    //=====================
    var radarController: RadarController!
    //====================
    var cameras: [SCNNode] = [SCNNode]()
    
    var car: SCNNode!
    var carBox: SCNNode!
    
    
    public var scnView: SCNView!
    public var scene: SCNScene!
    public weak var sceneRenderer: SCNSceneRenderer?
    
    
    init(scnView: SCNView) {
        super.init()
        
        self.scnView = scnView
        
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
            overlay.angle.text = String(self.carPivot.eulerAngles.y * (180/Float.pi))
            
            self.updateVisorTime = 0
        }

        self.carBox.position = self.car.presentation.position
        self.carBox.eulerAngles = self.car.presentation.eulerAngles
    }
}
extension SceneController: SCNPhysicsContactDelegate {
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == CategoryBitMask.radar.rawValue ||
            contact.nodeA.physicsBody?.categoryBitMask == CategoryBitMask.radar.rawValue {
            
            self.radarController.obstacleDetected(radar: 0)
            self.obstacleHandler()
        }
    }
    
    public func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if contact.nodeA.physicsBody?.categoryBitMask == CategoryBitMask.radar.rawValue ||
            contact.nodeA.physicsBody?.categoryBitMask == CategoryBitMask.radar.rawValue {
            
            self.radarController.wayReleased(radar: 0)
        }
    }
}


