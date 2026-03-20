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
      router.navigateToRoot()
      phoneConnectivity.peerSessionEnded = false
    }
  }
}
