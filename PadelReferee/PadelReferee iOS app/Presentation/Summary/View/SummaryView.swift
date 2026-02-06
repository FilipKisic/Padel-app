//
//  SummaryView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import SwiftUI

struct SummaryView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var viewModel: SummaryViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var appState: AppState
  
  // MARK: - BODY
  var body: some View {
    ZStack(alignment: .bottom) {
      LinearGradient(
        colors: [
          Color.accentColor.opacity(0.6),
          Color.accentColor.opacity(0.3),
          Color(uiColor: .systemBackground)
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()
      
      VStack(spacing: 40) {
        Spacer()
        
        // Trophy Icon
        Image(systemName: "trophy.fill")
          .font(.system(size: 100))
          .foregroundColor(.yellow)
          .shadow(color: .yellow.opacity(0.5), radius: 20)
        
        // Winner Text
        Text(viewModel.winnerText)
          .font(.system(size: 42, weight: .bold))
          .foregroundColor(.primary)
        
        // Time Played
        VStack(spacing: 8) {
          Text("Time Played")
            .font(.headline)
            .foregroundColor(.secondary)
          
          Text(viewModel.formattedElapsedTime)
            .font(.system(size: 36, weight: .semibold, design: .rounded))
            .foregroundColor(.primary)
        }
        
        // Final Score
        VStack(spacing: 16) {
          Text("Final Score")
            .font(.headline)
            .foregroundColor(.secondary)
          
          HStack(spacing: 24) {
            ForEach(Array(viewModel.sets.enumerated()), id: \.offset) { index, set in
              VStack(spacing: 8) {
                Text("Set \(index + 1)")
                  .font(.caption)
                  .foregroundColor(.secondary)
                
                VStack(spacing: 4) {
                  Text("\(set.playerGames)")
                    .font(.title)
                    .fontWeight(set.playerGames > set.opponentGames ? .bold : .regular)
                    .foregroundColor(set.playerGames > set.opponentGames ? .accentColor : .primary)
                  
                  Divider()
                    .frame(width: 40)
                  
                  Text("\(set.opponentGames)")
                    .font(.title)
                    .fontWeight(set.opponentGames > set.playerGames ? .bold : .regular)
                    .foregroundColor(set.opponentGames > set.playerGames ? .accentColor : .primary)
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
              }
            }
          }
        }
        
        Spacer()
        
        // Finish Button
        Button(action: {
          router.navigateToRoot()
        }) {
          Text("Finish")
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
      }
    }
    .navigationBarBackButtonHidden(true)
    .onAppear {
      if let completedSession = appState.completedSession {
        viewModel.loadSession(completedSession)
      }
    }
  }
}

#Preview {
  SummaryView()
}
