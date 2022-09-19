//
//  ScriptLoader.swift
//  Inkling
//
//  Created by Patrick Dubroy on 2022-09-19.
//

import JavaScriptCore
import Foundation

let scriptUrls = [
  "http://Patricks-M1-MacBook.local:8000/index.js"
]

class ScriptLoader {
  let context: JSContext

  init() {
    context = JSContext()
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

        let sumValue = context.evaluateScript(scriptContents)
        if let sum = sumValue?.toInt32() {
            print("\(sum)")
        }
      } catch {
        print("Unable to load script from \(url)")
        // contents could not be loaded
      }
    } else {
      assert(false, "bad url: \(urlString)")
    }
  }
}
