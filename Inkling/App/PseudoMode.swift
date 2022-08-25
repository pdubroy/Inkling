//
//  PseudoMode.swift
//  Inkling
//
//  Created by Marcel on 23/08/2022.
//

import Foundation
import UIKit

enum PseudoMode {
  case Default
  case Drag
  case Select
  case Erase
}

class PseudoModeInput {
  var mode: PseudoMode = .Default
  var fingerId: TouchId? = nil
  var position = CGVector()
  var offset = CGVector()
  
  func update(_ touches: Touches) {
    if mode == .Default {
      if touches.active_fingers.count == 1, let event = touches.did(.Finger, .Begin) {
        mode = .Drag
        fingerId = event.id
        position = event.pos
        offset = CGVector()
        touches.capture(event)
        
      }
    }
    
    if mode != .Default {
      for event in touches.moved(.Finger, fingerId!) {
        offset = event.pos
        touches.capture(event)
        
        if offset.dy - position.dy > 50.0 {
          mode = .Erase
        } else if offset.dy - position.dy < -50.0 {
          mode = .Select
        } else {
          mode = .Drag
        }
      }
      
      if let _ = touches.did(.Finger, .End, fingerId!) {
        mode = .Default
      }
    }
    
  }
  
  func render(_ renderer: Renderer) {
    if mode == .Drag {
      renderer.addShapeData(circleShape(pos: position, radius: 50.0, resolution: 32, color: Color(255, 0, 0, 50)))
    }
    
    if mode == .Erase {
      renderer.addShapeData(circleShape(pos: position, radius: 50.0, resolution: 32, color: Color(0, 255, 0, 50)))
    }
    
    if mode == .Select {
      renderer.addShapeData(circleShape(pos: position, radius: 50.0, resolution: 32, color: Color(0, 0, 255, 50)))
    }
  }
  
}
