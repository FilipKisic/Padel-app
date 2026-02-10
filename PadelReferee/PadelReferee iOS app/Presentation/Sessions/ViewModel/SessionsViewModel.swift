//
//  SessionsViewModel.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation
import Combine

class SessionsViewModel: ObservableObject {
  @Published var state: SessionHistoryState
  
  private let userDefaultsKey = "savedSessions"
  
  init(state: SessionHistoryState = SessionHistoryState()) {
    self.state = state
    loadSessions()
  }
  
  func addSession(_ session: Session) {
    state.sessionHistory.insert(session, at: 0)
    saveSessions()
  }
  
  func deleteSession(_ session: Session) {
    state.sessionHistory.removeAll { $0.id == session.id }
    saveSessions()
  }
  
  private func loadSessions() {
    if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
       let decoded = try? JSONDecoder().decode([Session].self, from: data) {
      state.sessionHistory = decoded
    }
  }
  
  private func saveSessions() {
    if let encoded = try? JSONEncoder().encode(state.sessionHistory) {
      UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
    }
  }
}
