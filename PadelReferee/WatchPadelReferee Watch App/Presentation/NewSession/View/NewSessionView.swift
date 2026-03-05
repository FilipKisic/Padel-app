//
//  NewSessionView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 26.02.2026..
//

import SwiftUI

struct NewSessionView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var viewModel: SessionViewModel
  
  @State private var selectedDuration = Calendar.current.date(bySettingHour: 1, minute: 30, second: 0, of: Date())!

  // MARK: - BODY
  var body: some View {
    VStack {
      DatePicker(
        "new-session.navigation.title",
        selection: $selectedDuration,
        displayedComponents: .hourAndMinute
      )
      
      Button {
        setDuration()
        viewModel.startTimer()
        router.navigate(to: .session)
      } label: {
        Text("new-session.button")
          .foregroundStyle(.black)
      }
      .buttonStyle(.borderedProminent)
    } //: VSTACK
    .navigationTitle("new-session.navigation.title")
    .padding(.horizontal)
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
