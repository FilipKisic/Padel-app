//
//  HistoryEntry.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 28.02.2026.
//

import Foundation

struct HistoryEntry: Equatable {
  let state: MatchState
  let remainingTime: TimeInterval
}
