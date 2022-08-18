//
//  ViewController.swift
//  Inkling
//
//  Created by Marcel Goethals on 18/08/2022.
//

import UIKit
import MetalKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
  var metalView: MTKView {
    return view as! MTKView
  }
  
  var renderer: Renderer!
  var multiGestureRecognizer: MultiGestureRecognizer!
  
  var debugInfo: UITextView!
  var previousFrameTime: Date = Date()
  
  var app: App!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Load GuestureRecognizer
    multiGestureRecognizer = MultiGestureRecognizer(target: nil, action: nil)
    multiGestureRecognizer.delegate = self
    multiGestureRecognizer.viewRef = self
    metalView.addGestureRecognizer(multiGestureRecognizer)
    
    // Load Renderer
    renderer = Renderer(metalView: metalView)
    renderer.viewRef = self
    
    // Application logic
    app = App()
    
    // Add debug view
    debugInfo = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    debugInfo.text = "FPS: 0"
    debugInfo.font = UIFont.systemFont(ofSize:14)
    debugInfo.center = CGPoint(x: 100, y: 50);
    metalView.addSubview(debugInfo)
  }
  
  func update(){
    // Update call
    multiGestureRecognizer.update()
    app.update(touches: multiGestureRecognizer.touch_data)
    
    // Calculate frame rate
    let dt = Date().timeIntervalSince(previousFrameTime)
    let fps = (1 / dt).rounded()
    previousFrameTime = Date()
    debugInfo.text = "FPS: \(fps)\n"
    
    // Reset drawing buffer and render app
    renderer.clearBuffer()
    app.render(renderer: renderer)
    
    // Clear touches buffer
    multiGestureRecognizer.reset_buffer()
  }
  
}


