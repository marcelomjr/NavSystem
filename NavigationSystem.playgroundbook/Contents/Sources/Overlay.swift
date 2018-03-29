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
    
    override func didMove(to view: SKView) {
        self.initialize()
    }
    
    func initialize() {
       self.speedLabel = self.childNode(withName: "speed") as! SKLabelNode
    }

}

extension SKSpriteNode {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    }
}
