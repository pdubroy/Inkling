//
//  StateBroadcast.swift
//  Inkling
//
//  Created by Marcel on 18/08/2022.
//

import Foundation
import Network

// This tool is used to connect to a local UDP server so we can inspect internal state live
class StateBroadcast {
  var connection: NWConnection?
  var hostUDP: NWEndpoint.Host = "192.168.1.83"
  var portUDP: NWEndpoint.Port = 6000
  
  func connect(){
    #if DEBUG
    connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)

    self.connection?.stateUpdateHandler = { (newState) in
        switch (newState) {
          case .ready:
            print("StateBroadcast: Ready")
            //self.send(messageToUDP)
            //self.receive()
          case .setup:
            print("StateBroadcast: Setup")
          case .cancelled:
            print("StateBroadcast: Cancelled")
          case .preparing:
            print("StateBroadcast: Preparing")
          default:
            print("ERROR! StateBroadcast not defined!")
        }
    }

    self.connection?.start(queue: .global())
    #endif
  }
  
  // Send raw data
  func send(_ content: Data) {
      self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
        if (NWError != nil) {
          print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
        }
      })))
  }

  // Send a string
  func send(_ content: String) {
    let contentToSendUDP = content.data(using: String.Encoding.utf8)
    self.connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError != nil) {
        print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
      }
    })))
  }
  
  func send<T>(_ key: String, _ content: T) where T : Codable {
    #if DEBUG
    let jsonEncoder = JSONEncoder()
    let data = [key: content]
    let jsonData = try! jsonEncoder.encode(data)
    let string = String(data: jsonData, encoding: String.Encoding.utf8)!
    self.send(string)
    #endif
  }
  
  // Receive messages
  func receive() {
    self.connection?.receiveMessage { (data, context, isComplete, error) in
        if (isComplete) {
          if (data != nil) {
              let backToString = String(decoding: data!, as: UTF8.self)
              print("Received message: \(backToString)")
          } else {
              print("Data == nil")
          }
        }
    }
  }
}
