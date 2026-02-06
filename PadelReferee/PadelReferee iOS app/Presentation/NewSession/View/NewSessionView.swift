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
      VStack(spacing: 32) {
        Spacer()
        
        VStack(spacing: 16) {
          Text("Match Duration")
            .font(.headline)
          
          HStack(spacing: 20) {
            TimePickerComponent(value: $viewModel.hours, label: "Hours", range: 0...23)
            Text(":")
              .font(.largeTitle)
              .fontWeight(.bold)
            TimePickerComponent(value: $viewModel.minutes, label: "Minutes", range: 0...59)
            Text(":")
              .font(.largeTitle)
              .fontWeight(.bold)
            TimePickerComponent(value: $viewModel.seconds, label: "Seconds", range: 0...59)
          }
        }
        
        Spacer()
      }
      
      Button(action: {
        appState.setMatchDuration(viewModel.selectedDuration)
        router.navigate(to: .match)
      }) {
        Text("Start new session")
          .font(.headline)
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(viewModel.isValidDuration ? Color.accentColor : Color.gray)
          .cornerRadius(12)
      }
      .disabled(!viewModel.isValidDuration)
      .padding()
    }
    .navigationTitle("New Session")
    .navigationBarTitleDisplayMode(.inline)
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

#Preview {
  NewSessionView()
}
