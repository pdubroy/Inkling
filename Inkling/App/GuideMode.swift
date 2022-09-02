//
//  GuideMode.swift
//  Inkling
//
//  Created by Marcel on 31/08/2022.
//

import Foundation
import UIKit

class GuideMode {
  
  var selected = 1
  
  let buttons = [
    (CGVector(dx: 50.0, dy: 50.0), 2, 2),
    (CGVector(dx: 507.0, dy: 50.0), 5, 9),
    (CGVector(dx: 567.0, dy: 50.0), 6, 10),
    (CGVector(dx: 627.0, dy: 50.0), 7, 11),
    (CGVector(dx: 687.0, dy: 50.0), 8, 12)
  ]
  
  var controlPoints: [CGVector]
  var draggingControlPoints: [TouchId: Int] = [:]

  init(_ controlPoints: [CGVector], _ touchIds: [TouchId]) {
    self.controlPoints = controlPoints
    
    for (index, touchId) in touchIds.enumerated() {
      draggingControlPoints[touchId] = index
    }
  }
  
  func update(_ touches: Touches) -> Bool {
    // Menu buttons
    if let event = touches.did(.Finger, .Begin) {
      for (index, (button, _, _)) in buttons.enumerated() {
        if distance(button, event.pos) < 30.0 {
          touches.capture(event)
          
          if index == 0 {
            return true
          } else {
            selected = index
            
            if selected == 1 || selected == 3 {
              controlPoints = Array(controlPoints[0...1])
            }
            
            if selected == 4 {
                controlPoints = [
                  controlPoints[0],
                  controlPoints[1],
                  controlPoints[0] + (controlPoints[0] - controlPoints[1]).normalized().rotated90clockwise() * 200.0,
                ]
            }
          }
        }
      }
    }
    
    
    // Move Guide
    for event in touches.events {
      if event.type == .Finger {
        if event.event_type == .Begin {
          let closestPoint = findClosestPointInCollection(points: controlPoints, point: event.pos, min_dist: 50.0)
          if closestPoint > -1 && !draggingControlPoints.contains(where: { (key: TouchId, value: Int) in value == closestPoint }) {
            draggingControlPoints[event.id] = closestPoint
            touches.capture(event)
          } else if selected == 1 || selected == 2 {
            let offset = (controlPoints[1] - controlPoints[0]) * 1000.0
            if PointLineDistance(p: event.pos, a: controlPoints[0] - offset, b: controlPoints[0] + offset) < 50.0 {
              controlPoints.append(event.pos)
              draggingControlPoints[event.id] = controlPoints.count - 1
              selected = 2
              touches.capture(event)
            }
          }
        }
        if event.event_type == .End {
          draggingControlPoints.removeValue(forKey: event.id)
        }
        
        if event.event_type == .Move || event.event_type == .Predict {
          if let index = draggingControlPoints[event.id]{
            controlPoints[index] = event.pos
            touches.capture(event)
          }
        }
      }
    }
    
    // Capture pencil events
    
    for (index, event) in touches.events.enumerated() {
      if event.type == .Pencil {
        if selected == 1 {
          let closestPointOnLine = ScalarProjection(p: event.pos, a: controlPoints[0], b: controlPoints[1])
          if distance(closestPointOnLine, event.pos) < 50.0 {
            touches.events[index].pos = closestPointOnLine
          }
        }
        
        if selected == 2 {
          let offsetA = (controlPoints[1] - controlPoints[0]) * 1000.0
          let offsetB = (controlPoints[controlPoints.count-1] - controlPoints[controlPoints.count-2]) * 1000.0
          let curve = [controlPoints[0] - offsetA] + ChaikinCurve(points: controlPoints) + [controlPoints[controlPoints.count-1] + offsetB]
          
          if let closestPointOnLine = ClosestPointOnPolyline(line: curve, point: event.pos) {
            if distance(closestPointOnLine, event.pos) < 50.0 {
              touches.events[index].pos = closestPointOnLine
            }
          }
          
        }
        
        if selected == 3 {
          
          let closestPointOnLine = ClosestPointOnCircle(p: event.pos, center: controlPoints[0], radius: distance(controlPoints[0], controlPoints[1]))
          if distance(closestPointOnLine, event.pos) < 50.0 {
            touches.events[index].pos = closestPointOnLine
          }
        }
        
        if selected == 4 {
          let fourthPoint = controlPoints[1] - controlPoints[0] + controlPoints[2]
          let curve = [
            controlPoints[0],
            controlPoints[1],
            fourthPoint,
            controlPoints[2],
            controlPoints[0],
          ]
          
          if let closestPointOnLine = ClosestPointOnPolyline(line: curve, point: event.pos) {
            if distance(closestPointOnLine, event.pos) < 50.0 {
              touches.events[index].pos = closestPointOnLine
            }
          }
        }
      }
    }
    
    return false
  }
  
  func render(_ renderer: Renderer) {
    let transparentRed = Color(220, 87, 87, 50)
    
    let size = CGVector(dx: 20.0, dy: 20.0)

    for (index, (position, texture, texture_selected)) in buttons.enumerated() {
      var texture = texture
      if index == selected {
        texture = texture_selected
      }
      renderer.addShapeData(imageShape(a: position - size, b: position + size, texture: texture))
    }
    
    
    for controlPoint in controlPoints {
      renderer.addShapeData(circleShape(pos: controlPoint, radius: 6.0, resolution: 16, color: Color(220, 87, 87, 255)))
    }
    
    if selected == 1 {
      let offset = (controlPoints[1] - controlPoints[0]) * 1000.0
      renderer.addShapeData(lineShape(a: controlPoints[0] + offset, b: controlPoints[1] - offset, weight: 1.0, color: transparentRed))
    }
    
    if selected == 2 {
      let offsetA = (controlPoints[1] - controlPoints[0]) * 1000.0
      let offsetB = (controlPoints[controlPoints.count-1] - controlPoints[controlPoints.count-2]) * 1000.0
      let curve = [controlPoints[0] - offsetA] + ChaikinCurve(points: controlPoints) + [controlPoints[controlPoints.count-1] + offsetB]
      renderer.addShapeData(polyLineShape(points: curve, weight: 1.0, color: transparentRed))
    }
    
    if selected == 3 {
      let size = distance(controlPoints[0], controlPoints[1])
      renderer.addShapeData(circleLineShape(pos: controlPoints[0], radius: Float(size), resolution: 64, width: 1.0, color: transparentRed))
    }
    
    if selected == 4 {
      //let offset = (controlPoints[1] - controlPoints[0]) * 1000.0
      let fourthPoint = controlPoints[1] - controlPoints[0] + controlPoints[2]
      renderer.addShapeData(lineShape(a: controlPoints[0] , b: controlPoints[1], weight: 1.0, color: transparentRed))
      renderer.addShapeData(lineShape(a: controlPoints[1] , b: fourthPoint, weight: 1.0, color: transparentRed))
      renderer.addShapeData(lineShape(a: fourthPoint , b: controlPoints[2], weight: 1.0, color: transparentRed))
      renderer.addShapeData(lineShape(a: controlPoints[2] , b: controlPoints[0], weight: 1.0, color: transparentRed))
      
      //renderer.addShapeData(lineShape(a: controlPoints[0] , b: fourthPoint, weight: 1.0, color: transparentRed))
      //renderer.addShapeData(lineShape(a: controlPoints[1] , b: controlPoints[2], weight: 1.0, color: transparentRed))
    }
  }
}
