//
//  StrokeCapture.swift
//  Inkling
//
//  Created by Marcel on 18/08/2022.
//

import Foundation
import UIKit

// Subsystem that captures pen movements and produces a Stroke Canvas Object

class StrokeCapture {
  var points: [CGVector] = []
  var predicted_points: [CGVector] = []
  var color: Color
  var verts: [Vertex] = []
  
  init(){
    points = []
    predicted_points = []
    color = Color.init(0, 0, 0)
    verts = []
  }
  
  // Process Stroke input data, Returns a new stroke once it's ready
  func update(touch_events: [TouchEvent]) -> Stroke? {
    // Reset predicted points every frame
    predicted_points = []
    
    var result: Stroke? = nil
    
    for event in touch_events {
      if event.type == .Pencil {
        switch event.event_type {
          case .Begin: begin_stroke(event.pos)
          case .Move: add_point(event.pos)
          case .Predict: add_predicted_point(event.pos)
          case .End: result = end_stroke(event.pos)
        }
      }
    }
    
    return result
  }
  
  func begin_stroke(_ pos: CGVector){
    points = [pos]
    predicted_points = []
    verts = []
    
    verts.append(Vertex(position: SIMD3(Float(pos.dx), Float(pos.dy), 1.0), color: color.as_simd_transparent()))
    verts.append(Vertex(position: SIMD3(Float(pos.dx), Float(pos.dy), 1.0), color: color.as_simd()))
  }
  
  func add_point(_ pos: CGVector){
    points.append(pos)
    verts.append(Vertex(position: SIMD3(Float(pos.dx), Float(pos.dy), 1.0), color: color.as_simd()))
  }
  
  func add_predicted_point(_ pos: CGVector){
    predicted_points.append(pos)
  }
  
  func end_stroke(_ pos: CGVector) -> Stroke {
    //points.append(contentsOf: predicted_points)
    points.append(pos)
    let stroke = Stroke(points, color)
    points = []
    predicted_points = []
    return stroke
  }
  
  func render(_ renderer: Renderer) {
    if points.count == 0 {
      return
    }
    
    let predicted_verts = predicted_points.map { pt in
      Vertex(position: SIMD3(Float(pt.dx), Float(pt.dy), 1.0), color: color.as_simd())
    }
     
    var joined_verts = verts + predicted_verts
    var last = joined_verts.last!
    last.color[3] = Float(0.0)
    joined_verts.append(last)
    
    renderer.addStrokeData(joined_verts)
  }
}
