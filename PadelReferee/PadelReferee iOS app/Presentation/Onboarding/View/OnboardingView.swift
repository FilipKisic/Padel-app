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
        image: determineCompanionImage(),
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
      
      continueButton()
    } //: VSTACK
    .scenePadding()
    .preferredColorScheme(.dark)
  }
  
  // MARK: - FUNCTIONS
  private func determineCompanionImage() -> String {
    if #available(iOS 26.0, *) {
      return "ipod.and.applewatch"
    }
    return "applewatch.case.sizes"
  }
}

private extension OnboardingView {
  @ViewBuilder
  func continueButton() -> some View {
    if #available(iOS 26.0, *) {
      Button {
        isOnboarded = true
        router.navigate(to: .sessions)
      } label: {
        Text("onboarding.button.title")
          .font(.headline)
          .foregroundColor(.black)
          .frame(maxWidth: .infinity)
          .padding()
      }
      .glassEffect(.regular.tint(.onboarding.opacity(0.8)).interactive())
      .padding()
    } else {
      Button {
        isOnboarded = true
        router.navigate(to: .sessions)
      } label: {
        Text("onboarding.button.title")
          .font(.headline)
          .foregroundColor(.black)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
      }
      .buttonStyle(.borderedProminent)
      .tint(.onboarding)
    }
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
