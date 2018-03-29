//#-hidden-code
import PlaygroundSupport
import UIKit

let viewController = NavSystemViewController()

PlaygroundSupport.PlaygroundPage.current.liveView = viewController

let navSystem = viewController.systemInterface!
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
navSystem.routine {
    
    //#-code-completion(literal, show, array, boolean)
    //#-code-completion(keyword, hide, var)
    //#-code-completion(keyword, show, for, if)
    //#-editable-code Tap to write your code
    //#-end-editable-code
    
    //#-code-completion(everything, hide)
    //#-code-completion(identifier, show, upper, frontal, diagonal, initialCamera, coneSide, coneProfile)
    navSystem.changeCamera(type: /*#-editable-code */.upper/*#-end-editable-code*/)
    
    
    //#-code-completion(everything, hide)
    navSystem.setSpeed(speed: /*#-editable-code */50/*#-end-editable-code*/)
    
}


navSystem.obstacleDetected {
    navSystem.brakeTheCar()
}

//#-hidden-code

navSystem.createScene(named: "art.scnassets/Chapter1.scn")
//#-end-hidden-code
