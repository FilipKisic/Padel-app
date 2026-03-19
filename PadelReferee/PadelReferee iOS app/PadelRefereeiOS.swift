//
//  PadelReferee_iOS_appApp.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026..
//

import SwiftUI
import SwiftData

@main
struct PadelRefereeiOS: App {
  // MARK: - PROPERTIES
  @AppStorage("isOnboarded") var isOnboarded: Bool = false
  
  private let container: ModelContainer
  
  // MARK: - CONSTRUCTOR
  init() {
    PhoneConnectivityManager.shared.startSession()
    
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
  
  // MARK: - BODY
  var body: some Scene {
    WindowGroup {
      MasterRouteView {
        if isOnboarded { SessionHistoryView() } else { OnboardingView() }
      }
    }
    .modelContainer(container)
  }
}
