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
  private let iCloud = NSUbiquitousKeyValueStore.default
  private let local = UserDefaults.standard

  init() {
    // Sync iCloud store on launch so we have the latest remote value
    iCloud.synchronize()

    // Take the maximum of both stores — reinstalling the app can only reset
    // UserDefaults, never iCloud, so the higher value is always the truth.
    let localValue  = local.double(forKey: AppState.totalPlayedSecondsKey)
    let iCloudValue = iCloud.double(forKey: AppState.totalPlayedSecondsKey)
    totalPlayedSeconds = max(localValue, iCloudValue)

    // If the stores diverged, bring the lower one up to date
    if localValue < totalPlayedSeconds {
      local.set(totalPlayedSeconds, forKey: AppState.totalPlayedSecondsKey)
    }
    if iCloudValue < totalPlayedSeconds {
      iCloud.set(totalPlayedSeconds, forKey: AppState.totalPlayedSecondsKey)
      iCloud.synchronize()
    }

    // Listen for iCloud changes pushed from other devices
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(iCloudDidChange(_:)),
      name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: iCloud
    )
  }

  var hasExceededFreeLimit: Bool {
    return totalPlayedSeconds >= freeTimeLimit
  }

  func setMatchDuration(_ duration: TimeInterval) {
    matchDuration = duration
  }

  func setCompletedSession(_ session: Session) {
    completedSession = session
    totalPlayedSeconds += session.duration
    persist(totalPlayedSeconds)
  }

  func reset() {
    matchDuration = 0
    completedSession = nil
    isWatchSession = false
  }

  // MARK: - Private

  private func persist(_ value: Double) {
    local.set(value, forKey: AppState.totalPlayedSecondsKey)
    iCloud.set(value, forKey: AppState.totalPlayedSecondsKey)
    iCloud.synchronize()
  }

  @objc private func iCloudDidChange(_ notification: Notification) {
    let remoteValue = iCloud.double(forKey: AppState.totalPlayedSecondsKey)
    guard remoteValue > totalPlayedSeconds else { return }
    DispatchQueue.main.async {
      self.totalPlayedSeconds = remoteValue
      self.local.set(remoteValue, forKey: AppState.totalPlayedSecondsKey)
    }
  }
}
