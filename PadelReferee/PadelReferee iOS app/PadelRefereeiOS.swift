//
//  PadelReferee_iOS_appApp.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026..
//

import SwiftUI

@main
struct PadelRefereeiOS: App {
  // MARK: - PROPERTIES
  @AppStorage("isOnboarded") var isOnboarded: Bool = false
  
  // MARK: - CONSTRUCTOR
  init() {
    PhoneConnectivityManager.shared.startSession()
  }
  
  // MARK: - BODY
  var body: some Scene {
    WindowGroup {
      MasterRouteView {
        if isOnboarded { SessionHistoryView() } else { OnboardingView() }
      }
    }
  }
}
