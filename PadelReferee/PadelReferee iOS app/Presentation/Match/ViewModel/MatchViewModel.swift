//
//  MatchViewModel.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation
import Combine

class MatchViewModel: ObservableObject {
  @Published var matchState = MatchScreenState()
  
  private(set) var match: Match
  private let gameService: MatchGameService
  private let timerService: TimerService
  private let connectivity = PhoneConnectivityManager.shared
  private var connectivityCancellable: AnyCancellable?
  private var timerStateCancellable: AnyCancellable?
  private var hasNotifiedSessionStart = false
  
  init(gameService: MatchGameService = MatchGameService(), timerService: TimerService = TimerService()) {
    self.match = Match(durationMinutes: 90)
    self.gameService = gameService
    self.timerService = timerService
    
    self.timerService.onTick = { [weak self] in
      guard let self = self else { return }
      self.timerService.tick(remainingTime: &self.match.remainingTime)
      self.matchState.elapsedTime = self.timerService.elapsedTime
    }
    
    // Subscribe to incoming score updates from Watch
    setupConnectivitySubscription()
  }
  
  private func setupConnectivitySubscription() {
    connectivityCancellable = connectivity.$receivedMatchConfig
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newConfig in
        guard let self = self else { return }
        self.match.config = newConfig
        self.match.history.removeAll()
        self.objectWillChange.send()
        
        if newConfig.isMatchOver {
          self.finishMatch()
        }
      }
    
    timerStateCancellable = connectivity.$receivedIsRunning
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isRunning in
        self?.applyTimerState(isRunning: isRunning)
      }
  }
  
  func setDuration(_ duration: TimeInterval) {
    self.match = Match(durationMinutes: Int(duration / 60))
    self.matchState = MatchScreenState()
    self.timerService.reset()
    self.hasNotifiedSessionStart = false
    // Re-subscribe since match object changed
    setupConnectivitySubscription()
  }
  
  // MARK: - Play / Pause
  func togglePlayPause() {
    switch matchState.phase {
      case .playing:
        pause()
      case .paused:
        play()
      case .finished:
        break
    }
  }
  
  func play() {
    matchState.phase = .playing
    timerService.start()

    if !hasNotifiedSessionStart {
      hasNotifiedSessionStart = true
      let durationMinutes = Int(match.totalDuration / 60)
      connectivity.sendSessionStarted(durationMinutes: durationMinutes)
    } else {
      connectivity.sendTimerState(isRunning: true)
    }
  }
  
  func pause() {
    matchState.phase = .paused
    timerService.stop()
    connectivity.sendTimerState(isRunning: false)
  }
  
  private func applyTimerState(isRunning: Bool) {
    if isRunning {
      matchState.phase = .playing
      timerService.start()
    } else {
      matchState.phase = .paused
      timerService.stop()
    }
  }
  
  // MARK: - Scoring
  func scorePoint(for team: Team) {
    guard matchState.phase == .playing else { return }
    gameService.saveHistory(history: &match.history, state: match.config, remainingTime: match.remainingTime)
    gameService.scorePoint(config: &match.config, for: team)
    objectWillChange.send()
    
    // Send updated state to Watch
    connectivity.sendMatchState(match.config)
    
    if match.config.isMatchOver {
      finishMatch()
    }
  }
  
  func undo() {
    gameService.undo(history: &match.history, state: &match.config, remainingTime: &match.remainingTime)
    objectWillChange.send()
    
    // Send updated state to Watch after undo
    connectivity.sendMatchState(match.config)
  }
  
  // MARK: - Cancel
  func cancel() {
    matchState.showCancelAlert = true
  }
  
  // MARK: - Private
  private func finishMatch() {
    matchState.phase = .finished
    timerService.stop()
  }
  
  // MARK: - Display Helpers
  var formattedRemainingTime: String {
    timerService.formattedTime(from: match.remainingTime)
  }
  
  var progressPercentage: Double {
    timerService.progressPercentage(elapsed: matchState.elapsedTime, total: match.totalDuration)
  }
  
  func displayScore(for team: Team) -> String {
    gameService.displayScore(for: team, in: match.config)
  }
  
  func gamesInSet(_ setIndex: Int, for team: Team) -> Int {
    gameService.gamesInSet(setIndex, for: team, in: match.config)
  }
  
  deinit {
    timerService.stop()
  }
}
