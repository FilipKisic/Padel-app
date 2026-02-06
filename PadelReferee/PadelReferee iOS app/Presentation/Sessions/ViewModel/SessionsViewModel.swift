//
//  SessionsViewModel.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation
import Combine

class SessionsViewModel: ObservableObject {
  @Published var state: SessionsState = .empty
  
  private var sessions: [SessionModel] = []
  private let userDefaultsKey = "savedSessions"
  
  init() {
    loadSessions()
  }
  
  func addSession(_ session: SessionModel) {
    sessions.insert(session, at: 0)
    saveSessions()
    updateState()
  }
  
  func deleteSession(_ session: SessionModel) {
    sessions.removeAll { $0.id == session.id }
    saveSessions()
    updateState()
  }
  
  private func loadSessions() {
    if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
       let decoded = try? JSONDecoder().decode([SessionModel].self, from: data) {
      sessions = decoded
    }
    updateState()
  }
  
  private func saveSessions() {
    if let encoded = try? JSONEncoder().encode(sessions) {
      UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
    }
  }
  
  private func updateState() {
    state = sessions.isEmpty ? .empty : .history(sessions)
  }
}
