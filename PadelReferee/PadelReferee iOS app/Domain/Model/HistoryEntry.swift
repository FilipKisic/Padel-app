//
//  HistoryEntry.swift
//  PadelReferee
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

struct HistoryEntry: Equatable {
  let state: MatchState
  let remainingTime: TimeInterval
}
