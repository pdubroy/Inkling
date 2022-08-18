//
//  MultiGestureRecognizer.swift
//  Inkling
//
//  Created by Marcel Goethals on 18/08/2022.
//

import UIKit

typealias TouchId = Int

enum TouchEventType {
  case Begin
  case Move
  case Predict
  case End
}

enum TouchType {
  case Pencil
  case Finger
}

struct TouchEvent {
  let id: TouchId
  let type: TouchType
  let event_type: TouchEventType
  let pos: CGVector
  let force: CGFloat?
}

struct Touches {
  var events: [TouchEvent]
  var active_fingers: [TouchId: CGVector]
  var active_pencil: CGVector?
}

class MultiGestureRecognizer: UIGestureRecognizer {
  var touch_data = Touches(
    events: [],
    active_fingers: [:],
    active_pencil: nil
  )
  
  var viewRef: ViewController!

  override init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)

    // allows pen + touch input at the same time
    requiresExclusiveTouchType = false
  }
  
  func update() {
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
        touch_data.events.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.Begin, pos: pos, force: touch.force))
      } else {
        touch_data.events.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.Begin, pos: pos, force: nil))
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
            touch_data.events.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.Move, pos: pos, force: touch.force))
          } else {
            touch_data.events.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.Move, pos: pos, force: nil))
          }
        }
      }

      if let predicted = event.predictedTouches(for: touch) {
        for touch in predicted {
          let pos = CGVector(point: touch.preciseLocation(in: view))
          if touch.type == .pencil {
            touch_data.events.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.Predict, pos: pos, force: touch.force))
          } else {
            touch_data.events.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.Predict, pos: pos, force: nil))
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
        touch_data.events.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.End, pos: pos, force: touch.force))
      } else {
        touch_data.events.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.End, pos: pos, force: nil))
      }
    }
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
    for touch in touches {
      let id = Int(bitPattern: Unmanaged.passUnretained(touch).toOpaque())
      let pos = CGVector(point: touch.preciseLocation(in: view))
      if touch.type == .pencil {
        touch_data.events.append(TouchEvent(id: id, type: TouchType.Pencil, event_type: TouchEventType.End, pos: pos, force: touch.force))
      } else {
        touch_data.events.append(TouchEvent(id: id, type: TouchType.Finger, event_type: TouchEventType.End, pos: pos, force: nil))
      }
    }
  }
}

