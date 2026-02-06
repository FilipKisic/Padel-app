//
//  NewSessionView.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//

import SwiftUI

struct NewSessionView: View {
  @StateObject private var viewModel = NewSessionViewModel()
  @ObservedObject var sessionsViewModel: SessionsViewModel
  @Environment(\.dismiss) private var dismiss
  
  init(viewModel: SessionsViewModel) {
    self.sessionsViewModel = viewModel
  }
  
  var body: some View {
    NavigationStack {
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
          viewModel.startSession()
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
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
      .fullScreenCover(isPresented: $viewModel.showMatch) {
        MatchView(duration: viewModel.selectedDuration, onFinish: { session in
          sessionsViewModel.addSession(session)
          dismiss()
        })
      }
    }
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
  NewSessionView(viewModel: SessionsViewModel())
}
