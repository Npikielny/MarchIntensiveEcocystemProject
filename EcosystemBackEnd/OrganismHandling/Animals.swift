//
//  Animals.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/13/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Animal: Matter {
    
    var height: CGFloat
    //Species Traits
    var lookType: LookType
    var handler: EnvironmentHandler
    //Priority Handling
    var hunger: Float
    var thirst: Float
    var health: Float {
        didSet {
            if self.health <= 0 {
                self.die()
            }
        }
    }
    var breedingUrge: Float
    
    var maxhunger: Float
    
    var maxthirst: Float
    
    var maxhealth: Float
    
    var maxbreedingUrge: Float
    
    var priority: Priority = .Idle
    //Life Handling
    var age: Float = 0
    var sex: Sex = {
        if Int.random(in: 0...1) == 0 {
            return .Male
        }else {
            return .Female
        }
    }()
    var dead: Bool = false
    var inProcess: Bool = false
    var Id: Int32
    //Movement
    
    var targetTries: Int = 0
    
    var target: SCNVector3 = SCNVector3().zero()
    func getHeight() -> CGFloat {return self.node.worldPosition.y-(self.node.boundingBox.min.y)/2}
    var targetMate: Animal?
    var targetFood: Food?
    //Individual Traits
    var maxSpeed: CGFloat = 0
    var Speed: CGFloat = 2
    
    var efficiency: CGFloat
    
    lazy var priorities: () -> [(Priority,Float,Float)] = {return [(.Food,self.hunger,self.maxhunger), (.Water,self.thirst,self.maxthirst), (.Breed,self.breedingUrge,self.maxbreedingUrge)]}
    
    var barring = [Priority]()
    
//
//    init(Position: SCNVector3, Species: String, lookType: LookType, Handler: SimulationBase) {
//        let model = getPrefab(Species+".scn", Shaders: nil)
//        self.height = model.boundingBox.max.y-model.boundingBox.min.y
//        self.lookType = lookType
//        self.handler = Handler
//        self.Id = Int32(handler.animals.count)
//        super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: model)
//        self.node.name = Handler.Names.randomElement()
//        additionalSetup()
//        self.node.worldPosition = Position
//        self.handler.animals.append(self)
//    }
//
    var move: (Animal) -> ()
    
    var speciesData: AnimalClass.Type
    
    var hunter: Bool = false
    
    var nearbyHunters = [Animal]()
    
    init(SpeciesStats: AnimalClass.Type, Position: SCNVector3, Handler: EnvironmentHandler) {
        self.speciesData = SpeciesStats
        self.hunger = SpeciesStats.maxHunger
        self.thirst = SpeciesStats.maxThirst
        self.breedingUrge = SpeciesStats.maxBreedingUrge
        self.health = SpeciesStats.maxHealth
        self.maxSpeed = SpeciesStats.Speed
        self.efficiency = SpeciesStats.efficiency
        let model = getPrefab(SpeciesStats.name+".scn", Shaders: nil)
        self.height = model.boundingBox.max.y-model.boundingBox.min.y
        self.lookType = SpeciesStats.lookType
        self.handler = Handler
        self.Id = Int32(handler.animals.count)
        
        self.maxhunger = SpeciesStats.maxHunger
        self.maxthirst = SpeciesStats.maxThirst
        self.maxhealth = SpeciesStats.maxHealth
        self.maxbreedingUrge = SpeciesStats.maxBreedingUrge
        
        self.move = SpeciesStats.movementFunction
        
        super.init(Velocity: SCNVector3(0,0,0), Acceleration: SCNVector3(0,0,0), Node: model)
        self.node.name = Handler.Names.randomElement()
        additionalSetup()
        self.node.worldPosition = Position
        self.handler.animals.append(self)
        
        self.target = self.node.worldPosition.setValue(Component: .y, Value: handler.mapValueAt(self.node.worldPosition))
        
        self.affectedByGravity = SpeciesStats.affectedByGravity
        
        self.hunter = SpeciesStats.hunter
    }
    
