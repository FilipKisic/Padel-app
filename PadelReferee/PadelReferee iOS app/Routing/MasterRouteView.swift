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
      appState.isWatchSession = true
      matchViewModel.handleWatchSessionStarted(durationMinutes: phoneConnectivity.watchDurationMinutes)
      router.navigateToRoot()
      router.navigate(to: .match)
      phoneConnectivity.watchSessionStarted = false
    }
    .onReceive(phoneConnectivity.$peerSessionEnded) { ended in
      guard ended else { return }
      let session = matchViewModel.buildCancelledSession()
      appState.setCompletedSession(session)
      router.navigateToRoot()
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
