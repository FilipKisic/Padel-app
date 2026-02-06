//
//  SessionModel.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

struct SessionModel: Identifiable, Codable, Equatable {
  let id: UUID
  let date: Date
  let duration: TimeInterval
  let winner: Team
  let sets: [SetScore]
  
  init(id: UUID = UUID(), date: Date, duration: TimeInterval, winner: Team, sets: [SetScore]) {
    self.id = id
    self.date = date
    self.duration = duration
    self.winner = winner
    self.sets = sets
  }
  
  var formattedDuration: String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    let seconds = Int(duration) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }
  
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
}
