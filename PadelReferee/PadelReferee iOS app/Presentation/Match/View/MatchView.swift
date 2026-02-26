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
  
  @Environment(\.verticalSizeClass) private var verticalSizeClass
  
  // MARK: - BODY
  var body: some View {
    Group {
      if verticalSizeClass == .compact {
        landscapeBody
      } else {
        portraitBody
      }
    }
    .navigationBarBackButtonHidden(true)
    .alert("Cancel Match", isPresented: $viewModel.matchState.showCancelAlert) {
      Button("Cancel Match", role: .destructive) {
        router.navigateToRoot()
      }
      Button("Continue Playing", role: .cancel) { }
    } message: {
      Text("Are you sure you want to cancel this match? All progress will be lost.")
    }
    .onAppear {
      viewModel.setDuration(appState.matchDuration)
      if appState.isWatchInitiated {
        viewModel.play()
        appState.isWatchInitiated = false
      }
    }
    .onChange(of: viewModel.matchState.phase) { _, newPhase in
      if newPhase == .finished, let winner = viewModel.match.config.winner {
        let session = Session(
          date: Date(),
          duration: viewModel.matchState.elapsedTime,
          winner: winner,
          sets: viewModel.match.config.sets
        )
        appState.setCompletedSession(session)
        router.navigate(to: .summary)
      }
    }
    .preferredColorScheme(.dark)
  }
  
  // MARK: - PORTRAIT BODY
  private var portraitBody: some View {
    VStack(spacing: 0) {
      servePositionDisplay(currentPosition: viewModel.match.config.servePosition)
        .frame(height: 100)
        .padding(.horizontal, 20)
      
      Spacer()
      
      VStack(spacing: 0) {
        opponentGameAndSetScore()
        
        RoundedRectangle(cornerRadius: 10)
          .fill(.cyan)
          .frame(height: 5)
        
        playerGameAndSetScore()
      }
      .padding(.horizontal, 20)
      
      Spacer()
      
      bottomSheet()
    } //: VSTACK
  }
  
  // MARK: - LANDSCAPE BODY
  private var landscapeBody: some View {
    HStack(spacing: 0) {
      // LEFT: Opponent score panel
      landscapeScorePanel(for: .opponent)
      
      // CENTER: Controls
      landscapeControlPanel()
      
      // RIGHT: Player score panel
      landscapeScorePanel(for: .player)
    } //: HSTACK
    .ignoresSafeArea(.keyboard)
  }
}

