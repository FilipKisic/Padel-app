//
//  SetScoreData.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 16.03.2026.
//

import Foundation
import SwiftData

@Model
class SetScoreData {
  var order: Int = 0
  var playerGames: Int = 0
  var opponentGames: Int = 0
  var isTiebreak: Bool = false
  var session: Session?
  
  init(order: Int = 0, playerGames: Int = 0, opponentGames: Int = 0, isTiebreak: Bool = false) {
    self.order = order
    self.playerGames = playerGames
    self.opponentGames = opponentGames
    self.isTiebreak = isTiebreak
  }
}
