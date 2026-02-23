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
    send(["type": "sessionStarted", "durationMinutes": durationMinutes])
  }
  
  // MARK: - Send match state to iOS
  func sendMatchState(_ state: MatchState, elapsedTime: TimeInterval) {
    var message: [String: Any] = [
      "type": "scoreUpdate",
      "playerPoint": state.playerPoint.rawValue,
      "opponentPoint": state.opponentPoint.rawValue,
      "playerTiebreakPoints": state.playerTiebreakPoints,
      "opponentTiebreakPoints": state.opponentTiebreakPoints,
      "currentSetIndex": state.currentSetIndex,
      "servePosition": state.servePosition.rawValue,
      "isDeuce": state.isDeuce,
      "isTiebreak": state.isTiebreak,
      "isMatchOver": state.isMatchOver,
      "elapsedTime": elapsedTime
    ]
    
    let setsData = state.sets.map { set -> [String: Any] in
      ["playerGames": set.playerGames, "opponentGames": set.opponentGames, "isTiebreak": set.isTiebreak]
    }
    message["sets"] = setsData
    
    if let winner = state.winner {
      message["winner"] = winner == .player ? "player" : "opponent"
    }
    
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
    guard let type = message["type"] as? String else { return }
    
    switch type {
    case "scoreUpdate":
      if let matchState = Self.decodeMatchState(from: message) {
        Task { @MainActor in
          self.receivedMatchState = matchState
        }
      }
    default:
      break
    }
  }
  
  // MARK: - Decoding
  static func decodeMatchState(from message: [String: Any]) -> MatchState? {
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
      var set = SetScore()
      set.playerGames = dict["playerGames"] as? Int ?? 0
      set.opponentGames = dict["opponentGames"] as? Int ?? 0
      set.isTiebreak = dict["isTiebreak"] as? Bool ?? false
      return set
    }
    
    var winner: Team? = nil
    if let winnerStr = message["winner"] as? String {
      winner = winnerStr == "player" ? .player : .opponent
    }
    
    return MatchState(
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
