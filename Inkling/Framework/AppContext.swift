//
//  AppContext.swift
//  Inkling
//
//  Created by Marcel on 23/08/2022.
//

import Foundation

class AppContext {
  var viewRef: ViewController!
  
  init(){}
  
  func loadImage(){
    viewRef.present(viewRef.imagePicker, animated: true)
  }
}
