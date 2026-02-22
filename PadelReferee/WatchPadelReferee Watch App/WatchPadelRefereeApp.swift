//
//  WatchPadelRefereeApp.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 22.02.2026..
//

import SwiftUI

@main
struct WatchPadelReferee_Watch_AppApp: App {
  init() {
    WatchConnectivityManager.shared.startSession()
  }
  
  var body: some Scene {
    WindowGroup {
      StartView()
    }
  }
}
