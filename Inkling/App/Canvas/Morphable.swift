//
//  Morphable.swift
//  Inkling
//
//  Created by Marcel on 24/08/2022.
//

import Foundation

protocol Morphable {
  var stroke: Stroke { get set }
  var nodes: [Node] { get set }
  
  func move()
}