// MARK: - EXTENSIONS
private extension MatchView {
  // MARK: - LANDSCAPE HELPERS
  @ViewBuilder
  func landscapeScorePanel(for team: Team) -> some View {
    let isOpponent = team == .opponent
    VStack(spacing: 0) {
      Text(isOpponent ? "Opponent" : "Your team")
        .textCase(.uppercase)
        .font(.system(size: 14, weight: .medium, design: .rounded))
        .foregroundColor(isOpponent ? .accent : .primary)
        .padding(.top, 12)
      
      HStack(spacing: 16) {
        ForEach(0..<3, id: \.self) { setIndex in
          VStack(spacing: 2) {
            Text("\(setIndex + 1)")
              .font(.system(size: 14))
              .foregroundColor(viewModel.match.config.currentSetIndex == setIndex ? .white : .gray)
            Text("\(viewModel.gamesInSet(setIndex, for: team))")
              .font(.system(size: 36, weight: .medium, design: .rounded))
              .foregroundColor(.green)
          } //: VSTACK
        }
      } //: HSTACK
      .padding(.top, 8)
      
      Spacer()
      
      Text(viewModel.displayScore(for: team))
        .font(.system(size: 72, weight: .bold, design: .rounded))
        .foregroundColor(isOpponent ? .accent : .primary)
      
      Spacer()
      
      Button {
        if viewModel.matchState.phase == .playing {
          viewModel.scorePoint(for: team)
        }
      } label: {
        Text("+15")
          .font(.system(size: 22, weight: .semibold, design: .rounded))
          .foregroundStyle(isOpponent ? AnyShapeStyle(.accent) : AnyShapeStyle(.plainText))
      }
      .frame(width: 75, height: 75)
      .background(.button)
      .clipShape(Circle())
      .padding(.bottom, 12)
    } //: VSTACK
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.sheet)
  }
  
  @ViewBuilder
  func landscapeControlPanel() -> some View {
    VStack(spacing: 8) {
      servePositionDisplay(currentPosition: viewModel.match.config.servePosition)
        .frame(width: 72, height: 72)
        .padding(.top, 12)
      
      Spacer()
      
      Text(viewModel.formattedRemainingTime)
        .font(.system(size: 32, weight: .medium, design: .rounded))
        .foregroundColor(.yellow)
      
      Button {
        viewModel.togglePlayPause()
      } label: {
        Image(systemName: viewModel.matchState.phase == .playing ? "pause" : "play.fill")
          .font(.system(size: 36))
          .foregroundColor(.white)
      }
      .frame(width: 90, height: 90)
      .background(.button)
      .clipShape(Circle())
      
      Spacer()
      
      HStack {
        undoWithProgressIndicator()
        Spacer()
        Button {
          viewModel.cancel()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 36))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, .red)
        }
      } //: HSTACK
      .padding(.horizontal, 12)
      .padding(.bottom, 12)
    } //: VSTACK
    .frame(width: 140, maxHeight: .infinity)
  }
  
  // MARK: - PORTRAIT HELPERS
  @ViewBuilder
  func servePositionDisplay(currentPosition: ServePosition) -> some View {
    VStack(spacing: 8) {
      HStack(spacing: 8) {
        quadrantBox(isActive: currentPosition == .topLeft)
        quadrantBox(isActive: currentPosition == .topRight)
      } //: HSTACK
      HStack(spacing: 8) {
        quadrantBox(isActive: currentPosition == .bottomLeft)
        quadrantBox(isActive: currentPosition == .bottomRight)
      } //: HSTACK
    } //: VSTACK
  }
  
  @ViewBuilder
  func quadrantBox(isActive: Bool) -> some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(isActive ? Color.yellow : Color.cyan)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  @ViewBuilder
  func opponentGameAndSetScore() -> some View {
    HStack(alignment: .top, spacing: 0) {
      // Opponent Current Score
      Text(viewModel.displayScore(for: .opponent))
        .font(.system(size: 96, weight: .bold, design: .rounded))
        .foregroundColor(.accent)
      
      Spacer()
      
      VStack(alignment: .leading) {
        Text("Opponent")
          .textCase(.uppercase)
          .font(.system(size: 20, weight: .medium, design: .rounded))
          .foregroundColor(.accent)
        
        HStack(spacing: 25) {
          VStack {
            Text("1")
              .font(.system(size: 18))
              .foregroundColor(viewModel.match.config.currentSetIndex == 0 ? .white : .gray)
            Text("\(viewModel.gamesInSet(0, for: .opponent))")
              .font(.system(size: 48, weight: .medium, design: .rounded))
              .foregroundColor(.green)
          } //: VSTACK
          VStack {
            Text("2")
              .font(.system(size: 18))
              .foregroundColor(viewModel.match.config.currentSetIndex == 1 ? .white : .gray)
            Text("\(viewModel.gamesInSet(1, for: .opponent))")
              .font(.system(size: 48, weight: .medium, design: .rounded))
              .foregroundColor(.green)
          } //: VSTACK
          VStack {
            Text("3")
              .font(.system(size: 18))
              .foregroundColor(viewModel.match.config.currentSetIndex == 2 ? .white : .gray)
            Text("\(viewModel.gamesInSet(2, for: .opponent))")
              .font(.system(size: 48, weight: .medium, design: .rounded))
              .foregroundColor(.green)
          } //: VSTACK
        } //: HSTACK
        
      } //: VSTACK
    } //: HSTACK
  }
  
  @ViewBuilder
  func playerGameAndSetScore() -> some View {
    HStack(spacing: 0) {
      // Opponent Current Score
      Text(viewModel.displayScore(for: .player))
        .font(.system(size: 96, weight: .bold, design: .rounded))
      
      Spacer()
      
      VStack(alignment: .leading) {
        HStack(spacing: 25) {
          Text("\(viewModel.gamesInSet(0, for: .player))")
            .font(.system(size: 48, weight: .medium, design: .rounded))
          Text("\(viewModel.gamesInSet(1, for: .player))")
            .font(.system(size: 48, weight: .medium, design: .rounded))
          Text("\(viewModel.gamesInSet(2, for: .player))")
            .font(.system(size: 48, weight: .medium, design: .rounded))
        } //: HSTACK
        Text("Your team")
          .textCase(.uppercase)
          .font(.system(size: 20, weight: .medium, design: .rounded))
      } //: VSTACK
    } //: HSTACK
  }
  
  @ViewBuilder
  func bottomSheet() -> some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        undoWithProgressIndicator()
        
        Spacer()
        
        Text(viewModel.formattedRemainingTime)
          .font(.system(size: 48, weight: .medium, design: .rounded))
          .foregroundColor(.yellow)
        
        Spacer()
        
        Button {
          viewModel.cancel()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 50))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, .red)
        }
      } //: HSTACK
      .padding(.horizontal, 20)
      .padding(.top, 20)
      
      HStack(alignment: .bottom) {
        VStack {
          Text("Opponent")
            .textCase(.uppercase)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundStyle(.accent)
          
          Button {
            if viewModel.matchState.phase == .playing {
              viewModel.scorePoint(for: .opponent)
            }
          } label: {
            Text("+15")
              .font(.system(size: 24, weight: .semibold, design: .rounded))
              .foregroundStyle(.accent)
          }
          .frame(width: 85, height: 85)
          .background(.button)
          .clipShape(Circle())
        } //: VSTACK
        
        Spacer()
        
        Button {
          viewModel.togglePlayPause()
        } label: {
          Image(systemName: viewModel.matchState.phase == .playing ? "pause" : "play.fill")
            .font(.system(size: 50))
            .foregroundColor(.white)
        }
        .frame(width: 130, height: 130)
        .background(.button)
        .clipShape(Circle())
        
        Spacer()
        
        VStack {
          Text("Your team")
            .textCase(.uppercase)
            .font(.system(size: 12, weight: .medium, design: .rounded))
          
          Button {
            if viewModel.matchState.phase == .playing {
              viewModel.scorePoint(for: .player)
            }
          } label: {
            Text("+15")
              .font(.system(size: 24, weight: .semibold, design: .rounded))
              .foregroundStyle(.plainText)
          }
          .frame(width: 85, height: 85)
          .background(.button)
          .clipShape(Circle())
        } //: VSTACK
      } //: HSTACK
      .padding(.vertical, 30)
      .padding(.horizontal, 20)
      
    } //: VSTACK
    .frame(maxWidth: .infinity)
    .background(.sheet)
    .cornerRadius(30)
  }
  
  @ViewBuilder
  func undoWithProgressIndicator() -> some View {
    ZStack {
      Circle()
        .stroke(.yellow.opacity(0.3), lineWidth: 6)
        .frame(width: 50, height: 50)
      
      Circle()
        .trim(from: 0, to: viewModel.progressPercentage)
        .stroke(.yellow, style: StrokeStyle(lineWidth: 6, lineCap: .round))
        .frame(width: 50, height: 50)
        .rotationEffect(.degrees(-90))
      
      Button {
        viewModel.undo()
      }
      label: {
        Image(systemName: "arrow.uturn.backward")
          .font(.system(size: 24))
          .foregroundColor(.yellow)
      }
    }
  }
}

// MARK: - PREVIEW
#Preview("Portrait") {
  let viewModel = MatchViewModel()
  let appState = AppState()
  NavigationView {
    MatchView()
      .preferredColorScheme(.dark)
  }
  .environmentObject(viewModel)
  .environmentObject(appState)
}

#Preview("Landscape") {
  let viewModel = MatchViewModel()
  let appState = AppState()
  NavigationView {
    MatchView()
      .preferredColorScheme(.dark)
  }
  .environmentObject(viewModel)
  .environmentObject(appState)
  .previewInterfaceOrientation(.landscapeLeft)
}
