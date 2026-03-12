//
//  SummaryView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 26.02.2026..
//

import SwiftUI
import HealthKit

struct SummaryView: View {
  @EnvironmentObject private var viewModel: SessionViewModel
  @EnvironmentObject private var workoutManager: WorkoutManager
  @EnvironmentObject private var router: Router
  
  // MARK: - BODY
  var body: some View {
    if workoutManager.workout == nil {
      ProgressView("summary.saving")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
    } else {
      ScrollView {
        VStack(spacing: 10) {
          if viewModel.winner != nil {
            winnerView()
          }
          
          VStack(alignment: .leading) {
            SummaryMetricView(
              title: "summary.duration",
              value: durationFormatter.string(from: workoutManager.workout?.duration ?? .zero) ?? ""
            )
            .accentColor(.yellow)
            
            SummaryMetricView(
              title: "summary.calories",
              value: caloriesString(from: workoutManager.workout!)
            )
            .accentColor(.pink)
            
            SummaryMetricView(
              title: "summary.avg-heart-rate",
              value: "\(Int(workoutManager.averageHeartRate)) BPM"
            )
            .accentColor(.red)
            
            Text("summary.activity-rings")
            ActivityRingsView(healthStore: workoutManager.healthStore)
              .frame(width: 50, height: 50)
          }
        } //: VSTACK
      } //: SCROLLVIEW
      .navigationTitle("summary.navigation.title")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden()
      .scenePadding()
      .ignoresSafeArea(edges: .bottom)
      .onDisappear {
        router.navigateToRoot()
        workoutManager.resetWorkout()
      }
    }
  }
  
  // MARK: - HELPERS
  private var durationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.zeroFormattingBehavior = .pad
    return formatter
  }()
  
  private func caloriesString(from workout: HKWorkout) -> String {
    let energy = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
    return String(format: "%.0f kcal", energy)
  }
}

private extension SummaryView {
  @ViewBuilder
  func winnerView() -> some View {
    Image(systemName: "trophy.fill")
      .resizable()
      .frame(width: 40, height: 40)
      .foregroundStyle(.yellow)
      .padding(.top)
    
    Text(viewModel.winner == .player ? LocalizedStringKey("summary.your-team-won") : LocalizedStringKey("summary.opponent-won"))
      .font(.system(size: 16, weight: .semibold, design: .rounded))
    
    Divider()
  }
}

// MARK: - SUMMARY METRIC VIEW
struct SummaryMetricView: View {
  let title: LocalizedStringKey
  let value: String
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
      Text(value)
        .font(.system(.title2, design: .rounded)
          .lowercaseSmallCaps()
        )
        .foregroundColor(.accentColor)
      Divider()
    }
  }
}

// MARK: - PREVIEW
#Preview {
  let viewModel = SessionViewModel()
  let router = Router()
  let workoutManager = WorkoutManager()
  
  NavigationView {
    SummaryView()
  }
  .environmentObject(viewModel)
  .environmentObject(router)
  .environmentObject(workoutManager)
}
