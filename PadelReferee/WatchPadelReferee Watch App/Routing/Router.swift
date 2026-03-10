//
//  Router.swift
//  PadelReferee
//
//  Created by Filip Kisić on 26.02.2026..
//
import SwiftUI
import Combine

class Router: ObservableObject {
  // MARK: - ALL ROUTES
  enum Route: Hashable {
    case start
    case newSession
    case session
  }
  
  // MARK: - PROPERTIES
  @Published var path = NavigationPath()
  
  // MARK: - VIEW BUILDER
  @ViewBuilder func view(for route: Route) -> some View {
    switch route {
      case .start:
        StartView()
      case .newSession:
        NewSessionView()
      case .session:
        SessionTabView()
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
