//
//  SessionTavView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 27.02.2026..
//

import SwiftUI

struct SessionTabView: View {
  // MARK: - PROPERTIES
  @State private var activeTab: Tab = .session
  
  enum Tab {
    case controls, session
  }
  
  // MARK: - BODY
  var body: some View {
    TabView(selection: $activeTab) {
      ControlsView().tag(Tab.controls)
      SessionView().tag(Tab.session)
    }
  }
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
