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
