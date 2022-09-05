//
//  MorphableLine.swift
//  Inkling
//
//  Created by Marcel on 23/08/2022.
//

import UIKit

class CanvasCurve: CanvasElement {
  var stroke: Stroke
  var nodes: [Node]
  
  init(_ stroke: Stroke, _ nodes: [CGVector]){
    self.stroke = stroke
    self.nodes = []
    self.nodes = nodes.map({ pos in
      Node(pos, self)
    })
  }
  
  func morph(){

  }
  
  func getOffsetPositionForNode(_ node: Node) -> CGVector {
    var other = nodes[0]
    
    if other === node {
      other = nodes[1]
    }
    
    return node.position + (other.position - node.position).normalized() * 20.0
  }
  
  
  func render(_ renderer: Renderer) {
    stroke.render(renderer)
    renderer.addShapeData(polyLineShape(points: ChaikinCurve(points: nodes.map({ n in n.position })), weight: 1.0, color: Color(255,0,0)))
  }
}
