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
  var color: Color
  var verts: [Vertex]
  
  init(_ points: [CGVector], _ color: Color) {
    self.points = points
    self.color = color
    self.verts = []
    update_verts()
  }
  
  func update_verts(){
    verts = []
    
    let first = points.first!
    verts.append(Vertex(position: SIMD3(Float(first.dx), Float(first.dy), 1.0), color: color.as_simd_transparent()))
    for pt in points {
      verts.append(Vertex(position: SIMD3(Float(pt.dx), Float(pt.dy), 1.0), color: color.as_simd()))
    }
    let last = points.last!
    verts.append(Vertex(position: SIMD3(Float(last.dx), Float(last.dy), 1.0), color: color.as_simd_transparent()))
  }
  
  func render(_ renderer: Renderer) {
    renderer.addStrokeData(verts);
  }
}
