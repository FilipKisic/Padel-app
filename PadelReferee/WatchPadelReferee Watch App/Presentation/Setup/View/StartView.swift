//
//  StartView.swift
//  PadelReferee Watch App
//
//  Created by Filip Kisić on 15.01.2026..
//

import SwiftUI

struct StartView: View {
  // MARK: - PROPERTIES
  @State private var isShowingSession = false
  
  // MARK: - BODY
  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Spacer()
        
        // App icon / Title
        VStack(spacing: 8) {
          Image(systemName: "sportscourt")
            .font(.system(size: 40))
            .foregroundColor(.green)
          
          Text("Padel Referee")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
          
          Text("Score Tracker")
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
        
        Spacer()
        
        // Start match button
        Button(action: {
          isShowingSession = true
        }) {
          HStack {
            Image(systemName: "play.fill")
            Text("Start Match")
          }
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(.black)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
          .background(Color.green)
          .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
      }
      .navigationDestination(isPresented: $isShowingSession) {
        SessionView()
          .navigationBarBackButtonHidden(true)
      }
    }
  }
}

// MARK: - PREVIEW
#Preview {
  StartView()
}
