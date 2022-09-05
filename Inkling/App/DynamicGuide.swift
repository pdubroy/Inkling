//
//  DynamicCurve.swift
//  Inkling
//
//  Created by Marcel on 05/09/2022.
//

import Foundation
import UIKit

class DynamicGuide {
  var pencil_is_down = true
  var finger_is_down = true
  var finger_id: TouchId
  var finger: CGVector
  var pencil: CGVector
  
  init(_ finger_id: TouchId, _ finger_pos: CGVector, _ pencil_pos: CGVector) {
    self.finger_id = finger_id
    self.finger = finger_pos
    self.pencil = pencil_pos
  }
  
  func update(_ touches: Touches) -> Bool {
    
    // Finger up
    if let _ = touches.did(.Finger, .End, finger_id) {
      finger_is_down = false
    }
    
    // Pencil up
    if let _ = touches.did(.Pencil, .End) {
      pencil_is_down = false
    }
    
    // If everything had been lifted, destroy the guide
    if !pencil_is_down && !finger_is_down {
      return true
    }
    
    // If the pencil is placed
    if let _ = touches.did(.Pencil, .Begin) {
      pencil_is_down = true
    }
    
    // If the finger is dangling, allow the user to grab it using a different finger
    if finger_is_down == false {
      if let event = touches.did(.Finger, .Begin) {
        if distance(finger, event.pos) < 50.0 {
          finger_is_down = true
          finger = event.pos
        }
      }
    }
    
    for event in touches.moved(.Finger) {
      finger = event.pos
    }
    
    // If the pencil is moved, update pencil position
    for (index, event) in touches.events.enumerated() {
      if event.type == .Pencil && (event.event_type == .Move || event.event_type == .Predict) {
        let closestPointOnLine = ScalarProjection(p: event.pos, a: finger, b: pencil)
        pencil = closestPointOnLine
        touches.events[index].pos = closestPointOnLine
      }
    }
    
    return false
  }
  
  func render(_ renderer: Renderer){
    
    renderer.addShapeData(circleShape(pos: finger, radius: 6.0, resolution: 16, color: Color(220, 87, 87, 255)))
    
    let offset = (pencil - finger) * 1000.0
    renderer.addShapeData(lineShape(a: pencil + offset, b: pencil - offset, weight: 1.0, color: Color(220, 87, 87, 50)))
  }
}
