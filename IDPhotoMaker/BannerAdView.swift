import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        DispatchQueue.main.async {
            if let rootVC = Self.findRootViewController() {
                banner.rootViewController = rootVC
                banner.load(GADRequest())
            }
        }
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    private static func findRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            ?? UIApplication.shared.connectedScenes.first as? UIWindowScene else { return nil }
        return scene.keyWindow?.rootViewController
    }
}
