//
//  TimerService.swift
//  PadelReferee
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

class TimerService {
  private var timer: Timer?
  private(set) var elapsedTime: TimeInterval = 0
  
  var onTick: (() -> Void)?
  
  func start() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      self.elapsedTime += 1
      self.onTick?()
    }
  }
  
  func stop() {
    timer?.invalidate()
    timer = nil
  }
  
  func reset() {
    stop()
    elapsedTime = 0
  }
  
  func tick(remainingTime: inout TimeInterval) {
    if remainingTime > 0 {
      remainingTime -= 1
    }
  }
  
  func formattedTime(from time: TimeInterval) -> String {
    let totalSeconds = Int(time)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    let seconds = totalSeconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }
  
  func progressPercentage(elapsed: TimeInterval, total: TimeInterval) -> Double {
    guard total > 0 else { return 0 }
    return min(elapsed / total, 1.0)
  }
  
  func isTimeLow(remainingTime: TimeInterval) -> Bool {
    remainingTime <= 5 * 60 // 5 minutes or less
  }
  
  deinit {
    stop()
  }
}
