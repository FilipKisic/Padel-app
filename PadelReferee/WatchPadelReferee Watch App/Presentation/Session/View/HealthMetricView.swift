//
//  HealthMetricView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 06.03.2026..
//

import SwiftUI

struct HealthMetricView: View {
  var body: some View {
    VStack(alignment: .leading) {
      Text("01:27:43")
        .foregroundStyle(.yellow)
      Text("147 KCAL")
      
      Text("137 BPM")
      
    }
    .font(.system(.title, design: .rounded))
    .frame(maxWidth: .infinity, alignment: .leading)
    .ignoresSafeArea(edges: .bottom)
    .scenePadding()
  }
}

#Preview {
  HealthMetricView()
}
