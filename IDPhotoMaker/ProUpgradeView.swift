import SwiftUI

struct ProUpgradeView: View {
    @ObservedObject var store = StoreManager.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.97, blue: 1.0),
                    Color(red: 0.92, green: 0.91, blue: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                // Header
                Image(systemName: "sparkles")
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.39, green: 0.40, blue: 0.95), .purple],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )

                Text("Pro にアップグレード")
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    proFeatureRow(icon: "eye.slash.fill", text: "広告を完全非表示")
                    proFeatureRow(icon: "sparkles", text: "美肌補正 10種類")
                    proFeatureRow(icon: "sun.max.fill", text: "明るさ・コントラスト調整")
                    proFeatureRow(icon: "square.resize", text: "証明写真サイズ +9種")
                    proFeatureRow(icon: "paintpalette.fill", text: "背景色 +6色")
                    proFeatureRow(icon: "rectangle.portrait.on.rectangle.portrait", text: "印刷レイアウト（L判/2L判）")
                }
                .padding(24)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
                .padding(.horizontal, 24)

                Spacer()

                // Purchase button
                Button {
                    Task {
                        await store.purchase()
                        if store.isPro { dismiss() }
                    }
                } label: {
                    HStack(spacing: 10) {
                        if store.purchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                        }
                        Text(store.purchasing ? "処理中..." : "買い切り \(store.proProduct?.displayPrice ?? "¥100") で解放")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.22, green: 0.20, blue: 0.64), Color(red: 0.50, green: 0.45, blue: 0.95)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.4), radius: 12, y: 6)
                }
                .disabled(store.purchasing)
                .padding(.horizontal, 24)

                // Restore
                Button {
                    Task { await store.restore() }
                } label: {
                    Text("購入を復元")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                }

                Spacer().frame(height: 16)
            }
        }
    }

    private func proFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                .frame(width: 28)
            Text(text)
                .font(.system(size: 15, weight: .medium))
        }
    }
}
