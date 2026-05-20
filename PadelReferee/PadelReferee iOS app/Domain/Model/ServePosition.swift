//
//  ServePosition.swift
//  PadelReferee
//
//  Created by Filip Kisić on 29.01.2026.
//

import Foundation

enum ServePosition: Int, CaseIterable {
  case topLeft = 0
  case topRight = 1
  case bottomLeft = 2
  case bottomRight = 3
  
  var label: String {
    switch self {
      case .topLeft: return "new-session.position.top-left"
      case .topRight: return "new-session.position.top-right"
      case .bottomLeft: return "new-session.position.bottom-left"
      case .bottomRight: return "new-session.position.bottom-right"
    }
  }
}