//
//    init(DebugInit: EnvironmentHandler) {
//        self.height = 0.2
//        self.lookType = .Velocity
//        self.handler = DebugInit
////        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.node, options: [:]))
////        self.node.physicsBody?.angularVelocityFactor = SCNVector3().zero()
//        self.Id = Int32(DebugInit.animals.count)
//        super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: SCNNode(geometry: SCNSphere(radius: 0.1)))
//        additionalSetup()
//        self.node.worldPosition = SCNVector3().initOfComponent(Component: .y, Value: 10)
//        self.handler.animals.append(self)
//
//    }
    
    func die() {
        if dead == false {
            dead = true
    //        let spin = CABasicAnimation(keyPath: "rotation")
    //        spin.fromValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: 0))
    //        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 0, z: 1, w: CGFloat(2 * Float.pi)/4))
    //        spin.duration = 10
    //        self.node.addAnimation(spin, forKey: "rotation")
            let action = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi/4, duration: 1)
            self.node.runAction(action, completionHandler: {
                self.handler.animals.removeAll(where: {$0.node == self.node})
                self.node.removeFromParentNode()
				
                for _ in 0..<Int(self.speciesData.maxHealth)/50 {
					Meat(Position: self.node.worldPosition, Handler: self.handler).velocity = SCNVector3(x: .random(in: -5..<5), y: .random(in: 1..<10), z: .random(in: -5..<5))
				}
				
            })
        }
        
    }
    
    func additionalPhysics() {
        //Customizeable Function Run on Physics Render
    }
    
    func additionalSetup() {
        
    }
    
    func breedRequest(_ Recipient: Animal) -> Bool {
        if Recipient.hunger > 30 && Recipient.thirst > 30 && Recipient.breedingUrge < 70 {
            if let _ = Recipient.targetMate {
                self.targetMate = nil
                return false
            }else {
                self.targetMate = Recipient
                Recipient.targetMate = self
                self.priority = .Breed
                Recipient.priority = .Breed
                let target = (self.node.worldPosition + Recipient.node.worldPosition).scalarMultiplication(Scalar: 0.5)
                let breedingPoint = target.setValue(Component: .y, Value: self.handler.mapValueAt(target))
                self.target = breedingPoint
                Recipient.target = breedingPoint
                return true
            }
        }else {
            self.targetMate = nil
            return false
        }
    }
    func randomTarget() {
        self.target = (self.node.worldPosition + SCNVector3().random().toMagnitude(20))
    }
}

class Bird: Animal {
    
    override func randomTarget() {
        self.target = self.node.worldPosition + SCNVector3().random().toMagnitude(CGFloat.random(in: 45...60))
        self.target = self.target.setValue(Component: .y, Value: CGFloat.random(in: 7...15) + self.handler.mapValueAt(self.target))
        
        if abs(self.target.x) > self.handler.mapDimension / 2 || abs(self.target.z) > self.handler.mapDimension / 2 {
            var i = 0
            while abs(self.target.x) > self.handler.mapDimension / 2 || abs(self.target.z) > self.handler.mapDimension / 2 && i < 10 {
                self.target = self.node.worldPosition + SCNVector3().random().toMagnitude(CGFloat.random(in: 45...60))
                self.target = self.target.setValue(Component: .y, Value: CGFloat.random(in: 7...15) + self.handler.mapValueAt(self.target))
                i += 1
            }
            if i == 10 {
                self.target = SCNVector3().zero()
                self.target = self.target.setValue(Component: .y, Value: CGFloat.random(in: 7...15) + self.handler.mapValueAt(self.target))
            }
        }
    }
}

class Hunter: Animal {
    var targetAnimal: Animal?
}

