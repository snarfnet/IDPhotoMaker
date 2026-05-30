import SwiftUI

struct EditorView: View {
    @EnvironmentObject var state: AppState
    @State private var selectedBG: BackgroundColor = .white

    var previewImage: UIImage? {
        guard let fg = state.processedImage, let size = state.selectedSize else { return nil }
        return PhotoProcessor.compositeOnBackground(
            foreground: fg,
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

                BannerAdView(adUnitID: "ca-app-pub-9404799280370656/2973583668")
                    .frame(height: 50)

                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        if let img = previewImage {
                            ZStack {
                                // Checkered background to show transparency
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 12, y: 6)

                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .padding(12)
                            }
                            .frame(maxWidth: 280)
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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("背景色")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                ForEach(BackgroundColor.allCases) { bg in
                                    BGColorButton(bg: bg, isSelected: selectedBG == bg) {
                                        selectedBG = bg
                                        state.selectedBG = bg
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)

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

                    BannerAdView(adUnitID: "ca-app-pub-9404799280370656/9069278214")
                        .frame(height: 50)
                }
                .background(Color(red: 0.97, green: 0.97, blue: 1.0))
            }
        }
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
