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
    ZStack(alignment: .bottom) {
      switch viewModel.state {
        case .empty:
          EmptyStateView()
        case .history(let sessions):
          HistoryStateView(sessions: sessions, onDelete: { session in
            viewModel.deleteSession(session)
          })
      }
      
      Button(action: {
        router.navigate(to: .newSession)
      }) {
        Text("Start new session")
          .font(.headline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.accentColor)
          .cornerRadius(12)
      }
      .padding()
    }
    .navigationTitle("Sessions")
    .onAppear {
      if let completedSession = appState.completedSession {
        viewModel.addSession(completedSession)
        appState.reset()
      }
    }
  }
}

struct EmptyStateView: View {
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "tennisball.circle")
        .font(.system(size: 80))
        .foregroundColor(.accentColor)
      
      Text("No sessions yet")
        .font(.title2)
        .fontWeight(.semibold)
      
      Text("Let's play some Padel")
        .font(.body)
        .foregroundColor(.secondary)
    }
  }
}

struct HistoryStateView: View {
  let sessions: [SessionModel]
  let onDelete: (SessionModel) -> Void
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        ForEach(sessions) { session in
          SessionCard(session: session)
            .swipeActions(edge: .trailing) {
              Button(role: .destructive) {
                onDelete(session)
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
}

struct SessionCard: View {
  let session: SessionModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: session.winner == .player ? "trophy.fill" : "trophy")
          .foregroundColor(session.winner == .player ? .yellow : .secondary)
        
        Text(session.winner == .player ? "You Won!" : "Opponent Won!")
          .font(.headline)
        
        Spacer()
        
        Text(session.formattedDate)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      HStack {
        Text("Time Played:")
          .font(.subheadline)
          .foregroundColor(.secondary)
        Text(session.formattedDuration)
          .font(.subheadline)
          .fontWeight(.semibold)
      }
      
      HStack(spacing: 20) {
        ForEach(Array(session.sets.enumerated()), id: \.offset) { index, set in
          VStack(spacing: 4) {
            Text("Set \(index + 1)")
              .font(.caption)
              .foregroundColor(.secondary)
            HStack(spacing: 8) {
              Text("\(set.playerGames)")
                .font(.title3)
                .fontWeight(.bold)
              Text("-")
                .foregroundColor(.secondary)
              Text("\(set.opponentGames)")
                .font(.title3)
                .fontWeight(.bold)
            }
          }
        }
      }
    }
    .padding()
    .background(Color(uiColor: .secondarySystemGroupedBackground))
    .cornerRadius(12)
  }
}

#Preview {
  SessionsView()
}
