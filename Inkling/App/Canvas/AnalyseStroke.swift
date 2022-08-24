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

func analyseStroke(_ stroke: Stroke) -> [MorphableLine] {
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
  
  // Extract straight segments, and
  var straight_segments: [(Int, Int)] = []
  var curved_segments: [(Int, Int)] = []
  
  for i in 0..<key_points.count-1 {
    let a = key_points[i]
    let b = key_points[i+1]
    
    if a.corner && b.corner {
      straight_segments.append((a.index, b.index))
    } else {
      if curved_segments.count > 0, curved_segments.last!.1 == a.index {
        curved_segments[curved_segments.count-1].1 = b.index
      } else {
        curved_segments.append((a.index, b.index))
      }
    }
  }
  
  
  var lines: [MorphableLine] = []
  
  for seg in straight_segments {
    lines.append(MorphableLine(stroke.segment(seg.0, seg.1)))
  }
  
  return lines
  
//  let key_point_indices = simplified_points.map { point in
//    stroke.points.firstIndex(where: {$0 == point})!
//  }
//
//  return key_point_indices.map { index in stroke.points[index] }
}
