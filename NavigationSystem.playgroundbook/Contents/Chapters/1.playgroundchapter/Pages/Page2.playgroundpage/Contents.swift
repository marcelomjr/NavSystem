//#-hidden-code
import PlaygroundSupport
import UIKit

let viewController = NavSystemViewController()

PlaygroundSupport.PlaygroundPage.current.liveView = viewController

let navSystem = viewController.systemInterface!


navSystem.setupFrontalRadars(limitDistance: 10)
navSystem.showRadars()

public func setupCamera(type: CameraType) {
    
    navSystem.changeCamera(type: type)
}

public func brakeTheCar() {
    navSystem.brakeTheCar()
}

public func setSpeedControl(speed: Float) {
    navSystem.setSpeed(goalSpeed: speed)
}



//#-end-hidden-code
/*:
 # Radar Sensor
 
 An autonomous car must first and foremost be **safe** for its passengers and for the people near the car.
 
 So now your task is to ensure that if a person or obstacle is in the in the car path it will stop before the impact.
 
 For **low speeds** we will use the Radar (Radio Detection And Ranging) sensor.
 
 Radar is a device that allows you to detect distant objects and infer their distances.
 
 But for this you will need to know how to control the car, for now use these two functions of our library:
 
 1. navSystem.setSpeed(speed: floatValue): The system will accelerate the car until it reaches the defined speed.
 
 2. navSystem.brakeTheCar(): It triggers the brakes of the vehicle.
 3. setupCamera(type): It change the point of view about the car. try use one of these types:
    upper, frontal, diagonal, coneSide, coneProfile
 
 * Try to use the function setSpeedControl and see what is the maximum speed at which the car can stop inside the safety area.
 */

func setupSystem() {
    
    setupCamera(type: /*#-editable-code */.upper/*#-end-editable-code*/)
    
    setSpeedControl(speed: /*#-editable-code */50/*#-end-editable-code*/)
    
}

/*:
This function handler when a obstacle is in the front of the car, try change this...
 */
 navSystem.obstacleDetected {
    navSystem.brakeTheCar()
 }

//#-hidden-code
navSystem.routine(block: setupSystem)

navSystem.start()


//#-end-hidden-code








