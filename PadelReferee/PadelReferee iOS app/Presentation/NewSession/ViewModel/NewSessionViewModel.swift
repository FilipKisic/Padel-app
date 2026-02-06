//
//  NewSessionViewModel.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation
import Combine

class NewSessionViewModel: ObservableObject {
  @Published var state: NewSessionState = .idle
  @Published var hours: Int = 1
  @Published var minutes: Int = 30
  @Published var seconds: Int = 0
  @Published var showMatch: Bool = false
  
  var selectedDuration: TimeInterval {
    TimeInterval(hours * 3600 + minutes * 60 + seconds)
  }
  
  func startSession() {
    state = .ready(duration: selectedDuration)
    showMatch = true
  }
  
  var isValidDuration: Bool {
    selectedDuration > 0
  }
}
