//
//  MatchGameService.swift
//  PadelReferee
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

class MatchGameService {
  
  // MARK: - Point Logic
  func nextPoint(from point: Point) -> Point? {
    switch point {
      case .zero: return .fifteen
      case .fifteen: return .thirty
      case .thirty: return .forty
      case .forty: return nil
      case .advantage: return nil
    }
  }
  
  func previousPoint(from point: Point) -> Point? {
    switch point {
      case .zero: return nil
      case .fifteen: return .zero
      case .thirty: return .fifteen
      case .forty: return .thirty
      case .advantage: return .forty
    }
  }
  
  // MARK: - Serve Position Logic
  /// Maps servingPlayerIndex (0–3) and court side to a quadrant.
  /// Players 0,2 = bottom row (your team), players 1,3 = top row (opponents).
  /// Right = deuce court, Left = ad court.
  func servePositionFor(playerIndex: Int, isServingFromRight: Bool) -> ServePosition {
    let isBottomRow = playerIndex % 2 == 0
    if isBottomRow {
      return isServingFromRight ? .bottomRight : .bottomLeft
    } else {
      return isServingFromRight ? .topRight : .topLeft
    }
  }
  
  func nextServingPlayerIndex(from index: Int) -> Int {
    (index + 1) % 4
  }
  
  func previousServingPlayerIndex(from index: Int) -> Int {
    (index + 3) % 4
  }
  
  // MARK: - Set Score Logic
  func addGame(to setScore: inout SetScore, for team: Team) {
    switch team {
      case .player: setScore.playerGames += 1
      case .opponent: setScore.opponentGames += 1
    }
  }
  
  func isSetWon(setScore: SetScore, by team: Team) -> Bool {
    let playerScore = setScore.playerGames
    let opponentScore = setScore.opponentGames
    
    // Tiebreak: first to 7, win by 2
    if setScore.isTiebreak {
      let maxScore = max(playerScore, opponentScore)
      let minScore = min(playerScore, opponentScore)
      if maxScore >= 7 && (maxScore - minScore) >= 2 {
        return team == .player ? playerScore > opponentScore : opponentScore > playerScore
      }
      return false
    }
    
    // Normal set: first to 6, win by 2, or 7-5
    switch team {
      case .player:
        return playerScore >= 6 && playerScore - opponentScore >= 2
      case .opponent:
        return opponentScore >= 6 && opponentScore - playerScore >= 2
    }
  }
  
  func shouldStartTiebreak(setScore: SetScore) -> Bool {
    setScore.playerGames == 6 && setScore.opponentGames == 6
  }
  
  // MARK: - Match Config Logic
  func setsWon(in config: MatchConfig, by team: Team) -> Int {
    config.sets.filter { isSetWon(setScore: $0, by: team) }.count
  }
  
  // MARK: - Scoring Logic
  func scorePoint(config: inout MatchConfig, for team: Team) {
    guard !config.isMatchOver else { return }
    
    if config.isTiebreak {
      scoreTiebreakPoint(config: &config, for: team)
    } else {
      scoreRegularPoint(config: &config, for: team)
    }
  }
  
  private func scoreRegularPoint(config: inout MatchConfig, for team: Team) {
    // Get current points
    let scoringTeamPoint = team == .player ? config.playerPoint : config.opponentPoint
    let otherTeamPoint = team == .player ? config.opponentPoint : config.playerPoint
    
    if config.isDeuce {
      if scoringTeamPoint == .advantage {
        winGame(state: &config, for: team)
        return
      } else if otherTeamPoint == .advantage {
        config.playerPoint = .forty
        config.opponentPoint = .forty
      } else {
        if team == .player {
          config.playerPoint = .advantage
        } else {
          config.opponentPoint = .advantage
        }
      }
      // Alternate serve side within game
      let isRight = config.servePosition == .topRight || config.servePosition == .bottomRight
      config.servePosition = servePositionFor(playerIndex: config.servingPlayerIndex, isServingFromRight: !isRight)
      return
    }
    
    // Check for deuce
    if scoringTeamPoint == .forty && otherTeamPoint == .forty {
      // Give advantage
      if team == .player {
        config.playerPoint = .advantage
      } else {
        config.opponentPoint = .advantage
      }
      config.isDeuce = true
      // Alternate serve side within game
      let isRight = config.servePosition == .topRight || config.servePosition == .bottomRight
      config.servePosition = servePositionFor(playerIndex: config.servingPlayerIndex, isServingFromRight: !isRight)
      return
    }
    
    // Regular point progression
    if scoringTeamPoint == .forty {
      winGame(state: &config, for: team)
    } else if let nextPoint = nextPoint(from: scoringTeamPoint) {
      if team == .player {
        config.playerPoint = nextPoint
      } else {
        config.opponentPoint = nextPoint
      }
      
      // Check if entering deuce
      if config.playerPoint == .forty && config.opponentPoint == .forty {
        config.isDeuce = true
      }
      
      // Alternate serve side within game
      let isRight = config.servePosition == .topRight || config.servePosition == .bottomRight
      config.servePosition = servePositionFor(playerIndex: config.servingPlayerIndex, isServingFromRight: !isRight)
    }
  }
  
