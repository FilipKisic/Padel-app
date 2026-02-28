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
  @Binding var activeTab: SessionTab
  
  // MARK: - BODY
  var body: some View {
    HStack(spacing: 20) {
      VStack() {
        Button {
          viewModel.undo()
          withAnimation {
            activeTab = .session
          }
        } label: {
          Image(systemName: "arrow.uturn.backward")
        }
        .tint(.cyan)
        .font(.title2)
        Text("Undo point")
          .padding(.bottom, 15)
        
        Button {
          viewModel.stopTimer()
          router.navigateToRoot()
        } label: {
          Image(systemName: "xmark")
        }
        .tint(.red)
        .font(.title2)
        Text("End")
      } //: VSTACK
      
      VStack {
        Button {
          viewModel.restartMatch()
          withAnimation {
            activeTab = .session
          }
        } label: {
          Image(systemName: "arrow.clockwise")
        }
        .tint(.green)
        .font(.title2)
        Text("Restart")
          .padding(.bottom, 15)
        
        Button {
          viewModel.toggleTimer()
          withAnimation {
            activeTab = .session
          }
        } label: {
          Image(systemName: "pause")
        }
        .tint(.yellow)
        .font(.title2)
        Text("Pause")
      } //: VSTACK
    } //: HSTACK
    .navigationBarBackButtonHidden()
  }
}

// MARK: - PREVIEW
#Preview {
  @Previewable @State var activeTab: SessionTab = .controls
  ControlsView(activeTab: $activeTab)
}