protocol AnimalClass {
    static var lookType: LookType {get}
    static var maxHunger: Float {get}
    static var maxThirst: Float {get}
    static var maxHealth: Float {get}
    static var maxBreedingUrge: Float {get}
    static var Speed: CGFloat {get}
    static var efficiency: CGFloat {get}
    static var perceptionCap: CGFloat {get}
    static var species: Species {get}
    static var foodType: FoodType {get}
    static var name: String {get}
    static var movementFunction : (Animal) -> () {get}
    static var frictionCoefficient: CGFloat {get}
    static var affectedByGravity: Bool {get}
    static var averageLitterSize: Int {get}
    static var minBreedingAge: Int {get}
    static var maxAge: Int {get}
    static var hunter: Bool {get}
    static var attackDamage: Float {get}
}

struct rabbit: AnimalClass {
    static var lookType: LookType = .Forward
    static var maxHunger: Float = 100
    static var maxThirst: Float = 100
    static var maxHealth: Float = 100
    static var maxBreedingUrge: Float = 100
    static var Speed: CGFloat = 20
    static var efficiency: CGFloat = 0.8
    static var perceptionCap: CGFloat = 100
    static var species: Species = .Rabbit
    static var foodType: FoodType = .Vegetarian
    static var name: String = "rabbit"
    static var movementFunction: (Animal) -> () = {
        let h = $0.handler.mapValueAt($0.node.worldPosition)
        if ($0.velocity.zero(.y)).getMagnitude() == 0 {
            let distance = ($0.target - $0.node.worldPosition).zero(.y).getMagnitude()
            let tp: SCNVector3 = {
                let maxDist: CGFloat = 10
                if distance <= maxDist {
                    return $0.target
                }else {
                    return ($0.target - $0.node.worldPosition).toMagnitude(maxDist) + $0.node.worldPosition
                }
            }($0)
            let y2H = $0.handler.mapValueAt(tp)
            let dx = (tp - $0.node.worldPosition).zero(.y).getMagnitude()
            let dx2 = pow(dx, 2)
            let v2 = pow($0.Speed,2)
            let g: CGFloat = -9.807
            let dy = y2H - h
            let sqrtPart = dx2 - 4 * ((g*dx2)/(v2*2)) * ((g*dx2)/(v2*2) - dy)
            if dx > 0 {
                if sqrtPart >= 0 {
                    let angle: CGFloat = {
                        let a1 = atan((-1 * dx + pow(sqrtPart,0.5))/((g*dx2)/(v2)))
                        let a2 = atan((-1 * dx - pow(sqrtPart,0.5))/((g*dx2)/(v2)))
                        if $0.priority == .Flee {
                            return [a1,a2].min(by: {abs($0) < abs($1)}) ?? CGFloat.pi / 4
                        }else {
                            return [a1,a2].max(by: {abs($0) < abs($1)}) ?? CGFloat.pi / 4
                        }
                    }($0)
                    $0.velocity = tp.directionVector(Center: $0.node.worldPosition).setValue(Component: .y, Value: 0).toMagnitude($0.Speed*cos(angle)).setValue(Component: .y, Value: $0.Speed * sin(angle))
                    if $0.velocity.x.isNaN || $0.velocity.y.isNaN || $0.velocity.z.isNaN {
                        print(y2H,h,dx,dx2,v2,g,dy,sqrtPart,$0.Speed)
                        $0.velocity = SCNVector3(0,0,0)
                    }
                }else {
                    $0.velocity = tp.directionVector(Center: $0.node.worldPosition).setValue(Component: .y, Value: 0).toMagnitude($0.Speed*cos(CGFloat.pi/4)).setValue(Component: .y, Value: $0.Speed * sin(CGFloat.pi/4))
                    if $0.velocity.x.isNaN || $0.velocity.y.isNaN || $0.velocity.z.isNaN {
                        print(y2H,h,dx,dx2,v2,g,dy,sqrtPart,$0.Speed)
                        $0.velocity = SCNVector3(0,0,0)
                    }
                }
            }
        }
    }
    static var averageLitterSize: Int = 6
    static var frictionCoefficient: CGFloat = 1
    static var affectedByGravity: Bool = true
    
