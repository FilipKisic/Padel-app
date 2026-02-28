//
//  SessionTavView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 27.02.2026..
//

import SwiftUI

struct SessionTabView: View {
  // MARK: - PROPERTIES
  @State private var activeTab: SessionTab = .session
  
  // MARK: - BODY
  var body: some View {
    TabView(selection: $activeTab) {
      ControlsView(activeTab: $activeTab).tag(SessionTab.controls)
      SessionView().tag(SessionTab.session)
    }
  }
}

enum SessionTab {
  case controls, session
}

// MARK: - PREVIEW
#Preview {
  let router = Router()
  let viewModel = SessionViewModel()
  
  NavigationView {
    SessionTabView()
  }
  .environmentObject(router)
  .environmentObject(viewModel)
}
