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
  @Published var receivedElapsedTime: TimeInterval = 0
  
  // MARK: - Session
  func startSession() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }
  
  // MARK: - Send match state to Watch
  func sendMatchState(_ config: MatchConfig, elapsedTime: TimeInterval) {
    var message: [String: Any] = [
      "type": "scoreUpdate",
      "playerPoint": config.playerPoint.rawValue,
      "opponentPoint": config.opponentPoint.rawValue,
      "playerTiebreakPoints": config.playerTiebreakPoints,
      "opponentTiebreakPoints": config.opponentTiebreakPoints,
      "currentSetIndex": config.currentSetIndex,
      "servePosition": config.servePosition.rawValue,
      "isDeuce": config.isDeuce,
      "isTiebreak": config.isTiebreak,
      "isMatchOver": config.isMatchOver,
      "elapsedTime": elapsedTime
    ]
    
    let setsData = config.sets.map { set -> [String: Any] in
      ["playerGames": set.playerGames, "opponentGames": set.opponentGames, "isTiebreak": set.isTiebreak]
    }
    message["sets"] = setsData
    
    if let winner = config.winner {
      message["winner"] = winner == .player ? "player" : "opponent"
    }
    
    send(message)
  }
  
  func resetWatchSession() {
    watchSessionStarted = false
    receivedMatchConfig = nil
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
    guard let type = message["type"] as? String else { return }
    
    switch type {
    case "sessionStarted":
      let duration = message["durationMinutes"] as? Int ?? 90
      self.watchDurationMinutes = duration
      self.watchSessionStarted = true
      
    case "scoreUpdate":
      if let config = Self.decodeMatchConfig(from: message) {
        let elapsed = message["elapsedTime"] as? Double ?? 0
        self.receivedMatchConfig = config
        self.receivedElapsedTime = elapsed
      }
      
    default:
      break
    }
  }
  
  // MARK: - Decoding
  static func decodeMatchConfig(from message: [String: Any]) -> MatchConfig? {
    guard
      let playerPointRaw = message["playerPoint"] as? String,
      let opponentPointRaw = message["opponentPoint"] as? String,
      let playerPoint = Point(rawValue: playerPointRaw),
      let opponentPoint = Point(rawValue: opponentPointRaw),
      let playerTiebreakPoints = message["playerTiebreakPoints"] as? Int,
      let opponentTiebreakPoints = message["opponentTiebreakPoints"] as? Int,
      let currentSetIndex = message["currentSetIndex"] as? Int,
      let servePositionRaw = message["servePosition"] as? Int,
      let servePosition = ServePosition(rawValue: servePositionRaw),
      let isDeuce = message["isDeuce"] as? Bool,
      let isTiebreak = message["isTiebreak"] as? Bool,
      let isMatchOver = message["isMatchOver"] as? Bool,
      let setsData = message["sets"] as? [[String: Any]]
    else { return nil }
    
    let sets = setsData.map { dict -> SetScore in
      SetScore(
        playerGames: dict["playerGames"] as? Int ?? 0,
        opponentGames: dict["opponentGames"] as? Int ?? 0,
        isTiebreak: dict["isTiebreak"] as? Bool ?? false
      )
    }
    
    var winner: Team? = nil
    if let winnerStr = message["winner"] as? String {
      winner = winnerStr == "player" ? .player : .opponent
    }
    
    return MatchConfig(
      playerPoint: playerPoint,
      opponentPoint: opponentPoint,
      playerTiebreakPoints: playerTiebreakPoints,
      opponentTiebreakPoints: opponentTiebreakPoints,
      sets: sets,
      currentSetIndex: currentSetIndex,
      servePosition: servePosition,
      isDeuce: isDeuce,
      isTiebreak: isTiebreak,
      isMatchOver: isMatchOver,
      winner: winner
    )
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
