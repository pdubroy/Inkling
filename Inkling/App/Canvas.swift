//
//  Canvas.swift
//  Inkling
//
//  Created by Marcel on 22/08/2022.
//

import Foundation
import UIKit

class NodePoint {
  var position: CGVector
  
  init(_ position: CGVector) {
    self.position = position
  }
  
  func render(_ renderer: Renderer) {
    renderer.addShapeData(circleShape(pos: position, radius: 4.0, resolution: 8, color: Color(0, 0, 255)))
    renderer.addShapeData(circleShape(pos: position, radius: 3.0, resolution: 8, color: Color(255, 255, 255)))
  }
}

class Canvas {
  var strokes: [Stroke] = []
  var nodes: [NodePoint] = [
    NodePoint(CGVector(dx: 500.0, dy: 500.0))
  ]
  
  // Dragging state
  var dragging_node: NodePoint? = nil
  
  // Renderable Element
  func add_stroke(_ stroke: Stroke) {
    strokes.append(stroke)
  }
  
  func update(_ touches: Touches) {
    // Pencil down
    if let event = touches.did(.Pencil, .Begin) {
      // Find closest node
      let dragging_node_index = findClosestPointInCollection(points: nodes.map({ n in n.position}), point: event.pos, min_dist: 30.0)
      if dragging_node_index > -1 {
        dragging_node = nodes[dragging_node_index]
        touches.capture(event)
      }
    }
    
    // Dragging Node
    if let dragging_node = dragging_node {
      for event in touches.moved(.Pencil) {
        dragging_node.position = event.pos
        touches.capture(event)
      }
    }
    
    // Pencil up
    if let event = touches.did(.Pencil, .End) {
      dragging_node = nil
    }
    
  }
  
  func render(_ renderer: Renderer){
    for stroke in strokes {
      stroke.render(renderer)
    }
  }
  
  func render_nodes(_ renderer: Renderer) {
    for node in nodes {
      node.render(renderer)
    }
  }
}
