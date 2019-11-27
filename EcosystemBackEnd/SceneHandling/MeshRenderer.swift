//
//  MeshRenderer.swift
//  EcosystemBackEnd
//
//  Created by Noah Pikielny on 11/10/19.
//  Copyright © 2019 Noah Pikielny. All rights reserved.
//

import SceneKit
import GameplayKit


class Mesh {
    
    var Verticies: [SCNVector3]
    var Indicies: [UInt16]
    var node: SCNNode!
    
    lazy var source = {return SCNGeometrySource(vertices: self.Verticies)}
    lazy var element = {return SCNGeometryElement(indices: self.Indicies, primitiveType: SCNGeometryPrimitiveType.triangles)}
    
    init(Verticies: [SCNVector3], Indices: [UInt16]) {
        self.Verticies = Verticies
        self.Indicies = Indices
        makeMesh()
        
    }
    
    func makeMesh() {
        if let _ = self.node {
            self.node.geometry = SCNGeometry(sources: [self.source()], elements: [self.element()])
        }else {
            self.node = SCNNode(geometry: SCNGeometry(sources: [self.source()], elements: [self.element()]))
        }
        customizeMesh()
    }
    
    func customizeMesh() {}
    
    
    
}

//class SceneGenerator {
//    var ground: Mesh
//    var water: Mesh
//    var pineGen: PineGenerator
//    var noiseMap: GKNoiseMap
//    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int) {
//        var vertices = [SCNVector3]()
//            noiseMap = {
//                let source = GKPerlinNoiseSource()
//                source.persistence = 0.9
//                let noise = GKNoise(source)
//                let size = vector2(1.0, 1.0)
//                let origin = vector2(0.0, 0.0)
//                let sampleCount = vector2(Int32(widthCount), Int32(heightCount))
//                return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
//            }()
//            for w in 0..<widthCount {
//                for h in 0..<heightCount {
//                    let vertex = SCNVector3(x: width*CGFloat(w)/CGFloat(widthCount-1)-width/2, y: 1-CGFloat(noiseMap.interpolatedValue(at: vector_float2(Float(w),Float(h)))), z: height*CGFloat(h)/CGFloat(heightCount-1)-height/2)
//                    vertices.append(vertex)
//                }
//            }
//
//            var groundIndices = [UInt16]()
//            var waterIndices = [UInt16]()
//
//            let index: (Int,Int) -> Int = {return $0 * heightCount + $1}
//
//
//            for w in 0..<widthCount-1 {
//                for h in 0..<heightCount-1 {
//                    var squareVerticies = [UInt16]()
//                    squareVerticies.append(UInt16(index(w,h)))
//                    squareVerticies.append(UInt16(index(w,h+1)))
//                    squareVerticies.append(UInt16(index(w+1,h)))
//                    squareVerticies.append(UInt16(index(w+1,h+1)))
//
//                    var water: Bool = false
//
//                    for i in [index(w,h),index(w,h+1),index(w+1,h),index(w+1,h+1)] {
//                        if vertices[i].y < 2 {
//                            water = true
//                        }
//                    }
//
//                    groundIndices.append(squareVerticies[0])
//                    groundIndices.append(squareVerticies[1])
//                    groundIndices.append(squareVerticies[3])
//
//                    groundIndices.append(squareVerticies[0])
//                    groundIndices.append(squareVerticies[3])
//                    groundIndices.append(squareVerticies[2])
//
//                    if water == true {
//                        waterIndices.append(squareVerticies[0])
//                        waterIndices.append(squareVerticies[1])
//                        waterIndices.append(squareVerticies[3])
//
//                        waterIndices.append(squareVerticies[0])
//                        waterIndices.append(squareVerticies[3])
//                        waterIndices.append(squareVerticies[2])
//                    }
//
//                }
//            }
//        ground = Mesh(Verticies: vertices, Indices: groundIndices)
//        ground.node.name = "Ground"
//        let color1: NSColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
//        let color2: NSColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
//        ground.node.geometry?.materials.first?.roughness.contents = 1
//        ground.node.geometry?.materials.first!.shaderModifiers = [.geometry :
//            getShader(from: "groundShader")
//        ]
//
//
//
//
//
//        water = Mesh(Verticies: vertices, Indices: waterIndices)
//        water.node.name = "Water"
//
//        let color: NSColor = #colorLiteral(red: 0, green: 0.9859127402, blue: 1, alpha: 0.5554098887)
//        water.node.geometry?.materials.first!.diffuse.contents = color
//        water.node.geometry?.materials.first?.metalness.contents = 1
//        water.node.geometry?.materials.first?.roughness.contents = 0
//        water.node.geometry?.materials.first?.multiply.contents = NSColor.white
//        water.node.geometry?.materials.first?.shininess = 1
//        water.node.geometry?.materials.first?.specular.contents = 1
//        water.node.geometry?.materials.first!.shaderModifiers = [.geometry :
//            getShader(from: "waterShader")
//        ]
//
//
//
//
//        pineGen = PineGenerator(NumberOfPines: 500, NoiseMap: noiseMap, Width: 400, Height: 400, widthCount: 100, heightCount: 100)
//
//    }
//}

