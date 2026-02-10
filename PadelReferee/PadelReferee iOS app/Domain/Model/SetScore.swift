//
//  SetScore.swift
//  PadelReferee
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

struct SetScore: Equatable, Codable, Hashable {
  var playerGames: Int
  var opponentGames: Int
  var isTiebreak: Bool
  
  init(playerGames: Int = 0, opponentGames: Int = 0, isTiebreak: Bool = false) {
    self.playerGames = playerGames
    self.opponentGames = opponentGames
    self.isTiebreak = isTiebreak
  }
}
