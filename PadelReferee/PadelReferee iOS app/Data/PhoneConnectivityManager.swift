//
//  WatchManager.swift
//  PadelReferee
//
//  Created by Filip Kisić on 22.02.2026..
//

import Foundation
import WatchConnectivity
import Combine

@MainActor
final class PhoneConnectivityManager: NSObject, ObservableObject {
  @Published var lastReceivedMessage: String = ""
  
  static let shared = PhoneConnectivityManager()
  
  func startSession() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }
  
  func sendUpdate(text: String) {
    let session = WCSession.default
    guard session.activationState == .activated else {
      print("Phone: Session not activated")
      return
    }
    guard session.isPaired, session.isWatchAppInstalled else {
      print("Phone is not paired or watch app not installed")
      return
    }
    
    session.sendMessage(["text": text], replyHandler: nil) { error in
      print("iOS send error: ", error.localizedDescription)
    }
  }
}

extension PhoneConnectivityManager: WCSessionDelegate {
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: (any Error)?
  ) {}
  
  func sessionDidBecomeInactive(_ session: WCSession) {}
  
  func sessionDidDeactivate(_ session: WCSession) { session.activate() }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    guard let text = message["text"] as? String else { return }
    Task { @MainActor in
      self.lastReceivedMessage = text
    }
  }
}
