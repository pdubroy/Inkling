//
//  MorphableFill.swift
//  Inkling
//
//  Created by Marcel on 30/08/2022.
//

import Foundation

class CanvasFill: CanvasElement {
  var nodes: [Node]
  var renderShape: RenderShape
  var color: Color
  
  init(_ nodes: [Node], color: Color){
    self.nodes = nodes
    self.color = color
    self.renderShape = polyFillShape(points: nodes.map({ n in n.position }), color: color)
  }
  
  func morph(){
    self.renderShape = polyFillShape(points: nodes.map({ n in n.position }), color: color)
  }
  
  func render(_ renderer: Renderer) {
    
  }
}
