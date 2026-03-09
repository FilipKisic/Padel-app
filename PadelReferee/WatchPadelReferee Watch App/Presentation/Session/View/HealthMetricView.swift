//
//  HealthMetricView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 06.03.2026..
//

import SwiftUI
import HealthKit

struct HealthMetricView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var workoutManager: WorkoutManager
  @EnvironmentObject private var viewModel: SessionViewModel
  
  private var topOffset: CGFloat {
    let font = UIFont.preferredFont(forTextStyle: .title2)
    return font.ascender - font.capHeight
  }
  
  // MARK: - BODY
  var body: some View {
    TimelineView(MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date())) { context in
      VStack(alignment: .leading) {
        Text(viewModel.formattedTime)
          .foregroundStyle(.yellow)
        
        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Text(
            workoutManager.heartRate
              .formatted(.number.precision(.fractionLength(0)))
          )
          
          Text("label.metrics.bpm")
            .font(.system(.title2, design: .rounded))
            .bold()
          Image(systemName: "heart.fill")
            .foregroundStyle(.red)
            .font(.system(size: 20))
            .offset(x: 0, y: -topOffset * 0.4)
        } //: HSTACK
        
        Text(
          Measurement(
            value: workoutManager.activeEnergy,
            unit: UnitEnergy.kilocalories
          ).formatted(
            .measurement(
              width: .abbreviated,
              usage: .workout,
              numberFormatStyle: .number,
            )
          )
        )
        
        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Text(
            workoutManager.averageHeartRate
              .formatted(
                .number.precision(.fractionLength(0))
              )
          )
          Text("label.metrics.bpm")
            .font(.system(.title2, design: .rounded))
            .bold()
          Text("label.metrics.average-hr")
            .font(
              .system(.footnote, design: .rounded, weight: .semibold)
              .leading(.tight)
            )
            .lineLimit(2)
            .offset(x: 0, y: -topOffset * 1.75)
        }
      } //: VSTACK
      .font(.system(.title, design: .rounded, weight: .medium))
      .frame(maxWidth: .infinity, alignment: .leading)
      .ignoresSafeArea(edges: .bottom)
      .scenePadding()
    }
  }
}

// MARK: - PREVIEW
#Preview {
  let viewModel = SessionViewModel()
  let workoutManager = WorkoutManager()
  NavigationView {
    HealthMetricView()
  }
  .environmentObject(viewModel)
  .environmentObject(workoutManager)
}

private struct MetricsTimelineSchedule: TimelineSchedule {
  var startDate: Date
  
  init(from startDate: Date) {
    self.startDate = startDate
  }
  
  func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
    PeriodicTimelineSchedule(
      from: self.startDate,
      by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0)
    ).entries(
      from: startDate,
      mode: mode
    )
  }
}
