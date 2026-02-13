//
//  NewSessionViewModel.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation
import Combine

class NewSessionViewModel: ObservableObject {
  @Published var state: NewSessionState
  
  init(state: NewSessionState = NewSessionState()) {
    self.state = state
  }
  
  var selectedDuration: TimeInterval {
    TimeInterval(state.hours * 3600 + state.minutes * 60 + state.seconds)
  }
  
  var isValidDuration: Bool {
    selectedDuration > 0
  }
}
