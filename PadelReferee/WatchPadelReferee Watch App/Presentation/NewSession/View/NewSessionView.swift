//
//  NewSessionView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 26.02.2026..
//

import SwiftUI
import WatchKit

struct NewSessionView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var viewModel: SessionViewModel
  @EnvironmentObject private var workoutManager: WorkoutManager
  @EnvironmentObject private var connectivity: WatchConnectivityManager

  @State private var selectedDuration = Calendar.current.date(bySettingHour: 1, minute: 30, second: 0, of: Date())!
  @State private var showLockedAlert = false

  // MARK: - BODY
  var body: some View {
    VStack {
      DatePicker(
        "new-session.navigation.title",
        selection: $selectedDuration,
        displayedComponents: .hourAndMinute
      )
      
      Button {
        if connectivity.isLocked {
          showLockedAlert = true
        } else {
          setDuration()
          WKInterfaceDevice.current().play(.click)
          router.navigate(to: .servePosition)
        }
      } label: {
        Text("label.next")
          .foregroundStyle(.black)
      }
      .buttonStyle(.borderedProminent)
    } //: VSTACK
    .navigationTitle("new-session.duration.title")
    .scenePadding()
    .alert("paywall.watch.alert.title", isPresented: $showLockedAlert) {
      Button("paywall.watch.alert.button", role: .cancel) { }
    } message: {
      Text("paywall.watch.alert.message")
    }
  }
  
  // MARK: - FUNCTIONS
  func setDuration() {
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: selectedDuration)
    let minute = calendar.component(.minute, from: selectedDuration)
    let totalMinutes = hour * 60 + minute
    
    viewModel.setDuration(minutes: totalMinutes)
  }
}

// MARK: - PREVIEW
#Preview {
  let viewModel = SessionViewModel()
  let router = Router()
  
  NavigationView {
    NewSessionView()
  }
  .environmentObject(viewModel)
  .environmentObject(router)
}
