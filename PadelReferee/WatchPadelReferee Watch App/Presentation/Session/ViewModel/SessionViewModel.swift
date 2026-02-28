//
//  SessionViewModel.swift
//  PadelReferee
//
//  Created by Filip Kisić on 15.01.2026..
//

import Foundation
import Combine

class SessionViewModel: ObservableObject {
  // MARK: - PROPERTIES
  @Published var state: MatchState = MatchState()
  @Published var remainingTime: TimeInterval = 0
  @Published var isRunning: Bool = false

  private var totalDuration: TimeInterval = 0
  private var history: [HistoryEntry] = []

  private let gameService = MatchGameService()
  private let timerService = TimerService()

  private var connectivityCancellable: AnyCancellable?
  private var timerStateCancellable: AnyCancellable?
  private let connectivity = WatchConnectivityManager.shared
  private var hasNotifiedSessionStart = false

  // MARK: - INIT
  init(durationMinutes: Int = 90) {
    self.totalDuration = TimeInterval(durationMinutes * 60)
    self.remainingTime = self.totalDuration

    timerService.onTick = { [weak self] in
      guard let self = self else { return }
      if self.remainingTime > 0 {
        self.remainingTime -= 1
      }
    }

    // Subscribe to incoming score updates from iOS
    connectivityCancellable = connectivity.$receivedMatchState
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newState in
        self?.state = newState
      }

    // Subscribe to incoming timer state from iOS
    timerStateCancellable = connectivity.$receivedIsRunning
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isRunning in
        self?.applyTimerState(isRunning: isRunning)
      }
  }

  // MARK: - TIMER
  func startTimer() {
    guard !isRunning else { return }
    isRunning = true

    // Notify iOS that session started (only once)
    if !hasNotifiedSessionStart {
      hasNotifiedSessionStart = true
      let durationMinutes = Int(totalDuration / 60)
      connectivity.sendSessionStarted(durationMinutes: durationMinutes)
    } else {
      connectivity.sendTimerState(isRunning: true)
    }

    timerService.start()
  }

  func stopTimer() {
    isRunning = false
    timerService.stop()
    connectivity.sendTimerState(isRunning: false)
  }

  func toggleTimer() {
    if isRunning {
      stopTimer()
    } else {
      startTimer()
    }
  }

  private func applyTimerState(isRunning: Bool) {
    if isRunning {
      guard !self.isRunning else { return }
      self.isRunning = true
      timerService.start()
    } else {
      self.isRunning = false
      timerService.stop()
    }
  }

  // MARK: - SCORING
  func scorePoint(for team: Team) {
    gameService.saveHistory(history: &history, state: state, remainingTime: remainingTime)
    gameService.scorePoint(state: &state, for: team)
    connectivity.sendMatchState(state)
  }

  func undo() {
    guard let lastEntry = history.popLast() else { return }
    state = lastEntry.state
    remainingTime = lastEntry.remainingTime
    connectivity.sendMatchState(state)
  }

  func setDuration(minutes: Int) {
    totalDuration = TimeInterval(minutes * 60)
    remainingTime = totalDuration
    state = MatchState()
    history = []
    timerService.reset()
  }

  func restartMatch() {
    stopTimer()
    totalDuration = TimeInterval(90 * 60)
    remainingTime = totalDuration
    state = MatchState()
    history = []
    timerService.reset()

    // Notify iOS of restart
    hasNotifiedSessionStart = true
    connectivity.sendSessionStarted(durationMinutes: 90)

    startTimer()
  }

  // MARK: - DISPLAY
  var playerScore: String {
    gameService.displayScore(for: .player, in: state)
  }

  var opponentScore: String {
    gameService.displayScore(for: .opponent, in: state)
  }

  var formattedTime: String {
    timerService.formattedTime(from: remainingTime)
  }

  var isTimeLow: Bool {
    timerService.isTimeLow(remainingTime: remainingTime)
  }

  var canUndo: Bool {
    gameService.canUndo(history: history)
  }

  var isMatchOver: Bool {
    state.isMatchOver
  }

  var winner: Team? {
    state.winner
  }

  var currentServePosition: ServePosition {
    state.servePosition
  }

  func playerGames(inSet setIndex: Int) -> Int {
    gameService.gamesInSet(setIndex, for: .player, in: state)
  }

  func opponentGames(inSet setIndex: Int) -> Int {
    gameService.gamesInSet(setIndex, for: .opponent, in: state)
  }

  var currentSetIndex: Int {
    state.currentSetIndex
  }

  var playerSetsWon: Int {
    state.playerSetsWon
  }

  var opponentSetsWon: Int {
    state.opponentSetsWon
  }

  // MARK: - CLEANUP
  deinit {
    stopTimer()
  }
}

  
