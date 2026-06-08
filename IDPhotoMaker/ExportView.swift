import SwiftUI

struct ExportView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var store = StoreManager.shared
    @State private var saved = false
    @State private var showShare = false
    @State private var saveError: String? = nil
    @State private var showPrintLayout = false
    @State private var selectedPrint: PrintLayout? = nil

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Button { state.screen = .editor } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 0.22, green: 0.20, blue: 0.64))
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    }
                    Spacer()
                    Text("完成")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if !store.isPro {
                    BannerAdView(adUnitID: "ca-app-pub-9404799280370656/2973583668")
                        .frame(height: 50)
                }

                ScrollView {
                    VStack(spacing: 24) {
                        // Final photo
                        if let img = state.finalImage {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.12), radius: 20, y: 10)
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .padding(16)
                            }
                            .frame(maxWidth: 260)
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .topTrailing) {
                                if saved {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("保存済み")
                                    }
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .padding(.trailing, 40)
                                    .padding(.top, 8)
                                }
                            }
                        }

                        // Size info
                        if let size = state.selectedSize {
                            HStack(spacing: 16) {
                                InfoBadge(title: "サイズ", value: size.subtitle, icon: "ruler")
                                InfoBadge(title: "解像度", value: "\(size.widthPx)×\(size.heightPx)px", icon: "photo")
                                InfoBadge(title: "印刷品質", value: "300dpi", icon: "printer")
                            }
                        }

                        // Print layout (Pro)
                        if store.isPro {
                            printLayoutSection
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 12))
                                Text("Pro: 印刷レイアウト（L判/2L判）")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        if let err = saveError {
                            Text(err)
                                .font(.system(size: 13))
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                        // Restart button
                        Button {
                            state.capturedImage = nil
                            state.processedImage = nil
                            state.finalImage = nil
                            state.selectedSize = nil
                            state.selectedFilter = nil
                            state.brightness = 0.0
                            state.contrast = 1.0
                            state.screen = .home
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                Text("最初からやり直す")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }

                // Bottom buttons
                VStack(spacing: 0) {
                    Divider()
                    VStack(spacing: 10) {
                        Button {
                            saveToPhotos()
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: saved ? "checkmark.circle.fill" : "square.and.arrow.down.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text(saved ? "保存しました！" : "カメラロールに保存")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                saved
                                ? AnyShapeStyle(Color.green)
                                : AnyShapeStyle(LinearGradient(
                                    colors: [Color(red: 0.22, green: 0.20, blue: 0.64), Color(red: 0.39, green: 0.40, blue: 0.95)],
                                    startPoint: .leading, endPoint: .trailing))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: (saved ? Color.green : Color(red: 0.39, green: 0.40, blue: 0.95)).opacity(0.4), radius: 10, y: 5)
                        }

                        Button {
                            showShare = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("共有する")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(Color(red: 0.22, green: 0.20, blue: 0.64))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(red: 0.39, green: 0.40, blue: 0.95), lineWidth: 1.5))
                            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    if !store.isPro {
                        BannerAdView(adUnitID: "ca-app-pub-9404799280370656/9069278214")
                            .frame(height: 50)
                    }
                }
                .background(Color(red: 0.97, green: 0.97, blue: 1.0))
            }
        }
        .sheet(isPresented: $showShare) {
            if let img = state.finalImage {
                ShareSheet(items: [img])
            }
        }
    }

    // MARK: - Print Layout

    private var printLayoutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("印刷レイアウト")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(PrintLayout.allCases) { layout in
                    Button {
                        selectedPrint = layout
                        if let img = state.finalImage, let size = state.selectedSize {
                            let printed = layout.generate(photo: img, size: size)
                            UIImageWriteToSavedPhotosAlbum(printed, nil, nil, nil)
                            saveError = nil
                            withAnimation { saved = true }
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: layout.icon)
                                .font(.system(size: 22))
                                .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                            Text(layout.label)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.primary)
                            Text(layout.subtitle)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    private func saveToPhotos() {
        guard let img = state.finalImage else { return }
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        withAnimation { saved = true }
    }
}

// MARK: - Print Layout

enum PrintLayout: String, CaseIterable, Identifiable {
    case lSize, twoLSize

    var id: String { rawValue }

    var label: String {
        switch self {
        case .lSize: return "L判"
        case .twoLSize: return "2L判"
        }
    }

    var subtitle: String {
        switch self {
        case .lSize: return "89×127mm"
        case .twoLSize: return "127×178mm"
        }
    }

    var icon: String {
        switch self {
        case .lSize: return "rectangle.portrait.on.rectangle.portrait"
        case .twoLSize: return "rectangle.grid.2x2"
        }
    }

    var widthPx: Int {
        switch self {
        case .lSize: return Int(89.0 / 25.4 * 300)    // 1051
        case .twoLSize: return Int(127.0 / 25.4 * 300) // 1500
        }
    }

    var heightPx: Int {
        switch self {
        case .lSize: return Int(127.0 / 25.4 * 300)   // 1500
        case .twoLSize: return Int(178.0 / 25.4 * 300) // 2102
        }
    }

    func generate(photo: UIImage, size: IDPhotoSize) -> UIImage {
        let canvasW = CGFloat(widthPx)
        let canvasH = CGFloat(heightPx)
        let photoW = CGFloat(size.widthPx)
        let photoH = CGFloat(size.heightPx)

        let cols = max(1, Int(canvasW / (photoW + 20)))
        let rows = max(1, Int(canvasH / (photoH + 20)))

        let spacingX = (canvasW - CGFloat(cols) * photoW) / CGFloat(cols + 1)
        let spacingY = (canvasH - CGFloat(rows) * photoH) / CGFloat(rows + 1)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasW, height: canvasH))
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: CGSize(width: canvasW, height: canvasH)))

            for row in 0..<rows {
                for col in 0..<cols {
                    let x = spacingX + CGFloat(col) * (photoW + spacingX)
                    let y = spacingY + CGFloat(row) * (photoH + spacingY)
                    photo.draw(in: CGRect(x: x, y: y, width: photoW, height: photoH))
                }
            }
        }
    }
}

struct InfoBadge: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
            Text(value)
                .font(.system(size: 12, weight: .bold))
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
