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
  
  var line: MorphableLine
  var node_index: Int
  
  init(_ position: CGVector, _ line: MorphableLine, _ node_index: Int) {
    self.position = position
    self.line = line
    self.node_index = node_index
  }
  
  func move(_ position: CGVector) {
    self.position = position
    self.line.move()
  }
  
//  func render(_ renderer: Renderer) {
//    renderer.addShapeData(circleShape(pos: position, radius: 4.0, resolution: 8, color: Color(0, 0, 255)))
//    renderer.addShapeData(circleShape(pos: position, radius: 3.0, resolution: 8, color: Color(255, 255, 255)))
//  }
}
