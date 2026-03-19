//
//  WatchPadelRefereeApp.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 22.02.2026..
//

import SwiftUI
import SwiftData

@main
struct WatchPadelReferee_Watch_AppApp: App {
  private let container: ModelContainer
  
  init() {
    WatchConnectivityManager.shared.startSession()
    
    let schema = Schema([Session.self, SetScoreData.self])
    let config = ModelConfiguration(
      cloudKitDatabase: .automatic
    )
    do {
      container = try ModelContainer(for: schema, configurations: [config])
    } catch {
      fatalError("Failed to create ModelContainer: \(error)")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      MasterRouteView {
        StartView()
      }
    }
    .modelContainer(container)
  }
}
