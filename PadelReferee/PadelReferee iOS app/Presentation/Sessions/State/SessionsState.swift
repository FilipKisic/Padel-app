//
//  SessionsState.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

enum SessionsState: Equatable {
  case empty
  case history([SessionModel])
}
