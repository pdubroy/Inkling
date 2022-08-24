//
//  Geometry.swift
//  Inkling
//
//  Created by Marcel on 23/08/2022.
//

import Foundation
import UIKit

func findClosestPointInCollection(points: [CGVector], point: CGVector, min_dist: CGFloat = 100) -> Int {
  var closest_distance = min_dist
  var closest_index = -1
  for (i, pt) in points.enumerated() {
    let d = distance(pt, point)
    
    if d < closest_distance {
      closest_distance = d
      closest_index = i
    }
  }
  
  return closest_index
}

func findClosestLineInCollection(lines: [(CGVector, CGVector)], point: CGVector, min_dist: CGFloat = 100) -> Int {
  var closest_distance = min_dist
  var closest_index = -1
  for (i, (a, b)) in lines.enumerated() {
    let d = PointLineDistance(p: point, a: a, b: b)
    
    if d < closest_distance {
      closest_distance = d
      closest_index = i
    }
  }
  
  return closest_index
}


//RDP Line Simplification Algorithm
func SimplifyStroke(line:[CGVector], epsilon: CGFloat) -> [CGVector] {
  if line.count == 2 {
    return line
  }
  
  let start = line.first!
  let end = line.last!
  
  var largestDistance: CGFloat = -1;
  var furthestIndex = -1;
  
  for i in 1..<line.count {
    let point = line[i]
    let dist = PointLineDistance(p:point, a:start, b:end)
    if dist > largestDistance {
      largestDistance = dist
      furthestIndex = i
    }
  }
  
  if(largestDistance > epsilon) {
    let segment_a = SimplifyStroke(line: Array(line[...furthestIndex]), epsilon: epsilon)
    let segment_b = SimplifyStroke(line: Array(line[furthestIndex...]), epsilon: epsilon)
    
    return segment_a + segment_b[1...]
  }
  return [start, end]
}


func PointLineDistance(p:CGVector, a:CGVector, b:CGVector) -> CGFloat {
  let norm = ScalarProjection(p: p, a: a, b: b)
  return (p - norm).length()
}

func ScalarProjection(p:CGVector, a:CGVector, b:CGVector) -> CGVector{
  let ap = p - a
  let ab = (b - a).normalized()
  let f = ab * dot(ap, ab)
  return a + f
}
