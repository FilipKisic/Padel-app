//
//  SessionsView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import SwiftUI
import SwiftData
import CoreData
import Combine

struct SessionHistoryView: View {
  // MARK: - PROPERTIES
  @Query(sort: \Session.date, order: .reverse) private var sessions: [Session]
  @Environment(\.modelContext) private var modelContext
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var appState: AppState
  
  // MARK: - BODY
  var body: some View {
    if #available(iOS 26.0, *) {
      wholeViewGlassUI()
    } else {
      wholeViewStandard()
    }
  }
}

// MARK: - EXTENSIONS
private extension SessionHistoryView {
  
  @available(iOS 26.0, *)
  @ViewBuilder
  func wholeViewGlassUI() -> some View {
    ZStack {
      if sessions.isEmpty {
        emptyStateView()
      } else {
        sessionListStateView()
      }
    }
    .safeAreaBar(edge: .bottom, content: {
      startNewSessionButtonView()
        .scenePadding()
    })
    .navigationTitle("sessions.title")
    .navigationBarBackButtonHidden()
    .preferredColorScheme(.dark)
    .onAppear {
      saveCompletedSessionIfNeeded()
    }
    .onReceive(NotificationCenter.default.publisher(
      for: NSPersistentCloudKitContainer.eventChangedNotification
    ).receive(on: DispatchQueue.main)) { notification in
      handleCloudKitEvent(notification)
    }
  }
  
  @ViewBuilder
  func wholeViewStandard() -> some View {
    ZStack {
      if sessions.isEmpty {
        emptyStateView()
      } else {
        sessionListStateView()
      }
    }
    .navigationTitle("sessions.title")
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          router.navigate(to: .newSession)
        } label: {
          Image(systemName: "plus")
            .font(.title2)
        }
        .buttonStyle(.borderedProminent)
        .clipShape(.circle)
      }
    }
    .preferredColorScheme(.dark)
    .onAppear {
      saveCompletedSessionIfNeeded()
    }
    .onReceive(NotificationCenter.default.publisher(
      for: NSPersistentCloudKitContainer.eventChangedNotification
    ).receive(on: DispatchQueue.main)) { notification in
      handleCloudKitEvent(notification)
    }
  }
  
  func saveCompletedSessionIfNeeded() {
    if let completedSession = appState.completedSession {
      modelContext.insert(completedSession)
      try? modelContext.save()
      appState.reset()
    }
  }
  
  @ViewBuilder
  func emptyStateView() -> some View {
    VStack() {
      Spacer()
      
      Image(systemName: "tennisball.circle.fill")
        .font(.system(size: 50))
        .symbolRenderingMode(.hierarchical)
        .foregroundColor(.accentColor)
        .padding(.bottom)
      
      
      Text("sessions.empty-state.title")
        .font(.title2)
        .fontWeight(.semibold)
        .padding(.bottom, 2)
      
      Text("sessions.empty-state.message")
        .font(.title3)
        .foregroundColor(.secondary)
      
      Spacer()
    }
  }
  
  @ViewBuilder
  func sessionListStateView() -> some View {
    List {
      ForEach(sessions) { session in
        SessionCard(session: session)
          .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
              modelContext.delete(session)
              try? modelContext.save()
            } label: {
              Label("label.delete", systemImage: "trash")
            }
          }
          .listRowSeparator(.hidden)
      }
    } //: LIST VIEW
    .listStyle(.inset)
  }
  
  func handleCloudKitEvent(_ notification: Notification) {
    guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
      return
    }
    if event.endDate != nil && event.type == .import {
      refreshSessions()
    }
  }
  
  func refreshSessions() {
      let descriptor = FetchDescriptor<Session>(
        sortBy: [SortDescriptor(\.date, order: .reverse)]
      )
      _ = try? modelContext.fetch(descriptor)
  }
  
  @available(iOS 26.0, *)
  @ViewBuilder
  func startNewSessionButtonView() -> some View {
      Button {
        router.navigate(to: .newSession)
      } label: {
        Text("sessions.button.title")
          .font(.headline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
      }
      .glassEffect(.regular.tint(.accentColor.opacity(0.7)).interactive())
  }
}

// MARK: - PREVIEW
#Preview {
  let appState = AppState()
  let router = Router()
  
  return ZStack {
    NavigationStack {
      SessionHistoryView()
    }
  }
  .modelContainer(for: [Session.self, SetScoreData.self], inMemory: true)
  .environmentObject(appState)
  .environmentObject(router)
}
