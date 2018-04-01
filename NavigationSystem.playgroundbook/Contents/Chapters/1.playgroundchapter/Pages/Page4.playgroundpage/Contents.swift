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
 # First Sensor: Radar
 
 An autonomous car must first and foremost be **safe** for its passengers and for the people near the car.
 
 So now your task is to ensure that if a person or obstacle is in the in the car path it will stop before the impact.
 
 For **low speeds** we will use the Radar (Radio Detection And Ranging) sensor.
 
 Radar is a device that allows you to detect distant objects and infer their distances.
 
 Mas para isso você irá precisar saber como controlar o carro, por enquanto use essas duas funções de nossa biblioteca:
 
 1. navSystem.setSpeed(speed: floatValue): O sistema irá acelerar o carro até atingir a velocidade definida.
 
 2. navSystem.brakeTheCar(): Aciona os freios do veículo.
 
 */

func setupSystem() {
    setupCamera(type: /*#-editable-code */.diagonal/*#-end-editable-code*/)
    
    
    setSpeedControl(speed: /*#-editable-code */50/*#-end-editable-code*/)
    
}

navSystem.routine(block: setupSystem)

navSystem.start()

navSystem.obstacleDetected {
    navSystem.brakeTheCar()
}









