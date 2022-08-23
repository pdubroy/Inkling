//
//  ColorSelector.swift
//  Inkling
//
//  Created by Marcel on 18/08/2022.
//

import Foundation
import UIKit

class ColorPicker {
  let colors: [Color]
  var active_color: Color
  
  var open: Bool
  
  var position: CGVector
  
  init() {
    colors = [
      Color(0,18,25),
      Color(44,150,210),
      Color(148,210,189),
      Color(236,156,0),
      Color(213,39,28)
    ]
    active_color = colors[0]
    position = CGVector(dx: 1160, dy: 800) // Bottom right corner
    
    open = false
  }
  
  func update(_ touches: Touches) -> Color? {
    
    if let event = touches.did(.Pencil, .Begin) {
      // Handle Open Menu
      if open {
        for (i, color) in colors.enumerated() {
          let pos = position - CGVector(dx: 0, dy: i * 50)
          if distance(event.pos, pos) < 25 {
            active_color = color
            open = false
            touches.capture(event)
            return active_color
          }
        }
      }
      // Handle closed menu
      else {
        if distance(event.pos, position) < 30 {
          open = true
          touches.capture(event)
        }
      }
    }
    
    return nil
  }

  
  func render(_ renderer: Renderer) {
    if open {
      for (i, color) in colors.enumerated() {
        let pos = position - CGVector(dx: 0, dy: i * 50)
        renderer.addShapeData(circleShape(pos: pos, radius: 20.0, resolution: 32, color: color))
      }
    } else {
      renderer.addShapeData(circleShape(pos: position, radius: 20.0, resolution: 32, color: active_color))
    }
    
  }
}
