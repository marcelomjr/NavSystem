//
//  File.swift
//  NavigationSystem
//
//  Created by Marcelo Martimiano Junior on 23/03/2018.
//  Copyright © 2018 Marcelo. All rights reserved.
//

import Foundation
import SpriteKit

class Overlay: SKScene {
    
    public var speedLabel: SKLabelNode!
    public var angle: SKLabelNode!
    public var left: SKSpriteNode!
    public var right: SKSpriteNode!
    public var brake: SKSpriteNode!
    public var speedNode: SKSpriteNode!
    public var controlDelegate: control!
    
    override func didMove(to view: SKView) {
        self.initialize()
        
        /* self.left = self.childNode(withName: "left") as! SKSpriteNode
         self.left.isUserInteractionEnabled = true
         
         self.speedNode = self.childNode(withName: "speedbutton") as! SKSpriteNode
         self.speedNode.isUserInteractionEnabled = true
         
         self.right = self.childNode(withName: "right") as! SKSpriteNode
         self.right.isUserInteractionEnabled = true
         
         self.brake = self.childNode(withName: "brake") as! SKSpriteNode
         self.brake.isUserInteractionEnabled = true*/
    }
    
    func initialize() {
        self.speedLabel = self.childNode(withName: "speed") as! SKLabelNode
        //self.angle = self.childNode(withName: "angle") as! SKLabelNode
    }
    
}
/*
 extension SKSpriteNode {
 override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
 let radius: Float = 10
 if let overlay = self.parent as? Overlay {
 if self.name == "brake"{
 overlay.controlDelegate.brake()
 }
 else if self.name == "speedbutton" {
 overlay.controlDelegate.setSpeed(a: 30)
 }
 else if self.name == "left" {
 overlay.controlDelegate.turnCar(radius: radius, side: .left, a: 90)
 }
 else {
 overlay.controlDelegate.turnCar(radius: radius, side: .right, a: 90)
 }
 }
 }
 }*/

