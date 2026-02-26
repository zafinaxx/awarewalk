import SwiftUI
import StoreKit
import Observation

@MainActor
@Observable
final class SubscriptionManager {
    var isSubscribed = false
    var subscriptionType: SubscriptionType = .none
    var expirationDate: Date?

    enum SubscriptionType: String, CaseIterable {
        case none, monthly, yearly, lifetime
    }

    // MARK: - Product IDs

    static let monthlyID = "com.jingjing.AwareWalk.pro.monthly"
    static let yearlyID = "com.jingjing.AwareWalk.pro.yearly"
    static let lifetimeID = "com.jingjing.AwareWalk.pro.lifetime"
    static let themeFamilyPrefix = "com.jingjing.AwareWalk.theme."

    static var allProductIDs: Set<String> {
        [monthlyID, yearlyID, lifetimeID]
    }

    init() {
        loadFromDefaults()
    }

    // MARK: - 加载产品

    func loadProducts() async throws -> [Product] {
        try await Product.products(for: Self.allProductIDs)
    }

    // MARK: - 购买

    func purchase(_ product: Product, in scene: UIWindowScene) async throws -> Bool {
        let result = try await product.purchase(confirmIn: scene)

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            applyTransaction(transaction)
            await transaction.finish()
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    // MARK: - 购买主题族

    func purchaseThemeFamily(_ familyId: String, in scene: UIWindowScene) async throws -> Bool {
        let productId = Self.themeFamilyPrefix + familyId
        let products = try await Product.products(for: [productId])
        guard let product = products.first else { return false }
        return try await purchase(product, in: scene)
    }

    // MARK: - 恢复购买

    func restorePurchases() async {
        for await result in StoreKit.Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                applyTransaction(transaction)
            }
        }
    }

    // MARK: - 监听交易更新

    func listenForTransactions() async {
        for await result in StoreKit.Transaction.updates {
            if let transaction = try? checkVerified(result) {
                applyTransaction(transaction)
                await transaction.finish()
            }
        }
    }

    // MARK: - 内部方法

    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let value):
            return value
        }
    }

    private func applyTransaction(_ transaction: StoreKit.Transaction) {
        switch transaction.productID {
        case Self.monthlyID:
            isSubscribed = true
            subscriptionType = .monthly
            expirationDate = transaction.expirationDate
        case Self.yearlyID:
            isSubscribed = true
            subscriptionType = .yearly
            expirationDate = transaction.expirationDate
        case Self.lifetimeID:
            isSubscribed = true
            subscriptionType = .lifetime
            expirationDate = nil
        default:
            break
        }
        saveToDefaults()
    }

    // MARK: - UserDefaults 持久化

    private func saveToDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(isSubscribed, forKey: "sub_active")
        defaults.set(subscriptionType.rawValue, forKey: "sub_type")
        defaults.set(expirationDate?.timeIntervalSince1970, forKey: "sub_expiry")
    }

    private func loadFromDefaults() {
        let defaults = UserDefaults.standard
        isSubscribed = defaults.bool(forKey: "sub_active")
        if let raw = defaults.string(forKey: "sub_type") {
            subscriptionType = SubscriptionType(rawValue: raw) ?? .none
        }
        let expiry = defaults.double(forKey: "sub_expiry")
        expirationDate = expiry > 0 ? Date(timeIntervalSince1970: expiry) : nil
    }
}

enum SubscriptionError: Error {
    case verificationFailed
    case productNotFound
}
