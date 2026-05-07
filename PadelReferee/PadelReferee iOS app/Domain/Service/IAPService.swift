//
//  IAPService.swift
//  PadelReferee iOS app
//
//  Created by Filip Kisić on 29.01.2026.
//
import Foundation
import StoreKit
import Combine

class IAPService: ObservableObject {
  static let productID = "kisic.filip.PadelPlus.unlimitedAccess"

  @Published private(set) var isPremium: Bool = false
  @Published private(set) var product: Product?
  @Published private(set) var isLoading: Bool = false
  @Published private(set) var errorMessage: String?

  private var transactionListener: Task<Void, Never>?

  init() {
    transactionListener = listenForTransactions()
    Task {
      await loadProduct()
      await refreshPurchaseStatus()
    }
  }

  deinit {
    transactionListener?.cancel()
  }

  @MainActor
  func purchase() async {
    guard let product else { return }
    isLoading = true
    errorMessage = nil

    do {
      let result = try await product.purchase()
      switch result {
      case .success(let verification):
        let transaction = try verification.payloadValue
        await transaction.finish()
        isPremium = true
      case .userCancelled, .pending:
        break
      @unknown default:
        break
      }
    } catch {
      errorMessage = error.localizedDescription
    }
    isLoading = false
  }

  @MainActor
  func restorePurchases() async {
    isLoading = true
    errorMessage = nil

    do {
      try await AppStore.sync()
      await refreshPurchaseStatus()
    } catch {
      errorMessage = error.localizedDescription
    }
    isLoading = false
  }

  private func loadProduct() async {
    do {
      let products = try await Product.products(for: [Self.productID])
      await MainActor.run { product = products.first }
    } catch {
      await MainActor.run { errorMessage = error.localizedDescription }
    }
  }

  private func refreshPurchaseStatus() async {
    var found = false
    for await result in Transaction.currentEntitlements {
      if let transaction = try? result.payloadValue,
         transaction.productID == Self.productID {
        found = true
        break
      }
    }
    await MainActor.run { isPremium = found }
  }

  private func listenForTransactions() -> Task<Void, Never> {
    Task {
      for await result in Transaction.updates {
        if let transaction = try? result.payloadValue {
          await transaction.finish()
          await refreshPurchaseStatus()
        }
      }
    }
  }
}
