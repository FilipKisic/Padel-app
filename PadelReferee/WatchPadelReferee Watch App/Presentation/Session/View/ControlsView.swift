//
//  ControlsView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 27.02.2026..
//

import SwiftUI

struct ControlsView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var viewModel: SessionViewModel
  @EnvironmentObject private var workoutManager: WorkoutManager
  
  @Binding var activeTab: SessionTab
  
  @State private var isEndDialogPresented = false
  @State private var isRestartDialogPresented = false
  
  // MARK: - BODY
  var body: some View {
    HStack(spacing: 20) {
      VStack {
        undoButton()
        Text("controls.undo")
          .padding(.bottom, 10)
        
        endMatchButton()
        Text("controls.end")
      } //: VSTACK
      
      VStack {
        restartMatchButton()
        Text("controls.restart")
          .padding(.bottom, 10)
        
        togglePauseButton()
        Text(viewModel.screenState.phase == .playing ? LocalizedStringKey("controls.pause") : LocalizedStringKey("controls.resume"))
      } //: VSTACK
    } //: HSTACK
    .scenePadding()
    .navigationBarBackButtonHidden()
  }
}

private extension ControlsView {
  @ViewBuilder
  func undoButton() -> some View {
    Button {
      viewModel.undo()
      withAnimation {
        activeTab = .metric
      }
    } label: {
      Image(systemName: "arrow.uturn.backward")
    }
    .tint(.cyan)
    .font(.title2)
  }
  
  @ViewBuilder
  func endMatchButton() -> some View {
    Button {
      isEndDialogPresented = true
    } label: {
      Image(systemName: "xmark")
    }
    .tint(.red)
    .font(.title2)
    .confirmationDialog("controls.end.confirm.title", isPresented: $isEndDialogPresented) {
      Button("controls.confirm", role: .destructive) {
        viewModel.endMatch(
          calories: workoutManager.activeEnergy,
          averageHeartRate: workoutManager.averageHeartRate
        )
        workoutManager.endSession()
        router.navigateToRoot()
      }
      
      Button("controls.cancel", role: .cancel) {
        isEndDialogPresented = false
      }
    }
  }
  
  @ViewBuilder
  func restartMatchButton() -> some View {
    Button {
      isRestartDialogPresented = true
    } label: {
      Image(systemName: "arrow.clockwise")
    }
    .tint(.green)
    .font(.title2)
    .confirmationDialog("controls.restart.confirm.title", isPresented: $isRestartDialogPresented) {
      Button("controls.confirm", role: .destructive) {
        viewModel.restartMatch()
        workoutManager.resetWorkout()
        workoutManager.startSession()
        withAnimation {
          activeTab = .metric
        }
      }
      
      Button("controls.cancel", role: .cancel) {
        isRestartDialogPresented = false
      }
    }
  }
  
  @ViewBuilder
  func togglePauseButton() -> some View {
    Button {
      viewModel.toggleTimer()
      workoutManager.togglePause()
      withAnimation {
        activeTab = .metric
      }
    } label: {
      Image(systemName: viewModel.screenState.phase == .playing ? "pause" : "play")
    }
    .tint(.yellow)
    .font(.title2)
  }
}

// MARK: - PREVIEW
#Preview {
  @Previewable @State var activeTab: SessionTab = .controls
  let viewModel = SessionViewModel()
  let router = Router()
  
  NavigationView {
    ControlsView(activeTab: $activeTab)
  }
  .environmentObject(viewModel)
  .environmentObject(router)
}
