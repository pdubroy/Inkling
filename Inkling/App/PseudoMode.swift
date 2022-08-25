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
        offset = event.pos
        touches.capture(event)
        
      }
    }
    
    if mode != .Default {
      for event in touches.moved(.Finger, fingerId!) {
        offset = event.pos
        touches.capture(event)
        
        
        
        if distance(offset, position) > 40.0 {
          let angle = (offset - position).angle()
          
          if angle > 0.0 {
            mode = .Erase
          } else {
            mode = .Select
          }
          
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

    if mode != .Default {
      renderer.addShapeData(circleShape(pos: position, radius: 40.0, resolution: 32, color: Color(50, 44, 44, 255)))
      
      if distance(offset, position) > 40.0 {
        
        // compute position
        let dot_position = position + (offset - position).normalized() * 40.0
        //renderer.addShapeData(circleShape(pos: dot_position, radius: 7.0, resolution: 16, color: Color(255, 255, 255, 255)))
        renderer.addShapeData(circleShape(pos: dot_position, radius: 6.0, resolution: 16, color: Color(220, 87, 87, 255)))
        
        if mode == .Erase {
          let size = CGVector(dx: 20.0, dy: 20.0)
          renderer.addShapeData(imageShape(a: position - size, b: position + size, texture: 0))
        }
        
        if mode == .Select {
          let size = CGVector(dx: 20.0, dy: 20.0)
          renderer.addShapeData(imageShape(a: position - size, b: position + size, texture: 1))
        }
      }
    }
  }
  
}
