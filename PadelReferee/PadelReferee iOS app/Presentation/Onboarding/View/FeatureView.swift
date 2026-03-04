//
//  FeatureView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 04.03.2026..
//

import SwiftUI

struct FeatureView: View {
  // MARK: - PROPERTIES
  let image: String
  let title: String
  let description: String
  
  // MARK: - BODY
  var body: some View {
    HStack {
      Image(systemName: image)
        .resizable()
        .frame(width: 45, height: 45)
        .foregroundStyle(.onboarding)
        .padding()
      
      VStack(alignment: .leading) {
        Text(LocalizedStringKey(title))
          .font(.headline.bold())
        Text(LocalizedStringKey(description))
          .font(.system(size: 14))
          .foregroundStyle(.gray)
      } //: VSTACK
    } //: HSTACK
  }
}

// MARK: - PREVIEW
#Preview {
  FeatureView(
    image: "ipod.and.applewatch",
    title: "onboarding.companion.title",
    description: "onboarding.companion.description"
  )
}
