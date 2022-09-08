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
  var curvePoints: [CGVector]
  
  init(_ stroke: Stroke, _ nodes: [CGVector]){
    self.stroke = stroke
    self.nodes = []
    self.curvePoints = ChaikinCurve(points: nodes)
    self.nodes = nodes.map({ pos in
      Node(pos, self)
    })
  }
  
  func morph(){
    curvePoints = ChaikinCurve(points: nodes.map({ n in n.position }))
    stroke.points = curvePoints
    stroke.updateVerts()
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
    renderer.addShapeData(polyLineShape(points: ChaikinCurve(points: nodes.map({ n in n.position })), weight: 1.0, color: Color(255,0,0, 50)))
    
//    for pt in sampleCurve(stroke.points) {
//      renderer.addShapeData(circleShape(pos: pt, radius: 2.0, resolution: 4, color: Color(255, 0, 0)))
//    }
  }
}