  private func scoreTiebreakPoint(config: inout MatchConfig, for team: Team) {
    if team == .player {
      config.playerTiebreakPoints += 1
    } else {
      config.opponentTiebreakPoints += 1
    }
    
    // Tiebreak serve rotation: server changes after 1st point, then every 2 points
    let totalPoints = config.playerTiebreakPoints + config.opponentTiebreakPoints
    if totalPoints == 1 || (totalPoints > 1 && (totalPoints - 1) % 2 == 0) {
      config.servingPlayerIndex = nextServingPlayerIndex(from: config.servingPlayerIndex)
      // New server starts from right (deuce) court
      config.servePosition = servePositionFor(playerIndex: config.servingPlayerIndex, isServingFromRight: true)
    } else {
      // Alternate side within current server's points
      let isRight = config.servePosition == .topRight || config.servePosition == .bottomRight
      config.servePosition = servePositionFor(playerIndex: config.servingPlayerIndex, isServingFromRight: !isRight)
    }
    
    // Check if tiebreak is won (first to 7, win by 2)
    let playerScore = config.playerTiebreakPoints
    let opponentScore = config.opponentTiebreakPoints
    
    if playerScore >= 7 && playerScore - opponentScore >= 2 {
      winGame(state: &config, for: .player)
    } else if opponentScore >= 7 && opponentScore - playerScore >= 2 {
      winGame(state: &config, for: .opponent)
    }
  }
  
  private func winGame(state: inout MatchConfig, for team: Team) {
    addGame(to: &state.currentSet, for: team)
    
    // Reset points
    state.playerPoint = .zero
    state.opponentPoint = .zero
    state.playerTiebreakPoints = 0
    state.opponentTiebreakPoints = 0
    state.isDeuce = false
    
    // Rotate to next server for the next game
    if !state.isTiebreak {
      state.servingPlayerIndex = nextServingPlayerIndex(from: state.servingPlayerIndex)
      state.servePosition = servePositionFor(playerIndex: state.servingPlayerIndex, isServingFromRight: true)
    }
    
    // Check if set is won
    if isSetWon(setScore: state.currentSet, by: team) {
      winSet(state: &state, for: team)
    } else if shouldStartTiebreak(setScore: state.currentSet) {
      state.isTiebreak = true
      state.currentSet.isTiebreak = true
    }
  }
  
  private func winSet(state: inout MatchConfig, for team: Team) {
    state.isTiebreak = false
    
    // Check if match is won (best of 3)
    let wonSets = setsWon(in: state, by: team)
    
    if wonSets >= 2 {
      state.isMatchOver = true
      state.winner = team
      guard state.sets.count == 3 else {
        state.sets.append(SetScore(playerGames: 0, opponentGames: 0, isTiebreak: false));
        return
      }
    } else {
      state.currentSetIndex += 1
      state.sets.append(SetScore())
    }
  }
  
  func finishMatch(config: inout MatchConfig) {
    if config.sets.count < 3 {
      let emptySetsToAdd = 3 - config.sets.count
      for _ in 0..<emptySetsToAdd {
        config.sets.append(SetScore(playerGames: 0, opponentGames: 0))
      }
    }
  }
  
  // MARK: - History Management
  func saveHistory(history: inout [HistoryEntry], state: MatchConfig, remainingTime: TimeInterval) {
    let entry = HistoryEntry(state: state, remainingTime: remainingTime)
    history.append(entry)
    
    // Limit history to last 50 entries to save memory
    if history.count > 50 {
      history.removeFirst()
    }
  }
  
  func undo(history: inout [HistoryEntry], state: inout MatchConfig, remainingTime: inout TimeInterval) {
    guard let lastEntry = history.popLast() else { return }
    state = lastEntry.state
    remainingTime = lastEntry.remainingTime
  }
  
  func canUndo(history: [HistoryEntry]) -> Bool {
    !history.isEmpty
  }
  
  // MARK: - Display Helpers
  func displayScore(for team: Team, in state: MatchConfig) -> String {
    if state.isTiebreak {
      return team == .player ? "\(state.playerTiebreakPoints)" : "\(state.opponentTiebreakPoints)"
    }
    return team == .player ? state.playerPoint.rawValue : state.opponentPoint.rawValue
  }
  
  func gamesInSet(_ setIndex: Int, for team: Team, in state: MatchConfig) -> Int {
    guard setIndex < state.sets.count else { return 0 }
    return team == .player ? state.sets[setIndex].playerGames : state.sets[setIndex].opponentGames
  }
}
