//
//  Canvas.swift
//  Inkling
//
//  Created by Marcel on 22/08/2022.
//

import Foundation




class Canvas {
  var strokes: [Stroke] = []
  // Strokes to render
  // Editable lines, beziers and surfaces
  // Nodal Points
  
  // Renderable Element
  func add_stroke(_ stroke: Stroke) {
    strokes.append(stroke)
  }
  
  func render(_ renderer: Renderer){
    for stroke in strokes {
      stroke.render(renderer)
    }
  }
}
