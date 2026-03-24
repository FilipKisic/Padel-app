//
//  WatchMessage.swift
//  PadelReferee
//
//  Created by Filip Kisić on 23.02.2026..
//
import Foundation

class WatchMessage {
  private var type: WatchMessageType?
  private var playerPoint: String?
  private var opponentPoint: String?
  private var playerTiebreakPoints: Int?
  private var opponentTiebreakPoints: Int?
  private var sets: [[String : Any]]?
  private var currentSetIndex: Int?
  private var servePosition: Int?
  private var servingPlayerIndex: Int?
  private var isDeuce: Bool?
  private var isTiebreak: Bool?
  private var isMatchOver: Bool?
  private var winner: String?
  private var durationMinutes: Int?
  private var isRunning: Bool?
  
  static func build() -> WatchMessage {
    return WatchMessage()
  }
  
  func withType(_ type: WatchMessageType) -> WatchMessage {
    self.type = type
    return self
  }
  
  func withState(_ state: MatchState) -> WatchMessage {
    self.playerPoint = state.playerPoint.rawValue
    self.opponentPoint = state.opponentPoint.rawValue
    self.playerTiebreakPoints = state.playerTiebreakPoints
    self.opponentTiebreakPoints = state.opponentTiebreakPoints
    self.currentSetIndex = state.currentSetIndex
    self.servePosition = state.servePosition.rawValue
    self.servingPlayerIndex = state.servingPlayerIndex
    self.isDeuce = state.isDeuce
    self.isTiebreak = state.isTiebreak
    self.isMatchOver = state.isMatchOver
    
    self.sets = state.sets.map { set -> [String: Any] in
      ["playerGames": set.playerGames, "opponentGames": set.opponentGames, "isTiebreak": set.isTiebreak]
    }
    
    if let winner = state.winner {
      self.winner = winner == .player ? "player" : "opponent"
    }
    
    return self
  }
  
  func withDurationMinutes(_ minutes: Int) -> WatchMessage {
    self.durationMinutes = minutes
    return self
  }
  
  func withIsRunning(_ running: Bool) -> WatchMessage {
    self.isRunning = running
    return self
  }
  
  func serialize() -> [String: Any] {
    var message: [String: Any] = [
      "type": type?.rawValue ?? WatchMessageType.scoreUpdate.rawValue
    ]
    
    if let playerPoint { message["playerPoint"] = playerPoint }
    if let opponentPoint { message["opponentPoint"] = opponentPoint }
    if let playerTiebreakPoints { message["playerTiebreakPoints"] = playerTiebreakPoints }
    if let opponentTiebreakPoints { message["opponentTiebreakPoints"] = opponentTiebreakPoints }
    if let currentSetIndex { message["currentSetIndex"] = currentSetIndex }
    if let servePosition { message["servePosition"] = servePosition }
    if let servingPlayerIndex { message["servingPlayerIndex"] = servingPlayerIndex }
    if let isDeuce { message["isDeuce"] = isDeuce }
    if let isTiebreak { message["isTiebreak"] = isTiebreak }
    if let isMatchOver { message["isMatchOver"] = isMatchOver }
    if let winner { message["winner"] = winner }
    if let sets { message["sets"] = sets }
    if let durationMinutes { message["durationMinutes"] = durationMinutes }
    if let isRunning { message["isRunning"] = isRunning }
    
    return message
  }
  
  // MARK: - Deserialization
  static func messageType(from message: [String: Any]) -> WatchMessageType? {
    guard let typeStr = message["type"] as? String else { return nil }
    return WatchMessageType(rawValue: typeStr)
  }
  
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
      let servingPlayerIndex = message["servingPlayerIndex"] as? Int,
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
      servingPlayerIndex: servingPlayerIndex,
      isDeuce: isDeuce,
      isTiebreak: isTiebreak,
      isMatchOver: isMatchOver,
      winner: winner
    )
  }
  
  static func decodeIsRunning(from message: [String: Any]) -> Bool? {
    return message["isRunning"] as? Bool
  }
  
  static func decodeDurationMinutes(from message: [String: Any]) -> Int {
    message["durationMinutes"] as? Int ?? 90
  }
  
}

enum WatchMessageType: String {
  case scoreUpdate
  case sessionStarted
  case timerUpdate
  case sessionEnded
}
