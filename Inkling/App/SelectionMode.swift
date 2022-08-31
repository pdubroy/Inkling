//
//  SelectionMode.swift
//  Inkling
//
//  Created by Marcel on 31/08/2022.
//

import Foundation
import UIKit

enum SelectionModeEvent {
  case StartMorph(TransformMatrix)
  case Morph(TransformMatrix)
  
  case Simplify
  case Close
  case Delete
}

class SelectionMode {
  var active = false
  //var transformFingers: [TouchId: CGVector] = [:]
  
  let buttons = [
    (CGVector(dx: 50.0, dy: 50.0), 2),
    (CGVector(dx: 120.0, dy: 50.0), 3),
    (CGVector(dx: 1150.0, dy: 50.0), 4)
  ]
  
  func update(_ touches: Touches) -> SelectionModeEvent? {
    var result: SelectionModeEvent? = nil
    
    // Move gesture
    if touches.active_fingers.count == 2 {
      // Read positions
      var positions: [CGVector] = []
      for (touchId, touch) in touches.active_fingers {
        //transformFingers[touchId] = touch
        positions.append(touch)
      }
      
      for event in touches.events {
        if event.type == .Finger && event.event_type != .End {
          touches.capture(event)
        }
      }
      
      let transform = TransformMatrix()
      transform.from_line(positions[0], positions[1])
      
      if active == false {
        result = .StartMorph(transform)
        active = true
      } else {
        result = .Morph(transform)
      }
    } else {
      if active == true {
        //transformFingers = [:]
        active = false
      }
    }
    
    
    // Menu buttons
    if let event = touches.did(.Finger, .Begin) {
      for (button, id) in buttons {
        if distance(button, event.pos) < 30.0 {
          touches.capture(event)
          
          if id == 2 {
            result = .Close
          } else if id == 3 {
            result = .Simplify
          } else if id == 4 {
            result = .Delete
          }
        }
      }
    }
    
    return result
  }
  
  func render(_ renderer: Renderer){
    let size = CGVector(dx: 20.0, dy: 20.0)

    for (position, texture) in buttons {
      renderer.addShapeData(imageShape(a: position - size, b: position + size, texture: texture))
    }
  }
}
