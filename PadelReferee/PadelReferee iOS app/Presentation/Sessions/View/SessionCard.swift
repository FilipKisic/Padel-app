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
      Image(systemName: "trophy.circle.fill")
        .font(.system(size: 45))
        .symbolRenderingMode(.hierarchical)
        .foregroundColor(.accentColor)
      
      Spacer()
      
      Text(session.winner == .player ? "You Won!" : "Opponent Won!")
        .font(.title2)
        .bold()
      
      Spacer()
      
      Text(session.formattedDate)
        .font(.subheadline)
        .foregroundStyle(Color.gray)
    } //: VSTACK
  }
  
  @ViewBuilder
  func rightColumn() -> some View {
    VStack(spacing: 0) {
      Text("Opponent")
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
      
      Text("Your team")
        .textCase(.uppercase)
        .font(.caption)
        .bold()
    } //: VSTACK
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
