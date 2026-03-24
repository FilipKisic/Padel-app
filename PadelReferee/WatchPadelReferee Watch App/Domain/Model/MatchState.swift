//
//  MatchState.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 28.02.2026.
//

import Foundation

struct MatchState: Equatable {
  var playerPoint: Point = .zero
  var opponentPoint: Point = .zero
  var playerTiebreakPoints: Int = 0
  var opponentTiebreakPoints: Int = 0
  var sets: [SetScore] = [SetScore()]
  var currentSetIndex: Int = 0
  var servePosition: ServePosition = .bottomRight
  var servingPlayerIndex: Int = 0
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
