//
//  NewSessionView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import SwiftUI

struct NewSessionView: View {
  // MARK: - PROPERTIES
  @EnvironmentObject private var viewModel: NewSessionViewModel
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var appState: AppState
  
  // MARK: - BODY
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack {
        Spacer()
        
        timePicker()
        
        Spacer()
        
        startNewSessionButton()
      } //: VSTACK
    }
    .navigationTitle("New Session")
    .navigationBarTitleDisplayMode(.inline)
    .preferredColorScheme(.dark)
  }
}

private extension NewSessionView {
  @ViewBuilder
  func timePicker() -> some View {
    VStack(spacing: 16) {
      Text("Match Duration")
        .font(.headline)
      
      HStack(spacing: 20) {
        TimePickerComponent(value: $viewModel.state.hours, label: "Hours", range: 0...23)
        Text(":")
          .font(.largeTitle)
          .fontWeight(.bold)
        TimePickerComponent(value: $viewModel.state.minutes, label: "Minutes", range: 0...59)
        Text(":")
          .font(.largeTitle)
          .fontWeight(.bold)
        TimePickerComponent(value: $viewModel.state.seconds, label: "Seconds", range: 0...59)
      } //: HSTACK
    } //: VSTACK
  }
  
  @ViewBuilder
  func startNewSessionButton() -> some View {
    Button{
      appState.setMatchDuration(viewModel.selectedDuration)
      router.navigate(to: .match)
    } label: {
      Text("Start new session")
        .font(.headline)
        .foregroundColor(.plainText)
        .frame(maxWidth: .infinity)
        .padding()
        .cornerRadius(12)
    }
    .glassEffect(.regular.tint(.accentColor.opacity(0.8)).interactive())
    .disabled(!viewModel.isValidDuration)
    .padding()
  }
}

struct TimePickerComponent: View {
  @Binding var value: Int
  let label: String
  let range: ClosedRange<Int>
  
  var body: some View {
    VStack(spacing: 8) {
      Text(label)
        .font(.caption)
        .foregroundColor(.secondary)
      
      Picker("", selection: $value) {
        ForEach(Array(range), id: \.self) { number in
          Text(String(format: "%02d", number))
            .tag(number)
        }
      }
      .pickerStyle(.wheel)
      .frame(width: 80, height: 120)
      .clipped()
    }
  }
}

// MARK: - PREVIEW
#Preview {
  let viewModel = NewSessionViewModel()
  let router = Router()
  let appState = AppState()
  
  NavigationView {
    NewSessionView()
  }
  .environmentObject(viewModel)
  .environmentObject(router)
  .environmentObject(appState)
  .preferredColorScheme(.dark)
}
