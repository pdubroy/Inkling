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


func isPointInTriangle(p: CGVector, a: CGVector, b: CGVector, c: CGVector) -> Bool {
  let ab = b - a
  let bc = c - b
  let ca = a - c
  
  let ap = p - a
  let bp = p - b
  let cp = p - c
  
  let cross1 = cross(ab, ap)
  let cross2 = cross(bc, bp)
  let cross3 = cross(ca, cp)
  
  if cross1 > 0 || cross2 > 0 || cross3 > 0 {
    return false
  }
  
  return true
}

func isPointInPolygon(_ point: CGVector, _ polygon: [CGVector]) -> Bool {
  // Just like, draw a line to a point very far away, and check intersections with the polygon edges.
  // If there is an uneven number of interesections, the point is inside
  var point_inf = point
  point_inf.dx += 10000000
  
  // Close the loop
  let polygon = polygon + [polygon[0]]
  
  var intersections = 0
  
  for i in 0...polygon.count - 2 {
    let a = polygon[i]
    let b = polygon[i+1]
    if lineSegmentIntersection(a, b, point, point_inf) != nil {
      intersections += 1
    }
  }
  
  // If the number is uneven return true
  return intersections % 2 == 1
}


// Returns a point if two line segments intersect
func lineSegmentIntersection(_ p0:CGVector, _ p1:CGVector, _ p2:CGVector, _ p3:CGVector) -> CGVector? {
  let s10_x = p1.dx - p0.dx;
  let s10_y = p1.dy - p0.dy;
  let s32_x = p3.dx - p2.dx;
  let s32_y = p3.dy - p2.dy;

  let denom = s10_x * s32_y - s32_x * s10_y;
  if (denom == 0) {
    return nil // Collinear
  }
      
  let denomPositive = denom > 0;

  let s02_x = p0.dx - p2.dx;
  let s02_y = p0.dy - p2.dy;
  let s_numer = s10_x * s02_y - s10_y * s02_x;
  if ((s_numer < 0) == denomPositive) {
    return nil // No collision
  }
  
  let t_numer = s32_x * s02_y - s32_y * s02_x;
  if ((t_numer < 0) == denomPositive) {
    return nil // No collision
  }
  
  if (((s_numer > denom) == denomPositive) || ((t_numer > denom) == denomPositive)) {
    return nil// No collision
  }
    
  // Collision detected
  let t = t_numer / denom;

  let i_x = p0.dx + (t * s10_x);
  let i_y = p0.dy + (t * s10_y);

  return CGVector(dx: i_x, dy: i_y)
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

func ClosestPointOnCircle(p: CGVector, center: CGVector, radius: CGFloat) -> CGVector {
  let v = (p - center)
  return center + v / v.length() * radius
}


func ClosestPointOnPolyline(line: [CGVector], point: CGVector, min_dist: CGFloat = 100) -> CGVector? {
  var closest_distance = min_dist
  var closest_point: CGVector? = nil
  
  for i in 0..<line.count-1 {
    let a = line[i]
    let b = line[i+1]
    
    let c = ClosestPointOnLineSegment(point, a, b)
    let d = distance(point, c)
    if d < closest_distance {
      closest_distance = d
      closest_point = c
    }
  }
  
  return closest_point
}

func ClosestPointOnLineSegment(_ p: CGVector, _ a: CGVector, _ b: CGVector) -> CGVector {
  let atob = b - a
  let atop = p - a
  
  let len = atob.dx * atob.dx + atob.dy * atob.dy
  var dot = atop.dx * atob.dx + atop.dy * atob.dy
  
  let t = min( 1, max( 0, dot / len ) )

  dot = ( b.dx - a.dx ) * ( p.dy - a.dy ) - ( b.dy - a.dy ) * ( p.dx - a.dx )
    
  return CGVector(dx: a.dx + atob.dx * t,  dy: a.dy + atob.dy * t)
}


func lineLength(_ points: [CGVector]) -> CGFloat {
  var length_accumulator: CGFloat = 0
  
  for i in 0..<points.count-1 {
    let length = distance(points[i+1], points[i])
    length_accumulator += length
  }
  
  return length_accumulator
}
