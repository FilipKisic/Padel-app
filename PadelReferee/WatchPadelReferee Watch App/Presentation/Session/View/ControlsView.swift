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
  
  // MARK: - BODY
  var body: some View {
    HStack(spacing: 20) {
      VStack {
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
        Text("controls.undo")
          .padding(.bottom, 10)
        
        Button {
          viewModel.endMatch()
          workoutManager.endSession()
          router.navigateToRoot()
        } label: {
          Image(systemName: "xmark")
        }
        .tint(.red)
        .font(.title2)
        Text("controls.end")
      } //: VSTACK
      
      VStack {
        Button {
          viewModel.restartMatch()
          workoutManager.resetWorkout()
          workoutManager.startSession()
          withAnimation {
            activeTab = .metric
          }
        } label: {
          Image(systemName: "arrow.clockwise")
        }
        .tint(.green)
        .font(.title2)
        Text("controls.restart")
          .padding(.bottom, 10)
        
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
        Text(viewModel.screenState.phase == .playing ? LocalizedStringKey("controls.pause") : LocalizedStringKey("controls.resume"))
      } //: VSTACK
    } //: HSTACK
    .scenePadding()
    .navigationBarBackButtonHidden()
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
