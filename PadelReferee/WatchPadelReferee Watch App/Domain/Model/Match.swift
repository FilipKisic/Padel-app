//
//  Match.swift
//  PadelReferee
//
//  Created by Filip Kisić on 15.01.2026.
//

import Foundation
import Combine

// MARK: - POINT
enum Point: String, CaseIterable {
  case zero = "0"
  case fifteen = "15"
  case thirty = "30"
  case forty = "40"
  case advantage = "AD"
  
  var next: Point? {
    switch self {
      case .zero: return .fifteen
      case .fifteen: return .thirty
      case .thirty: return .forty
      case .forty: return nil
      case .advantage: return nil
    }
  }
  
  var previous: Point? {
    switch self {
      case .zero: return nil
      case .fifteen: return .zero
      case .thirty: return .fifteen
      case .forty: return .thirty
      case .advantage: return .forty
    }
  }
}

// MARK: - TEAM
enum Team: Equatable {
  case player
  case opponent
}

// MARK: - SERVE POSITION
enum ServePosition: Int, CaseIterable {
  case topLeft = 0
  case topRight = 1
  case bottomLeft = 2
  case bottomRight = 3
  
  var next: ServePosition {
    ServePosition(rawValue: (self.rawValue + 1) % 4) ?? .topLeft
  }
  
  var previous: ServePosition {
    ServePosition(rawValue: (self.rawValue + 3) % 4) ?? .bottomRight
  }
}

// MARK: - SET SCORE
struct SetScore: Equatable {
  var playerGames: Int = 0
  var opponentGames: Int = 0
  var isTiebreak: Bool = false
  
  mutating func addGame(for team: Team) {
    switch team {
      case .player: playerGames += 1
      case .opponent: opponentGames += 1
    }
  }
  
