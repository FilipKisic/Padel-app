//
//  NewSessionState.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

enum NewSessionPhase: Equatable {
  case idle
  case ready(duration: TimeInterval)
}

struct NewSessionState: Equatable {
  var phase: NewSessionPhase = .idle
  var hours: Int = 1
  var minutes: Int = 30
  var seconds: Int = 0
}
