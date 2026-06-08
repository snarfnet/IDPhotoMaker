import SwiftUI

struct HomeView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var store = StoreManager.shared
    @State private var showProSheet = false

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.20, blue: 0.64),
                            Color(red: 0.39, green: 0.40, blue: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(edges: .top)

                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.top, 16)

                        Text("かんたん証明写真")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("きれいな証明写真を、かんたんに")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.bottom, 32)
                    }
                    .padding(.top, 20)
                }
                .frame(height: 220)

                if !store.isPro {
                    BannerAdView(adUnitID: "ca-app-pub-9404799280370656/2973583668")
                        .frame(height: 50)
                }

                ScrollView {
                    VStack(spacing: 20) {
                        // Feature cards
                        HStack(spacing: 12) {
                            FeatureCard(icon: "scissors", title: "背景自動除去", color: Color(red: 0.39, green: 0.40, blue: 0.95))
                            FeatureCard(icon: "square.resize", title: "サイズ自動調整", color: Color(red: 0.13, green: 0.69, blue: 0.58))
                        }
                        HStack(spacing: 12) {
                            FeatureCard(icon: "paintpalette.fill", title: "背景色選択", color: Color(red: 0.95, green: 0.52, blue: 0.22))
                            FeatureCard(icon: "square.and.arrow.down.fill", title: "カメラロール保存", color: Color(red: 0.85, green: 0.23, blue: 0.52))
                        }

                        // Main CTA
                        Button {
                            state.screen = .sizePicker
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("写真を作成する")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.22, green: 0.20, blue: 0.64),
                                        Color(red: 0.39, green: 0.40, blue: 0.95)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.4), radius: 12, y: 6)
                        }
                        .padding(.top, 8)

                        // Pro upgrade banner
                        if !store.isPro {
                            Button { showProSheet = true } label: {
                                proUpgradeBanner
                            }
                            .buttonStyle(.plain)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                                Text("Pro 有効")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(red: 0.22, green: 0.20, blue: 0.64))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // Size list preview
                        VStack(alignment: .leading, spacing: 12) {
                            Text("対応サイズ")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            ForEach(IDPhotoSize.freePresets) { size in
                                sizePreviewRow(size: size, locked: false)
                            }

                            if store.isPro {
                                ForEach(IDPhotoSize.proPresets) { size in
                                    sizePreviewRow(size: size, locked: false)
                                }
                            }
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 80)
                }

                if !store.isPro {
                    BannerAdView(adUnitID: "ca-app-pub-9404799280370656/9069278214")
                        .frame(height: 50)
                }
            }
        }
        .sheet(isPresented: $showProSheet) {
            ProUpgradeView()
        }
    }

    private func sizePreviewRow(size: IDPhotoSize, locked: Bool) -> some View {
        HStack {
            Image(systemName: size.icon)
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                .frame(width: 24)
            Text(size.name)
                .font(.system(size: 14, weight: .medium))
            Spacer()
            Text(size.subtitle)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    private var proUpgradeBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 28))
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text("Pro にアップグレード")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("美肌補正・サイズ追加・広告非表示")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer()

            Text(store.proProduct?.displayPrice ?? "¥100")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.22, green: 0.20, blue: 0.64))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(red: 0.22, green: 0.20, blue: 0.64), Color(red: 0.50, green: 0.45, blue: 0.95)],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(red: 0.22, green: 0.20, blue: 0.64).opacity(0.3), radius: 10, y: 5)
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}
