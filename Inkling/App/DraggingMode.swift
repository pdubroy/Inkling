//
//  DragMode.swift
//  Inkling
//
//  Created by Marcel on 31/08/2022.
//

import Foundation

class DraggingMode {
  var clusters: NodeClusters
  var draggingCluster: NodeCluster? = nil
  
  init(_ clusters: NodeClusters) {
    self.clusters = clusters
  }
  
  func update(_ touches: Touches) {
    if draggingCluster == nil {
      if let event = touches.did(.Pencil, .Begin) {
        // Find closest node
        if let cluster = clusters.findClosestCluster(event.pos) {
          draggingCluster = cluster
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
    
    if let _ = touches.did(.Pencil, .End) {
      if draggingCluster != nil {
        clusters.mergeCluster(draggingCluster!)
        draggingCluster = nil
      }
    }
  }
}
