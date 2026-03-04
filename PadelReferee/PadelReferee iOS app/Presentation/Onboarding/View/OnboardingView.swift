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
    VStack {
      Image("PadelPlusLogo")
        .resizable()
        .frame(width: 80, height: 80)
        .cornerRadius(20)
        .padding()
      
      Text("onboarding.title")
        .font(.title.bold())
        .multilineTextAlignment(.center)
        .padding(.bottom, 40)
      
      FeatureView(
        image: "ipod.and.applewatch",
        title: "onboarding.companion.title",
        description: "onboarding.companion.description"
      )
      .padding(.vertical)
      
      FeatureView(
        image: "rectangle.landscape.rotate",
        title: "onboarding.horizontal.title",
        description: "onboarding.horizontal.description"
      )
      .padding(.vertical)
      
      FeatureView(
        image: "arrow.uturn.backward.circle",
        title: "onboarding.undo.title",
        description: "onboarding.undo.description"
      )
      .padding(.vertical)
      
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

// MARK: - PREVIEW
#Preview {
  let router = Router()
  
  NavigationView {
    OnboardingView()
  }
  .environmentObject(router)
}
