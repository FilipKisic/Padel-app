//
//  SummaryViewModel.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation
import Combine

class SummaryViewModel: ObservableObject {
  @Published var state: SummaryState = .showing
  
  @Published var winner: Team = .player
  @Published var elapsedTime: TimeInterval = 0
  @Published var sets: [SetScore] = []
  
  func loadSession(_ session: Session) {
    self.winner = session.winner
    self.elapsedTime = session.duration
    self.sets = session.sets
  }
  
  var formattedElapsedTime: String {
    let hours = Int(elapsedTime) / 3600
    let minutes = (Int(elapsedTime) % 3600) / 60
    let seconds = Int(elapsedTime) % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
  }
  
  var winnerText: String {
    winner == .player ? "You Won!" : "Opponent Won!"
  }
}
