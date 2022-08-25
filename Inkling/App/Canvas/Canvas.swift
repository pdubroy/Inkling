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
  var selectedClusters: [NodeCluster] = []
  
  var selection = Selection()
  
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
    
    if mode == .Select {
      if let polygon = selection.update(touches) {
        print("Clusters")
        let foundClusters = clusters.findClustersInPolygon(polygon)
        
        for fc in foundClusters {
          if selectedClusters.contains(where: {nc in nc === fc }) {
            selectedClusters.removeAll(where: {nc in nc === fc })
          } else {
            selectedClusters.append(fc)
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
  
  func render(_ renderer: Renderer, _ mode: PseudoMode){
    for stroke in strokes {
      stroke.render(renderer)
    }
    
    if mode == .Drag || mode == .Select {
      clusters.render(renderer)
    }
    
    if mode == .Select {
      selection.render(renderer)
      
      for sc in selectedClusters {
        renderer.addShapeData(circleShape(pos: sc.position, radius: 4.0, resolution: 8, color: Color(255, 0, 0)))
      }
    }
  }
}
