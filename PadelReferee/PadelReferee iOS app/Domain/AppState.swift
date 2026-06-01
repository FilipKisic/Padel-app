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
  @Published var initialServePosition: ServePosition = .bottomRight
  @Published var completedSession: Session?
  @Published var isWatchSession: Bool = false
  @Published var isWaitingForHealthData: Bool = false

  private var healthDataTimeoutTimer: Timer?
  @Published private(set) var totalPlayedSeconds: Double

  let freeTimeLimit: TimeInterval = 15 //3 hours

  private static let totalPlayedSecondsKey = "totalPlayedSeconds"
  private let iCloud = NSUbiquitousKeyValueStore.default
  private let local = UserDefaults.standard

  init() {
    // Sync iCloud store on launch so we have the latest remote value
    iCloud.synchronize()

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

  func setInitialServePosition(_ position: ServePosition) {
    initialServePosition = position
  }

  func setCompletedSession(_ session: Session) {
    completedSession = session
    totalPlayedSeconds += session.duration
    persist(totalPlayedSeconds)
  }

  func startWaitingForHealthData() {
    isWaitingForHealthData = true
    healthDataTimeoutTimer?.invalidate()
    healthDataTimeoutTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
      DispatchQueue.main.async { self?.isWaitingForHealthData = false }
    }
  }

  func updateCompletedSessionHealthData(calories: Double, averageHeartRate: Double) {
    completedSession?.calories = calories
    completedSession?.averageHeartRate = averageHeartRate
    healthDataTimeoutTimer?.invalidate()
    healthDataTimeoutTimer = nil
    isWaitingForHealthData = false
  }

  func reset() {
    matchDuration = 0
    initialServePosition = .bottomRight
    completedSession = nil
    isWatchSession = false
    healthDataTimeoutTimer?.invalidate()
    healthDataTimeoutTimer = nil
    isWaitingForHealthData = false
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
