//
//  CanvasSelection.swift
//  Inkling
//
//  Created by Marcel on 31/08/2022.
//

import Foundation
import UIKit

class CanvasSelection {
  
  var selectedClusters: [NodeCluster] = []
  var oldPositions: [CGVector] = []
  
  init(_ selectedClusters: [NodeCluster]) {
    self.selectedClusters = selectedClusters
  }
  
  func startMorph(_ oldTransform: TransformMatrix) {
    let oldTransform = oldTransform.get_inverse()
    oldPositions = selectedClusters.map { cluster in oldTransform.transform_vector(cluster.position)}
  }
  
  func morph(_ newTransform: TransformMatrix){
    for (i, position) in oldPositions.enumerated() {
      selectedClusters[i].move(newTransform.transform_vector(position))
    }
  }
  
  func simplify(){
    var strokes: [Stroke] = []
    
    for cluster in selectedClusters {
      for node in cluster.nodes {
        if let stroke = node.getStroke() {
          if !strokes.contains(where: { s in s === stroke}) {
            strokes.append(stroke)
          }
        }
      }
    }
    
    for stroke in strokes {
      stroke.simplify()
    }
  }
  
//  func contains(_ cluster: NodeCluster) -> Bool {
//    return selectedClusters.contains { c in c === cluster}
//  }
  
  func render(_ renderer: Renderer){
    if selectedClusters.count > 0 {
      for cluster in selectedClusters {
        let position = cluster.position
        renderer.addShapeData(circleShape(pos: position, radius: 4.0, resolution: 8, color: Color(255, 255, 255)))
        renderer.addShapeData(circleShape(pos: position, radius: 3.0, resolution: 8, color: Color(255, 0, 0)))
      }
    }
  }
}
