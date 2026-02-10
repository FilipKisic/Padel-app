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

// PREVIOUS CODE
//VStack(alignment: .leading, spacing: 12) {
//  HStack {
//    Image(systemName: session.winner == .player ? "trophy.fill" : "trophy")
//      .foregroundColor(session.winner == .player ? .yellow : .secondary)
//    
//    Text(session.winner == .player ? "You Won!" : "Opponent Won!")
//      .font(.headline)
//    
//    Spacer()
//    
//    Text(session.formattedDate)
//      .font(.caption)
//      .foregroundColor(.secondary)
//  }
//  
//  HStack {
//    Text("Time Played:")
//      .font(.subheadline)
//      .foregroundColor(.secondary)
//    Text(session.formattedDuration)
//      .font(.subheadline)
//      .fontWeight(.semibold)
//  }
//  
//  HStack(spacing: 20) {
//    ForEach(Array(session.sets.enumerated()), id: \.offset) { index, set in
//      VStack(spacing: 4) {
//        Text("Set \(index + 1)")
//          .font(.caption)
//          .foregroundColor(.secondary)
//        HStack(spacing: 8) {
//          Text("\(set.playerGames)")
//            .font(.title3)
//            .fontWeight(.bold)
//          Text("-")
//            .foregroundColor(.secondary)
//          Text("\(set.opponentGames)")
//            .font(.title3)
//            .fontWeight(.bold)
//        }
//      }
//    }
//  }
//}
//.padding()
//.background(Color(uiColor: .secondarySystemGroupedBackground))
//.cornerRadius(12)

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
        .foregroundStyle(.blue)
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
