//
//  ServePositionSetupView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 20.05.2026..
//

import SwiftUI
import WatchKit

struct ServePositionSetupView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var viewModel: SessionViewModel
  @EnvironmentObject private var workoutManager: WorkoutManager
  
  @State private var selectedPosition: ServePosition = .bottomLeft
  
  // MARK: - BODY
  var body: some View {
    VStack(spacing: 8) {
      courtGrid()
      
      Button {
        WKInterfaceDevice.current().play(.start)
        startMatch()
      } label: {
        Text("new-session.button.start")
          .foregroundStyle(.black)
      }
      .buttonStyle(.borderedProminent)
    }
    .padding(.horizontal, 4)
    .navigationTitle("new-session.serve.title")
  }
  
  // MARK: - FUNCTIONS
  private func startMatch() {
    viewModel.setInitialServePosition(selectedPosition)
    workoutManager.startSession()
    viewModel.startTimer()
    router.navigate(to: .session)
  }
}

// MARK: - COURT GRID
private extension ServePositionSetupView {
  @ViewBuilder
  func courtGrid() -> some View {
    VStack(spacing: 5) {
      HStack(spacing: 5) {
        quadrantButton(for: .topLeft)
        quadrantButton(for: .topRight)
      } //: HSTACK
      
      HStack(spacing: 5) {
        quadrantButton(for: .bottomLeft)
        quadrantButton(for: .bottomRight)
      } //: HSTACK
    } //: VSTACK
  }
  
  @ViewBuilder
  func quadrantButton(for position: ServePosition) -> some View {
    let isSelected = selectedPosition == position
    
    Button {
      selectedPosition = position
    } label: {
      RoundedRectangle(cornerRadius: 10)
        .fill(isSelected ? Color.yellow : Color.cyan)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.plain)
  }
}

// MARK: - PREVIEW
#Preview {
  let viewModel = SessionViewModel()
  let router = Router()
  let workoutManager = WorkoutManager()
  
  NavigationView {
    ServePositionSetupView()
  }
  .environmentObject(viewModel)
  .environmentObject(router)
  .environmentObject(workoutManager)
}

