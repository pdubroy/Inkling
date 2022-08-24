//
//  PseudoMode.swift
//  Inkling
//
//  Created by Marcel on 23/08/2022.
//

import Foundation
import UIKit

class PseudoMode {
  var mode = false
  var fingerId: TouchId? = nil
  var position = CGVector()
  var offset = CGVector()
  
  func update(_ touches: Touches) {
    if mode == false {
      if touches.active_fingers.count == 1, let event = touches.did(.Finger, .Begin) {
        mode = true
        fingerId = event.id
        position = event.pos
        offset = CGVector()
        touches.capture(event)
        
      }
    }
    
    if mode == true {
//      for event in touches.moved(.Finger) {
//        position = event.pos
//        touches.capture(event)
//      }
      
      if let _ = touches.did(.Finger, .End, fingerId!) {
        mode = false
      }
    }
    
  }
  
  func render(_ renderer: Renderer) {
    if mode == true {
      renderer.addShapeData(circleShape(pos: position, radius: 50.0, resolution: 32, color: Color(255, 0, 0, 50)))
    }
  }
  
}
