//
//  MultiGestureRecognizer.swift
//  Inkling
//
//  Created by Marcel Goethals on 18/08/2022.
//

import UIKit

typealias TouchId = Int

enum TouchEventType: Codable {
  case Begin
  case Move
  case Predict
  case End
}

enum TouchType: Codable {
  case Pencil
  case Finger
}

struct TouchEvent: Codable {
  let id: TouchId
  let type: TouchType
  let event_type: TouchEventType
  let pos: CGVector
  let force: CGFloat?
}

class Touches: Codable {
  var events: [TouchEvent] = []
  var active_fingers: [TouchId: CGVector] = [:]
  var active_pencil: CGVector? = nil
  
  func did(_ type: TouchType, _ event_type: TouchEventType) -> TouchEvent? {
    return events.first { e in e.type == type && e.event_type == event_type}
  }
  
  func did(_ type: TouchType, _ event_type: TouchEventType, _ id: TouchId) -> TouchEvent? {
    return events.first { e in e.id == id && e.type == type && e.event_type == event_type}
  }
  
  func capture(_ event: TouchEvent) {
    events.removeAll { e in e.type == event.type && e.event_type == event.event_type}
  }
  
  func moved(_ type: TouchType) -> [TouchEvent] {
    return events.filter { event in event.type == type && (event.event_type == .Move || event.event_type == .Predict) }
  }
  
  func moved(_ type: TouchType, _ id: TouchId) -> [TouchEvent] {
    return events.filter { event in event.id == id && event.type == type && (event.event_type == .Move || event.event_type == .Predict) }
  }
}

class MultiGestureRecognizer: UIGestureRecognizer {
  var touch_data = Touches()
  var event_buffer: [TouchEvent] = []
  
  var viewRef: ViewController!

  override init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)

    // allows pen + touch input at the same time
    requiresExclusiveTouchType = false
  }
  
  func update() {
    // Copy over event buffer
    touch_data.events = event_buffer
    event_buffer = []
    
    for touch in touch_data.events {
      // Collect active fingers into a dictionary,
      if touch.type == .Finger {
        switch touch.event_type {
          case .End:
            touch_data.active_fingers[touch.id] = nil
          default:
            touch_data.active_fingers[touch.id] = touch.pos
        }
      } else { // Put active pencil
        switch touch.event_type {
          case .End:
            touch_data.active_pencil = nil
          default:
            touch_data.active_pencil = touch.pos
        }
      }
    }
  }
  
  func reset_buffer(){
    touch_data.events = []
  }
  
  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    
    for touch in touches {
      let pos = CGVector(point: touch.preciseLocation(in: view))
      let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
      
      if touch.type == .pencil {
        event_buffer.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.Begin, pos: pos, force: touch.force))
      } else {
        event_buffer.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.Begin, pos: pos, force: nil))
      }
    }
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
      
      if let coalesced = event.coalescedTouches(for: touch) {
        for touch in coalesced {
          let pos = CGVector(point: touch.preciseLocation(in: view))
          if touch.type == .pencil {
            event_buffer.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.Move, pos: pos, force: touch.force))
          } else {
            event_buffer.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.Move, pos: pos, force: nil))
          }
        }
      }

      if let predicted = event.predictedTouches(for: touch) {
        for touch in predicted {
          let pos = CGVector(point: touch.preciseLocation(in: view))
          if touch.type == .pencil {
            event_buffer.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.Predict, pos: pos, force: touch.force))
          } else {
            event_buffer.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.Predict, pos: pos, force: nil))
          }
        }
      }
    }
  }

  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
      let pos = CGVector(point: touch.preciseLocation(in: view))
      if touch.type == .pencil {
        event_buffer.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.End, pos: pos, force: touch.force))
      } else {
        event_buffer.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.End, pos: pos, force: nil))
      }
    }
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
      let pos = CGVector(point: touch.preciseLocation(in: view))
      if touch.type == .pencil {
        event_buffer.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.End, pos: pos, force: touch.force))
      } else {
        event_buffer.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.End, pos: pos, force: nil))
      }
    }
  }
}

