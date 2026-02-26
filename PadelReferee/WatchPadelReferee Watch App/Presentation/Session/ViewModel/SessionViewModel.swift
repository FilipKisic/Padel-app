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
  @Published var match: Match
  @Published var isRunning: Bool = false
  
  private var timerCancellable: AnyCancellable?
  private var matchCancellable: AnyCancellable?
  private var connectivityCancellable: AnyCancellable?
  private var timerStateCancellable: AnyCancellable?
  private let connectivity = WatchConnectivityManager.shared
  private var hasNotifiedSessionStart = false
  
  // MARK: - INIT
  init(durationMinutes: Int = 90) {
    self.match = Match(durationMinutes: durationMinutes)
    
    // Forward match changes to this view model
    matchCancellable = match.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
    
    // Subscribe to incoming score updates from iOS
    connectivityCancellable = connectivity.$receivedMatchState
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newState in
        self?.match.state = newState
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
      let durationMinutes = Int(match.totalDuration / 60)
      connectivity.sendSessionStarted(durationMinutes: durationMinutes)
    } else {
      connectivity.sendTimerState(isRunning: true)
    }
    
    timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        self?.match.tick()
      }
  }
  
  func stopTimer() {
    isRunning = false
    timerCancellable?.cancel()
    timerCancellable = nil
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
      timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .sink { [weak self] _ in self?.match.tick() }
    } else {
      self.isRunning = false
      timerCancellable?.cancel()
      timerCancellable = nil
    }
  }
  
  // MARK: - SCORING
  func scorePoint(for team: Team) {
    match.scorePoint(for: team)
    
    // Send updated state to iOS
    connectivity.sendMatchState(match.state)
  }
  
  func undo() {
    match.undo()
    
    // Send updated state to iOS after undo
    connectivity.sendMatchState(match.state)
  }
  
  func setDuration(minutes: Int) {
    match = Match(durationMinutes: minutes)
    matchCancellable = match.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
  }

  func restartMatch() {
    stopTimer()
    match = Match(durationMinutes: 90)
    
    // Re-setup the forwarding subscription for the new match
    matchCancellable = match.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
    
    // Re-subscribe to connectivity for the new match
    connectivityCancellable = connectivity.$receivedMatchState
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newState in
        self?.match.state = newState
      }
    
    // Notify iOS of restart
    hasNotifiedSessionStart = true
    connectivity.sendSessionStarted(durationMinutes: 90)
    
    startTimer()
  }
  
  // MARK: - DISPLAY
  var playerScore: String {
    match.displayScore(for: .player)
  }
  
  var opponentScore: String {
    match.displayScore(for: .opponent)
  }
  
  var formattedTime: String {
    match.formattedTime
  }
  
  var isTimeLow: Bool {
    match.isTimeLow
  }
  
  var canUndo: Bool {
    match.canUndo
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
    match.gamesInSet(setIndex, for: .player)
  }
  
  func opponentGames(inSet setIndex: Int) -> Int {
    match.gamesInSet(setIndex, for: .opponent)
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
    stopTimer()
  }
}
