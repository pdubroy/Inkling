//
//  ChaikinCurve.swift
//  Inkling
//
//  Created by Marcel on 02/09/2022.
//

import Foundation
import UIKit

func ChaikinCurve(points: [CGVector], depth: Int = 3) -> [CGVector] {
  var chaikin_points: [CGVector] = []
  
  for i in 0..<points.count-1 {
    let a = points[i];
    let b = points[i+1];
    
    let la = lerp(start: a, end: b, t: 0.25);
    let lb = lerp(start: a, end: b, t: 0.75);
    
    chaikin_points.append(la)
    chaikin_points.append(lb)
  }
  
  if(depth == 0) {
      return chaikin_points
  } else {
    return [points[0]] + ComputeChaikinPoints(points: chaikin_points, depth: depth-1) + [points[points.count-1]]
  }
}

func ComputeChaikinPoints(points: [CGVector], depth: Int = 3) -> [CGVector] {
  var chaikin_points: [CGVector] = []
  
  for i in 0..<points.count-1 {
    let a = points[i];
    let b = points[i+1];
    
    let la = lerp(start: a, end: b, t: 0.25);
    let lb = lerp(start: a, end: b, t: 0.75);
    
    chaikin_points.append(la)
    chaikin_points.append(lb)
  }
  
  if(depth == 0) {
      return chaikin_points
  } else {
    return ComputeChaikinPoints(points: chaikin_points, depth: depth-1)
  }
}

