import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    let isPro = true
    private init() {}
}
