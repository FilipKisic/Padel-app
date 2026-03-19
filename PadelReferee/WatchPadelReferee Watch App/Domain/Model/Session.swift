//
//  Session.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 16.03.2026.
//

import Foundation
import SwiftData

@Model
class Session {
  var id: UUID = UUID()
  var date: Date = Date()
  var duration: TimeInterval = 0
  var winnerRaw: String?
  @Relationship(deleteRule: .cascade, inverse: \SetScoreData.session) var setScores: [SetScoreData]?
  var calories: Double = 0
  var averageHeartRate: Double = 0
  
  var winner: Team? {
    get {
      guard let raw = winnerRaw else { return nil }
      return raw == "player" ? .player : .opponent
    }
    set {
      switch newValue {
      case .player: winnerRaw = "player"
      case .opponent: winnerRaw = "opponent"
      case nil: winnerRaw = nil
      }
    }
  }
  
  var isCompleted: Bool { winner != nil }
  
  var sets: [SetScore] {
    (setScores ?? [])
      .sorted { $0.order < $1.order }
      .map { SetScore(playerGames: $0.playerGames, opponentGames: $0.opponentGames, isTiebreak: $0.isTiebreak) }
  }
  
  init(
    id: UUID = UUID(),
    date: Date = Date(),
    duration: TimeInterval = 0,
    winner: Team? = nil,
    sets: [SetScore] = [],
    calories: Double = 0,
    averageHeartRate: Double = 0
  ) {
    self.id = id
    self.date = date
    self.duration = duration
    self.calories = calories
    self.averageHeartRate = averageHeartRate
    self.setScores = sets.enumerated().map { index, set in
      SetScoreData(order: index, playerGames: set.playerGames, opponentGames: set.opponentGames, isTiebreak: set.isTiebreak)
    }
    switch winner {
    case .player: self.winnerRaw = "player"
    case .opponent: self.winnerRaw = "opponent"
    case nil: self.winnerRaw = nil
    }
  }
  
  var formattedDuration: String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    let seconds = Int(duration) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }
  
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
