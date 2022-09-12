//
//  AnalyseStroke.swift
//  Inkling
//
//  Created by Marcel on 24/08/2022.
//


import Foundation
import UIKit

struct KeyPoint {
  var point: CGVector
  var index: Int
  var corner: Bool
  var tangent_upstream: CGVector
  var tangent_downstream: CGVector
}


// This function takes raw stroke data, and uses it to split the stroke into chunks of straight lines and curves.
// At it's core, the algorithm tries to find "key points" using the RDP Line Simplification Algorithm
// It then tries to find out if those points are corners, or smooth tangents
// Segments that lie between two "pointy corners" are considered straight lines, everything else is considered a curve
// Curves are then bezier-ified

func analyseStroke(_ stroke: Stroke) -> [CanvasElement] {
  // Find key points
  let simplified_points = SimplifyStroke(line: stroke.points, epsilon: 10.0)
  
  var key_points: [KeyPoint] = []
  
  for simplified_point in simplified_points {
    // find key_point index
    let index = stroke.points.firstIndex(where: {$0 == simplified_point})!
    
    let length_of_point = stroke.lengths[index]
    
    let (a, _) = stroke.getPointAtLength(length_of_point - 10)
    let (b, _) = stroke.getPointAtLength(length_of_point + 10)

    // Short straw approximation for checking corners
    let tangent = (a - b)
    
    // Compare points further along the line, to see if the shape approximates a triangle
    let (ma, _) = stroke.getPointAtLength(length_of_point - 20)
    let (mb, _) = stroke.getPointAtLength(length_of_point + 20)
    let pla = PointLineDistance(p: ma, a: simplified_point, b: a)
    let plb = PointLineDistance(p: mb, a: simplified_point, b: b)
    let pldist = pla + plb
    
    let corner =  (pldist < 4.0 && tangent.lengthSquared() < 300.0) || index == 0 || index == stroke.points.count - 1
  
    let tangent_norm = (a-b).normalized()
    
    var tangent_upstream = corner ? (a - simplified_point).normalized() : tangent_norm
    var tangent_downstream = corner ? (b - simplified_point).normalized() : CGVector(dx: 0.0, dy: 0.0) - tangent_norm
    
    key_points.append(KeyPoint(
      point: simplified_point,
      index: index,
      corner: corner,
      tangent_upstream: tangent_upstream,
      tangent_downstream: tangent_downstream
    ))
  }
  
  
  // Extract straight segments, and curves
  var segment: [KeyPoint] = [key_points[0]]
  var elements: [CanvasElement] = []
  
  for i in 1..<key_points.count {
    let kp = key_points[i]
    segment.append(kp)
    if kp.corner {
      if segment.count == 2 {
        elements.append(CanvasLine(stroke.segment(segment[0].index, segment[1].index)))
      } else {
        let segmentedStroke = stroke.segment(segment[0].index, segment[segment.count-1].index)
        let initialGuess = segment.map({kp in kp.point })
        let fittedGuess = fitCurveChaikin(points: segmentedStroke.points, initialGuess: initialGuess, error: 20.0)
        elements.append(CanvasCurve(segmentedStroke, fittedGuess))
      }
      segment = [kp]
    }
  }
  
  return elements
}