struct SpaciallyAwareVector {
    var vector: SCNVector3
    var status: pointTypes = .Normal
}

enum pointTypes {
    case Tree
    case NearWater
    case Normal
    case Water
}


class Ground: Mesh {
    var noiseMap: GKNoiseMap
    var vertices = [SpaciallyAwareVector]()
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int) {
        
        noiseMap = {
            let source = GKPerlinNoiseSource()
            source.persistence = 0.9
            
//            source.seed = Int32.random(in: 0...100)

            let noise = GKNoise(source)
            let size = vector2(1.0, 1.0)
            let origin = vector2(0.0, 0.0)
            let sampleCount = vector2(Int32(widthCount), Int32(heightCount))
            return GKNoiseMap(noise, size: size, origin: origin, sampleCount: sampleCount, seamless: true)
        }()
            
        
        
        for w in 0..<widthCount {
            for h in 0..<heightCount {
                let vertex = SCNVector3(x: width*CGFloat(w)/CGFloat(widthCount)-width/2, y: 1-CGFloat(noiseMap.interpolatedValue(at: vector_float2(Float(w),Float(h)))), z: height*CGFloat(h)/CGFloat(heightCount)-height/2)
                vertices.append(SpaciallyAwareVector(vector: vertex))
            }
        }

        var indices = [UInt16]()

        let index: (Int,Int) -> Int = {return $0 * heightCount + $1}


        for w in 0..<widthCount-1 {
            for h in 0..<heightCount-1 {
                var squareVerticies = [UInt16]()
                squareVerticies.append(UInt16(index(w,h)))
                squareVerticies.append(UInt16(index(w,h+1)))
                squareVerticies.append(UInt16(index(w+1,h)))
                squareVerticies.append(UInt16(index(w+1,h+1)))
                indices.append(squareVerticies[0])
                indices.append(squareVerticies[1])
                indices.append(squareVerticies[3])

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[3])
                indices.append(squareVerticies[2])

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[3])
                indices.append(squareVerticies[1])

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[2])
                indices.append(squareVerticies[3])
                var found: Bool = false
                for i in squareVerticies {
                    if self.vertices[Int(i)].vector.y == 0 {
                        found = true
                    }
                }
                if found == true {
                    for i in squareVerticies {
                        if self.vertices[Int(i)].vector.y != 0 {
                            self.vertices[Int(i)].status = .NearWater
                        }else {
                            self.vertices[Int(i)].status = .Water
                        }
                    }
                }
            }
        }
        
        super.init(Verticies: vertices.map({$0.vector}), Indices: indices)
        self.node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: SCNGeometry(sources: [source()], elements: [element()]), options: [:]))
        
    }
    
    override func customizeMesh() {
        let color1: NSColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        let color2: NSColor = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
        let color3: NSColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
               
        self.node.geometry?.materials.first?.roughness.contents = 1
        self.node.geometry?.materials.first!.shaderModifiers = [.geometry :
            getShader(from: "groundShader")
        ]
//        self.node.categoryBitMask = 1
    }
}

