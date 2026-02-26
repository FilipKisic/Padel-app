//
//  SummaryView.swift
//  WatchPadelReferee Watch App
//
//  Created by Filip Kisić on 26.02.2026..
//

import SwiftUI

struct SummaryView: View {
  @EnvironmentObject private var viewModel: SessionViewModel
  @EnvironmentObject private var router: Router
  
  // MARK: - BODY
  var body: some View {
    VStack(spacing: 10) {
      Image(systemName: "trophy.fill")
        .resizable()
        .frame(width: 40, height: 40)
        .foregroundStyle(.yellow)
        .padding(.top)
      
      Text("Your team won!")
        .font(.system(size: 16, weight: .semibold, design: .rounded))
      
      Spacer()
      
      Button {
        
      } label: {
        Text("Rematch")
          .foregroundStyle(.black)
      }
      .buttonStyle(.borderedProminent)
      .padding(.horizontal)
      
    } //: VSTACK
    .navigationTitle("Summary")
  }
}

// MARK: - PREVIEW
#Preview {
  let viewModel = SessionViewModel()
  let router = Router()
  
  NavigationView {
    SummaryView()
  }
  .environmentObject(viewModel)
  .environmentObject(router)
}
