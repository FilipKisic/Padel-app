//
//  MasterRouteView.swift
//  PadelReferee
//
//  Created by Filip Kisić on 06.02.2026..
//

import SwiftUI

struct MasterRouteView<Content: View>: View {
  // MARK: - PROPERTIES
  @StateObject private var router = Router()
  @StateObject private var appState = AppState()
  @StateObject private var iapService = IAPService()
  @StateObject private var newSessionViewModel = NewSessionViewModel()
  @StateObject private var matchViewModel = MatchViewModel()
  @StateObject private var summaryViewModel = SummaryViewModel()
  
  @ObservedObject private var phoneConnectivity = PhoneConnectivityManager.shared
  
  private let content: Content
  
  // MARK: - INITIALIZER
  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content()
  }
  
  // MARK: - BODY
  var body: some View {
    NavigationStack(path: $router.path) {
      content.navigationDestination(for: Router.Route.self) { route in
        router.view(for: route)
      }
    } //: NAVIGATION STACK
    .environmentObject(router)
    .environmentObject(appState)
    .environmentObject(iapService)
    .environmentObject(newSessionViewModel)
    .environmentObject(matchViewModel)
    .environmentObject(summaryViewModel)
    .onReceive(phoneConnectivity.$watchSessionStarted) { started in
      guard started else { return }
      let duration = TimeInterval(phoneConnectivity.watchDurationMinutes * 60)
      appState.setMatchDuration(duration)
      appState.setInitialServePosition(phoneConnectivity.watchInitialServePosition)
      appState.isWatchSession = true
      matchViewModel.handleWatchSessionStarted(durationMinutes: phoneConnectivity.watchDurationMinutes, servePosition: phoneConnectivity.watchInitialServePosition)
      router.navigateToRoot()
      router.navigate(to: .match)
      phoneConnectivity.watchSessionStarted = false
    }
    .onReceive(phoneConnectivity.$peerSessionEnded) { ended in
      guard ended else { return }
      if appState.isWaitingForHealthData {
        // iOS ended first — Watch is confirming with health data; update in place
        appState.updateCompletedSessionHealthData(
          calories: phoneConnectivity.watchCalories,
          averageHeartRate: phoneConnectivity.watchAverageHeartRate
        )
      } else {
        // Watch ended first — build full session with health data and show summary
        var session = matchViewModel.buildCancelledSession()
        session.calories = phoneConnectivity.watchCalories
        session.averageHeartRate = phoneConnectivity.watchAverageHeartRate
        appState.setCompletedSession(session)
        router.navigateToRoot()
        router.navigate(to: .summary)
      }
      phoneConnectivity.peerSessionEnded = false
    }
    .onChange(of: appState.hasExceededFreeLimit) { _, exceeded in
      guard !iapService.isPremium else { return }
      phoneConnectivity.sendLockStatus(isLocked: exceeded)
    }
    .onChange(of: iapService.isPremium) { _, isPremium in
      phoneConnectivity.sendLockStatus(isLocked: !isPremium && appState.hasExceededFreeLimit)
    }
    .onAppear {
      phoneConnectivity.sendLockStatus(isLocked: appState.hasExceededFreeLimit && !iapService.isPremium)
    }
  }
}
