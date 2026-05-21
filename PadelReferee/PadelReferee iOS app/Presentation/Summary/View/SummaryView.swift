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

        healthMetrics()
          .padding(.vertical, 20)

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
    .onChange(of: appState.isWaitingForHealthData) { _, waiting in
      if !waiting, let session = appState.completedSession {
        viewModel.updateHealthData(calories: session.calories, averageHeartRate: session.averageHeartRate)
      }
    }
    .preferredColorScheme(.dark)
    
  }
}

private extension SummaryView {
  @ViewBuilder
  func winnerPodium() -> some View {
    if let winnerText = viewModel.winnerText {
      Image(systemName: "trophy.fill")
        .font(.system(size: 100))
        .foregroundColor(.yellow)
        .shadow(color: .yellow.opacity(0.5), radius: 20)
      
      Text(LocalizedStringKey(winnerText))
        .font(.system(size: 42, weight: .bold, design: .rounded))
        .foregroundColor(.primary)
    } else {
      Image(systemName: "figure.racquetball")
        .font(.system(size: 80))
        .foregroundColor(.gray)
      
      Text("session.ended-early.message")
        .font(.system(size: 32, weight: .bold, design: .rounded))
        .foregroundColor(.secondary)
    }
  }
  
  @ViewBuilder
  func timePlayed() -> some View {
    VStack(spacing: 10) {
      Text("summary.time-played")
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
      Text("summary.final-score")
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
  func healthMetrics() -> some View {
    if appState.isWaitingForHealthData {
      VStack(spacing: 8) {
        ProgressView()
          .tint(.secondary)
        Text("summary.health-data.loading")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding(.vertical, 10)
    } else if viewModel.calories > 0 || viewModel.averageHeartRate > 0 {
      HStack(spacing: 50) {
        VStack(spacing: 6) {
          Image(systemName: "flame.fill")
            .foregroundColor(.orange)
            .font(.title2)
          Text(String(format: "%.0f", viewModel.calories))
            .font(.system(size: 26, weight: .medium, design: .rounded))
            .foregroundColor(.plainText)
          Text("summary.calories")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        VStack(spacing: 6) {
          Image(systemName: "heart.fill")
            .foregroundColor(.red)
            .font(.title2)
          Text(String(format: "%.0f", viewModel.averageHeartRate))
            .font(.system(size: 26, weight: .medium, design: .rounded))
            .foregroundColor(.plainText)
          Text("summary.heart-rate")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
    }
  }
  
  @ViewBuilder
  func finishButton() -> some View {
    if #available(iOS 26.0, *) {
      Button {
        router.navigateToRoot()
      } label: {
        Text("summary.button.title")
          .font(.headline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .cornerRadius(12)
      }
      .glassEffect(.regular.tint(.accentColor.opacity(0.8)).interactive())
      .scenePadding()
    } else {
      Button {
        router.navigateToRoot()
      } label: {
        Text("summary.button.title")
          .font(.headline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
      }
      .buttonStyle(.borderedProminent)
      .tint(.accent)
      .scenePadding()
    }
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
