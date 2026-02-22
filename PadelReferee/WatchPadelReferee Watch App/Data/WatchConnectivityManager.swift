//
//  PhoneDataPublisher.swift
//  PadelReferee
//
//  Created by Filip Kisić on 22.02.2026..
//
import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
  @Published var lastReceivedText: String = "—"
  
  static let shared = WatchConnectivityManager()
  
  func startSession() {
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }
  
  func sendUpdate(text: String) {
    let session = WCSession.default
    guard session.activationState == .activated else { return }
    guard session.isReachable else {
      print("Watch: iPhone not reachable (try foreground on both).")
      return
    }
    
    session.sendMessage(["text": text], replyHandler: nil) { error in
      print("Watch send error:", error.localizedDescription)
    }
  }
}

extension WatchConnectivityManager: WCSessionDelegate {
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {}
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    guard let text = message["text"] as? String else { return }
    Task { @MainActor in
      self.lastReceivedText = text
    }
  }
}
