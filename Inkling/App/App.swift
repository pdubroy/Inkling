//
//  App.swift
//  Inkling
//
//  Created by Marcel on 18/08/2022.
//

import Foundation
import UIKit

class App {
  
  var strokeCapture: StrokeCapture!
  var strokes: [Stroke]
  
  
  init() {
    strokeCapture = StrokeCapture()
    strokes = []
  }
  
  func update(touches: Touches){
    let result = strokeCapture.update(touch_events: touches.events)
    if let result = result {
      strokes.append(result)
    }
  }
  
  func render(renderer: Renderer) {
    for stroke in strokes {
      stroke.render(renderer)
    }
    
    strokeCapture.render(renderer)
  }
  
}
