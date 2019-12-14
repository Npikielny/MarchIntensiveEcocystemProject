//
//  PhysicsHandler.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/12/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit

class EnvironmentHandler {
    
    var Scene: EnvironmentScene
    
    var terrain: Ground!
    var water: SurfaceWaterMesh!
    var treeGen: TreeGenerator!
    
    var sky: MDLSkyCubeTexture!
        var time: Float = 0
        var azimuth: Float = 0
        
    
    var selectionIndex: Int? = nil {
        didSet {
            if let _ = selectionIndex {
                if self.selectionIndex! < self.animals.count {
                    self.selectedAnimal = self.animals[self.selectionIndex!]
                }else {
                    self.selectedAnimal = nil
                }
            }else {
                if self.animals.count > 0 {
                    self.selectionIndex = 0
                }else {
                    self.selectedAnimal = nil
                }
            }
        }
    }
    
    var selectedAnimal: Animal?
    
    lazy var setupFunctions: [(()->(),String)] = [(()->(),String)]()
    var setupFunctionIndex: Int = 0
    var initialized: Bool = false // Necessary to keep animals from moving before startup
    init(_ FileNamed: String) {
        self.Scene = EnvironmentScene(named: FileNamed)!
        setupFunctions.append(({}, "Setting Up SCNScene"))
        setupFunctions.append((setupLighting, "Adding Lighting and Loading Sky"))
        setupFunctions.append((setupTerrrain, "Adding Terrain"))
        setupFunctions.append((setupWater, "Adding Water"))
        setupFunctions.append((setupTrees, "Adding Trees"))
        setupFunctions.append((classifyVerticies, "Preparing Scene For Life"))
        setupFunctions.append((getNames, "Finding Animal Names"))
        setupFunctions.append((addAnimals, "Adding Animals"))
        setupFunctions.append((addFood, "Adding Food"))
//        setupFunctions.append((debugPoints,"Adding Debugging Points"))
        setupFunctions.append((commenceEngine, "Starting Physics Engine"))
    }
    
    var Names: [String]!
    
    func getNames() {
        guard let filepath = Bundle.main.path(forResource: "PetNames", ofType: "csv")
            else {
                fatalError("FailedtoFindPath")
        }
        
        
        var contents = try! String(contentsOfFile: filepath)
        var nems = contents.components(separatedBy: ",")
        nems = nems.map({$0.lowercased()})
        nems = nems.map({$0.capitalized})
        
        self.Names = nems
    }
    
    func runSetupFunction() {
        if setupFunctionIndex < setupFunctions.count {
            (setupFunctions[setupFunctionIndex].0)()
            setupFunctionIndex += 1
        }else {
            fatalError("Index Out of Range")
        }
    }
    
    
    var lightSource: SCNNode!
    var skySave: [Float:CGImage?] = [:]
    var skyIndex: Float = 0
    func setupLighting() {
        lightSource = SCNNode()
        lightSource.light = SCNLight()
        lightSource.light?.type = .directional
        lightSource.worldPosition = SCNVector3(0,0,1).toMagnitude(500)
        self.Scene.rootNode.addChildNode(lightSource)
        lightSource.name = "LightSource"
        setupSky()
        
        let ambientNode = SCNNode()
        ambientNode.light = SCNLight()
        ambientNode.light?.type = .ambient
        ambientNode.worldPosition = SCNVector3(0, 100, 0)
        
        ambientNode.light?.color = NSColor.white
        ambientNode.light?.intensity = 100
        self.Scene.rootNode.addChildNode(ambientNode)
        ambientNode.name = "Ambient Light"
    }
    
