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
    VStack(alignment: .leading, spacing: 0) {
      winnerPodium()
        .padding(.bottom, 30)
      
      healthSummary()
        .padding(.bottom, 10)
      
      setScoreSummary()
      Spacer()
      
      finishButton()
    } //: VSTACK
    .navigationBarBackButtonHidden(true)
    .scenePadding()
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
    HStack(spacing: 10) {
      if let winnerText = viewModel.winnerText {
        Circle()
          .frame(width: 80, height: 80)
          .foregroundStyle(.card)
          .overlay {
            Image(systemName: "trophy.fill")
              .font(.system(size: 40))
              .foregroundColor(.yellow)
              .shadow(color: .yellow.opacity(0.5), radius: 20)
          }
        
        Text(LocalizedStringKey(winnerText))
          .font(.system(size: 24, weight: .bold, design: .rounded))
          .foregroundColor(.primary)
        
        Spacer()
      } else {
        Circle()
          .frame(width: 80, height: 80)
          .foregroundStyle(.card)
          .overlay {
            Image(systemName: "figure.racquetball")
              .font(.system(size: 40))
              .foregroundColor(.gray)
          }
        
        Text("session.ended-early.message")
          .font(.system(size: 24, weight: .bold, design: .rounded))
          .foregroundColor(.secondary)
        
        Spacer()
      }
    } //: HSTACK
  }
  
  @ViewBuilder
  func healthSummary() -> some View {
    Text("summary.session-details")
      .font(.system(size: 24, weight: .semibold, design: .rounded))
    
    VStack(alignment: .leading, spacing: 0) {
      Text("summary.time-played")
      Text(viewModel.formattedElapsedTime)
        .font(.system(size: 28, weight: .semibold, design: .rounded))
        .foregroundStyle(.yellow)
      
      Divider()
        .padding(.vertical, 10)
      
      HStack {
        VStack(alignment: .leading) {
          Text("summary.calories")
          Text(viewModel.calories.formatted(.number.precision(.fractionLength(0))) + "kcal")
            .font(.system(size: 28, weight: .semibold, design: .rounded)
              .lowercaseSmallCaps()
            )
            .foregroundStyle(.pink)
        } //: VSTACK
        
        Spacer()
        
        VStack(alignment: .leading) {
          Text("summary.heart-rate")
          Text(viewModel.averageHeartRate.formatted(.number.precision(.fractionLength(0))) + "bpm")
            .font(.system(size: 28, weight: .semibold, design: .rounded)
              .lowercaseSmallCaps()
            )
            .foregroundStyle(.red)
        } //: VSTACK
      } //: HSTACK
    } //: VSTACK
    .padding()
    .background(.card)
    .cornerRadius(20)
  }
  
  @ViewBuilder
  func setScoreSummary() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text("summary.teams")
        
        Spacer()
        
        Text("summary.set.first")
          .font(.subheadline)
          .foregroundStyle(.gray)
        
        Text("summary.set.second")
          .foregroundStyle(.gray)
          .font(.subheadline)
        
        Text("summary.set.third")
          .font(.subheadline)
          .foregroundStyle(.gray)
      } //: HSTACK
      
      HStack(spacing: 15) {
        Text("label.opponent")
          .font(.system(size: 28, weight: .semibold, design: .rounded).lowercaseSmallCaps())
        
        Spacer()
        
        ForEach(Array(viewModel.sets.enumerated()), id: \.offset) { index, set in
          Text("\(set.opponentGames)")
            .font(.system(size: 28, weight: .semibold, design: .rounded))
        }
        .padding(.trailing, 10)
      } //: HSTACK
      .foregroundStyle(.accent)
      
      Divider()
        .padding(.vertical, 10)
      
      HStack(spacing: 15) {
        Text("label.your-team")
          .font(.system(size: 28, weight: .semibold, design: .rounded).lowercaseSmallCaps())
        
        Spacer()
        
        ForEach(Array(viewModel.sets.enumerated()), id: \.offset) { index, set in
          Text("\(set.playerGames)")
            .font(.system(size: 28, weight: .semibold, design: .rounded))
        }
        .padding(.trailing, 10)
      } //: HSTACK
    } //: VSTACK
    .padding()
    .background(.card)
    .cornerRadius(20)
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
      } //: VSTACK
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
        } //: VSTACK
        
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
        } //: VSTACK
      } //: HSTACK
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
    }
  }
}


// MARK: - PREVIEW
#Preview {
  let session = Session(
    id: UUID(),
    date: Date(),
    duration: 5337,
    winner: .player,
    sets: [
      SetScore(playerGames: 6, opponentGames: 4),
      SetScore(playerGames: 3, opponentGames: 6),
      SetScore(playerGames: 7, opponentGames: 5)
    ],
    calories: 176,
    averageHeartRate: 122
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
