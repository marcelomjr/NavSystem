//
//  NavInterface.swift
//  NavigationSystem
//
//  Created by Marcelo Martimiano Junior on 25/03/2018.
//  Copyright © 2018 Marcelo. All rights reserved.
//

import Foundation

public enum CameraType: String {
    case upper = "upperCamera"
    case frontal = "frontalCamera"
    case diagonal = "diagonalCamera"
    case initialCamera = "initialCamera"
    
    // Chapter1
    case coneSide = "coneSide"
    case coneProfile = "coneProfile"
}

public protocol NaveInterface {
    func changeCamera(type: CameraType)
    func brakeTheCar()
    func setSpeed(speed: Float)
    func obstacleDetected(handler: @escaping () -> Void)
    func setupFrontalRadars(limitDistance: Float)
    func showRadars()
    func hideRadars()
    func routine(block: (() -> Void)?)
    func createScene(named: String)
    func turnCar(degreeAngle: Float)
}
