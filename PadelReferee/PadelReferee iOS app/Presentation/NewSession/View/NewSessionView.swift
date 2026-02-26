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
  
  @State var isExpanded = false
  @State var viewHeight: CGFloat = .zero
  
  // MARK: - TEST
  @State private var duration = Date.now
  
  // MARK: - BODY
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack {
        timePicker()
        
        Spacer()
        
        startNewSessionButton()
      } //: VSTACK
    }
    .navigationTitle("New Session")
    .preferredColorScheme(.dark)
  }
}

private extension NewSessionView {
  @ViewBuilder
  func timePicker() -> some View {
    VStack() {
      HStack {
        Image(systemName: "timer")
          .foregroundColor(.yellow)
        Text("Duration")
        Spacer()
        Text(viewModel.getFormattedDuration())
          .foregroundColor(.yellow)
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background {
            Capsule()
              .fill(.white.opacity(0.2))
          }
      } //: HSTACK
      
      if isExpanded {
        Divider()
      }
      
      HStack(spacing: 20) {
        TimePickerComponent(value: $viewModel.state.hours, label: "h", range: 0...23)
        Text(":")
          .font(.title)
          .fontWeight(.bold)
        TimePickerComponent(value: $viewModel.state.minutes, label: "min", range: 0...59)
      } //: HSTACK
    } //: VSTACK
    .padding()
    .background(GeometryReader {
      Color.card.preference(key: ViewHeightKey.self, value: $0.frame(in: .local).size.height)
    })
    .onPreferenceChange(ViewHeightKey.self) { viewHeight = $0 }
    .frame(height: isExpanded ? viewHeight : 60, alignment: .top)
    .clipped()
    .frame(maxWidth: .infinity)
    .transition(.move(edge: .bottom))
    .onTapGesture {
      withAnimation(.easeInOut) {
        isExpanded.toggle()
      }
    }
    .cornerRadius(20)
    .padding()
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
    HStack {
      Picker("", selection: $value) {
        ForEach(Array(range), id: \.self) { number in
          Text(String(format: "%02d", number))
            .tag(number)
        }
      }
      .pickerStyle(.wheel)
      .frame(width: 60, height: 200)
      .clipped()
      
      Text(label)
        .font(.subheadline)
        .fontWeight(.medium)
    } //: HSTACK
  }
}

private struct ViewHeightKey: PreferenceKey {
  static var defaultValue: CGFloat { 0 }
  
  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = value + nextValue()
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
