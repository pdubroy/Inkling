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
    
    // Generate transform for all line segments
    let oldCurvePoints = curvePoints
    let oldCurveLengths = lineLengths(oldCurvePoints)
    let newCurvePoints = ChaikinCurve(points: nodes.map({ n in n.position }))
    let newCurveLengths = lineLengths(newCurvePoints)
    
    //print(oldSimplifiedCurvePoints.count, newSimplifiedCurvePoints.count)
    let actualCurveLength = stroke.lengths[stroke.lengths.count - 1]
    
    //var lengthAccumulator: CGFloat = 0.0
    var lastPoint = stroke.points[0]
    for i in 0...stroke.points.count-1 {
      let dist = distance(lastPoint, stroke.points[i])
      let length = stroke.lengths[i] / actualCurveLength
      lastPoint = stroke.points[i]
      
      let oldPointOnCurve = getPointAtLength(lengths: oldCurveLengths, points: oldCurvePoints, length: length * oldCurveLengths[oldCurveLengths.count-1])
      let newPointOnCurve = getPointAtLength(lengths: newCurveLengths, points: newCurvePoints, length: length * newCurveLengths[newCurveLengths.count-1])
      let delta = newPointOnCurve - oldPointOnCurve
      
      stroke.points[i] += delta
      
    }
    
    curvePoints = newCurvePoints
//    let sampledIndexes = sampleCurveIndex(self.stroke.points, 20.0)
//
//    for i in 0..<newSimplifiedCurvePoints.count-1 {
//      let new_a = newSimplifiedCurvePoints[i]
//      let new_b = newSimplifiedCurvePoints[i+1]
//
//      let old_a = oldSimplifiedCurvePoints[i]
//      let old_b = oldSimplifiedCurvePoints[i+1]
//
//      var old_transform = TransformMatrix()
//      old_transform.from_line(old_a, old_b)
//      old_transform = old_transform.get_inverse()
//
//      let new_transform = TransformMatrix()
//      new_transform.from_line(new_a, new_b)
//
//      let old_vec_length = distance(old_a, old_b)
//      let new_vec_length = distance(new_a, new_b)
//      let scale = new_vec_length / old_vec_length
//
//
//      for j in sampledIndexes[i]..<sampledIndexes[i+1] {
//        let point = stroke.points[j]
//        var projected = old_transform.transform_vector(point)
//        projected.dx = projected.dx * scale
//        let new_point = new_transform.transform_vector(projected)
//        stroke.points[j] = new_point
//      }
//
//
//    }
    
    stroke.updateVerts()
    
    //stroke.points = curvePoints
    //stroke.updateVerts()
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
    //renderer.addShapeData(polyLineShape(points: ChaikinCurve(points: nodes.map({ n in n.position })), weight: 1.0, color: Color(255,0,0, 50)))
    
//    for pt in sampleCurve(stroke.points) {
//      renderer.addShapeData(circleShape(pos: pt, radius: 2.0, resolution: 4, color: Color(255, 0, 0)))
//    }
  }
}
