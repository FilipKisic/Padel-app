//
//  SessionCard.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 07.02.2026..
//

import SwiftUI

struct SessionCard: View {
  // MARK: - PROPERTIES
  let session: Session
  
  // MARK: - BODY
  var body: some View {
    HStack {
      leftColumn()
      Spacer()
      rightColumn()
    }
    .frame(height: 130)
    .padding()
    .background(.card)
    .cornerRadius(10)
    .preferredColorScheme(.dark)
  }
}

// MARK: - EXTENSIONS
private extension SessionCard {
  @ViewBuilder
  func leftColumn() -> some View {
    VStack(alignment: .leading) {
      if session.isCompleted {
        Image(systemName: "trophy.circle.fill")
          .font(.system(size: 45))
          .symbolRenderingMode(.hierarchical)
          .foregroundColor(.accentColor)
      } else {
        Image(systemName: "figure.racquetball")
          .font(.system(size: 40))
          .symbolRenderingMode(.hierarchical)
          .foregroundColor(.gray)
      }
      
      Spacer()
      
      if let winner = session.winner {
        Text(winner == .player ? "session.your-team.won.message" : "session.opponent.won.message")
          .font(.title2)
          .bold()
      } else {
        Text("session.ended-early.message")
          .font(.title2)
          .bold()
          .foregroundStyle(.secondary)
      }
      
      Spacer()
      
      HStack(spacing: 12) {
        Label(session.formattedDuration, systemImage: "clock")
        if session.calories > 0 {
          Label(String(format: "%.0f", session.calories), systemImage: "flame.fill")
            .foregroundStyle(.pink)
        }
        if session.averageHeartRate > 0 {
          Label("\(Int(session.averageHeartRate))", systemImage: "heart.fill")
            .foregroundStyle(.red)
        }
      }
      .font(.caption)
      .foregroundStyle(.gray)
    } //: VSTACK
  }
  
  @ViewBuilder
  func rightColumn() -> some View {
    VStack(spacing: 0) {
      Text("label.opponent")
        .textCase(.uppercase)
        .font(.caption)
        .bold()
        .foregroundStyle(.accent)
      
      HStack (spacing: 20) {
        Text("1")
          .font(.subheadline)
          .foregroundStyle(.gray)
        Text("2")
          .font(.subheadline)
          .foregroundStyle(.gray)
        Text("3")
          .font(.subheadline)
          .foregroundStyle(.gray)
      } //: HSTACK
      
      HStack {
        ForEach(session.sets, id: \.self) { set in
          Text("\(set.opponentGames)")
            .font(.title)
            .bold()
            .foregroundStyle(.accent)
        }
      } //: HSTACK
      
      RoundedRectangle(cornerRadius: 5)
        .frame(width: 80, height: 2)
        .foregroundStyle(.cyan)
        .padding(.vertical, 5)
      
      HStack {
        ForEach(session.sets, id: \.self) {set in
          Text("\(set.playerGames)")
            .font(.title)
            .bold()
        }
      } //: HSTACK
      
      Text("label.your-team")
        .textCase(.uppercase)
        .font(.caption)
        .bold()
    } //: VSTACK
  }
}

#Preview {
  let sessionPlayerWon = Session(
    id: UUID(),
    date: Date(),
    duration: 3520,
    winner: .player,
    sets: [
      SetScore(playerGames: 6, opponentGames: 4),
      SetScore(playerGames: 3, opponentGames: 6),
      SetScore(playerGames: 7, opponentGames: 5)
    ]
  )
  
  let sessionOpponentWon = Session(
    id: UUID(),
    date: Date(),
    duration: 2320,
    winner: .opponent,
    sets: [
      SetScore(playerGames: 6, opponentGames: 2),
      SetScore(playerGames: 2, opponentGames: 6),
      SetScore(playerGames: 6, opponentGames: 4)
    ],
    averageHeartRate: 69,
  )
  let sessionUnfinished = Session(
    id: UUID(),
    date: Date(),
    duration: 1218,
    winner: nil,
    sets: [
      SetScore(playerGames: 6, opponentGames: 4),
      SetScore(playerGames: 0, opponentGames: 0),
      SetScore(playerGames: 0, opponentGames: 0)
    ]
  )
  SessionCard(session: sessionPlayerWon)
    .colorScheme(.dark)
  SessionCard(session: sessionOpponentWon)
    .colorScheme(.dark)
  SessionCard(session: sessionUnfinished)
    .colorScheme(.dark)
}
