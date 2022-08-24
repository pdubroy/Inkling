//
//  Canvas.swift
//  Inkling
//
//  Created by Marcel on 22/08/2022.
//

import Foundation
import UIKit



class Canvas {
  var strokes: [Stroke] = []
  //var nodes: [Node] = []
  var lines: [Morphable] = []
  var clusters: NodeClusters = NodeClusters()
  
  // Dragging state
  var draggingCluster: NodeCluster? = nil
  
  func add_stroke(_ stroke: Stroke) {
    //strokes.append(stroke)
    let line_segments = analyseStroke(stroke)
  
    for line in line_segments {
      lines.append(line)
      
      if let line = line as? MorphableLine {
        strokes.append(line.stroke)
        clusters.addNode(line.nodes[0])
        clusters.addNode(line.nodes[1])
      }
      
      if let bezier = line as? MorphableBezier {
        strokes.append(bezier.stroke)
        clusters.addNode(bezier.nodes[0])
        clusters.addNode(bezier.nodes[1])
      }
    }
  }
  
  func update(_ touches: Touches) {
    // Pencil down
    if let event = touches.did(.Pencil, .Begin) {
      // Find closest node
      if let cluster = clusters.findClosestCluster(event.pos) {
        draggingCluster = cluster
        touches.capture(event)
      }
    }
    
    
    if let draggingClusterUnwrapped = draggingCluster {
      // Pencil moved
      for event in touches.moved(.Pencil) {
        draggingClusterUnwrapped.move(event.pos)
        touches.capture(event)
      }
      
      // Pencil up
      if let _ = touches.did(.Pencil, .End) {
        clusters.mergeCluster(draggingClusterUnwrapped)
        draggingCluster = nil
      }
    }
    

    
  }
  
  func render(_ renderer: Renderer){
    for stroke in strokes {
      stroke.render(renderer)
    }
  }
  
  func render_nodes(_ renderer: Renderer) {
    clusters.render(renderer)
  }
}
