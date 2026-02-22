//
//  SessionView.swift
//  PadelReferee Watch App
//
//  Created by Filip Kisić on 15.01.2026..
//

import SwiftUI

struct SessionView: View {
  // MARK: - PROPERTIES
  @StateObject private var viewModel = SessionViewModel()
  @Environment(\.dismiss) private var dismiss
  
  @ObservedObject private var watchConnectivityManager = WatchConnectivityManager.shared
  
  // MARK: - BODY
  var body: some View {
    VStack(spacing: 0) {
      // MARK: - UNDO BUTTON
      HStack {
        Button(action: {
          viewModel.undo()
        }) {
          Image(systemName: "arrow.uturn.backward")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.red)
            .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .padding(5)
        .background(.darkGray)
        .clipShape(.circle)
        .opacity(viewModel.canUndo ? 1.0 : 0.5)
        .disabled(!viewModel.canUndo)
        .offset(x: -10, y: 7)
        
        Spacer()
      } //: HSTACK
      .padding(.horizontal, 24)
      
      // MARK: - OPPONENT
      HStack {
        Button(action: {
          viewModel.scorePoint(for: .opponent)
          
          watchConnectivityManager.sendUpdate(text: "Hello from watchOS!")
        }) {
          Text(viewModel.opponentScore)
            .font(.system(size: 58, weight: .medium, design: .rounded))
            .foregroundColor(.green)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        
        VStack {
          Text("OPPONENT")
            .font(.system(size: 12, weight: .medium))
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
      .padding(.horizontal, 12)
      
      // MARK: - SERVING
      ServeIndicatorView(currentPosition: viewModel.currentServePosition)
        .frame(height: 35)
      
      // MARK: - PLAYER
      HStack {
        Button(action: {
          viewModel.scorePoint(for: .player)
        }) {
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
          Text("YOUR TEAM")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
        } //: VSTACK
      } //: HSTACK
      .padding(.horizontal, 12)
      
      // MARK: - TIMER
      Text(viewModel.formattedTime)
        .font(.system(size: 25, weight: .medium, design: .rounded))
        .foregroundColor(viewModel.isTimeLow ? .red : .white)
        .onTapGesture {
          viewModel.toggleTimer()
        }
        .padding(.bottom, 12)
      
      Text(watchConnectivityManager.lastReceivedText)
        .font(.system(size: 12, weight: .medium))
        
    } //: VSTACK
    .ignoresSafeArea()
    .onAppear {
      viewModel.startTimer()
    }
    // MARK: - ALERT
    .alert("Match Over!", isPresented: .constant(viewModel.isMatchOver)) {
      Button("New Match") {
        viewModel.restartMatch()
      }
      
      Button("Exit", role: .cancel) {
        dismiss()
      }
    } message: {
      if let winner = viewModel.winner {
        Text(winner == .player ? "Your team wins!" : "Opponent wins!")
      }
    } //: ALERT
    
  }
}

// MARK: - SERVE INDICATOR VIEW
struct ServeIndicatorView: View {
  let currentPosition: ServePosition
  
  var body: some View {
    VStack(spacing: 2) {
      HStack(spacing: 2) {
        ServeQuadrantView(isActive: currentPosition == .topLeft, color: .blue)
        ServeQuadrantView(isActive: currentPosition == .topRight, color: .blue)
      } //: HSTACK
      
      HStack(spacing: 2) {
        ServeQuadrantView(isActive: currentPosition == .bottomLeft, color: .blue)
        ServeQuadrantView(isActive: currentPosition == .bottomRight, color: .blue)
      } //: HSTACK
    } //: VSTACK
  }
}

// MARK: - SERVE QUADRANT VIEW
struct ServeQuadrantView: View {
  let isActive: Bool
  let color: Color
  
  var body: some View {
    RoundedRectangle(cornerRadius: 2)
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
      if(!isPlayer) {
        Text("\(setNumber)")
          .font(.system(size: 14, weight: .medium))
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
  SessionView()
}
