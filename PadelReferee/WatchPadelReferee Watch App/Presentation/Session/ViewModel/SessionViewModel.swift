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
  @Published var screenState = SessionScreenState()

  private(set) var match: Match

  private let gameService: MatchGameService
  private let timerService: TimerService

  private var connectivityCancellable: AnyCancellable?
  private var timerStateCancellable: AnyCancellable?
  private let connectivity = WatchConnectivityManager.shared
  private var hasNotifiedSessionStart = false

  // MARK: - INIT
  init(
    durationMinutes: Int = 90,
    gameService: MatchGameService = MatchGameService(),
    timerService: TimerService = TimerService()
  ) {
    self.match = Match(durationMinutes: durationMinutes)
    self.gameService = gameService
    self.timerService = timerService

    self.timerService.onTick = { [weak self] in
      guard let self = self else { return }
      self.timerService.tick(remainingTime: &self.match.remainingTime)
      self.objectWillChange.send()
    }

    setupConnectivitySubscriptions()
  }

  private func setupConnectivitySubscriptions() {
    connectivityCancellable = connectivity.$receivedMatchState
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newState in
        guard let self = self else { return }
        self.match.state = newState
        self.match.history.removeAll()
        self.objectWillChange.send()

        if newState.isMatchOver {
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

  // MARK: - DURATION
  func setDuration(minutes: Int) {
    match = Match(durationMinutes: minutes)
    screenState = SessionScreenState()
    timerService.reset()
  }

  // MARK: - TIMER
  func startTimer(notifyPeer: Bool = true) {
    guard screenState.phase != .playing else { return }
    screenState.phase = .playing

    if notifyPeer {
      if !hasNotifiedSessionStart {
        hasNotifiedSessionStart = true
        let durationMinutes = Int(match.totalDuration / 60)
        connectivity.sendSessionStarted(durationMinutes: durationMinutes)
      } else {
        connectivity.sendTimerState(isRunning: true)
      }
    } else {
      hasNotifiedSessionStart = true
    }

    timerService.start()
  }

  func stopTimer() {
    screenState.phase = .paused
    timerService.stop()
    connectivity.sendTimerState(isRunning: false)
  }

  func toggleTimer() {
    switch screenState.phase {
      case .playing: stopTimer()
      case .paused: startTimer()
      case .finished: break
    }
  }

  private func applyTimerState(isRunning: Bool) {
    if isRunning {
      guard screenState.phase != .playing else { return }
      screenState.phase = .playing
      timerService.start()
    } else {
      screenState.phase = .paused
      timerService.stop()
    }
  }

  private func finishMatch() {
    screenState.phase = .finished
    timerService.stop()
  }

  // MARK: - SCORING
  func scorePoint(for team: Team) {
    gameService.saveHistory(history: &match.history, state: match.state, remainingTime: match.remainingTime)
    gameService.scorePoint(state: &match.state, for: team)
    objectWillChange.send()
    connectivity.sendMatchState(match.state)

    if match.state.isMatchOver {
      finishMatch()
    }
  }

  func undo() {
    gameService.undo(history: &match.history, state: &match.state, remainingTime: &match.remainingTime)
    objectWillChange.send()
    connectivity.sendMatchState(match.state)
  }

  func restartMatch() {
    stopTimer()
    match = Match(durationMinutes: 90)
    screenState = SessionScreenState()
    timerService.reset()

    hasNotifiedSessionStart = true
    connectivity.sendSessionStarted(durationMinutes: 90)

    setupConnectivitySubscriptions()
    startTimer()
  }

  // MARK: - DISPLAY
  var playerScore: String {
    gameService.displayScore(for: .player, in: match.state)
  }

  var opponentScore: String {
    gameService.displayScore(for: .opponent, in: match.state)
  }

  var formattedTime: String {
    timerService.formattedTime(from: match.remainingTime)
  }

  var isTimeLow: Bool {
    timerService.isTimeLow(remainingTime: match.remainingTime)
  }

  var canUndo: Bool {
    gameService.canUndo(history: match.history)
  }

  var isMatchOver: Bool {
    match.state.isMatchOver
  }

  var winner: Team? {
    match.state.winner
  }

  var currentServePosition: ServePosition {
    match.state.servePosition
  }

  func playerGames(inSet setIndex: Int) -> Int {
    gameService.gamesInSet(setIndex, for: .player, in: match.state)
  }

  func opponentGames(inSet setIndex: Int) -> Int {
    gameService.gamesInSet(setIndex, for: .opponent, in: match.state)
  }

  var currentSetIndex: Int {
    match.state.currentSetIndex
  }

  var playerSetsWon: Int {
    match.state.playerSetsWon
  }

  var opponentSetsWon: Int {
    match.state.opponentSetsWon
  }

  // MARK: - CLEANUP
  deinit {
    timerService.stop()
  }
}
