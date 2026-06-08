import StoreKit
import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    static let proProductID = "com.tokyonasu.idphotomaker.pro"

    @Published var isPro: Bool = false
    @Published var proProduct: Product?
    @Published var purchasing = false

    private init() {
        isPro = UserDefaults.standard.bool(forKey: "isPro")
        Task { await loadProducts(); await checkEntitlements() }
        listenForTransactions()
    }

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [Self.proProductID])
            proProduct = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase() async {
        guard let product = proProduct, !purchasing else { return }
        purchasing = true
        defer { purchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified = verification {
                    await verification.payloadValue.finish()
                    unlock()
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase error: \(error)")
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await checkEntitlements()
    }

    private func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result, tx.productID == Self.proProductID {
                unlock()
                return
            }
        }
    }

    private func listenForTransactions() {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let tx) = result, tx.productID == Self.proProductID {
                    await tx.finish()
                    await MainActor.run { self.unlock() }
                }
            }
        }
    }

    private func unlock() {
        isPro = true
        UserDefaults.standard.set(true, forKey: "isPro")
    }
}
