//
//  App.swift
//  Inkling
//
//  Created by Marcel on 18/08/2022.
//

import Foundation
import UIKit

class App {
  
  var colorPicker: ColorPicker!
  var strokeCapture: StrokeCapture!
  var strokes: [Stroke]
  
  
  init() {
    colorPicker = ColorPicker()
    strokeCapture = StrokeCapture()
    strokes = []
  }
  
  func update(touches: Touches){
    // Capture tap on color picker
    let color = colorPicker.update(touches.events)
    if let color = color {
      strokeCapture.color = color
      return
    }
    
    // Capture strokes
    let result = strokeCapture.update(touches.events)
    if let result = result {
      strokes.append(result)
    }
    
  }
  
  func render(renderer: Renderer) {
    for stroke in strokes {
      stroke.render(renderer)
    }
    
    strokeCapture.render(renderer)
    
    colorPicker.render(renderer)
    
    renderer.addShapeData(imageShape(a: CGVector(dx: 100.0, dy: 100.0), b: CGVector(dx: 300.0, dy: 300.0), texture: 0))
    renderer.addShapeData(imageShape(a: CGVector(dx: 400.0, dy: 100.0), b: CGVector(dx: 600.0, dy: 300.0), texture: 1))
  }
  
}
