//
//  Stroke.swift
//  Inkling
//
//  Created by Marcel on 18/08/2022.
//

import Foundation
import UIKit

class Stroke {
  var points: [CGVector]
  var weights: [CGFloat]
  
  var color: Color
  var verts: [Vertex]
  
  init(_ points: [CGVector], _ weights: [CGFloat], _ color: Color) {
    assert(points.count == weights.count)
    
    self.points = points
    self.weights = weights
    self.color = color
    self.verts = []
    update_verts()
  }
  
  func update_verts(){
    verts = []
    
    let first = points.first!
    let first_weight = weights.first!
    verts.append(Vertex(position: SIMD3(Float(first.dx), Float(first.dy), Float(first_weight)), color: color.as_simd_transparent()))
    for (pt, weight) in zip(points, weights) {
      verts.append(Vertex(position: SIMD3(Float(pt.dx), Float(pt.dy), Float(weight)), color: color.as_simd()))
    }
    let last = points.last!
    let last_weight = weights.last!
    verts.append(Vertex(position: SIMD3(Float(last.dx), Float(last.dy), Float(last_weight)), color: color.as_simd_transparent()))
  }
  
  func render(_ renderer: Renderer) {
    renderer.addStrokeData(verts);
  }
}
