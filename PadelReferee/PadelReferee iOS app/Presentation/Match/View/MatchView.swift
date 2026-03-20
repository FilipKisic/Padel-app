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
  
  @Environment(\.verticalSizeClass) private var verticalType
  
  // MARK: - BODY
  var body: some View {
    Group {
      if verticalType == .compact {
        horizontalLayout()
      } else {
        verticalLayout()
      }
    }
    .navigationBarBackButtonHidden(true)
    .alert("match.cancel-match.alert.title", isPresented: $viewModel.matchState.showCancelAlert) {
      Button("match.cancel-match.alert.button.confirm.title", role: .destructive) {
        cancelMatch()
      }
      Button("match.cancel-match.alert.button.cancel.title", role: .cancel) { }
    } message: {
      Text("match.cancel-match.alert.description")
    }
    .onAppear {
      startMatchOnAppear()
      UIApplication.shared.isIdleTimerDisabled = true // Keep display ON
    }
    .onDisappear {
      UIApplication.shared.isIdleTimerDisabled = false
    }
    .onChange(of: viewModel.matchState.phase) { _, newPhase in
      finishMatch(newPhase)
    }
    .preferredColorScheme(.dark)
  }
  
  // MARK: - FUNCTIONS
  private func cancelMatch() {
    if !appState.isWatchSession {
      let session = Session(
        date: Date(),
        duration: viewModel.matchState.elapsedTime,
        winner: nil,
        sets: viewModel.match.config.sets
      )
      appState.setCompletedSession(session)
    }
    viewModel.confirmCancel()
    router.navigate(to: .summary)
  }
  
  private func startMatchOnAppear() {
    guard viewModel.matchState.phase != .playing else { return }
    viewModel.setDuration(appState.matchDuration)
    viewModel.play()
  }
  
  private func finishMatch(_ newPhase: MatchPhase) {
    if newPhase == .finished {
      if appState.isWatchSession {
        router.navigateToRoot()
        return
      }
      let session = Session(
        date: Date(),
        duration: viewModel.matchState.elapsedTime,
        winner: viewModel.match.config.winner,
        sets: viewModel.match.config.sets
      )
      appState.setCompletedSession(session)
      router.navigate(to: .summary)
    }
  }
}

// MARK: - EXTENSIONS
private extension MatchView {
  @ViewBuilder
  func verticalLayout() -> some View {
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
  
  @ViewBuilder
  func horizontalLayout() -> some View {
    HStack {
      opponentScoreHorizontal(currentPosition: viewModel.match.config.servePosition)
      
      timerColumnHorizontal()
      
      playerScoreHorizontal(currentPosition: viewModel.match.config.servePosition)
    }
  }
  
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
        Text("label.opponent")
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
        Text("label.your-team")
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
          Text("label.opponent")
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
          Text("label.your-team")
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
  
  @ViewBuilder
  func opponentScoreHorizontal(currentPosition: ServePosition) -> some View {
    VStack {
      Text("label.opponent")
        .textCase(.uppercase)
        .font(.system(size: 48, weight: .medium, design: .rounded))
        .foregroundStyle(.accent)
      
      Text(viewModel.displayScore(for: .opponent))
        .font(.system(size: 242, weight: .bold, design: .rounded))
        .foregroundColor(.accent)
        .frame(height: 240)
      
      HStack(spacing: 8) {
        quadrantBox(isActive: currentPosition == .topLeft)
        quadrantBox(isActive: currentPosition == .topRight)
      } //: HSTACK
    } //: VSTACK
  }
  
  @ViewBuilder
  func timerColumnHorizontal() -> some View {
    VStack(alignment: .center) {
      Image(systemName: "timer")
        .font(.system(size: 48, weight: .medium, design: .rounded))
        .foregroundStyle(.yellow)
        .padding(.bottom, 10)
      
      GeometryReader { geo in
        ZStack(alignment: .bottom) {
          RoundedRectangle(cornerRadius: 20)
            .fill(.yellow.opacity(0.2))
          
          RoundedRectangle(cornerRadius: 20)
            .fill(.yellow)
            .frame(height: geo.size.height * (1 - viewModel.progressPercentage))
            .animation(.linear(duration: 1), value: viewModel.progressPercentage)
        }
      }
      .frame(width: 30)
      .frame(maxHeight: .infinity)
    } //: VSTACK
    .frame(width: 60)
  }
  
  @ViewBuilder
  func playerScoreHorizontal(currentPosition: ServePosition) -> some View {
    VStack {
      Text("label.your-team")
        .textCase(.uppercase)
        .font(.system(size: 48, weight: .medium, design: .rounded))
      
      Text(viewModel.displayScore(for: .player))
        .font(.system(size: 242, weight: .bold, design: .rounded))
        .frame(height: 240)
      
      HStack(spacing: 8) {
        quadrantBox(isActive: currentPosition == .bottomLeft)
        quadrantBox(isActive: currentPosition == .bottomRight)
      } //: HSTACK
    } //: VSTACK
  }
  
}

// MARK: - PREVIEW
#Preview {
  let viewModel = MatchViewModel()
  let appState = AppState()
  
  NavigationView {
    MatchView()
      .preferredColorScheme(.dark)
  }
  .environmentObject(viewModel)
  .environmentObject(appState)
}
