//
//  ResolutionFinder.swift
//  PadelReferee
//
//  Created by Filip Kisić on 12.03.2026..
//
import WatchKit

public enum WatchSize {
  case mm38, mm40, mm44, mm49, unknown
}

extension WKInterfaceDevice {
  public var watchSize: WatchSize {
    let screenSize = WKInterfaceDevice.current().screenBounds
    
    if screenSize.width >= 205 && screenSize.height >= 251 {
      return .mm49
    } else if screenSize.width >= 184 && screenSize.height >= 224 {
      return .mm44
    } else if screenSize.width >= 162 && screenSize.height >= 197 {
      return .mm40
    } else if screenSize.width >= 136 && screenSize.height >= 170 {
      return .mm38
    } else { return .unknown }
  }
}
