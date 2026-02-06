//
//  NewSessionState.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

enum NewSessionState: Equatable {
  case idle
  case ready(duration: TimeInterval)
}
