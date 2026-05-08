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
  @Published var completedSession: Session?
  @Published var isWatchSession: Bool = false
  @Published private(set) var totalPlayedSeconds: Double

  let freeTimeLimit: TimeInterval = 30 // 3 * 3600 = 3 hours

  private static let totalPlayedSecondsKey = "totalPlayedSeconds"

  init() {
    totalPlayedSeconds = UserDefaults.standard.double(forKey: AppState.totalPlayedSecondsKey)
  }

  var hasExceededFreeLimit: Bool {
    print("hasExceededFreeLimit: \(totalPlayedSeconds >= freeTimeLimit)")
    return totalPlayedSeconds >= freeTimeLimit
  }

  func setMatchDuration(_ duration: TimeInterval) {
    matchDuration = duration
  }

  func setCompletedSession(_ session: Session) {
    completedSession = session
    totalPlayedSeconds += session.duration
    UserDefaults.standard.set(totalPlayedSeconds, forKey: AppState.totalPlayedSecondsKey)
  }

  func reset() {
    matchDuration = 0
    completedSession = nil
    isWatchSession = false
  }
}
