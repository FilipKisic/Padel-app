//
//  Match.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 15.01.2026.
//

import Foundation

class Match {
  var state: MatchState
  var history: [HistoryEntry]
  var remainingTime: TimeInterval

  let totalDuration: TimeInterval

  init(durationMinutes: Int = 90) {
    self.totalDuration = TimeInterval(durationMinutes * 60)
    self.remainingTime = self.totalDuration
    self.state = MatchState()
    self.history = []
  }
}

