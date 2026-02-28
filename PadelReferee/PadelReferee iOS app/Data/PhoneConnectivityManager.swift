//
//  PhoneConnectivityManager.swift
//  PadelReferee
//
//  Created by Filip Kisić on 22.02.2026..
//

import Foundation
import WatchConnectivity
import Combine

@MainActor
final class PhoneConnectivityManager: NSObject, ObservableObject {
  static let shared = PhoneConnectivityManager()
  
  // MARK: - Published state from Watch
  @Published var watchSessionStarted: Bool = false
  @Published var watchDurationMinutes: Int = 90
  @Published var receivedMatchConfig: MatchConfig?
  @Published var receivedIsRunning: Bool?
  
  // MARK: - Session
  func startSession() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }
  
  // MARK: - Send match state to Watch
  func sendMatchState(_ config: MatchConfig) {
    let message = WatchMessage
      .build()
      .withType(.scoreUpdate)
      .withConfig(config)
      .serialize()
    
    send(message)
  }
  
  // MARK: - Send session started to Watch
  func sendSessionStarted(durationMinutes: Int) {
    let message = WatchMessage
      .build()
      .withType(.sessionStarted)
      .withDurationMinutes(durationMinutes)
      .serialize()
    
    send(message)
  }

  func resetWatchSession() {
    watchSessionStarted = false
    receivedMatchConfig = nil
  }
  
  // MARK: - Send timer state to Watch
  func sendTimerState(isRunning: Bool) {
    let message = WatchMessage
      .build()
      .withType(.timerUpdate)
      .withIsRunning(isRunning)
      .serialize()
    send(message)
  }
  
  // MARK: - Private
  private func send(_ message: [String: Any]) {
    let session = WCSession.default
    
    guard session.activationState == .activated else {
      print("Phone: Session not activated")
      return
    }
    
    guard session.isPaired, session.isWatchAppInstalled else {
      print("Phone: Not paired or watch app not installed")
      return
    }
    
    if session.isReachable {
      session.sendMessage(message, replyHandler: nil) { error in
        print("Phone send error: \(error.localizedDescription)")
      }
    } else {
      try? session.updateApplicationContext(message)
    }
  }
  
  private func handleMessage(_ message: [String: Any]) {
    guard let type = WatchMessage.messageType(from: message) else { return }
    
    switch type {
      case .sessionStarted:
      self.watchDurationMinutes = WatchMessage.decodeDurationMinutes(from: message)
      self.watchSessionStarted = true
      
      case .scoreUpdate:
      if let config = WatchMessage.decodeMatchConfig(from: message) {
        self.receivedMatchConfig = config
      }
      
      case .timerUpdate:
      if let isRunning = WatchMessage.decodeIsRunning(from: message) {
        self.receivedIsRunning = isRunning
      }
    }
  }
}

// MARK: - WCSessionDelegate
extension PhoneConnectivityManager: WCSessionDelegate {
  nonisolated func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: (any Error)?
  ) {}
  
  nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
  
  nonisolated func sessionDidDeactivate(_ session: WCSession) { session.activate() }
  
  nonisolated func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    Task { @MainActor in
      self.handleMessage(message)
    }
  }
  
  nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    Task { @MainActor in
      self.handleMessage(applicationContext)
    }
  }
}
