//
//  MorphableFill.swift
//  Inkling
//
//  Created by Marcel on 30/08/2022.
//

import Foundation
import UIKit

class CanvasFill: CanvasElement {
  var nodes: [Node]
  var renderShape: RenderShape
  var color: Color
  
  init(_ points: [CGVector], color: Color){
    self.nodes = []
    self.color = color
    self.renderShape = polyFillShape(points: [], color: color)
    
    self.nodes = points.map({p in
      Node(p, self)
    })
    self.renderShape = polyFillShape(points: nodes.map({ n in n.position }), color: color)
  }
  
  func morph(){
    self.renderShape = polyFillShape(points: nodes.map({ n in n.position }), color: color)
  }
  
  func getOffsetPositionForNode(_ node: Node) -> CGVector {
    let index = nodes.firstIndex(where: {n in n === node})!
    var left = index - 1
    if left == -1 {
      left = nodes.count - 1
    }
    var right = index + 1
    if right == nodes.count {
      right = 0
    }
    
    let offset = ((nodes[left].position - node.position) + (nodes[right].position - node.position)).normalized() * 10.0;
    
    
    return node.position + offset
  }
  
  func render(_ renderer: Renderer) {
    renderer.addShapeData(renderShape)
  }
}
