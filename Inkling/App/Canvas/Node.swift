//
//  Node.swift
//  Inkling
//
//  Created by Marcel on 24/08/2022.
//

import Foundation
import UIKit

class Node {
  var position: CGVector
  
  var element: CanvasElement
  
  init(_ position: CGVector, _ element: CanvasElement) {
    self.position = position
    self.element = element
  }
  
  func move(_ position: CGVector) {
    self.position = position
    self.element.morph()
  }
  
  func getStroke() -> Stroke? {
    if let e = element as? CanvasLine {
      return e.stroke
    }
    
    if let e = element as? CanvasBezier {
      return e.stroke
    }
    
    return nil
  }
}

class BezierNode {
  var position: CGVector
  
  var element: CanvasElement
  var parent: Node
  
  init(_ position: CGVector, _ parent: Node, _ element: CanvasElement) {
    self.position = position - parent.position
    self.parent = parent
    self.element = element
  }
  
  func move(_ position: CGVector) {
    self.position = position - parent.position
    self.element.morph()
  }
  
  func render(_ renderer: Renderer){
    let position = parent.position + position
    
    renderer.addShapeData(lineShape(a: parent.position, b: position, weight: 0.5, color: Color(73, 172, 214)))
    renderer.addShapeData(circleShape(pos: position, radius: 3.0, resolution: 8, color: Color(255, 255, 255)))
    renderer.addShapeData(circleShape(pos: position, radius: 2.0, resolution: 8, color: Color(73, 172, 214)))
  }
}
