//
//  SessionsView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import SwiftUI

struct SessionHistoryView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var viewModel: SessionsViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var appState: AppState
  
  // MARK: - BODY
  var body: some View {
    ZStack {
      if viewModel.state.sessionHistory.isEmpty {
        emptyStateView()
      } else {
        sessionListStateView()
      }
    }
    .navigationTitle("Sessions")
    .preferredColorScheme(.dark)
    .onAppear {
      if let completedSession = appState.completedSession {
        viewModel.addSession(completedSession)
        appState.reset()
      }
    }
  }
}

// MARK: - EXTENSIONS
private extension SessionHistoryView {
  @ViewBuilder
  func emptyStateView() -> some View {
    VStack() {
      Spacer()
      
      Image(systemName: "tennisball.circle.fill")
        .font(.system(size: 50))
        .symbolRenderingMode(.hierarchical)
        .foregroundColor(.accentColor)
        .padding(.bottom)
      
      
      Text("No sessions yet")
        .font(.title2)
        .fontWeight(.semibold)
        .padding(.bottom, 2)
      
      Text("Let's play some Padel")
        .font(.title3)
        .foregroundColor(.secondary)
      
      Spacer()
      
      startNewSessionButtonView()
    }
  }
  
  @ViewBuilder
  func sessionListStateView() -> some View {
    VStack {
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(viewModel.state.sessionHistory) { session in
            SessionCard(session: session)
              .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                  viewModel.deleteSession(session)
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              }
          }
        }
        .padding()
        .padding(.bottom, 80)
      } //: SCROLL VIEW
      startNewSessionButtonView()
    } //: VSTACK
  }
  
  @ViewBuilder
  func startNewSessionButtonView() -> some View {
    Button {
      router.navigate(to: .newSession)
    } label: {
      Text("Start new session")
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .cornerRadius(12)
    }
    .glassEffect(.regular.tint(.accentColor.opacity(0.8)).interactive())
    .padding()
  }
}

// MARK: - PREVIEW
#Preview {
  let session = Session(
    id: UUID(),
    date: Date(),
    duration: 3600,
    winner: .player,
    sets: [
      SetScore(playerGames: 6, opponentGames: 4),
      SetScore(playerGames: 3, opponentGames: 6),
      SetScore(playerGames: 7, opponentGames: 5)
    ]
  )
  let viewModel = SessionsViewModel()
  let appState = AppState()
  
  viewModel.state.sessionHistory = [session]
  
  return ZStack {
    NavigationView {
      SessionHistoryView()
    }
  }
  .environmentObject(viewModel)
  .environmentObject(appState)
}
