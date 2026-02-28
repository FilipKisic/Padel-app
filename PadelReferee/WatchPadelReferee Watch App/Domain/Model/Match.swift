//
//  Match.swift
//  PadelReferee
//
//  Created by Filip Kisić on 15.01.2026.
//

import Foundation

// MARK: - POINT
enum Point: String, CaseIterable {
  case zero = "0"
  case fifteen = "15"
  case thirty = "30"
  case forty = "40"
  case advantage = "AD"
}

// MARK: - TEAM
enum Team: Equatable {
  case player
  case opponent
}

// MARK: - SERVE POSITION
enum ServePosition: Int, CaseIterable {
  case topLeft = 0
  case topRight = 1
  case bottomLeft = 2
  case bottomRight = 3
}

// MARK: - SET SCORE
struct SetScore: Equatable {
  var playerGames: Int = 0
  var opponentGames: Int = 0
  var isTiebreak: Bool = false
}

// MARK: - MATCH STATE
struct MatchState: Equatable {
  var playerPoint: Point = .zero
  var opponentPoint: Point = .zero
  var playerTiebreakPoints: Int = 0
  var opponentTiebreakPoints: Int = 0
  var sets: [SetScore] = [SetScore()]
  var currentSetIndex: Int = 0
  var servePosition: ServePosition = .topLeft
  var isDeuce: Bool = false
  var isTiebreak: Bool = false
  var isMatchOver: Bool = false
  var winner: Team? = nil
  
  var currentSet: SetScore {
    get { sets[currentSetIndex] }
    set { sets[currentSetIndex] = newValue }
  }
  
  var playerSetsWon: Int {
    sets.filter { s in
      s.isTiebreak
        ? s.playerGames > s.opponentGames && s.playerGames >= 7 && (s.playerGames - s.opponentGames) >= 2
        : s.playerGames >= 6 && s.playerGames - s.opponentGames >= 2
    }.count
  }

  var opponentSetsWon: Int {
    sets.filter { s in
      s.isTiebreak
        ? s.opponentGames > s.playerGames && s.opponentGames >= 7 && (s.opponentGames - s.playerGames) >= 2
        : s.opponentGames >= 6 && s.opponentGames - s.playerGames >= 2
    }.count
  }
}

// MARK: - HISTORY ENTRY
struct HistoryEntry: Equatable {
  let state: MatchState
  let remainingTime: TimeInterval
}

