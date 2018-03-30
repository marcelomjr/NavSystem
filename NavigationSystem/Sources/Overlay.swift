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
    public var controlDelegate: control!
    
    override func didMove(to view: SKView) {
        self.initialize()
        self.left = self.childNode(withName: "left") as! SKSpriteNode
        
        self.left.isUserInteractionEnabled = true
        self.right = self.childNode(withName: "right") as! SKSpriteNode
        self.right.isUserInteractionEnabled = true
    }
    
    func initialize() {
       self.speedLabel = self.childNode(withName: "speed") as! SKLabelNode
        self.angle = self.childNode(withName: "angle") as! SKLabelNode
    }

}

extension SKSpriteNode {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let overlay = self.parent as? Overlay {
            if self.name == "left" {
                overlay.controlDelegate.turn(a: -10)
            }
            else {
                overlay.controlDelegate.turn(a: 10)
            }
        }
    }
}
