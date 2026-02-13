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
          Color.accentColor.opacity(0.8),
          Color.accentColor.opacity(0.3),
          Color(uiColor: .systemBackground)
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()
      
      VStack(spacing: 0) {
        winnerPodium()
          .padding(.vertical, 30)
        
        timePlayed()
          .padding(.vertical, 30)
        
        finalScore()
        
        Spacer()
        
        finishButton()
      } //: VSTACK
    } //: ZSTACK
    .navigationBarBackButtonHidden(true)
    .onAppear {
      if let completedSession = appState.completedSession {
        viewModel.loadSession(completedSession)
      }
    }
    .preferredColorScheme(.dark)
  }
}

private extension SummaryView {
  @ViewBuilder
  func winnerPodium() -> some View {
    Image(systemName: "trophy.fill")
      .font(.system(size: 100))
      .foregroundColor(.yellow)
      .shadow(color: .yellow.opacity(0.5), radius: 20)
    
    Text(viewModel.winnerText)
      .font(.system(size: 42, weight: .bold, design: .rounded))
      .foregroundColor(.primary)
  }
  
  @ViewBuilder
  func timePlayed() -> some View {
    VStack(spacing: 10) {
      Text("Time Played")
        .font(.headline)
        .fontDesign(.rounded)
        .foregroundColor(.secondary)
      
      Text(viewModel.formattedElapsedTime)
        .font(.system(size: 36, weight: .medium, design: .rounded))
        .foregroundColor(.plainText)
    } //: VSTACK
  }
  
  @ViewBuilder
  func finalScore() -> some View {
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
              Text("\(set.opponentGames)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.accentColor)
              
              Divider()
                .frame(width: 40)
              
              Text("\(set.playerGames)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.plainText)
            }
            .padding()
            .background(.button)
            .cornerRadius(12)
          } //: VSTACK
        } //: FOR EACH
      } //: HSTACK
    } //: VSTACK
  }
  
  @ViewBuilder
  func finishButton() -> some View {
    Button {
      router.navigateToRoot()
    } label: {
      Text("Finish")
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .cornerRadius(12)
    }
    .glassEffect(.regular.tint(.accentColor.opacity(0.8)).interactive())
    .padding(.horizontal)
    .padding(.bottom, 40)
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
  let viewModel = SummaryViewModel()
  let router = Router()
  let appState = AppState()
  
  //viewModel.loadSession(session)
  
  NavigationView {
    SummaryView()
      .preferredColorScheme(.dark)
      .onAppear{
        viewModel.loadSession(session)
      }
  }
  .environmentObject(viewModel)
  .environmentObject(router)
  .environmentObject(appState)
}
