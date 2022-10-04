//
//  ScriptLoader.swift
//  Inkling
//
//  Created by Patrick Dubroy on 2022-09-19.
//

import JavaScriptCore
import Foundation

let scriptUrls = [
  "http://Patricks-M1-MacBook.local:8000/main.js"
]

// Add some extensions that make it more convenient to access and manipulate
// the global object in the JSContext.

extension JSContext {
  subscript(_ key: NSString) -> JSValue? {
    get { return objectForKeyedSubscript(key) }
  }

  subscript(_ key: NSString) -> Any? {
    get { return objectForKeyedSubscript(key) }
    set { setObject(newValue, forKeyedSubscript: key) }
  }
}

extension JSValue {
  subscript(_ key: NSString) -> JSValue? {
    get { return objectForKeyedSubscript(key) }
  }

  subscript(_ key: NSString) -> Any? {
    get { return objectForKeyedSubscript(key) }
    set { setObject(newValue, forKeyedSubscript: key) }
  }
}


class ScriptLoader: CanvasObserver {
  let context: JSContext

  init() {
    context = JSContext()

    // Forward console.log to the Swift side
    let logHandler: @convention(block) (String) -> Void = { string in
      print(string)
    }
    context["console"]?["log"] = logHandler

    // Set up an exception handler which prints to the Swift console
    context.exceptionHandler = {_, exception in
      if let exception = exception {
        print(exception.toString()!)
      }
    }
  }

  func onStrokeEnd(_ stroke: Stroke) {
    let points = stroke.points.map { [$0.dx, $0.dy] }
    context["onStrokeEnd"]?.call(withArguments: [points])
  }

  func loadAllScripts() {
    for url in scriptUrls {
      loadScript(urlString: url)
    }
  }

  func loadScript(urlString: String) {
    if let url = URL(string: urlString) {
      do {
        let scriptContents = try String(contentsOf: url)
        context.evaluateScript(scriptContents)
      } catch {
        print("Unable to load script from \(url)")
      }
    } else {
      assert(false, "bad url: \(urlString)")
    }
  }

  func elementAdded(_ element: CanvasElement) {
    context["onCanvasElementAdded"]?.call(withArguments: [element])
  }

  func elementRemoved(_ element: CanvasElement) {
    context["onCanvasElementRemoved"]?.call(withArguments: [element])
  }
}