class SurfaceWaterMesh: Mesh {
    var Time: CGFloat = 0
    
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int) {
        var vertices = [SCNVector3]()
        for w in 0..<widthCount {
            for h in 0..<heightCount {
                let heightMap: CGFloat = 0
                let vertex = SCNVector3(x: width*CGFloat(w)/CGFloat(widthCount-1)-width/2, y: CGFloat(heightMap), z: height*CGFloat(h)/CGFloat(heightCount-1)-height/2)
                vertices.append(vertex)
            }
        }

        var indices = [UInt16]()

        let index: (Int,Int) -> Int = {return $0 * heightCount + $1}


        for w in 0..<widthCount-1 {
            for h in 0..<heightCount-1 {
                var squareVerticies = [UInt16]()
                squareVerticies.append(UInt16(index(w,h)))
                squareVerticies.append(UInt16(index(w,h+1)))
                squareVerticies.append(UInt16(index(w+1,h)))
                squareVerticies.append(UInt16(index(w+1,h+1)))

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[1])
                indices.append(squareVerticies[3])

                indices.append(squareVerticies[0])
                indices.append(squareVerticies[3])
                indices.append(squareVerticies[2])
//
//                indices.append(squareVerticies[0])
//                indices.append(squareVerticies[3])
//                indices.append(squareVerticies[1])
//
//                indices.append(squareVerticies[0])
//                indices.append(squareVerticies[2])
//                indices.append(squareVerticies[3])
            }
        }
        
        super.init(Verticies: vertices, Indices: indices)
        
    }
    
    init(width: CGFloat, height: CGFloat, widthCount: Int, heightCount: Int, NoiseMap: GKNoiseMap, Threshold: CGFloat, NoiseMapWidth: Int, NoiseMapHeight: Int) {
        var vertices = [SCNVector3]()
        var indices = [UInt16]()
        
        var squares = [[SCNVector3]]()
        
        let conversion = NoiseMapWidth/widthCount
        for w in 0...widthCount {
            for h in 0...heightCount {
                var found: Int = 0
                for w2 in 0...conversion {
                    for h2 in 0...conversion {
                        if CGFloat(NoiseMap.interpolatedValue(at: vector_float2(Float(w*conversion+w2),Float(h*conversion+h2)))) > Threshold {
                            found += 1
                        }
                    }
                }
                if found > 0 {
                    squares.append([SCNVector3(CGFloat(w)/CGFloat(widthCount)*width,0,CGFloat(h)/CGFloat(heightCount)*height),
                                    SCNVector3(CGFloat(w)/CGFloat(widthCount)*width,0,CGFloat(h+1)/CGFloat(heightCount)*height),
                                    SCNVector3(CGFloat(w+1)/CGFloat(widthCount)*width,0,CGFloat(h)/CGFloat(heightCount)*height),
                                    SCNVector3(CGFloat(w+1)/CGFloat(widthCount)*width,0,CGFloat(h+1)/CGFloat(heightCount)*height)])
                }

            }
        }
        
        
        for i in squares {
            let initialCount = UInt16(vertices.count)
            for vertex in i {
                vertices.append(vertex)
            }
            indices.append(UInt16(0+initialCount))
            indices.append(UInt16(1+initialCount))
            indices.append(UInt16(3+initialCount))
            
            indices.append(UInt16(0+initialCount))
            indices.append(UInt16(3+initialCount))
            indices.append(UInt16(2+initialCount))
            
        }
        
        super.init(Verticies: vertices, Indices: indices)
    }
    
    override func customizeMesh() {
        let color: NSColor = #colorLiteral(red: 0, green: 0.9859127402, blue: 1, alpha: 0.5554098887)
        self.node.geometry?.materials.first!.diffuse.contents = color
        self.node.geometry?.materials.first?.metalness.contents = 1
        self.node.geometry?.materials.first?.roughness.contents = 0
        self.node.geometry?.materials.first?.multiply.contents = NSColor.white
        self.node.geometry?.materials.first?.shininess = 1
        self.node.geometry?.materials.first?.specular.contents = 1
        self.node.geometry?.materials.first!.shaderModifiers = [.geometry :
            getShader(from: "waterShader")
        ]
    }
}

func getShader(from filename: String) -> String {
    do {
        if let dirs = Bundle.main.url(forResource: filename, withExtension: "shader") {
            return try String(contentsOf: dirs, encoding: .utf8)
        }
    } catch {
        print(error)
    }
    print("shader \(filename) not found")
    return ""
}

