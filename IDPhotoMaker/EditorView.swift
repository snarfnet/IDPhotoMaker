import SwiftUI

struct EditorView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var store = StoreManager.shared
    @State private var selectedBG: BackgroundColor = .white
    @State private var selectedFilter: BeautyFilter? = nil
    @State private var brightness: Double = 0.0
    @State private var contrast: Double = 1.0

    var previewImage: UIImage? {
        guard let fg = state.processedImage, let size = state.selectedSize else { return nil }
        var img = fg
        if let filter = selectedFilter {
            img = filter.apply(to: img)
        }
        if brightness != 0.0 || contrast != 1.0 {
            img = applyAdjustments(to: img)
        }
        return PhotoProcessor.compositeOnBackground(
            foreground: img,
            background: UIColor(selectedBG.color),
            targetSize: size
        )
    }

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Button { state.screen = .capture } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 0.22, green: 0.20, blue: 0.64))
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    }
                    Spacer()
                    Text("編集")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Spacer()
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                if !store.isPro {
                    BannerAdView(adUnitID: "ca-app-pub-9404799280370656/2973583668")
                        .frame(height: 50)
                }

                ScrollView {
                    VStack(spacing: 20) {
                        // Preview
                        if let img = previewImage {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(12)
                            }
                            .frame(maxWidth: 260)
                            .frame(maxWidth: .infinity)
                        }

                        // Size info badge
                        if let size = state.selectedSize {
                            HStack(spacing: 8) {
                                Image(systemName: size.icon)
                                    .font(.system(size: 13))
                                Text("\(size.name)　\(size.subtitle)")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }

                        // Background color picker
                        bgColorSection

                        // Beauty filters (Pro)
                        beautyFilterSection

                        // Brightness / Contrast (Pro)
                        adjustmentSection

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }

                // Bottom
                VStack(spacing: 0) {
                    Divider()
                    Button {
                        if let img = previewImage {
                            state.selectedFilter = selectedFilter
                            state.brightness = brightness
                            state.contrast = contrast
                            state.finalImage = img
                            state.screen = .export
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18))
                            Text("この写真で決定")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.22, green: 0.20, blue: 0.64), Color(red: 0.39, green: 0.40, blue: 0.95)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.4), radius: 10, y: 5)
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
    }

    // MARK: - Background Color

    private var bgColorSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("背景色")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(BackgroundColor.freeColors) { bg in
                    BGColorButton(bg: bg, isSelected: selectedBG == bg) {
                        selectedBG = bg
                        state.selectedBG = bg
                    }
                }
            }

            if store.isPro {
                HStack(spacing: 12) {
                    ForEach(BackgroundColor.proColors) { bg in
                        BGColorButton(bg: bg, isSelected: selectedBG == bg) {
                            selectedBG = bg
                            state.selectedBG = bg
                        }
                    }
                }
            } else {
                proLockBanner(text: "Pro: 背景色 +6色")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    // MARK: - Beauty Filters

    private var beautyFilterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("美肌補正")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                if selectedFilter != nil && store.isPro {
                    Button("リセット") {
                        selectedFilter = nil
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                }
            }

            if store.isPro {
                LazyVGrid(columns: [
                    GridItem(.flexible()), GridItem(.flexible()),
                    GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(BeautyFilter.all) { filter in
                        FilterButton(filter: filter, isSelected: selectedFilter?.id == filter.id) {
                            selectedFilter = (selectedFilter?.id == filter.id) ? nil : filter
                        }
                    }
                }
            } else {
                proLockBanner(text: "Pro: 美肌補正 10種類")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    // MARK: - Adjustments

    private var adjustmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("明るさ・コントラスト")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)

            if store.isPro {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "sun.min")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Slider(value: $brightness, in: -0.15...0.15, step: 0.01)
                            .tint(Color(red: 0.39, green: 0.40, blue: 0.95))
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Text("明るさ")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 40)
                    }
                    HStack {
                        Image(systemName: "circle.lefthalf.filled")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Slider(value: $contrast, in: 0.8...1.3, step: 0.01)
                            .tint(Color(red: 0.39, green: 0.40, blue: 0.95))
                        Image(systemName: "circle.righthalf.filled")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                        Text("対比")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .frame(width: 40)
                    }
                }
            } else {
                proLockBanner(text: "Pro: 明るさ・コントラスト調整")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    // MARK: - Pro Lock Banner

    private func proLockBanner(text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Adjustments Helper

    private func applyAdjustments(to image: UIImage) -> UIImage {
        guard let ci = CIImage(image: image) else { return image }
        let filter = CIFilter.colorControls()
        filter.inputImage = ci
        filter.brightness = Float(brightness)
        filter.contrast = Float(contrast)
        filter.saturation = 1.0
        guard let output = filter.outputImage else { return image }
        let ctx = CIContext()
        guard let cg = ctx.createCGImage(output, from: ci.extent) else { return image }
        return UIImage(cgImage: cg)
    }
}

struct FilterButton: View {
    let filter: BeautyFilter
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isSelected
                              ? Color(red: 0.39, green: 0.40, blue: 0.95)
                              : Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: filter.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(isSelected ? .white : Color(red: 0.39, green: 0.40, blue: 0.95))
                }
                Text(filter.name)
                    .font(.system(size: 9, weight: isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? Color(red: 0.39, green: 0.40, blue: 0.95) : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
    }
}

struct BGColorButton: View {
    let bg: BackgroundColor
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(bg.color)
                        .frame(width: 44, height: 44)
                        .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    if isSelected {
                        Circle()
                            .stroke(Color(red: 0.39, green: 0.40, blue: 0.95), lineWidth: 3)
                            .frame(width: 50, height: 50)
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(bg == .white ? Color(red: 0.39, green: 0.40, blue: 0.95) : .white)
                    }
                }
                Text(bg.label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color(red: 0.39, green: 0.40, blue: 0.95) : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}
