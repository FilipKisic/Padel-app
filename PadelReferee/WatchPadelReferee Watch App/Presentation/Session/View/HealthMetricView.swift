//
//  HealthMetricView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 06.03.2026..
//

import SwiftUI
import HealthKit
import WatchKit

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
      VStack(alignment: .leading, spacing: -5) {
        Text(viewModel.formattedTime)
          .foregroundStyle(.yellow)
        
        HStack(alignment: .firstTextBaseline, spacing: 0) {
          Text(
            workoutManager.heartRate
              .formatted(.number.precision(.fractionLength(0)))
          )
          
          Image(systemName: "heart.fill")
            .foregroundStyle(.red)
            .font(.system(size: 20))
            .offset(x: 0, y: -topOffset * 0.3)
        } //: HSTACK
        
        Text(
          Measurement(
            value: workoutManager.activeEnergy,
            unit: UnitEnergy.kilocalories
          ).formatted(
            .measurement(
              width: .abbreviated,
              usage: .workout,
              numberFormatStyle: .number.precision(.fractionLength(0)),
            )
          )
        )
        
        averageHeartRate()
      } //: VSTACK
      .font(.system(size: 34, weight: .medium, design: .rounded))
      .frame(maxWidth: .infinity, alignment: .leading)
      .ignoresSafeArea(edges: .bottom)
      .scenePadding()
    }
  }
}

private extension HealthMetricView {
  @ViewBuilder
  func averageHeartRate() -> some View {
    switch WKInterfaceDevice.current().watchSize {
      case .mm38, .mm40, .unknown:
        averageHeartRateSmall()
      case .mm44, .mm49:
        averageHeartRateLarge()
    }
  }
  
  @ViewBuilder
  func averageHeartRateSmall() -> some View {
    HStack {
      Text(
        workoutManager.averageHeartRate
          .formatted(
            .number.precision(.fractionLength(0))
          )
      )
      VStack(alignment: .leading) {
        Text("label.metrics.average")
          .font(
            .system(.footnote, design: .rounded, weight: .semibold)
            .leading(.tight)
          )
        Text("label.metrics.hr")
          .font(
            .system(.footnote, design: .rounded, weight: .semibold)
            .leading(.tight)
          )
      } //: VSTACK
    } //: HSTACK
  }
  
  @ViewBuilder
  func averageHeartRateLarge() -> some View {
    HStack(alignment: .firstTextBaseline, spacing: 0) {
      Text(
        workoutManager.averageHeartRate
          .formatted(
            .number.precision(.fractionLength(0))
          )
      )
      Text("label.metrics.bpm")
        .font(.system(size: 26, weight: .semibold, design: .rounded ))
      
      VStack(alignment: .leading) {
        Text("label.metrics.average")
          .font(
            .system(.footnote, design: .rounded, weight: .semibold)
            .leading(.tight)
          )
        Text("label.metrics.hr")
          .font(
            .system(.footnote, design: .rounded, weight: .semibold)
            .leading(.tight)
          )
      } //: VSTACK
      .offset(x: 3, y: -topOffset * 1.85)
    } //: HSTACK
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
