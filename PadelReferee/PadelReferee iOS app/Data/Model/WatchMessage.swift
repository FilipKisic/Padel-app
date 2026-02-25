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
  private var isDeuce: Bool?
  private var isTiebreak: Bool?
  private var isMatchOver: Bool?
  private var winner: String?
  private var elapsedTime: TimeInterval?
  private var durationMinutes: Int?
  
  static func build() -> WatchMessage {
    return WatchMessage()
  }
  
  func withType(_ type: WatchMessageType) -> WatchMessage {
    self.type = type
    return self
  }
  
  func withConfig(_ config: MatchConfig) -> WatchMessage {
    self.playerPoint = config.playerPoint.rawValue
    self.opponentPoint = config.opponentPoint.rawValue
    self.playerTiebreakPoints = config.playerTiebreakPoints
    self.opponentTiebreakPoints = config.opponentTiebreakPoints
    self.currentSetIndex = config.currentSetIndex
    self.servePosition = config.servePosition.rawValue
    self.isDeuce = config.isDeuce
    self.isTiebreak = config.isTiebreak
    self.isMatchOver = config.isMatchOver
    
    self.sets = config.sets.map { set -> [String: Any] in
      ["playerGames": set.playerGames, "opponentGames": set.opponentGames, "isTiebreak": set.isTiebreak]
    }
    
    if let winner = config.winner {
      self.winner = winner == .player ? "player" : "opponent"
    }
    
    return self
  }
  
  func withElapsedTime(_ time: TimeInterval) -> WatchMessage {
    self.elapsedTime = time
    return self
  }
  
  func withDurationMinutes(_ minutes: Int) -> WatchMessage {
    self.durationMinutes = minutes
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
    if let isDeuce { message["isDeuce"] = isDeuce }
    if let isTiebreak { message["isTiebreak"] = isTiebreak }
    if let isMatchOver { message["isMatchOver"] = isMatchOver }
    if let winner { message["winner"] = winner }
    if let sets { message["sets"] = sets }
    if let elapsedTime { message["elapsedTime"] = elapsedTime }
    if let durationMinutes { message["durationMinutes"] = durationMinutes }
    
    return message
  }
  
  // MARK: - Deserialization
  static func messageType(from message: [String: Any]) -> WatchMessageType? {
    guard let typeStr = message["type"] as? String else { return nil }
    return WatchMessageType(rawValue: typeStr)
  }
  
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
  
  static func decodeDurationMinutes(from message: [String: Any]) -> Int {
    message["durationMinutes"] as? Int ?? 90
  }
  
  static func decodeElapsedTime(from message: [String: Any]) -> TimeInterval {
    message["elapsedTime"] as? Double ?? 0
  }
}

enum WatchMessageType: String {
  case scoreUpdate
  case sessionStarted
}
