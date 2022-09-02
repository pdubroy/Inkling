//
//  GuideModeCapture.swift
//  Inkling
//
//  Created by Marcel on 31/08/2022.
//

import Foundation
import UIKit

class GuideModeCapture {
  let buttons = [
    (CGVector(dx: 50.0, dy: 50.0), 2),
    (CGVector(dx: 120.0, dy: 50.0), 3),
    (CGVector(dx: 1150.0, dy: 50.0), 4)
  ]
  
  func update(_ touches: Touches) -> ([CGVector], [TouchId])? {
    if touches.active_fingers.count == 2 {
      var positions: [CGVector] = []
      var touchIds: [TouchId] = []
      for (touchId, touch) in touches.active_fingers {
        positions.append(touch)
        touchIds.append(touchId)
      }
      
      if distance(positions[0], positions[1]) < 70.0 {
        return (positions, touchIds)
      }
    }
    
    return nil
  }
}
