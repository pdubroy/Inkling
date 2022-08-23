//
//  ViewController.swift
//  Inkling
//
//  Created by Marcel Goethals on 18/08/2022.
//

import UIKit
import MetalKit
import MobileCoreServices
import UniformTypeIdentifiers


class ViewController: UIViewController, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  var metalView: MTKView {
    return view as! MTKView
  }
  
  var renderer: Renderer!
  var multiGestureRecognizer: MultiGestureRecognizer!
  
  var debugInfo: UITextView!
  var previousFrameTime: Date = Date()
  var imagePicker: UIImagePickerController!
  
  var app: App!
  
  var stateBroadcast: StateBroadcast!
  
  
  
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
    
    // Load debugging
    stateBroadcast = StateBroadcast()
    stateBroadcast.connect()
    
    // Application logic
    app = App(self)
    
    // Add debug view
    debugInfo = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    debugInfo.text = "FPS: 0"
    debugInfo.font = UIFont.systemFont(ofSize:14)
    debugInfo.center = CGPoint(x: 100, y: 50);
    metalView.addSubview(debugInfo)
    
    
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self

  }
  
  func update(){
    // Update call
    multiGestureRecognizer.update()
        
    //
    app.update(touches: multiGestureRecognizer.touch_data)
    
    
    
    // Calculate frame rate
    let dt = Date().timeIntervalSince(previousFrameTime)
    let fps = (1 / dt).rounded()
    previousFrameTime = Date()
    debugInfo.text = "FPS: \(fps)\n"
    
    
    // Reset drawing buffer and render app
    renderer.clearBuffer()
    app.render(renderer: renderer)
    
    
    // Update state on debugger
    //stateBroadcast.send("touch_data", multiGestureRecognizer.touch_data)
    //stateBroadcast.send("fps", fps)
    
    // Clear touches buffer
    multiGestureRecognizer.reset_buffer()
  }
  
  // File dialog stuff
  func openImageDialog(){
    metalView.addSubview(imagePicker.view)
    present(imagePicker, animated: true)
  }
  
  func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    dismiss(animated: true, completion: nil)
    let tempImage = info[UIImagePickerController.InfoKey.imageURL] as! NSURL
    app.loadImage(imageUrl: tempImage.absoluteString!)
  }
  
}
