import SwiftUI
import StoreKit
import Observation

@Observable
final class SubscriptionManager: Codable {
    var isSubscribed = false
    var subscriptionType: SubscriptionType = .none
    var expirationDate: Date?

    enum SubscriptionType: String, Codable {
        case none
        case monthly
        case yearly
        case lifetime
    }

    // MARK: - Product IDs

    static let monthlyID = "com.jingjing.AwareWalk.pro.monthly"
    static let yearlyID = "com.jingjing.AwareWalk.pro.yearly"
    static let lifetimeID = "com.jingjing.AwareWalk.pro.lifetime"
    static let appPurchaseID = "com.jingjing.AwareWalk.app"

    static let themeFamilyPrefix = "com.jingjing.AwareWalk.theme."

    static var allProductIDs: Set<String> {
        [monthlyID, yearlyID, lifetimeID]
    }

    // MARK: - 加载产品

    func loadProducts() async throws -> [Product] {
        try await Product.products(for: Self.allProductIDs)
    }

    // MARK: - 购买

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateSubscriptionStatus(transaction: transaction)
            await transaction.finish()
            return true

        case .userCancelled:
            return false

        case .pending:
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - 购买主题族

    func purchaseThemeFamily(_ familyId: String) async throws -> Bool {
        let productId = Self.themeFamilyPrefix + familyId
        let products = try await Product.products(for: [productId])
        guard let product = products.first else { return false }
        return try await purchase(product)
    }

    // MARK: - 恢复购买

    func restorePurchases() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                await updateSubscriptionStatus(transaction: transaction)
            }
        }
    }

    // MARK: - 监听交易更新

    func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                await updateSubscriptionStatus(transaction: transaction)
                await transaction.finish()
            }
        }
    }

    // MARK: - 内部方法

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let value):
            return value
        }
    }

    @MainActor
    private func updateSubscriptionStatus(transaction: Transaction) {
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
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case isSubscribed, subscriptionType, expirationDate
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSubscribed = try container.decode(Bool.self, forKey: .isSubscribed)
        subscriptionType = try container.decode(SubscriptionType.self, forKey: .subscriptionType)
        expirationDate = try container.decodeIfPresent(Date.self, forKey: .expirationDate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isSubscribed, forKey: .isSubscribed)
        try container.encode(subscriptionType, forKey: .subscriptionType)
        try container.encode(expirationDate, forKey: .expirationDate)
    }
}

enum SubscriptionError: Error {
    case verificationFailed
    case productNotFound
}
