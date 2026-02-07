//
//  SessionsView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import SwiftUI

struct SessionsView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var viewModel: SessionsViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var appState: AppState
  
  // MARK: - BODY
  var body: some View {
    ZStack {
      switch viewModel.state {
        case .empty:
          emptyStateView()
        case .history(let sessions):
          sessionListStateView(sessions: sessions)
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

private extension SessionsView {
  @ViewBuilder
  func emptyStateView() -> some View {
    VStack() {
      Spacer()
      
      Image(systemName: "tennisball.circle.fill")
        .font(.system(size: 80))
        .symbolRenderingMode(.hierarchical)
        .foregroundColor(.accentColor)
        .padding(.bottom, 16)
      
      
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
  func sessionListStateView(sessions: [Session]) -> some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        ForEach(sessions) { session in
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
    }
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
  let viewModel = SessionsViewModel()
  let appState = AppState()
  return ZStack {
    NavigationView {
      SessionsView()
    }
  }
  .environmentObject(viewModel)
  .environmentObject(appState)
}
