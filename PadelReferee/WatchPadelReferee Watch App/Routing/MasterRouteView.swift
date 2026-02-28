//
//  MasterRouteView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 26.02.2026..
//

import SwiftUI

struct MasterRouteView<Content: View>: View {
  // MARK: - PROPERTIES
  @StateObject private var router = Router()
  @StateObject private var sessionViewModel = SessionViewModel()

  @ObservedObject private var watchConnectivity = WatchConnectivityManager.shared

  private let content: Content
  
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
    .environmentObject(sessionViewModel)
    .onReceive(watchConnectivity.$iOSSessionStarted) { started in
      guard started else { return }
      sessionViewModel.setDuration(minutes: watchConnectivity.iOSDurationMinutes)
      router.navigateToRoot()
      router.navigate(to: .session)
      sessionViewModel.startTimer(notifyPeer: false)
      watchConnectivity.iOSSessionStarted = false
    }
  }
}
