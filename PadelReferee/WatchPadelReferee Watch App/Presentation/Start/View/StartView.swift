//
//  StartView.swift
//  PadelReferee Watch App
//
//  Created by Filip Kisić on 15.01.2026..
//

import SwiftUI

struct StartView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var router: Router
  
  // MARK: - BODY
  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Spacer()
        
        VStack(spacing: 5) {
          Image(systemName: "figure.racquetball")
            .font(.system(size: 40))
            .foregroundColor(.green)
          
          Text("Padel+")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
          
          Text("start.subtitle")
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
        
        Spacer()
        
        Button {
          router.navigate(to: .newSession)
        } label: {
          HStack(spacing: 10) {
            Image(systemName: "play.fill")
            Text("start.button")
          }
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(.black)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
      } //: VSTACK
    } //: NAVIGATION STACK
  }
}

// MARK: - PREVIEW
#Preview {
  StartView()
}
