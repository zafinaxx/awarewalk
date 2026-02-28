import SwiftUI
import StoreKit
import Observation

@MainActor
@Observable
final class SubscriptionManager {
    var isSubscribed = false
    var subscriptionType: SubscriptionType = .none
    var expirationDate: Date?
    var products: [Product] = []
    var isPurchasing = false
    var purchaseError: String?

    enum SubscriptionType: String, CaseIterable {
        case none, monthly, yearly, lifetime, unlock
    }

    // MARK: - Product IDs

    static let monthlyID = "com.jingjing.AwareWalk.pro.monthly"
    static let yearlyID = "com.jingjing.AwareWalk.pro.yearly"
    static let lifetimeID = "com.jingjing.AwareWalk.pro.lifetime"
    static let unlockID = "com.jingjing.AwareWalk.pro.unlock"
    static let themeFamilyPrefix = "com.jingjing.AwareWalk.theme."

    static var allProductIDs: Set<String> {
        [monthlyID, yearlyID, lifetimeID, unlockID]
    }

    init() {
        loadFromDefaults()
    }

    // MARK: - 加载产品

    func loadProducts() async {
        do {
            products = try await Product.products(for: Self.allProductIDs)
            print("[AwareWalk] 已加载 \(products.count) 个产品")
        } catch {
            print("[AwareWalk] 加载产品失败: \(error)")
        }
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    // MARK: - 购买（无需 UIWindowScene）

    func purchase(_ product: Product) async -> Bool {
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                applyTransaction(transaction)
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            print("[AwareWalk] 购买失败: \(error)")
            return false
        }
    }

    // MARK: - 按 ID 购买

    func purchaseByID(_ productID: String) async -> Bool {
        if products.isEmpty {
            await loadProducts()
        }
        guard let product = product(for: productID) else {
            purchaseError = "Product not found"
            return false
        }
        return await purchase(product)
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
        case Self.unlockID:
            isSubscribed = true
            subscriptionType = .unlock
            expirationDate = nil
        default:
            if transaction.productID.hasPrefix(Self.themeFamilyPrefix) {
                isSubscribed = true
            }
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
