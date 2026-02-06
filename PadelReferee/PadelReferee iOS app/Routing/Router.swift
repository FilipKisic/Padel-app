//
//  Router.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 06.02.2026.
//

import SwiftUI
import Combine

class Router: ObservableObject {
  // MARK: - ALL ROUTES
  enum Route: Hashable {
    case sessions
    case newSession
    case match
    case summary
  }
  
  // MARK: - PROPERTIES
  @Published var path = NavigationPath()
  
  // MARK: - VIEW BUILDER
  @ViewBuilder func view(for route: Route) -> some View {
    switch route {
      case .sessions:
        SessionsView()
      case .newSession:
        NewSessionView()
      case .match:
        MatchView()
      case .summary:
        SummaryView()
    }
  }
  
  // MARK: - FUNCTIONS
  func navigate(to route: Route) {
    path.append(route)
  }
  
  func navigateBack() {
    path.removeLast()
  }
  
  func navigateToRoot() {
    path.removeLast(path.count)
  }
}
