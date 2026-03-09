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
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var workoutManager: WorkoutManager
  
  // MARK: - BODY
  var body: some View {
    ScrollView {
      VStack(spacing: 10) {
        Image(systemName: "trophy.fill")
          .resizable()
          .frame(width: 40, height: 40)
          .foregroundStyle(.yellow)
          .padding(.top)

        Text(viewModel.winner == .player ? LocalizedStringKey("summary.your-team-won") : LocalizedStringKey("summary.opponent-won"))
          .font(.system(size: 16, weight: .semibold, design: .rounded))
        
        Divider()
        
        if let workout = workoutManager.workout {
          SummaryMetricView(
            title: "summary.duration",
            value: durationString(from: workout)
          )
          
          SummaryMetricView(
            title: "summary.calories",
            value: caloriesString(from: workout)
          )
        }
        
        SummaryMetricView(
          title: "summary.avg-heart-rate",
          value: "\(Int(workoutManager.averageHeartRate)) BPM"
        )
        
        Button {
          workoutManager.resetWorkout()
          router.navigateToRoot()
        } label: {
          Text("summary.rematch")
            .foregroundStyle(.black)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
        .padding(.top, 5)
        
      } //: VSTACK
    } //: SCROLLVIEW
    .navigationTitle("summary.navigation.title")
    .navigationBarBackButtonHidden()
  }
  
  // MARK: - HELPERS
  private func durationString(from workout: HKWorkout) -> String {
    let duration = workout.duration
    let minutes = Int(duration) / 60
    let seconds = Int(duration) % 60
    return String(format: "%d:%02d", minutes, seconds)
  }
  
  private func caloriesString(from workout: HKWorkout) -> String {
    let energy = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
    return String(format: "%.0f kcal", energy)
  }
}

// MARK: - SUMMARY METRIC VIEW
struct SummaryMetricView: View {
  let title: LocalizedStringKey
  let value: String
  
  var body: some View {
    VStack(spacing: 2) {
      Text(title)
        .font(.system(size: 12, weight: .semibold, design: .rounded))
        .foregroundStyle(.gray)
      Text(value)
        .font(.system(size: 20, weight: .medium, design: .rounded))
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
