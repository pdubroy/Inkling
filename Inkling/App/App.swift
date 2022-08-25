//
//  App.swift
//  Inkling
//
//  Created by Marcel on 18/08/2022.
//

import Foundation
import UIKit

class App {
  var viewRef: ViewController!
  
  var canvas: Canvas!
  var colorPicker: ColorPicker!
  var strokeCapture: StrokeCapture!
  var pseudoMode: PseudoModeInput!
  
  //var strokes: [Stroke]
  var images: [RenderImage] = []
  
  
  init(_ viewRef: ViewController) {
    self.viewRef = viewRef
    canvas = Canvas()
    colorPicker = ColorPicker()
    strokeCapture = StrokeCapture()
    pseudoMode = PseudoModeInput()
  }
  
  func update(touches: Touches){
    
//    if touches.active_fingers.count == 5 {
//      print("open dialog")
//      viewRef.openImageDialog()
//    }
    

    
    
    /* Pencil interactions */
    // Capture tap on color picker
    if let color = colorPicker.update(touches) {
      strokeCapture.color = color
    }
    
    pseudoMode.update(touches)
    canvas.update(touches, pseudoMode.mode)
    
    
    
    // Capture dragging things on the canvas
    
    // Capture guides
    
    // Capture stroke drawing
    if pseudoMode.mode == .Default {
      if let stroke = strokeCapture.update(touches.events) {
        canvas.add_stroke(stroke)
      }
    }
    
  }
  
  func render(renderer: Renderer) {
    canvas.render(renderer, pseudoMode.mode)
    
    strokeCapture.render(renderer)
    colorPicker.render(renderer)
    pseudoMode.render(renderer)
    
    for image in images {
      renderer.addShapeData(imageShape(a: CGVector(dx: 100.0, dy: 100.0), b: CGVector(dx: 100.0 + Double(image.width / 4), dy: 100.0 + Double(image.height / 4)), texture: image.texture_id))
    }
    
    //renderer.addShapeData(imageShape(a: CGVector(dx: 400.0, dy: 100.0), b: CGVector(dx: 400.0 + (433.0 / 2.0) , dy: 100.0 + ( 94.0 / 2.0 )), texture: 99))
  }
  
  func loadImage(imageUrl: String){
    print(imageUrl)
    if let imageId = viewRef.renderer.loadTextureFile(imageUrl) {
      images.append(imageId)
    }
    
  }
  
}
