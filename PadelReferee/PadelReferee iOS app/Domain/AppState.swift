//
//  AppState.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 06.02.2026.
//

import Foundation
import Combine

class AppState: ObservableObject {
  @Published var matchDuration: TimeInterval = 0
  @Published var completedSession: SessionModel?
  
  func setMatchDuration(_ duration: TimeInterval) {
    matchDuration = duration
  }
  
  func setCompletedSession(_ session: SessionModel) {
    completedSession = session
  }
  
  func reset() {
    matchDuration = 0
    completedSession = nil
  }
}
