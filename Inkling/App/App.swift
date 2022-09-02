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
  var selectionCapture: SelectionCaputure!
  var guideModeCapture: GuideModeCapture!
  
  var draggingMode: DraggingMode?
  var selectionMode: SelectionMode?
  var guideMode: GuideMode?
  
  var pseudoMode: PseudoModeInput!
  
  //var strokes: [Stroke]
  var images: [RenderImage] = []
  
  
  init(_ viewRef: ViewController) {
    self.viewRef = viewRef
    
    canvas = Canvas()
    colorPicker = ColorPicker()
    
    strokeCapture = StrokeCapture()
    selectionCapture = SelectionCaputure()
    guideModeCapture = GuideModeCapture()
    
    pseudoMode = PseudoModeInput()
  }
  
  func update(touches: Touches){
    
    // color picker
    if let color = colorPicker.update(touches) {
      strokeCapture.color = color
    }
    
    // Selection gesture
    if selectionMode != nil {
      if let result = selectionMode!.update(touches) {
        switch result {
          case .Close:
            selectionMode = nil
            canvas.selection = nil
          case let .StartMorph(transform):
            canvas.selection?.startMorph(transform)
          case let .Morph(transform):
            canvas.selection?.morph(transform)
          case .Simplify:
          canvas.selection?.simplify()
          default: ()
        }
      }
    }
    
    // Dragging mode
    if let draggingMode = draggingMode {
      draggingMode.update(touches)
    }
    
    // Guide gesture
    if guideMode == nil, let (positions, touches) = guideModeCapture.update(touches) {
      guideMode = GuideMode(positions, touches)
    }
    
    // Guide mode
    if guideMode != nil {
      if guideMode!.update(touches) {
        guideMode = nil
      }
    }
    
    
    // PseudoModes
    pseudoMode.update(touches)
    if pseudoMode.mode == .Drag {
      if draggingMode == nil {
        draggingMode = DraggingMode(canvas.clusters)
      }
    } else {
      if draggingMode != nil {
        draggingMode = nil
      }
    }
    
    if pseudoMode.mode == .Select {
      if let polygon = selectionCapture.update(touches) {
        canvas.selectPolygon(polygon)
        selectionMode = SelectionMode()
      }
    }
    
    if pseudoMode.mode == .Default {
      if let stroke = strokeCapture.update(touches.events) {
        canvas.addStroke(stroke)
      }
    }
    
    
  }
  
  func render(renderer: Renderer) {
    if let guideMode = guideMode {
      guideMode.render(renderer)
    }
    
    canvas.render(renderer, pseudoMode.mode)
    
    strokeCapture.render(renderer)
    colorPicker.render(renderer)
    
    if selectionMode == nil || selectionMode!.active == false {
      pseudoMode.render(renderer)
    }
    
    selectionCapture.render(renderer)
    if let selectionMode = selectionMode {
      selectionMode.render(renderer)
    }
    

  }
  
  func loadImage(imageUrl: String){
    print(imageUrl)
    if let imageId = viewRef.renderer.loadTextureFile(imageUrl) {
      images.append(imageId)
    }
  }
  
}
