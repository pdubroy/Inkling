//
//  DragMode.swift
//  Inkling
//
//  Created by Marcel on 31/08/2022.
//

import Foundation

class DraggingMode {
  var clusters: NodeClusters
  var handles: [BezierNode]
  var draggingCluster: NodeCluster? = nil
  var draggingHandle: BezierNode? = nil
  
  init(_ clusters: NodeClusters, _ handles: [BezierNode]) {
    self.clusters = clusters
    self.handles = handles
  }
  
  func update(_ touches: Touches) {
    if draggingCluster == nil {
      if let event = touches.did(.Pencil, .Begin) {
        var capture = false;
        
        // Find closest node
        if let cluster = clusters.findClosestCluster(event.pos) {
          draggingCluster = cluster
          capture = true
        }
        
        let closestHandle = findClosestPointInCollection(points: handles.map({h in h.position + h.parent.position}), point: event.pos, min_dist: 30.0)
        if closestHandle > -1 {
          if draggingCluster == nil {
            draggingHandle = handles[closestHandle]
            capture = true
          } else if distance(draggingCluster!.position, event.pos) > distance(handles[closestHandle].position, event.pos) {
            draggingCluster = nil
            draggingHandle = handles[closestHandle]
          }
        }
        
        if capture {
          touches.capture(event)
        }
      }
    }
    
    if let draggingCluster = draggingCluster {
      // Pencil moved
      for event in touches.moved(.Pencil) {
        draggingCluster.move(event.pos)
        touches.capture(event)
      }
    }
    
    if let draggingHandle = draggingHandle {
      // Pencil moved
      for event in touches.moved(.Pencil) {
        draggingHandle.move(event.pos)
        touches.capture(event)
      }
    }
    
    if let _ = touches.did(.Pencil, .End) {
      if draggingCluster != nil {
        clusters.mergeCluster(draggingCluster!)
        draggingCluster = nil
      }
      
      if draggingHandle != nil {
        draggingCluster = nil
      }
    }
  }
}
