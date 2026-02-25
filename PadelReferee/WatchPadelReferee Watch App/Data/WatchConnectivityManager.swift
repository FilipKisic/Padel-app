//
//  WatchConnectivityManager.swift
//  PadelReferee
//
//  Created by Filip Kisić on 22.02.2026..
//
import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject {
  static let shared = WatchConnectivityManager()
  
  // MARK: - Published state from iOS
  @Published var receivedMatchState: MatchState?
  
  // MARK: - Session
  func startSession() {
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }
  
  // MARK: - Send session started to iOS
  func sendSessionStarted(durationMinutes: Int) {
    let message = WatchMessage
      .build()
      .withType(.sessionStarted)
      .withDurationMinutes(durationMinutes)
      .serialize()
    
    send(message)
  }
  
  // MARK: - Send match state to iOS
  func sendMatchState(_ state: MatchState, elapsedTime: TimeInterval) {
    let message = WatchMessage
      .build()
      .withType(.scoreUpdate)
      .withState(state)
      .withElapsedTime(elapsedTime)
      .serialize()
    
    send(message)
  }
  
  // MARK: - Private
  private func send(_ message: [String: Any]) {
    let session = WCSession.default
    guard session.activationState == .activated else {
      print("Watch: Session not activated")
      return
    }
    
    if session.isReachable {
      session.sendMessage(message, replyHandler: nil) { error in
        print("Watch send error: \(error.localizedDescription)")
      }
    } else {
      try? session.updateApplicationContext(message)
    }
  }
  
  private func handleMessage(_ message: [String: Any]) {
    guard let type = WatchMessage.messageType(from: message) else { return }
    
    switch type {
    case .scoreUpdate:
      if let matchState = WatchMessage.decodeMatchState(from: message) {
        Task { @MainActor in
          self.receivedMatchState = matchState
        }
      }
    case .sessionStarted:
      break
    }
  }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {}
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    handleMessage(message)
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    handleMessage(applicationContext)
  }
}
