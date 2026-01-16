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
  
  // MARK: - INIT
  init(durationMinutes: Int = 90) {
    self.match = Match(durationMinutes: durationMinutes)
    
    // Forward match changes to this view model
    matchCancellable = match.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
  }
  
  // MARK: - TIMER
  func startTimer() {
    guard !isRunning else { return }
    isRunning = true
    
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
  }
  
  func toggleTimer() {
    if isRunning {
      stopTimer()
    } else {
      startTimer()
    }
  }
  
  // MARK: - SCORING
  func scorePoint(for team: Team) {
    match.scorePoint(for: team)
  }
  
  func undo() {
    match.undo()
  }
  
  func restartMatch() {
    stopTimer()
    match = Match(durationMinutes: 90)
    
    // Re-setup the forwarding subscription for the new match
    matchCancellable = match.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }
    
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
