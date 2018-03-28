//
//  RadarsController.swift
//  NavigationSystem
//
//  Created by Marcelo Martimiano Junior on 25/03/2018.
//  Copyright © 2018 Marcelo. All rights reserved.
//

import Foundation
import SceneKit

class RadarController {
    private var radars: [SCNNode]
    private var radarsPB: [SCNNode]
    private var limitDistance: Float = 5
    private var maxDistance: Float = 10
    
    init(radarIndicators: [SCNNode], radars: [SCNNode]) {
        self.radars = radarIndicators
        self.radarsPB = radars
    }
    
    // o corpo físico do radar deve ser igual ao máximo no Scene kit editor
    func setLimitDistance(distance: Float) {
        if distance < 0.5 {
            self.limitDistance = 0.5
        }
        else if distance > self.maxDistance {
            self.limitDistance = self.maxDistance
        }
        else {
            self.limitDistance = distance
            let scaleFactor = distance / self.maxDistance
            self.radarsPB[0].scale = SCNVector3(1, 1, scaleFactor)
            self.radarsPB[0].position.z = -(2.5 + (distance / 2))
            self.radarsPB[0].physicsBody?.physicsShape = nil
        }
    }
    
    private func setRadarVisibility(selectedRadars: [Int], isHidden: Bool) {
        for selectedRadar in selectedRadars {
            for radar in self.radars {
                if radar.name == "r\(selectedRadar)" {
                    radar.isHidden = isHidden
                    if isHidden {
                        radar.removeAllActions()
                    }
                    else {
                        self.animateRadars(radar: radar)
                    }
                }
            }
        }
    }
    
    public func showFrontalRadars() {
        self.setRadarVisibility(selectedRadars: [0, 1, 2, 3], isHidden: false)
    }
    
    
    public func hideFrontalRadars() {
        self.setRadarVisibility(selectedRadars: [0, 1, 2, 3], isHidden: true)
    }
    
    public func obstacleDetected(radar: Int) {
        self.radars[0].geometry?.firstMaterial?.diffuse.contents = UIColor.red
    }
    
    public func wayReleased(radar: Int) {
        self.radars[0].geometry?.firstMaterial?.diffuse.contents = UIColor.green
    }
    
    func animateRadars(radar: SCNNode) {
        
        let expansionTime: TimeInterval = 1
        
        let factor = (self.limitDistance / self.maxDistance)
        let scale: CGFloat = 100 * CGFloat(factor)
        let move = -4.9 * factor
        
        let activeRadar = SCNAction.run { (radar) in
            radar.runAction(SCNAction.scale(by: scale, duration: expansionTime))
            radar.runAction(SCNAction.move(by: SCNVector3(0, 0, move), duration: expansionTime))
        }
        let hideRadar = SCNAction.run { (radar) in
            radar.position.z = 0
            radar.scale = SCNVector3(1, 1, 1)
        }
        
        let radarSequence = [
            activeRadar,
            SCNAction.wait(duration: expansionTime),
            hideRadar
        ]
        
        radar.runAction(SCNAction.repeatForever(SCNAction.sequence(radarSequence)))
        
    }

}
