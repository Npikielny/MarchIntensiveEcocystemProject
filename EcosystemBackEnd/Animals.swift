//
//  Animals.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/13/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class Animal {
    var node: SCNNode
    var lookType: LookType
    var handler: EnvironmentHandler
    init(Position: SCNVector3, Species: String, lookType: LookType, Handler: EnvironmentHandler) {
        self.node = getPrefab(Species+".scn", Shaders: nil)
        self.node.name = Species
        self.lookType = lookType
        self.handler = Handler
        self.node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: self.node, options: [:]))
        self.node.worldPosition = Position
        self.handler.animals.append(self)
        
    }
}

class Rabbit: Animal {
    init(Position: SCNVector3, Handler: EnvironmentHandler) {
        super.init(Position: Position, Species: "rabbit", lookType: .Forward, Handler: Handler)
    }
}

enum LookType {
    case Velocity
    case Forward
}