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
  func nextServePosition(from position: ServePosition) -> ServePosition {
    ServePosition(rawValue: (position.rawValue + 1) % 4) ?? .topLeft
  }
  
  func previousServePosition(from position: ServePosition) -> ServePosition {
    ServePosition(rawValue: (position.rawValue + 3) % 4) ?? .bottomRight
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
    
    if setScore.isTiebreak {
      // Tiebreak: first to 7, win by 2
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
        if playerScore >= 6 && playerScore - opponentScore >= 2 {
          return true
        }
      case .opponent:
        if opponentScore >= 6 && opponentScore - playerScore >= 2 {
          return true
        }
    }
    return false
  }
  
  func shouldStartTiebreak(setScore: SetScore) -> Bool {
    setScore.playerGames == 6 && setScore.opponentGames == 6
  }
  
  // MARK: - Match State Logic
  func setsWon(in state: MatchState, by team: Team) -> Int {
    state.sets.filter { isSetWon(setScore: $0, by: team) }.count
  }
  
  // MARK: - Scoring Logic
  func scorePoint(state: inout MatchState, for team: Team) {
    guard !state.isMatchOver else { return }
    
    if state.isTiebreak {
      scoreTiebreakPoint(state: &state, for: team)
    } else {
      scoreRegularPoint(state: &state, for: team)
    }
  }
  
  private func scoreRegularPoint(state: inout MatchState, for team: Team) {
    // Get current points
    let scoringTeamPoint = team == .player ? state.playerPoint : state.opponentPoint
    let otherTeamPoint = team == .player ? state.opponentPoint : state.playerPoint
    
    // Handle deuce scenarios
    if state.isDeuce {
      if scoringTeamPoint == .advantage {
        // Win game
        winGame(state: &state, for: team)
      } else if otherTeamPoint == .advantage {
        // Back to deuce
        state.playerPoint = .forty
        state.opponentPoint = .forty
      } else {
        // Give advantage
        if team == .player {
          state.playerPoint = .advantage
        } else {
          state.opponentPoint = .advantage
        }
      }
      return
    }
    
    // Check for deuce
    if scoringTeamPoint == .forty && otherTeamPoint == .forty {
      // Give advantage
      if team == .player {
        state.playerPoint = .advantage
      } else {
        state.opponentPoint = .advantage
      }
      state.isDeuce = true
      return
    }
    
    // Regular point progression
    if scoringTeamPoint == .forty {
      // Win game
      winGame(state: &state, for: team)
    } else if let nextPoint = nextPoint(from: scoringTeamPoint) {
      if team == .player {
        state.playerPoint = nextPoint
      } else {
        state.opponentPoint = nextPoint
      }
      
      // Check if entering deuce
      if state.playerPoint == .forty && state.opponentPoint == .forty {
        state.isDeuce = true
      }
    }
  }
  
  private func scoreTiebreakPoint(state: inout MatchState, for team: Team) {
    if team == .player {
      state.playerTiebreakPoints += 1
    } else {
      state.opponentTiebreakPoints += 1
    }
    
    // Change serve every 2 points (after first point, then every 2)
    let totalPoints = state.playerTiebreakPoints + state.opponentTiebreakPoints
    if totalPoints == 1 || (totalPoints > 1 && (totalPoints - 1) % 2 == 0) {
      state.servePosition = nextServePosition(from: state.servePosition)
    }
    
    // Check if tiebreak is won (first to 7, win by 2)
    let playerScore = state.playerTiebreakPoints
    let opponentScore = state.opponentTiebreakPoints
    
    if playerScore >= 7 && playerScore - opponentScore >= 2 {
      winGame(state: &state, for: .player)
    } else if opponentScore >= 7 && opponentScore - playerScore >= 2 {
      winGame(state: &state, for: .opponent)
    }
  }
  
  private func winGame(state: inout MatchState, for team: Team) {
    // Add game to current set
    addGame(to: &state.currentSet, for: team)
    
    // Reset points
    state.playerPoint = .zero
    state.opponentPoint = .zero
    state.playerTiebreakPoints = 0
    state.opponentTiebreakPoints = 0
    state.isDeuce = false
    
    // Change serve (in regular game, serve changes every game)
    if !state.isTiebreak {
      state.servePosition = nextServePosition(from: state.servePosition)
    }
    
    // Check if set is won
    if isSetWon(setScore: state.currentSet, by: team) {
      winSet(state: &state, for: team)
    } else if shouldStartTiebreak(setScore: state.currentSet) {
      // Start tiebreak
      state.isTiebreak = true
      state.currentSet.isTiebreak = true
    }
  }
  
  private func winSet(state: inout MatchState, for team: Team) {
    state.isTiebreak = false
    
    // Check if match is won (best of 3)
    let wonSets = setsWon(in: state, by: team)
    
    if wonSets >= 2 {
      state.isMatchOver = true
      state.winner = team
    } else {
      // Start new set
      state.currentSetIndex += 1
      state.sets.append(SetScore())
    }
  }
  
  // MARK: - History Management
  func saveHistory(history: inout [HistoryEntry], state: MatchState, remainingTime: TimeInterval) {
    let entry = HistoryEntry(state: state, remainingTime: remainingTime)
    history.append(entry)
    
    // Limit history to last 50 entries to save memory
    if history.count > 50 {
      history.removeFirst()
    }
  }
  
  func undo(history: inout [HistoryEntry], state: inout MatchState, remainingTime: inout TimeInterval) {
    guard let lastEntry = history.popLast() else { return }
    state = lastEntry.state
    remainingTime = lastEntry.remainingTime
  }
  
  func canUndo(history: [HistoryEntry]) -> Bool {
    !history.isEmpty
  }
  
  // MARK: - Display Helpers
  func displayScore(for team: Team, in state: MatchState) -> String {
    if state.isTiebreak {
      return team == .player ? "\(state.playerTiebreakPoints)" : "\(state.opponentTiebreakPoints)"
    }
    return team == .player ? state.playerPoint.rawValue : state.opponentPoint.rawValue
  }
  
  func gamesInSet(_ setIndex: Int, for team: Team, in state: MatchState) -> Int {
    guard setIndex < state.sets.count else { return 0 }
    return team == .player ? state.sets[setIndex].playerGames : state.sets[setIndex].opponentGames
  }
}
