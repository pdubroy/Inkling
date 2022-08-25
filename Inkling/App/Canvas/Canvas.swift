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
  
  func update(_ touches: Touches, _ mode: PseudoMode) {
    if mode == .Drag {
      // Pencil down
      if let event = touches.did(.Pencil, .Begin) {
        // Find closest node
        if let cluster = clusters.findClosestCluster(event.pos) {
          draggingCluster = cluster
          touches.capture(event)
        }
      }
      
      
      if let draggingCluster = draggingCluster {
        // Pencil moved
        for event in touches.moved(.Pencil) {
          draggingCluster.move(event.pos)
          touches.capture(event)
        }
      }
    }
    
    if mode == .Erase {
      for event in touches.moved(.Pencil) {
        for stroke in strokes {
          if let split_strokes = stroke.erase(event.pos) {
            clusters.removeNodesWithStroke(stroke)
            lines.removeAll(where: { l in l.stroke === stroke })
            strokes.removeAll(where: { s in s === stroke})
            for s in split_strokes {
              add_stroke(s)
            }
          }
        }
      }
    }
    
    
    // Pencil up
    if let _ = touches.did(.Pencil, .End) {
      if draggingCluster != nil {
        clusters.mergeCluster(draggingCluster!)
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
