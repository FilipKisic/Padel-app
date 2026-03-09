//
//  HealthStore.swift
//  PadelReferee
//
//  Created by Filip Kisić on 09.03.2026..
//
import Foundation
import HealthKit
import Combine

class WorkoutManager: NSObject, ObservableObject {
  // MARK: - PROPERTIES
  @Published var isRunning = false
  
  @Published var averageHeartRate: Double = 0
  @Published var heartRate: Double = 0
  @Published var activeEnergy: Double = 0
  @Published var workout: HKWorkout?
  
  @Published var showingSummaryView = false {
    didSet {
      if showingSummaryView == false {
        resetWorkout()
      }
    }
  }
  
  private var healthStore: HKHealthStore?
  private var session: HKWorkoutSession?
  var builder: HKLiveWorkoutBuilder?
  
  // MARK: - CONSTRUCTOR
  public override init() {
    guard HKHealthStore.isHealthDataAvailable() else {
      super.init()
      return
    }
    
    healthStore = HKHealthStore()
    super.init()
  }
  
  // MARK: - METHODS
  func requestAuthorization() {
    let typesToShare: Set = [ HKQuantityType.workoutType() ]
    
    let typesToRead: Set = [
      HKQuantityType.quantityType(forIdentifier: .heartRate)!,
      HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
      HKQuantityType.activitySummaryType()
    ]
    
    healthStore?.requestAuthorization(toShare: typesToShare, read: typesToRead) { _, __ in
      // Handle error
    }
  }
  
  func startSession() {
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = .other
    configuration.locationType = .indoor
    
    do {
      session = try HKWorkoutSession(healthStore: healthStore!, configuration: configuration)
      builder = session?.associatedWorkoutBuilder()
    } catch {
      // Handle error
      return
    }
    
    session?.delegate = self
    builder?.delegate = self
    
    builder?.dataSource = HKLiveWorkoutDataSource(
      healthStore: healthStore!,
      workoutConfiguration: configuration
    )
    
    let startDate = Date()
    session?.startActivity(with: startDate)
    builder?.beginCollection(withStart: startDate) { _, __ in }
  }
  
  func togglePause() {
    if isRunning {
      session?.pause()
    } else {
      session?.resume()
    }
  }
  
  func endSession() {
    session?.end()
    showingSummaryView = true
  }
  
  func updateForStatistics(_ statistics: HKStatistics?) {
    guard let statistics = statistics else { return }
    
    DispatchQueue.main.async {
      switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
          let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
          self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
          self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
          
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
          let energyUnit = HKUnit.kilocalorie()
          self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
          
        default:
          return
      }
    }
  }
  
  func resetWorkout() {
    builder = nil
    session = nil
    workout = nil
    averageHeartRate = 0
    heartRate = 0
    activeEnergy = 0
  }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
  func workoutSession(
    _ workoutSession: HKWorkoutSession,
    didChangeTo toState: HKWorkoutSessionState,
    from fromState: HKWorkoutSessionState,
    date: Date
  ) {
    DispatchQueue.main.async {
      self.isRunning = toState == .running
    }
    
    if toState == .ended {
      builder?.endCollection(withEnd: date) { (success, error) in
        self.builder?.finishWorkout { (workout, error) in
          DispatchQueue.main.async {
            self.workout = workout
          }
        }
      }
    }
  }
  
  func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    
  }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
  func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) { }
  
  func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
    for type in collectedTypes {
      guard let quantityType = type as? HKQuantityType else { return }
      
      let statistics = workoutBuilder.statistics(for: quantityType)
      
      updateForStatistics(statistics)
    }
  }
}
