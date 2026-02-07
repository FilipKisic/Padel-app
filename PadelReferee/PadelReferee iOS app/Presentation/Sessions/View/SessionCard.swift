//
//  SessionCard.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 07.02.2026..
//

import SwiftUI

struct SessionCard: View {
  let session: Session
  
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
  SessionCard(session: session)
    .colorScheme(.dark)
}
