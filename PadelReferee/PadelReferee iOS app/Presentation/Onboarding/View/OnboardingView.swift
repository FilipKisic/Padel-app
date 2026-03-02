//
//  OnboardingView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 02.03.2026..
//

import SwiftUI

struct OnboardingView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var router: Router
  @AppStorage("isOnboarded") var isOnboarded: Bool = false
  
  // MARK: - BODY
  var body: some View {
    VStack(spacing: 20) {
      Image("PadelPlusLogo")
        .resizable()
        .frame(width: 80, height: 80)
        .cornerRadius(20)
      
      Text("Welcome to the\nPadel+")
        .font(.title.bold())
        .multilineTextAlignment(.center)
        .padding(.bottom, 40)
      
      FeatureView(
        image: "ipod.and.applewatch",
        title: "Companion app",
        description: "To get most out of the Padel+ experience, install watchOS companion app and track match score of your wrist."
      )
      FeatureView(
        image: "rectangle.landscape.rotate",
        title: "Horizontal mode",
        description: "While you are on the padel court, put your iPhone in the horizontal orientation and transform it into the scoreboard."
      )
      FeatureView(
        image: "arrow.uturn.backward.circle",
        title: "Undo last entry",
        description: "If you are using the companion app, add or undo points from the one device while the other one will just correct the points."
      )
      
      Spacer()
      
      Button {
        isOnboarded = true
        router.navigate(to: .sessions)
      } label: {
        Text("Continue")
          .font(.headline)
          .foregroundColor(.black)
          .frame(maxWidth: .infinity)
          .padding()
      }
      .glassEffect(.regular.tint(.onboarding.opacity(0.8)).interactive())
      .padding()

    } //: VSTACK
    .padding()
    .preferredColorScheme(.dark)
  }
}

struct FeatureView: View {
  let image: String
  let title: String
  let description: String
  
  var body: some View {
    HStack {
      Image(systemName: image)
        .resizable()
        .frame(width: 45, height: 45)
        .foregroundStyle(.onboarding)
        .padding()
      
      VStack(alignment: .leading) {
        Text(title)
          .font(.headline.bold())
        Text(description)
          .font(.system(size: 14))
          .foregroundStyle(.gray)
      } //: VSTACK
    } //: HSTACK
  }
}

// MARK: - PREVIEW
#Preview {
  let router = Router()
  
  NavigationView {
    OnboardingView()
  }
  .environmentObject(router)
}
