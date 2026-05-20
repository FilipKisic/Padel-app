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

  private static let isLockedKey = "watchIsLocked"

  // MARK: - Published state from iOS
  @Published var receivedMatchState: MatchState?
  @Published var receivedIsRunning: Bool?
  @Published var iOSSessionStarted: Bool = false
  @Published var iOSDurationMinutes: Int = 90
  @Published var iOSInitialServePosition: ServePosition = .bottomRight
  @Published var peerSessionEnded: Bool = false
  @Published var isLocked: Bool = UserDefaults.standard.bool(forKey: WatchConnectivityManager.isLockedKey)
  
  // MARK: - Session
  func startSession() {
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }
  
  // MARK: - Send session started to iOS
  func sendSessionStarted(durationMinutes: Int, servePosition: ServePosition) {
    let message = WatchMessage
      .build()
      .withType(.sessionStarted)
      .withDurationMinutes(durationMinutes)
      .withServePosition(servePosition)
      .serialize()
    
    send(message)
  }
  
  // MARK: - Send match state to iOS
  func sendMatchState(_ state: MatchState) {
    let message = WatchMessage
      .build()
      .withType(.scoreUpdate)
      .withState(state)
      .serialize()
    
    send(message)
  }
  
  // MARK: - Send timer state to iOS
  func sendTimerState(isRunning: Bool) {
    let message = WatchMessage
      .build()
      .withType(.timerUpdate)
      .withIsRunning(isRunning)
      .serialize()
    send(message)
  }
  
  // MARK: - Send session ended to iOS
  func sendSessionEnded(calories: Double = 0, averageHeartRate: Double = 0) {
    let message = WatchMessage
      .build()
      .withType(.sessionEnded)
      .withCalories(calories)
      .withAverageHeartRate(averageHeartRate)
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
      case .timerUpdate:
        if let isRunning = WatchMessage.decodeIsRunning(from: message) {
          Task { @MainActor in
            self.receivedIsRunning = isRunning
          }
        }
      case .sessionStarted:
        let duration = WatchMessage.decodeDurationMinutes(from: message)
        let servePosition = WatchMessage.decodeServePosition(from: message) ?? .bottomRight
        Task { @MainActor in
          self.iOSDurationMinutes = duration
          self.iOSInitialServePosition = servePosition
          self.iOSSessionStarted = true
        }
      case .sessionEnded:
        Task { @MainActor in
          self.peerSessionEnded = true
        }
      case .accessLocked:
        if let locked = WatchMessage.decodeIsLocked(from: message) {
          Task { @MainActor in
            self.isLocked = locked
            UserDefaults.standard.set(locked, forKey: WatchConnectivityManager.isLockedKey)
          }
        }
    }
  }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityManager: WCSessionDelegate {
  func session(
  _ session: WCSession,
  activationDidCompleteWith activationState: WCSessionActivationState,
  error: Error?
  ) {
    let context = session.receivedApplicationContext
    guard !context.isEmpty else { return }
    handleMessage(context)
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    handleMessage(message)
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    handleMessage(applicationContext)
  }
}
