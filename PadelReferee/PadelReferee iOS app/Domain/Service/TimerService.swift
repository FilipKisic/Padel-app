//
//  TimerService.swift
//  PadelReferee
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

class TimerService {
  
  func tick(remainingTime: inout TimeInterval) {
    if remainingTime > 0 {
      remainingTime -= 1
    }
  }
  
  func formattedTime(from remainingTime: TimeInterval) -> String {
    let minutes = Int(remainingTime) / 60
    let seconds = Int(remainingTime) % 60
    return String(format: "%02d:%02d:%02d", minutes / 60, minutes % 60, seconds)
  }
  
  func isTimeLow(remainingTime: TimeInterval) -> Bool {
    remainingTime <= 5 * 60 // 5 minutes or less
  }
}
