//
//  SessionTavView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 27.02.2026..
//

import SwiftUI
import WatchKit

struct SessionTabView: View {
  // MARK: - PROPERTIES
  @State private var activeTab: SessionTab = .metric
  
  // MARK: - BODY
  var body: some View {
    TabView(selection: $activeTab) {
      ControlsView(activeTab: $activeTab).tag(SessionTab.controls)
      MetricTabView().tag(SessionTab.metric)
      NowPlayingView().tag(SessionTab.nowPlaying)
    }
  }
}

enum SessionTab {
  case controls, metric, nowPlaying
}

struct MetricTabView: View {
  // MARK: - PROPERTIES
  @State private var metricActiveTab: MetricTab = .score
  
  // MARK: - BODY
  var body: some View {
    TabView(selection: $metricActiveTab) {
      SessionView().tag(MetricTab.score)
      HealthMetricView().tag(MetricTab.health)
    }
    .tabViewStyle(.carousel)
    .navigationBarBackButtonHidden()
  }
}

enum MetricTab {
  case score, health
}

// MARK: - PREVIEW
#Preview {
  let router = Router()
  let viewModel = SessionViewModel()
  
  NavigationView {
    SessionTabView()
  }
  .environmentObject(router)
  .environmentObject(viewModel)
}
