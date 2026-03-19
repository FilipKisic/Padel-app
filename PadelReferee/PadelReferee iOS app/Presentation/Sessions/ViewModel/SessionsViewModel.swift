//
//  SessionsViewModel.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation
import SwiftData

@Observable
class SessionsViewModel {
  private var modelContext: ModelContext?
  
  func configure(with modelContext: ModelContext) {
    self.modelContext = modelContext
  }
  
  func addSession(_ session: Session) {
    modelContext?.insert(session)
    try? modelContext?.save()
  }
  
  func deleteSession(_ session: Session) {
    modelContext?.delete(session)
    try? modelContext?.save()
  }
}
