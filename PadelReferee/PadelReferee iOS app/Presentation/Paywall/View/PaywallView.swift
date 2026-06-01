//
//  PaywallView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 06.05.2026.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var iapService: IAPService
  @EnvironmentObject private var appState: AppState
  @Binding var isPresented: Bool
  
  // MARK: - BODY
  var body: some View {
    NavigationStack {
      VStack(spacing: 32) {
        Spacer()
        
        Image("PadelPlusLogo")
          .resizable()
          .frame(width: 80, height: 80)
          .cornerRadius(20)
          .padding()
        
        VStack(spacing: 20) {
          Text("paywall.title")
            .font(.title.bold())
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
          
          Text("paywall.description")
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .fixedSize(horizontal: false, vertical: true)
        } //: VSTACK
        
        freeTimeCard()
          .padding(.vertical, 20)
        
        Spacer()
        
        purchaseSection()
      } //: VSTACK
      .padding()
      .preferredColorScheme(.dark)
      .onChange(of: iapService.isPremium) { _, isPremium in
        if isPremium { isPresented = false }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            isPresented = false
          } label: {
            Image(systemName: "xmark")
              .foregroundColor(.white)
          }
        }
      } //: TOOLBAR
    } //: NAVIGATION STACK
  }
}

// MARK: - PRIVATE SUBVIEWS
private extension PaywallView {
  @ViewBuilder
  func freeTimeCard() -> some View {
    VStack(spacing: 8) {
      Text("paywall.free-time.label")
        .font(.subheadline)
        .foregroundStyle(.secondary)
      
      HStack(spacing: 4) {
        Text("3h 00m")
          .font(.title2.bold())
          .foregroundStyle(.red)
        Text("/")
          .font(.title2)
          .foregroundStyle(.secondary)
        Text("3h 00m")
          .font(.title2.bold())
          .foregroundStyle(.secondary)
      } //: HSTACK
      
      ProgressView(value: min(appState.totalPlayedSeconds / appState.freeTimeLimit, 1.0))
        .tint(.red)
        .frame(maxWidth: 200)
    } //: VSTACK
    .padding(20)
    .background(.card)
    .cornerRadius(16)
  }
  
  @ViewBuilder
  func purchaseSection() -> some View {
    VStack(spacing: 30) {
      purchaseButton()
      
      Button("paywall.button.restore") {
        Task { await iapService.restorePurchases() }
      }
      .disabled(iapService.isLoading)
      .foregroundStyle(.secondary)
      
      if let error = iapService.errorMessage {
        Text(error)
          .font(.caption)
          .foregroundStyle(.red)
          .multilineTextAlignment(.center)
      }
    } //: VSTACK
    .padding(.horizontal)
    .padding(.bottom, 20)
  }
  
  @ViewBuilder
  func purchaseButton() -> some View {
    if let product = iapService.product {
      if #available(iOS 26.0, *) {
        Button {
          Task { await iapService.purchase() }
        } label: {
          Group {
            if iapService.isLoading {
              ProgressView()
                .frame(maxWidth: .infinity)
            } else {
              Text("paywall.button.purchase \(product.displayPrice)")
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
            }
          }
          .padding()
        }
        .glassEffect(.regular.tint(.onboarding.opacity(0.8)).interactive())
        .disabled(iapService.isLoading)
      } else {
        Button {
          Task { await iapService.purchase() }
        } label: {
          Group {
            if iapService.isLoading {
              ProgressView()
                .frame(maxWidth: .infinity)
            } else {
              Text("paywall.button.purchase \(product.displayPrice)")
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
            }
          }
          .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .tint(.onboarding)
        .disabled(iapService.isLoading)
      }
    } else {
      ProgressView("paywall.loading")
    }
  }
  
  func formattedUsedTime() -> String {
    let total = Int(appState.totalPlayedSeconds)
    let hours = total / 3600
    let minutes = (total % 3600) / 60
    return String(format: "%dh %02dm", hours, minutes)
  }
}

// MARK: - PREVIEW
#Preview {
  let iapService = IAPService()
  let appState = AppState()
  let session = Session(date: Date(), duration: 5400)
  appState.setCompletedSession(session)
  
  return PaywallView(isPresented: .constant(true))
    .environmentObject(iapService)
    .environmentObject(appState)
}
