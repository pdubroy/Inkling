//
//  StrokePoint.swift
//  Inkling
//
//  Created by Marcel on 22/08/2022.
//

import Foundation

class StrokePoint {
  var x: Float
  var y: Float
  var weight: Float
  
  init(_ x: Float, _ y: Float, _ weight: Float = 1.0) {
    self.x = x
    self.y = y
    self.weight = weight
  }
  
}
