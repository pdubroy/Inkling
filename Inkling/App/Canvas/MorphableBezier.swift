//
//  MorphableBezier.swift
//  Inkling
//
//  Created by Marcel on 24/08/2022.
//


import Foundation
import UIKit

class MorphableBezier: Morphable {
  var stroke: Stroke
  var nodes: [Node]
  
  var controlPoints: [CGVector]
  
  init(_ stroke: Stroke, _ controlPoints: [CGVector]) {
    self.stroke = stroke
    self.controlPoints = controlPoints
    
    self.nodes = []
    self.nodes.append(Node(controlPoints[0], self))
    self.nodes.append(Node(controlPoints[3], self))
  }
  
  func move(){
    controlPoints[0] = nodes[0].position
    controlPoints[3] = nodes[1].position
    
    var points: [CGVector] = []
    let size = stroke.points.count
    
    for i in 0..<size {
      let t = CGFloat(i) / CGFloat(size)
      let pt = bezierQ(controlPoints, t)
      points.append(pt)
    }
    
    stroke.points = points
    stroke.updateVerts()
  }

}
