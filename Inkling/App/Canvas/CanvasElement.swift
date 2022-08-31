//
//  CanvasElement.swift
//  Inkling
//
//  Created by Marcel on 30/08/2022.
//

import Foundation

protocol CanvasElement: class {
  var nodes: [Node] { get set }
  
  func render(_ renderer: Renderer)
  func morph()
}