    var viableVerticies: [SpaciallyAwareVector]!
    var drinkableVertices: [SpaciallyAwareVector]!
    func setupTerrrain() {
        
        terrain = Ground(width: 400, height: 400, widthCount: 100, heightCount: 100)
        terrain.node.name = "Terrain"
        Scene.rootNode.addChildNode(terrain.node)
        self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "x")
        self.terrain.node.geometry?.materials.first!.setValue(Float(430), forKey: "z")
        
    }
    
    func setupWater() {
        water = SurfaceWaterMesh(width: 400, height: 400, widthCount: 25, heightCount: 25)
        water.node.name = "Water"
        if building == false {
            Scene.rootNode.addChildNode(water.node)
        }
    }
    
    func setupTrees() {
        treeGen = TreeGenerator(NumberOfPines: 200, Points: &terrain.vertices)
        if building == false {
            for i in treeGen.trees {
                Scene.rootNode.addChildNode(i.node)
            }
        }
    }
    
    func classifyVerticies() {
        viableVerticies = terrain.vertices
        viableVerticies.removeAll(where: {$0.status != .Normal && $0.status != .NearWater})
        drinkableVertices = terrain.vertices
        drinkableVertices.removeAll(where: {$0.status != .NearWater})
    }
    
    func addAnimals() {
        let Diego = Rabbit(Position: SCNVector3(0,10,0), Handler: self)
        Diego.node.name = "Diego"
        Scene.rootNode.addChildNode(Diego.node)
        
        for _ in 0..<25-1 {
            let rabbit = Rabbit(Position: SCNVector3().random().zero(.y).toMagnitude(CGFloat(Int.random(in:0...200))).setValue(Component: .y, Value: 30), Handler: self)
            Scene.rootNode.addChildNode(rabbit.node)
        }
        
    }
    
    func addFood() {
        for _ in 0..<100 {
            let apple = Apple(Position: (self.viableVerticies.randomElement()?.vector.setValue(Component: .y, Value: 10))!, Handler: self)
            apple.addPhysicsBody()
            self.Scene.rootNode.addChildNode(apple.node)
        }
    }
    
    func debugPoints() {
        for i in self.terrain.vertices {
            let node = SCNNode(geometry: SCNSphere(radius: 0.3))
            if i.status == .NearWater {
                node.geometry?.materials.first?.diffuse.contents = NSColor.cyan
            }else if i.status == .Water {
                node.geometry?.materials.first?.diffuse.contents = NSColor.blue
            }else if i.status == .Tree {
                node.geometry?.materials.first?.diffuse.contents = NSColor.orange
            }else {
                node.geometry?.materials.first?.diffuse.contents = NSColor.green
            }
            Scene.rootNode.addChildNode(node)
            node.worldPosition = i.vector
        }
    }
    
    var animals = [Animal]()
    var foods = [Food]()

    var statsNode: SCNNode = {
        let text = SCNText(string: "Diego", extrusionDepth: 1)
        text.font = NSFont.systemFont(ofSize: 10)
        let node = SCNNode()
        node.geometry = text
        return node
    }()

    var thirstNode: SCNNode = {
        let geo = SCNCapsule(capRadius: 0.2, height: 3)
        geo.heightSegmentCount = 30
        let node = SCNNode(geometry: geo)
        node.geometry?.materials.first!.setValue(Float(0), forKey: "threshold")
        node.geometry?.materials.first!.shaderModifiers = [.geometry:getShader(from: "waterStatShader")]
        node.geometry?.materials.first!.transparencyMode = .aOne
        return node
    }()

    var hungerNode: SCNNode = {
        let geo = SCNCapsule(capRadius: 0.2, height: 3)
        geo.heightSegmentCount = 30
        let node = SCNNode(geometry: geo)
        node.geometry?.materials.first!.setValue(Float(0), forKey: "threshold")
        node.geometry?.materials.first!.shaderModifiers = [.geometry:getShader(from: "hungerStatShader")]
        node.geometry?.materials.first!.transparencyMode = .aOne
        return node
    }()

    var healthNode: SCNNode = {
        let geo = SCNCapsule(capRadius: 0.2, height: 3)
        geo.heightSegmentCount = 30
        let node = SCNNode(geometry: geo)
        node.geometry?.materials.first!.setValue(Float(0), forKey: "threshold")
        node.geometry?.materials.first!.shaderModifiers = [.geometry:getShader(from: "healthStatShader")]
        node.geometry?.materials.first!.transparencyMode = .aOne
        return node
    }()
    
    var breedNode: SCNNode = {
        let geo = SCNCapsule(capRadius: 0.2, height: 3)
        geo.heightSegmentCount = 30
        let node = SCNNode(geometry: geo)
        node.geometry?.materials.first!.setValue(Float(0), forKey: "threshold")
        node.geometry?.materials.first!.shaderModifiers = [.geometry:getShader(from: "breedingStatShader")]
        node.geometry?.materials.first!.transparencyMode = .aOne
        return node
    }()
    
    
    var lastTime: Float = 0
    func Physics() {
        let difference = self.time - lastTime
        
        for item in animals {
            if item.node.worldPosition.y > 1 {
                
            }
            
        }
        
        lastTime = self.time
    }
    
}
