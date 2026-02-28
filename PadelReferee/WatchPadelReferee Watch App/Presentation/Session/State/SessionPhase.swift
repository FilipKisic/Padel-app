//
//  SessionPhase.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 28.02.2026.
//

import Foundation

enum SessionPhase: Equatable {
  case playing
  case paused
  case finished
}

struct SessionScreenState: Equatable {
  var phase: SessionPhase = .paused
  var showCancelAlert: Bool = false
}
