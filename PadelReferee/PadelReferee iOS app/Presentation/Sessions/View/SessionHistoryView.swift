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
    .safeAreaBar(edge: .bottom, content: {
      startNewSessionButtonView()
    })
    .navigationTitle("sessions.title")
    .navigationBarBackButtonHidden()
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
      
      
      Text("sessions.empty-state.title")
        .font(.title2)
        .fontWeight(.semibold)
        .padding(.bottom, 2)
      
      Text("sessions.empty-state.message")
        .font(.title3)
        .foregroundColor(.secondary)
      
      Spacer()
    }
  }
  
  @ViewBuilder
  func sessionListStateView() -> some View {
    List {
      ForEach(viewModel.state.sessionHistory) { session in
        SessionCard(session: session)
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              viewModel.deleteSession(session)
            } label: {
              Label("label.delete", systemImage: "trash")
            }
          }
          .listRowSeparator(.hidden)
      }
    } //: LIST VIEW
    .listStyle(.inset)
  }
  
  @ViewBuilder
  func startNewSessionButtonView() -> some View {
    Button {
      router.navigate(to: .newSession)
    } label: {
      Text("sessions.button.title")
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
    }
    .glassEffect(.regular.tint(.accentColor.opacity(0.7)).interactive())
    .padding()
  }
}

// MARK: - PREVIEW
#Preview {
  let session1 = Session(
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
  let session2 = Session(
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
  let session3 = Session(
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
  let session4 = Session(
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
  let session5 = Session(
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
  
  viewModel.state.sessionHistory = [session1, session2, session3, session4, session5]
  return ZStack {
    NavigationView {
      SessionHistoryView()
    }
  }
  .environmentObject(viewModel)
  .environmentObject(appState)
}
