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
  @StateObject private var sessionsViewModel = SessionsViewModel()
  @StateObject private var newSessionViewModel = NewSessionViewModel()
  @StateObject private var matchViewModel = MatchViewModel()
  @StateObject private var summaryViewModel = SummaryViewModel()
  
  private let content: Content
  
  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    NavigationStack(path: $router.path) {
      content.navigationDestination(for: Router.Route.self) { route in
        router.view(for: route)
      }
    } //: NAVIGATION STACK
    .environmentObject(router)
    .environmentObject(appState)
    .environmentObject(sessionsViewModel)
    .environmentObject(newSessionViewModel)
    .environmentObject(matchViewModel)
    .environmentObject(summaryViewModel)
  }
}
