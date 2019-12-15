//
//  Food.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/15/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Food: Matter {
    var foodType: FoodType
    var foodValue: Float = 40
    var handler: EnvironmentHandler
    
    init(Position: SCNVector3, Species: String, foodType: FoodType, Handler: EnvironmentHandler) {
        self.foodType = foodType
        self.handler = Handler
        super.init(Velocity: SCNVector3().zero(), Acceleration: SCNVector3().zero(), Node: getPrefab(Species+".scn", Shaders: nil))
        self.node.name = Species
        
//        self.node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: self.node, options: [:]))
//        self.node.physicsBody?.angularVelocityFactor = SCNVector3().zero()
        
        self.node.worldPosition = Position
        self.handler.foods.append(self)
    }
    
//    func addPhysicsBody() {
//        if let _ = self.node.physicsBody {
//            if self.node.physicsBody?.type == .static {
//                self.node.physicsBody?.type = .dynamic
//                self.node.physicsBody?.velocityFactor = SCNVector3(0, 1, 0)
//            }
//        }
//    }
    
    func eaten() {
        handler.foods.removeAll(where: {$0.node == self.node})
        self.node.removeFromParentNode()
    }
    
    func syncNode() { // This function realigns the node's position with the physicsbody after rendering
        node.transform = node.presentation.transform
    }
}

class Apple: Food {
    init(Position: SCNVector3, Handler: EnvironmentHandler) {
        super.init(Position: Position, Species: "apple", foodType: .Fruit, Handler: Handler)
        self.node.scale = SCNVector3(0.5,0.5,0.5)
        
    }
}
