//
//  MatchViewModel.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation
import Combine

class MatchViewModel: ObservableObject {
  private(set) var match: Match
  @Published var state: MatchScreenState = .paused
  @Published var elapsedTime: TimeInterval = 0
  @Published var showCancelAlert: Bool = false
  @Published private var refreshTrigger: Bool = false
  
  private var timer: Timer?
  private let gameService: MatchGameService
  private let timerService: TimerService
  
  init(duration: TimeInterval, gameService: MatchGameService = MatchGameService(), timerService: TimerService = TimerService()) {
    self.match = Match(durationMinutes: Int(duration / 60))
    self.gameService = gameService
    self.timerService = timerService
  }
  
  func togglePlayPause() {
    switch state {
      case .playing:
        pause()
      case .paused:
        play()
      case .finished:
        break
    }
  }
  
  func play() {
    state = .playing
    startTimer()
  }
  
  func pause() {
    state = .paused
    stopTimer()
  }
  
  func scorePoint(for team: Team) {
    guard state == .playing else { return }
    gameService.saveHistory(history: &match.history, state: match.state, remainingTime: match.remainingTime)
    gameService.scorePoint(state: &match.state, for: team)
    refresh()
    
    if match.state.isMatchOver {
      finishMatch()
    }
  }
  
  func undo() {
    gameService.undo(history: &match.history, state: &match.state, remainingTime: &match.remainingTime)
    refresh()
  }
  
  func cancel() {
    showCancelAlert = true
  }
  
  private func finishMatch() {
    state = .finished
    stopTimer()
  }
  
  private func startTimer() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      self.elapsedTime += 1
      self.timerService.tick(remainingTime: &self.match.remainingTime)
      self.refresh()
    }
  }
  
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func refresh() {
    refreshTrigger.toggle()
  }
  
  var formattedElapsedTime: String {
    timerService.formattedTime(from: elapsedTime)
  }
  
  var progressPercentage: Double {
    guard match.totalDuration > 0 else { return 0 }
    return min(elapsedTime / match.totalDuration, 1.0)
  }
  
  // MARK: - Display Helpers
  func displayScore(for team: Team) -> String {
    gameService.displayScore(for: team, in: match.state)
  }
  
  func gamesInSet(_ setIndex: Int, for team: Team) -> Int {
    gameService.gamesInSet(setIndex, for: team, in: match.state)
  }
  
  deinit {
    stopTimer()
  }
}
