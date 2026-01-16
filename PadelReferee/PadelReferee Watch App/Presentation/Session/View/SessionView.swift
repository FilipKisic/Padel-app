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
  
  // MARK: - BODY
  var body: some View {
    VStack(spacing: 8) {
      // Undo button row
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
        .opacity(viewModel.canUndo ? 1.0 : 0.3)
        .disabled(!viewModel.canUndo)
        
        Spacer()
      }
      .padding(.horizontal, 12)
      
      Spacer()
      
      // Main content
      GeometryReader { geometry in
        HStack(spacing: 8) {
          // Left side - Scores
          VStack(spacing: 2) {
            // Opponent score (tappable)
            Button(action: {
              viewModel.scorePoint(for: .opponent)
            }) {
              Text(viewModel.opponentScore)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            
            // Player score (tappable)
            Button(action: {
              viewModel.scorePoint(for: .player)
            }) {
              Text(viewModel.playerScore)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
          }
          .frame(width: geometry.size.width * 0.35)
          
          // Right side - Serve indicator and set scores
          VStack(spacing: 4) {
            // Opponent label and set scores
            HStack(spacing: 0) {
              Text("OPPONENT")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
              Spacer()
            }
            
            // Opponent set scores
            SetScoresView(
              set1Games: viewModel.opponentGames(inSet: 0),
              set2Games: viewModel.opponentGames(inSet: 1),
              set3Games: viewModel.opponentGames(inSet: 2),
              currentSetIndex: viewModel.currentSetIndex
            )
            
            // Serve indicator (4 quadrants)
            ServeIndicatorView(currentPosition: viewModel.currentServePosition)
              .frame(height: 30)
            
            // Player set scores
            SetScoresView(
              set1Games: viewModel.playerGames(inSet: 0),
              set2Games: viewModel.playerGames(inSet: 1),
              set3Games: viewModel.playerGames(inSet: 2),
              currentSetIndex: viewModel.currentSetIndex
            )
            
            // Player label
            HStack(spacing: 0) {
              Text("YOUR TEAM")
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
              Spacer()
            }
          }
          .frame(width: geometry.size.width * 0.45)
        }
        .padding(.horizontal, 8)
      }
      
      Spacer()
      
      // Timer
      Text(viewModel.formattedTime)
        .font(.system(size: 20, weight: .semibold, design: .rounded))
        .foregroundColor(viewModel.isTimeLow ? .red : .white)
        .onTapGesture {
          viewModel.toggleTimer()
        }
        .padding(.bottom, 12)
    }
    .ignoresSafeArea()
    .onAppear {
      viewModel.startTimer()
    }
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
    }
  }
}

// MARK: - SERVE INDICATOR VIEW
struct ServeIndicatorView: View {
  let currentPosition: ServePosition
  
  var body: some View {
    VStack(spacing: 2) {
      HStack(spacing: 2) {
        ServeQuadrant(isActive: currentPosition == .topLeft, color: .blue)
        ServeQuadrant(isActive: currentPosition == .topRight, color: .blue)
      }
      HStack(spacing: 2) {
        ServeQuadrant(isActive: currentPosition == .bottomLeft, color: .blue)
        ServeQuadrant(isActive: currentPosition == .bottomRight, color: .blue)
      }
    }
  }
}

// MARK: - SERVE QUADRANT
struct ServeQuadrant: View {
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
  
  var body: some View {
    HStack(spacing: 8) {
      SetScoreColumn(setNumber: 1, games: set1Games, isCurrentSet: currentSetIndex == 0)
      SetScoreColumn(setNumber: 2, games: set2Games, isCurrentSet: currentSetIndex == 1)
      SetScoreColumn(setNumber: 3, games: set3Games, isCurrentSet: currentSetIndex == 2)
    }
  }
}

// MARK: - SET SCORE COLUMN
struct SetScoreColumn: View {
  let setNumber: Int
  let games: Int
  let isCurrentSet: Bool
  
  var body: some View {
    VStack(spacing: 0) {
      Text("\(setNumber)")
        .font(.system(size: 8, weight: .medium))
        .foregroundColor(.gray)
      Text("\(games)")
        .font(.system(size: 14, weight: .bold, design: .rounded))
        .foregroundColor(isCurrentSet ? .white : .gray)
    }
  }
}

// MARK: - PREVIEW
#Preview {
  SessionView()
}
