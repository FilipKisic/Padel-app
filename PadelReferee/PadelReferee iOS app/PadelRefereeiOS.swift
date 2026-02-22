//
//  PadelReferee_iOS_appApp.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026..
//

import SwiftUI

@main
struct PadelRefereeiOS: App {
  init() {
    PhoneConnectivityManager.shared.startSession()
  }
  
  var body: some Scene {
    WindowGroup {
      MasterRouteView {
        SessionHistoryView()
      }
    }
  }
}
