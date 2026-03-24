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
      if session.winner == .player {
        Image(systemName: "trophy.circle.fill")
          .font(.system(size: 40))
          .symbolRenderingMode(.hierarchical)
          .foregroundColor(.accentColor)
      } else {
        Image(systemName: "figure.racquetball.circle.fill")
          .font(.system(size: 40))
          .symbolRenderingMode(.hierarchical)
          .foregroundColor(session.isCompleted ? .accentColor : .gray)
      }
      
      Spacer()
      
      VStack(alignment: .leading) {
        if let winner = session.winner {
          Text(winner == .player ? "session.your-team.won.message" : "session.opponent.won.message")
            .font(.title2)
            .bold()
            .foregroundStyle(winner == .player ? Color.white : .accentColor)
        } else {
          Text("session.ended-early.message")
            .font(.title2)
            .bold()
            .foregroundStyle(.secondary)
        }
        Text(session.formattedDate)
          .font(.footnote)
          .fontWeight(.semibold)
          .foregroundStyle(.gray)
      } //: VSTACK
      
      Spacer()
      
      HStack(spacing: 20) {
        Label(session.formattedDuration, systemImage: "timer")
          .foregroundStyle(.yellow)
          .labelStyle(CustomLabel(spacing: 5))
        
        if session.calories > 0 {
          Label(String(format: "%.0f", session.calories), systemImage: "flame.fill")
            .foregroundStyle(.pink)
            .labelStyle(CustomLabel(spacing: 5))
        }
        
        if session.averageHeartRate > 0 {
          Label("\(Int(session.averageHeartRate))", systemImage: "heart.fill")
            .foregroundStyle(.red)
            .labelStyle(CustomLabel(spacing: 5))
        }
      } //: HSTACK
      .font(.footnote)
      .fontWeight(.semibold)
    } //: VSTACK
  }
  
  @ViewBuilder
  func rightColumn() -> some View {
    VStack(spacing: 0) {
      Text("label.opponent")
        .textCase(.uppercase)
        .font(.caption)
        .bold()
        .fontDesign(.rounded)
        .foregroundStyle(.accent)
      
      HStack {
        ForEach(Array(session.sets.enumerated()), id: \.offset) { index, set in
          VStack {
            Text("\(index + 1)")
              .font(.subheadline)
              .foregroundStyle(.gray)
            Text("\(set.opponentGames)")
              .font(.title)
              .bold()
              .fontDesign(.rounded)
              .foregroundStyle(.accent)
          } //: VSTACK
        }
      } //: HSTACK
      
      RoundedRectangle(cornerRadius: 5)
        .frame(width: 80, height: 2)
        .foregroundStyle(.cyan)
        .padding(.vertical, 5)
      
      HStack {
        ForEach(Array(session.sets.enumerated()), id: \.offset) { _, set in
          Text("\(set.playerGames)")
            .font(.title)
            .fontDesign(.rounded)
            .bold()
        }
      } //: HSTACK
      
      Text("label.your-team")
        .textCase(.uppercase)
        .font(.caption)
        .bold()
    } //: VSTACK
  }
  
  @ViewBuilder
  func metricsRow() -> some View {
    HStack {
      
    } //: HSTACK
  }
}

// MARK: - CUSTOM LABEL
struct CustomLabel: LabelStyle {
  var spacing: Double = 0.0
  
  func makeBody(configuration: Configuration) -> some View {
    HStack(alignment: .firstTextBaseline, spacing: spacing) {
      configuration.icon
      configuration.title
    }
  }
}

#Preview {
  let sessionPlayerWon = Session(
    id: UUID(),
    date: Date(),
    duration: 3520,
    winner: .player,
    sets: [
      SetScore(playerGames: 6, opponentGames: 3),
      SetScore(playerGames: 3, opponentGames: 8),
      SetScore(playerGames: 7, opponentGames: 1)
    ],
    calories: 527,
    averageHeartRate: 132,
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
    calories: 2,
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
    .scenePadding()
  SessionCard(session: sessionOpponentWon)
    .colorScheme(.dark)
    .scenePadding()
  SessionCard(session: sessionUnfinished)
    .colorScheme(.dark)
    .scenePadding()
}
