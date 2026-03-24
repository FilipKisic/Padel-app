//
//  MatchState.swift
//  PadelReferee
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

struct MatchConfig: Equatable {
  var playerPoint: Point
  var opponentPoint: Point
  var playerTiebreakPoints: Int
  var opponentTiebreakPoints: Int
  var sets: [SetScore]
  var currentSetIndex: Int
  var servePosition: ServePosition
  var servingPlayerIndex: Int
  var isDeuce: Bool
  var isTiebreak: Bool
  var isMatchOver: Bool
  var winner: Team?
  
  init(
    playerPoint: Point = .zero,
    opponentPoint: Point = .zero,
    playerTiebreakPoints: Int = 0,
    opponentTiebreakPoints: Int = 0,
    sets: [SetScore] = [SetScore()],
    currentSetIndex: Int = 0,
    servePosition: ServePosition = .bottomRight,
    servingPlayerIndex: Int = 0,
    isDeuce: Bool = false,
    isTiebreak: Bool = false,
    isMatchOver: Bool = false,
    winner: Team? = nil
  ) {
    self.playerPoint = playerPoint
    self.opponentPoint = opponentPoint
    self.playerTiebreakPoints = playerTiebreakPoints
    self.opponentTiebreakPoints = opponentTiebreakPoints
    self.sets = sets
    self.currentSetIndex = currentSetIndex
    self.servePosition = servePosition
    self.servingPlayerIndex = servingPlayerIndex
    self.isDeuce = isDeuce
    self.isTiebreak = isTiebreak
    self.isMatchOver = isMatchOver
    self.winner = winner
  }
  
  var currentSet: SetScore {
    get { sets[currentSetIndex] }
    set { sets[currentSetIndex] = newValue }
  }
}
