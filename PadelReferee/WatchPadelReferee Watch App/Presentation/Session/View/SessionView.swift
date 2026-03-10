//
//  SessionView.swift
//  PadelReferee Watch App
//
//  Created by Filip Kisić on 15.01.2026..
//

import SwiftUI

struct SessionView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var viewModel: SessionViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var workoutManager: WorkoutManager
  
  // MARK: - BODY
  var body: some View {
    VStack(spacing: 0) {
      opponentScoreDisplay()
        .padding(.top, 20)
      
      servingIndicator()
      
      playerScoreDisplay()
      
      timer()
    } //: VSTACK
    .scenePadding()
    .navigationBarBackButtonHidden()
    .onChange(of: viewModel.isMatchOver) { _, isMatchOver in
      if isMatchOver {
        workoutManager.endSession()
      }
    }
  }
}

// MARK: - VIEW EXTENSIONS
private extension SessionView {
  @ViewBuilder
  func opponentScoreDisplay() -> some View {
    HStack {
      Button {
        viewModel.scorePoint(for: .opponent)
      } label: {
        Text(viewModel.opponentScore)
          .font(.system(size: 58, weight: .medium, design: .rounded))
          .foregroundColor(.green)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .buttonStyle(.plain)
      
      VStack {
        Text("session.opponent")
          .font(.system(size: 14, weight: .semibold, design: .rounded))
          .foregroundColor(.green)
        
        SetScoresView(
          set1Games: viewModel.opponentGames(inSet: 0),
          set2Games: viewModel.opponentGames(inSet: 1),
          set3Games: viewModel.opponentGames(inSet: 2),
          currentSetIndex: viewModel.currentSetIndex,
          isPlayer: false
        )
      } //: VSTACK
    } //: HSTACK
  }
  
  @ViewBuilder
  func servingIndicator() -> some View {
    VStack(spacing: 2) {
      HStack(spacing: 2) {
        ServeQuadrantView(isActive: viewModel.currentServePosition == .topLeft, color: .cyan)
        ServeQuadrantView(isActive: viewModel.currentServePosition == .topRight, color: .cyan)
      } //: HSTACK
      
      HStack(spacing: 2) {
        ServeQuadrantView(isActive: viewModel.currentServePosition == .bottomLeft, color: .cyan)
        ServeQuadrantView(isActive: viewModel.currentServePosition == .bottomRight, color: .cyan)
      } //: HSTACK
    } //: VSTACK
    .frame(height: 35)
  }
  
  @ViewBuilder
  func playerScoreDisplay() -> some View {
    HStack {
      Button {
        viewModel.scorePoint(for: .player)
      } label: {
        Text(viewModel.playerScore)
          .font(.system(size: 58, weight: .medium, design: .rounded))
          .foregroundColor(.white)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .buttonStyle(.plain)
      
      VStack {
        SetScoresView(
          set1Games: viewModel.playerGames(inSet: 0),
          set2Games: viewModel.playerGames(inSet: 1),
          set3Games: viewModel.playerGames(inSet: 2),
          currentSetIndex: viewModel.currentSetIndex,
        )
        Text("session.your-team")
          .font(.system(size: 14, weight: .semibold, design: .rounded))
          .foregroundColor(.white)
      } //: VSTACK
    } //: HSTACK
  }
  
  @ViewBuilder
  func timer() -> some View {
    Text(viewModel.formattedTime)
      .font(.system(size: 25, weight: .medium, design: .rounded))
      .foregroundColor(viewModel.isTimeLow ? .red : .white)
      .onTapGesture {
        viewModel.toggleTimer()
      }
  }
}

// MARK: - SERVE QUADRANT VIEW
struct ServeQuadrantView: View {
  let isActive: Bool
  let color: Color
  
  var body: some View {
    RoundedRectangle(cornerRadius: 4)
      .fill(isActive ? .yellow : color)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

// MARK: - SET SCORES VIEW
struct SetScoresView: View {
  let set1Games: Int
  let set2Games: Int
  let set3Games: Int
  let currentSetIndex: Int
  let isPlayer: Bool
  
  init(set1Games: Int, set2Games: Int, set3Games: Int, currentSetIndex: Int, isPlayer: Bool = true) {
    self.set1Games = set1Games
    self.set2Games = set2Games
    self.set3Games = set3Games
    self.currentSetIndex = currentSetIndex
    self.isPlayer = isPlayer
  }
  
  var body: some View {
    HStack(spacing: 8) {
      SetScoreColumnView(
        setNumber: 1,
        games: set1Games,
        isCurrentSet: currentSetIndex == 0,
        isPlayer: isPlayer
      )
      SetScoreColumnView(
        setNumber: 2,
        games: set2Games,
        isCurrentSet: currentSetIndex == 1,
        isPlayer: isPlayer
      )
      SetScoreColumnView(
        setNumber: 3,
        games: set3Games,
        isCurrentSet: currentSetIndex == 2,
        isPlayer: isPlayer
      )
    } //: HSTACK
  }
}

// MARK: - SET SCORE COLUMN VIEW
struct SetScoreColumnView: View {
  let setNumber: Int
  let games: Int
  let isCurrentSet: Bool
  let isPlayer: Bool
  
  init(setNumber: Int, games: Int, isCurrentSet: Bool, isPlayer: Bool = true) {
    self.setNumber = setNumber
    self.games = games
    self.isCurrentSet = isCurrentSet
    self.isPlayer = isPlayer
  }
  
  var body: some View {
    VStack(spacing: -5) {
      if (!isPlayer) {
        Text("\(setNumber)")
          .font(.system(size: 14, weight: .semibold, design: .rounded))
          .foregroundColor(isCurrentSet ? .white : .gray)
      }
      
      Text("\(games)")
        .font(.system(size: 32, weight: .medium, design: .rounded))
        .foregroundColor(isPlayer ? .white : .green)
    } //: VSTACK
  }
}

// MARK: - PREVIEW
#Preview {
  let sessionViewModel = SessionViewModel()
  let router = Router()
  
  NavigationView {
    SessionView()
  }
  .environmentObject(sessionViewModel)
  .environmentObject(router)
}
