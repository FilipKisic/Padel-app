//
//  NewSessionView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 26.02.2026..
//

import SwiftUI

struct NewSessionView: View {
  @State private var selectedDuration = Calendar.current.date(bySettingHour: 1, minute: 30, second: 0, of: Date())!

  // MARK: - BODY
  var body: some View {
    DatePicker(
      "Duration",
      selection: $selectedDuration,
      displayedComponents: .hourAndMinute
    )
    .navigationTitle("Duration")
  }
}

// MARK: - PREVIEW
#Preview {
  NavigationView {
    NewSessionView()
  }
}
