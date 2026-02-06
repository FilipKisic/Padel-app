//
//  MatchView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import SwiftUI

struct MatchView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var viewModel: MatchViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var appState: AppState
  
  // MARK: - BODY
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .bottom) {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 0) {
          // Serve Position Quadrants
          ServePositionView(currentPosition: viewModel.match.state.servePosition)
            .frame(height: 100)
            .padding(.horizontal, 40)
            .padding(.top, 60)
          
          Spacer()
          
          // Score Display
          VStack(spacing: 16) {
            // Opponent Section
            VStack(spacing: 12) {
              Text("OPPONENT")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.green)
              
              HStack(alignment: .top, spacing: 20) {
                // Opponent Current Score
                Text(viewModel.displayScore(for: .opponent))
                  .font(.system(size: 90, weight: .bold))
                  .foregroundColor(.green)
                
                // Opponent Games per Set
                VStack(alignment: .leading, spacing: 4) {
                  ForEach(0..<viewModel.match.state.currentSetIndex + 1, id: \.self) { setIndex in
                    HStack(spacing: 8) {
                      Text("\(setIndex + 1)")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                      Text("\(viewModel.gamesInSet(setIndex, for: .opponent))")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.green)
                        .frame(minWidth: 40, alignment: .trailing)
                    }
                  }
                }
              }
            }
            
            // Divider
            Rectangle()
              .fill(Color.cyan)
              .frame(height: 3)
              .frame(maxWidth: 300)
            
            // Player Section
            VStack(spacing: 12) {
              HStack(alignment: .bottom, spacing: 20) {
                // Player Current Score
                Text(viewModel.displayScore(for: .player))
                  .font(.system(size: 90, weight: .bold))
                  .foregroundColor(.white)
                
                // Player Games per Set
                VStack(alignment: .leading, spacing: 4) {
                  ForEach(0..<viewModel.match.state.currentSetIndex + 1, id: \.self) { setIndex in
                    HStack(spacing: 8) {
                      Text("\(setIndex + 1)")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                      Text("\(viewModel.gamesInSet(setIndex, for: .player))")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(minWidth: 40, alignment: .trailing)
                    }
                  }
                }
              }
              
              Text("YOUR TEAM")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            }
          }
          .padding(.horizontal)
          
          Spacer()
          
          // Bottom Sheet
          VStack(spacing: 0) {
            // Top Bar with Timer and Controls
            HStack(spacing: 20) {
              // Progress Indicator
              ZStack {
                Circle()
                  .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                  .frame(width: 50, height: 50)
                
                Circle()
                  .trim(from: 0, to: viewModel.progressPercentage)
                  .stroke(Color.yellow, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                  .frame(width: 50, height: 50)
                  .rotationEffect(.degrees(-90))
                
                Image(systemName: "clock")
                  .foregroundColor(.yellow)
              }
              
              Spacer()
              
              // Timer
              Text(viewModel.formattedElapsedTime)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
              
              Spacer()
              
              // Cancel Button
              Button(action: {
                viewModel.cancel()
              }) {
                Image(systemName: "xmark.circle.fill")
                  .font(.system(size: 50))
                  .foregroundColor(.red)
              }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            // Play/Pause Button
            Button(action: {
              viewModel.togglePlayPause()
            }) {
              ZStack {
                Circle()
                  .fill(Color(white: 0.2))
                  .frame(width: 120, height: 120)
                
                Image(systemName: viewModel.state == .playing ? "pause" : "play.fill")
                  .font(.system(size: 50))
                  .foregroundColor(.white)
              }
            }
            .padding(.vertical, 30)
          }
          .frame(maxWidth: .infinity)
          .background(Color(white: 0.15))
          .cornerRadius(30, corners: [.topLeft, .topRight])
        }
        
        // Tap Areas for Scoring - Only cover the upper area, not the bottom sheet
        if viewModel.state == .playing {
          GeometryReader { geo in
            HStack(spacing: 0) {
              // Your Team Tap Area (Left Half)
              Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                  viewModel.scorePoint(for: .player)
                }
              
              // Opponent Tap Area (Right Half)
              Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                  viewModel.scorePoint(for: .opponent)
                }
            }
            .frame(height: geo.size.height - 250) // Exclude bottom sheet area
          }
        }
      }
    }
    .navigationBarBackButtonHidden(true)
    .alert("Cancel Match", isPresented: $viewModel.showCancelAlert) {
      Button("Cancel Match", role: .destructive) {
        router.navigateToRoot()
      }
      Button("Continue Playing", role: .cancel) { }
    } message: {
      Text("Are you sure you want to cancel this match? All progress will be lost.")
    }
    .onAppear {
      viewModel.setDuration(appState.matchDuration)
    }
    .onChange(of: viewModel.state) { newState in
      if newState == .finished, let winner = viewModel.match.state.winner {
        let session = Session(
          date: Date(),
          duration: viewModel.elapsedTime,
          winner: winner,
          sets: viewModel.match.state.sets
        )
        appState.setCompletedSession(session)
        router.navigate(to: .summary)
      }
    }
  }
}

struct ServePositionView: View {
  let currentPosition: ServePosition
  
  var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 8) {
        QuadrantBox(isActive: currentPosition == .topLeft)
        QuadrantBox(isActive: currentPosition == .topRight)
      }
      HStack(spacing: 8) {
        QuadrantBox(isActive: currentPosition == .bottomLeft)
        QuadrantBox(isActive: currentPosition == .bottomRight)
      }
    }
  }
}

struct QuadrantBox: View {
  let isActive: Bool
  
  var body: some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(isActive ? Color.yellow : Color.cyan)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct SetIndicatorsView: View {
  let sets: [SetScore]
  
  var body: some View {
    HStack(spacing: 12) {
      ForEach(Array(sets.enumerated()), id: \.offset) { index, set in
        VStack(spacing: 4) {
          Text("Set \(index + 1)")
            .font(.caption2)
            .foregroundColor(.secondary)
          
          HStack(spacing: 4) {
            Text("\(set.playerGames)")
              .font(.caption)
              .foregroundColor(.white)
            Text("-")
              .font(.caption2)
              .foregroundColor(.secondary)
            Text("\(set.opponentGames)")
              .font(.caption)
              .foregroundColor(.green)
          }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(white: 0.2))
        .cornerRadius(6)
      }
    }
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}

#Preview {
  MatchView()
}
