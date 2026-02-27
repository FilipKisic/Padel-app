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
  
  // MARK: - BODY
  var body: some View {
    HStack {
      VStack{
        Button {
          
        } label: {
          Image(systemName: "xmark")
        }
        .tint(.red)
        .font(.title2)
        Text("End")
      } //: VSTACK
      
      VStack{
        Button {
          
        } label: {
          Image(systemName: "pause")
        }
        .tint(.yellow)
        .font(.title2)
        Text("Pause")
      } //: VSTACK
    } //: HSTACK
  }
}

// MARK: - PREVIEW
#Preview {
  ControlsView()
}
