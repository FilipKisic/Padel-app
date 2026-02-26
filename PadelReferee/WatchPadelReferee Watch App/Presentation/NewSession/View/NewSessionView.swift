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
        "Duration",
        selection: $selectedDuration,
        displayedComponents: .hourAndMinute
      )
      
      Button {
        setDuration()
        router.navigate(to: .session)
      } label: {
        Text("Start Match")
          .foregroundStyle(.black)
      }
      .buttonStyle(.borderedProminent)
    } //: VSTACK
    .navigationTitle("Duration")
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
