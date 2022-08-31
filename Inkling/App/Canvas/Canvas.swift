//
//  Canvas.swift
//  Inkling
//
//  Created by Marcel on 22/08/2022.
//

import Foundation
import UIKit


// Canvas is a dumb container that we act on from the outside

class Canvas {
  var elements: [CanvasElement] = []
  var clusters: NodeClusters = NodeClusters()
  var selection: CanvasSelection? = nil
  
  func addStroke(_ stroke: Stroke) {
    let line_segments = analyseStroke(stroke)
    
    for line in line_segments {
      addElement(line)
    }
  }
  
  func addFill(_ fill: CanvasFill) {
    addElement(fill)
  }
  
  func addElement(_ element: CanvasElement) {
    elements.append(element)
    
    for node in element.nodes {
      clusters.addNode(node)
    }
  }
  
  func removeElement(_ element: CanvasElement){
    elements.removeAll(where: { e in e === element })
    //clusters.removeAllForMorphable()
  }
  
  func selectPolygon(_ polygon: [CGVector]) {
    selection = CanvasSelection(clusters.findClustersInPolygon(polygon))
  }
  
//    if mode == .Erase {
////      for event in touches.moved(.Pencil) {
////        for stroke in strokes {
////          if let split_strokes = stroke.erase(event.pos) {
////            clusters.removeNodesWithStroke(stroke)
////            lines.removeAll(where: { l in l.stroke === stroke })
////            strokes.removeAll(where: { s in s === stroke})
////            for s in split_strokes {
////              add_stroke(s)
////            }
////          }
////        }
////      }
//    }
//
//    if mode == .Select {
//      if let polygon = selection.update(touches) {
//        print("Clusters")
//        let foundClusters = clusters.findClustersInPolygon(polygon)
//
//        for fc in foundClusters {
//          if selectedClusters.contains(where: {nc in nc === fc }) {
//            selectedClusters.removeAll(where: {nc in nc === fc })
//          } else {
//            selectedClusters.append(fc)
//          }
//        }
//      }
//    }
//
//
//    // Pencil up
//    if let _ = touches.did(.Pencil, .End) {
//      if draggingCluster != nil {
//        clusters.mergeCluster(draggingCluster!)
//        draggingCluster = nil
//      }
//    }
//
//  }
  
  func render(_ renderer: Renderer, _ mode: PseudoMode){
    for element in elements {
      element.render(renderer)
    }
    
    if mode == PseudoMode.Drag {
      clusters.render(renderer)
    }
    
    if mode == PseudoMode.Select {
      clusters.renderSelection(renderer)
    }
    
    if let selection = selection {
      selection.render(renderer)
    }
  }
  
//  func renderNodes(_ renderer: Renderer) {
//
//
//    if let selection = selection {
//      selection.render(renderer)
//    }
//  }

  
    
//    if mode == .Drag || mode == .Select {
//      clusters.render(renderer)
//    }
//
//    if mode == .Select {
//      selection.render(renderer)
//    }
//
//    if selectedClusters.count > 0 {
//
//      let size = CGVector(dx: 20.0, dy: 20.0)
//      var position = CGVector(dx: 50.0, dy: 50.0)
//
//      //renderer.addShapeData(circleShape(pos: position, radius: 30.0, resolution: 32, color: Color(50, 44, 44, 255)))
//      renderer.addShapeData(imageShape(a: position - size, b: position + size, texture: 2))
//
//      position = CGVector(dx: 120.0, dy: 50.0)
////      renderer.addShapeData(circleShape(pos: position, radius: 30.0, resolution: 32, color: Color(50, 44, 44, 255)))
//      renderer.addShapeData(imageShape(a: position - size, b: position + size, texture: 3))
//
//      position = CGVector(dx: 1150.0, dy: 50.0)
////      renderer.addShapeData(circleShape(pos: position, radius: 30.0, resolution: 32, color: Color(50, 44, 44, 255)))
//      renderer.addShapeData(imageShape(a: position - size, b: position + size, texture: 4))
//
//      for sc in selectedClusters {
//        renderer.addShapeData(circleShape(pos: sc.position, radius: 4.0, resolution: 8, color: Color(255, 0, 0)))
//      }
//    }
}