  func isSetWon(by team: Team) -> Bool {
    let playerScore = playerGames
    let opponentScore = opponentGames
    
    if isTiebreak {
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
  
  var shouldStartTiebreak: Bool {
    playerGames == 6 && opponentGames == 6
  }
}

// MARK: - MATCH STATE
struct MatchState: Equatable {
  var playerPoint: Point = .zero
  var opponentPoint: Point = .zero
  var playerTiebreakPoints: Int = 0
  var opponentTiebreakPoints: Int = 0
  var sets: [SetScore] = [SetScore()]
  var currentSetIndex: Int = 0
  var servePosition: ServePosition = .topLeft
  var isDeuce: Bool = false
  var isTiebreak: Bool = false
  var isMatchOver: Bool = false
  var winner: Team? = nil
  
  var currentSet: SetScore {
    get { sets[currentSetIndex] }
    set { sets[currentSetIndex] = newValue }
  }
  
  var playerSetsWon: Int {
    sets.filter { $0.isSetWon(by: .player) }.count
  }
  
  var opponentSetsWon: Int {
    sets.filter { $0.isSetWon(by: .opponent) }.count
  }
}

// MARK: - HISTORY ENTRY
struct HistoryEntry: Equatable {
  let state: MatchState
  let remainingTime: TimeInterval
}

// MARK: - MATCH
class Match: ObservableObject {
  @Published var state: MatchState = MatchState()
  @Published var history: [HistoryEntry] = []
  @Published var remainingTime: TimeInterval
  
  let totalDuration: TimeInterval
  
  init(durationMinutes: Int = 90) {
    self.totalDuration = TimeInterval(durationMinutes * 60)
    self.remainingTime = self.totalDuration
  }
  
  // MARK: - SCORING
  func scorePoint(for team: Team) {
    guard !state.isMatchOver else { return }
    
    // Save current state for undo
    saveHistory()
    
    if state.isTiebreak {
      scoreTiebreakPoint(for: team)
    } else {
      scoreRegularPoint(for: team)
    }
  }
  
  private func scoreRegularPoint(for team: Team) {
    // Get current points
    let scoringTeamPoint = team == .player ? state.playerPoint : state.opponentPoint
    let otherTeamPoint = team == .player ? state.opponentPoint : state.playerPoint
    
    // Handle deuce scenarios
    if state.isDeuce {
      if scoringTeamPoint == .advantage {
        // Win game
        winGame(for: team)
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
      winGame(for: team)
    } else if let nextPoint = scoringTeamPoint.next {
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
  
  private func scoreTiebreakPoint(for team: Team) {
    if team == .player {
      state.playerTiebreakPoints += 1
    } else {
      state.opponentTiebreakPoints += 1
    }
    
    // Change serve every 2 points (after first point, then every 2)
    let totalPoints = state.playerTiebreakPoints + state.opponentTiebreakPoints
    if totalPoints == 1 || (totalPoints > 1 && (totalPoints - 1) % 2 == 0) {
      state.servePosition = state.servePosition.next
    }
    
    // Check if tiebreak is won (first to 7, win by 2)
    let playerScore = state.playerTiebreakPoints
    let opponentScore = state.opponentTiebreakPoints
    
    if playerScore >= 7 && playerScore - opponentScore >= 2 {
      winGame(for: .player)
    } else if opponentScore >= 7 && opponentScore - playerScore >= 2 {
      winGame(for: .opponent)
    }
  }
  
  private func winGame(for team: Team) {
    // Add game to current set
    state.currentSet.addGame(for: team)
    
    // Reset points
    state.playerPoint = .zero
    state.opponentPoint = .zero
    state.playerTiebreakPoints = 0
    state.opponentTiebreakPoints = 0
    state.isDeuce = false
    
    // Change serve (in regular game, serve changes every game)
    if !state.isTiebreak {
      state.servePosition = state.servePosition.next
    }
    
    // Check if set is won
    if state.currentSet.isSetWon(by: team) {
      winSet(for: team)
    } else if state.currentSet.shouldStartTiebreak {
      // Start tiebreak
      state.isTiebreak = true
      state.currentSet.isTiebreak = true
    }
  }
  
  private func winSet(for team: Team) {
    state.isTiebreak = false
    
    // Check if match is won (best of 3)
    let setsWon = team == .player ? state.playerSetsWon : state.opponentSetsWon
    
    if setsWon >= 2 {
      state.isMatchOver = true
      state.winner = team
    } else {
      // Start new set
      state.currentSetIndex += 1
      state.sets.append(SetScore())
    }
  }
  
  // MARK: - UNDO
  func undo() {
    guard let lastEntry = history.popLast() else { return }
    state = lastEntry.state
    remainingTime = lastEntry.remainingTime
  }
  
  private func saveHistory() {
    let entry = HistoryEntry(state: state, remainingTime: remainingTime)
    history.append(entry)
    
    // Limit history to last 50 entries to save memory
    if history.count > 50 {
      history.removeFirst()
    }
  }
  
  var canUndo: Bool {
    !history.isEmpty
  }
  
  // MARK: - TIMER
  func tick() {
    if remainingTime > 0 {
      remainingTime -= 1
    }
  }
  
  var formattedTime: String {
    let minutes = Int(remainingTime) / 60
    let seconds = Int(remainingTime) % 60
    return String(format: "%02d:%02d:%02d", minutes / 60, minutes % 60, seconds)
  }
  
  var isTimeLow: Bool {
    remainingTime <= 5 * 60 // 5 minutes or less
  }
  
  // MARK: - DISPLAY HELPERS
  func displayScore(for team: Team) -> String {
    if state.isTiebreak {
      return team == .player ? "\(state.playerTiebreakPoints)" : "\(state.opponentTiebreakPoints)"
    }
    return team == .player ? state.playerPoint.rawValue : state.opponentPoint.rawValue
  }
  
  func gamesInSet(_ setIndex: Int, for team: Team) -> Int {
    guard setIndex < state.sets.count else { return 0 }
    return team == .player ? state.sets[setIndex].playerGames : state.sets[setIndex].opponentGames
  }
}
