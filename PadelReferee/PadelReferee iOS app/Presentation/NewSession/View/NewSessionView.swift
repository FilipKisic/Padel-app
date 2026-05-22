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
  @EnvironmentObject private var iapService: IAPService
  
  @State var isExpanded = false
  @State private var isServePositionExpanded = false
  @State var viewHeight: CGFloat = .zero
  @State private var servePositionHeight: CGFloat = .zero
  @State private var showPaywall = false
  
  // MARK: - TEST
  @State private var duration = Date.now
  
  // MARK: - BODY
  var body: some View {
    ZStack(alignment: .bottom) {
      VStack(spacing: 20) {
        timePicker()
        
        servePositionPicker()
        
        Spacer()
        
        startNewSessionButton()
      } //: VSTACK
    }
    .scenePadding()
    .navigationTitle("new-session.title")
    .preferredColorScheme(.dark)
    .sheet(isPresented: $showPaywall) {
      PaywallView(isPresented: $showPaywall)
        .environmentObject(iapService)
        .environmentObject(appState)
    }
  }
}

// MARK: - EXTENSIONS
private extension NewSessionView {
  func handleStartSession() {
    print("\(iapService.isPremium) - \(!appState.hasExceededFreeLimit)")
    if iapService.isPremium || !appState.hasExceededFreeLimit {
      appState.setMatchDuration(viewModel.selectedDuration)
      appState.setInitialServePosition(viewModel.selectedServePosition)
      router.navigate(to: .match)
    } else {
      showPaywall = true
    }
  }
  
  @ViewBuilder
  func timePicker() -> some View {
    VStack {
      HStack {
        Image(systemName: "timer")
          .foregroundColor(.yellow)
        Text("new-session.duration")
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
    .onTapGesture { withAnimation(.easeInOut) { isExpanded.toggle() } }
    .cornerRadius(20)
  }
  
  @ViewBuilder
  func servePositionPicker() -> some View {
    VStack {
      HStack {
        Image(systemName: "tennisball")
          .foregroundColor(.yellow)
        Text("new-session.serve")
        Spacer()
        
        Text(LocalizedStringKey(viewModel.selectedServePosition.label))
          .foregroundColor(.yellow)
          .padding(.horizontal, 10)
          .padding(.vertical, 5)
          .background {
            Capsule()
              .fill(.white.opacity(0.2))
          }
          
      } //: HSTACK
      
      if isServePositionExpanded {
        Divider()
      }
      
      VStack(spacing: 8) {
        HStack(spacing: 8) {
          serveQuadrantButton(for: .topLeft)
          serveQuadrantButton(for: .topRight)
        } //: HSTACK
        
        HStack(spacing: 8) {
          serveQuadrantButton(for: .bottomLeft)
          serveQuadrantButton(for: .bottomRight)
        } //: HSTACK
      } //: VSTACK
      .padding(.vertical, 10)
      .frame(height: 100)
    } //: VSTACK
    .padding()
    .background(GeometryReader {
      Color.card.preference(key: ViewHeightKey.self, value: $0.frame(in: .local).size.height)
    })
    .onPreferenceChange(ViewHeightKey.self) { servePositionHeight = $0 }
    .frame(height: isServePositionExpanded ? servePositionHeight : 60, alignment: .top)
    .clipped()
    .frame(maxWidth: .infinity)
    .transition(.move(edge: .bottom))
    .onTapGesture { withAnimation(.easeInOut) { isServePositionExpanded.toggle() } }
    .cornerRadius(20)
  }
  
  @ViewBuilder
  func serveQuadrantButton(for position: ServePosition) -> some View {
    let isSelected = viewModel.selectedServePosition == position
    
    Button {
      viewModel.selectedServePosition = position
    } label: {
      RoundedRectangle(cornerRadius: 8)
        .fill(isSelected ? Color.yellow : Color.cyan)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .buttonStyle(.plain)
    .disabled(!isServePositionExpanded)
  }
  
  @ViewBuilder
  func startNewSessionButton() -> some View {
    if #available(iOS 26.0, *) {
      Button {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        handleStartSession()
      } label: {
        Text("new-session.button.title")
          .font(.headline)
          .foregroundColor(.plainText)
          .frame(maxWidth: .infinity)
          .padding()
          .cornerRadius(12)
      }
      .glassEffect(.regular.tint(.accentColor.opacity(0.7)).interactive())
      .disabled(!viewModel.isValidDuration)
    } else {
      Button {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        handleStartSession()
      } label: {
        Text("new-session.button.title")
          .font(.headline)
          .foregroundColor(.plainText)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
      }
      .buttonStyle(.borderedProminent)
      .tint(.accent)
      .disabled(!viewModel.isValidDuration)
    }
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
  let iapService = IAPService()
  
  NavigationView {
    NewSessionView()
  }
  .environmentObject(viewModel)
  .environmentObject(router)
  .environmentObject(appState)
  .environmentObject(iapService)
  .preferredColorScheme(.dark)
}