    static var minBreedingAge: Int = 6
    static var maxAge: Int = 2 * 12
    
    static var hunter: Bool = false
    static var attackDamage: Float = 0
}

struct fox: AnimalClass {
    static var lookType: LookType = .Forward
    static var maxHunger: Float = 150
    static var maxThirst: Float = 150
    static var maxHealth: Float = 250
    static var maxBreedingUrge: Float = 5000
    static var Speed: CGFloat = 20
    static var efficiency: CGFloat = 3
    static var perceptionCap: CGFloat = 200
    static var species: Species = .Fox
    static var foodType: FoodType = .Meat
    static var name: String = "fox"
    static var movementFunction: (Animal) -> () = {
        let h = $0.handler.mapValueAt($0.node.worldPosition)
        let accel: SCNVector3 = ($0.target - $0.node.worldPosition).zero(.y)
        $0.velocity += accel.toMagnitude(0.1)
        if $0.priority == .Hunt {
            $0.velocity = $0.velocity.toMagnitude($0.Speed)
        }else {$0.velocity = $0.velocity.toMagnitude($0.Speed / 4)}
    }
    static var frictionCoefficient: CGFloat = 0.25
    static var affectedByGravity: Bool = true
    static var averageLitterSize: Int = 2
    
    static var minBreedingAge: Int = 10
    static var maxAge: Int = 5 * 12
    
    static var hunter: Bool = true
    static var attackDamage: Float = 30
}

struct sparrow: AnimalClass {
    static var lookType: LookType = .Forward
    static var maxHunger: Float = 75
    static var maxThirst: Float = 75
    static var maxHealth: Float = 75
    static var maxBreedingUrge: Float = 100
    static var Speed: CGFloat = 25
    static var efficiency: CGFloat = 0.25
    static var perceptionCap: CGFloat = 200
    static var species: Species = .Sparrow
    static var foodType: FoodType = .Fruit
    static var name: String = "sparrow"
    static var movementFunction: (Animal) -> () = {
        let headingDifference = (($0.target - $0.node.worldPosition).unitVector() - $0.velocity)
        $0.acceleration += headingDifference.scalarMultiplication(Scalar: $0.Speed)
        if $0.velocity.getMagnitude() > 0 {
            var speedCoef: CGFloat =  -1*abs(1/($0.target - $0.node.worldPosition).getMagnitude()) + $0.Speed - 1
            if speedCoef > 15 {
                speedCoef = 15
            }else if speedCoef < 1 {
                speedCoef = 1
            }
            $0.velocity = $0.velocity.toMagnitude(speedCoef)
        }
    }
    static var frictionCoefficient: CGFloat = 0.25
    static var affectedByGravity: Bool = false
    static var averageLitterSize: Int = 3
    
    static var minBreedingAge: Int = 2 * 12
    static var maxAge: Int = 3 * 12
    
    static var hunter: Bool = false
    static var attackDamage: Float = 0
}

func Rabbit(Position: SCNVector3, Handler: EnvironmentHandler) -> Animal {
    return Animal(SpeciesStats: rabbit.self, Position: Position, Handler: Handler)
}

func Fox(Position: SCNVector3, Handler: EnvironmentHandler) -> Animal {
    return Hunter(SpeciesStats: fox.self, Position: Position, Handler: Handler)
}

func Sparrow(Position: SCNVector3, Handler: EnvironmentHandler) -> Animal {
    return Bird(SpeciesStats: sparrow.self, Position: Position, Handler: Handler)
}

enum Species {
    case Rabbit
    case Fox
    case Sparrow
}

enum Sex {
    case Male
    case Female
}

var animalReproductionIndex: [String: (SCNVector3, EnvironmentHandler) -> Animal] = ["rabbit": Rabbit, "fox": Fox, "sparrow": Sparrow]
