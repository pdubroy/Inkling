//
//  Node.swift
//  Inkling
//
//  Created by Marcel on 24/08/2022.
//

import Foundation
import UIKit

class Node {
  var position: CGVector
  
  var element: CanvasElement
  
  init(_ position: CGVector, _ element: CanvasElement) {
    self.position = position
    self.element = element
  }
  
  func move(_ position: CGVector) {
    self.position = position
    self.element.morph()
  }
  
  func getStroke() -> Stroke? {
    if let e = element as? CanvasLine {
      return e.stroke
    }
    
    if let e = element as? CanvasBezier {
      return e.stroke
    }
    
    return nil
  }
}
