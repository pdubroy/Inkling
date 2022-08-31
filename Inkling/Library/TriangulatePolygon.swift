//
//  TriangulatePolygon.swift
//  Inkling
//
//  Created by Marcel on 30/08/2022.
//

import Foundation
import UIKit

func triangulatePolygon(_ points: [CGVector]) -> [Int] {
  print(" ")
  print("triangulating")
  dump(points)
  
  var points = points
  if points.count < 3 {
    return []
  }
  
  // TODO: Double check
  // Should be sure that lines don't overlap (No figure 8 for example)
  // Edges shouldn't be colinear (We can remove those up front)
  
  
  // Winding order should be clockwise
  if !isPolygonWindingOrderCW(points + [points[0]]) {
    print("counter clockwise")
    points = points.reversed()
  }
  print("clockwise")
  
  
  var indices: [Int] = Array(0..<points.count)
  var triangles: [Int] = []
  
  print("indices", indices)
  
  while indices.count > 3 {
    for i in 0..<indices.count {
      let a = indices[i]
      let b = getPointInLoop(indices, i-1)
      let c = getPointInLoop(indices, i+1)
      
      print("trying", a,b,c)
      
      let va = points[a]
      let vb = points[b]
      let vc = points[c]
      
      let vab = vb - va
      let vac = vc - va
      
      // Check if ear is Convex or Reflex, if reflex skip
      let convexity = cross(vab, vac)
      print("checking convexity", convexity)
      if convexity > 0 {
        continue;
      }
      
      print("convex")
      
      // Check if anything lies inside of this triangle
      var isEar = true;
      
      //print("checking is ear")
      for j in 0..<points.count {
        if j == a || j == b || j == c {
          continue
        }
        
        let p = points[j]
        if isPointInTriangle(p: p, a: vb, b: va, c: vc) {
          isEar = false
          break
        }
      }
      
      // If it is an ear, add it to the triangle list
      if isEar {
        //print("isEar")
        triangles.append(b)
        triangles.append(a)
        triangles.append(c)
        indices.remove(at: i)
        break
      }
    }
  }
  
  triangles.append(indices[0])
  triangles.append(indices[1])
  triangles.append(indices[2])
  
  
  return triangles
}


func getPointInLoop(_ points: [Int], _ index: Int) -> Int {
  if index >= points.count {
    return points[index % points.count]
  } else if index < 0 {
    return points[index % points.count + points.count]
  } else {
    return points[index]
  }
}


// Use signed area under polygon line segments to determine if polygon winding order is cw or ccw
func isPolygonWindingOrderCW(_ points: [CGVector]) -> Bool {
  var total_area: CGFloat = 0
  
  for i in 0..<points.count-1 {
    let a = points[i]
    let b = points[i+1]
    
    let avg_y = (a.dy + b.dy) / 2
    let dx = b.dx - a.dx
    
    let area = dx * avg_y
    
    total_area += area
  }
  
  return total_area < 0
}
