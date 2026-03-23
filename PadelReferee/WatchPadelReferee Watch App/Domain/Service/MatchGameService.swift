//
//  MatchGameService.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 28.02.2026.
//

import Foundation

class MatchGameService {

  // MARK: - POINT LOGIC
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

  // MARK: - SERVE POSITION LOGIC
  func nextServePosition(from position: ServePosition) -> ServePosition {
    switch position {
      case .topLeft: return .topRight
      case .topRight: return .bottomLeft
      case .bottomLeft: return .bottomRight
      case .bottomRight: return .topLeft
    }
  }

  func previousServePosition(from position: ServePosition) -> ServePosition {
    switch position {
      case .topLeft: return .bottomRight
      case .topRight: return .topLeft
      case .bottomLeft: return .topRight
      case .bottomRight: return .bottomLeft
    }
  }

  // MARK: - SET SCORE LOGIC
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
      let maxScore = max(playerScore, opponentScore)
      let minScore = min(playerScore, opponentScore)
      if maxScore >= 7 && (maxScore - minScore) >= 2 {
        return team == .player ? playerScore > opponentScore : opponentScore > playerScore
      }
      return false
    }

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

  // MARK: - SCORING LOGIC
  func scorePoint(state: inout MatchState, for team: Team) {
    guard !state.isMatchOver else { return }

    if state.isTiebreak {
      scoreTiebreakPoint(state: &state, for: team)
    } else {
      scoreRegularPoint(state: &state, for: team)
    }
  }

  private func scoreRegularPoint(state: inout MatchState, for team: Team) {
    let scoringTeamPoint = team == .player ? state.playerPoint : state.opponentPoint
    let otherTeamPoint = team == .player ? state.opponentPoint : state.playerPoint

    if state.isDeuce {
      if scoringTeamPoint == .advantage {
        winGame(state: &state, for: team)
      } else if otherTeamPoint == .advantage {
        state.playerPoint = .forty
        state.opponentPoint = .forty
      } else {
        if team == .player {
          state.playerPoint = .advantage
        } else {
          state.opponentPoint = .advantage
        }
      }
      return
    }

    if scoringTeamPoint == .forty && otherTeamPoint == .forty {
      if team == .player {
        state.playerPoint = .advantage
      } else {
        state.opponentPoint = .advantage
      }
      state.isDeuce = true
      return
    }

    if scoringTeamPoint == .forty {
      winGame(state: &state, for: team)
    } else if let nextPoint = nextPoint(from: scoringTeamPoint) {
      if team == .player {
        state.playerPoint = nextPoint
      } else {
        state.opponentPoint = nextPoint
      }

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

    let playerScore = state.playerTiebreakPoints
    let opponentScore = state.opponentTiebreakPoints

    if playerScore >= 7 && playerScore - opponentScore >= 2 {
      winGame(state: &state, for: .player)
    } else if opponentScore >= 7 && opponentScore - playerScore >= 2 {
      winGame(state: &state, for: .opponent)
    }
  }

  private func winGame(state: inout MatchState, for team: Team) {
    addGame(to: &state.currentSet, for: team)

    state.playerPoint = .zero
    state.opponentPoint = .zero
    state.playerTiebreakPoints = 0
    state.opponentTiebreakPoints = 0
    state.isDeuce = false

    // Serve changes every game (not during tiebreak, where it rotates per point)
    if !state.isTiebreak {
      state.servePosition = nextServePosition(from: state.servePosition)
    }

    if isSetWon(setScore: state.currentSet, by: team) {
      winSet(state: &state, for: team)
    } else if shouldStartTiebreak(setScore: state.currentSet) {
      state.isTiebreak = true
      state.currentSet.isTiebreak = true
    }
  }

  private func winSet(state: inout MatchState, for team: Team) {
    state.isTiebreak = false

    let setsWon = team == .player ? state.playerSetsWon : state.opponentSetsWon

    if setsWon >= 2 {
      state.isMatchOver = true
      state.winner = team
      guard state.sets.count == 3 else {
        state.sets.append(SetScore(playerGames: 0, opponentGames: 0, isTiebreak: false))
        return
      }
    } else {
      state.currentSetIndex += 1
      state.sets.append(SetScore())
    }
  }
  
  func finishMatch(state: inout MatchState) {
    if state.sets.count < 3 {
      let emptySetsToAdd = 3 - state.sets.count
      for _ in 0..<emptySetsToAdd {
        state.sets.append(SetScore(playerGames: 0, opponentGames: 0))
      }
    }
  }

  // MARK: - HISTORY MANAGEMENT
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

  // MARK: - DISPLAY HELPERS
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
