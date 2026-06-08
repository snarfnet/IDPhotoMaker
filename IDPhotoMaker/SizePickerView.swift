import SwiftUI

struct SizePickerView: View {
    @EnvironmentObject var state: AppState
    @ObservedObject var store = StoreManager.shared
    @State private var selected: IDPhotoSize? = nil

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                HStack {
                    Button {
                        state.screen = .home
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 0.22, green: 0.20, blue: 0.64))
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    }
                    Spacer()
                    Text("サイズを選択")
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
                    VStack(spacing: 12) {
                        ForEach(IDPhotoSize.freePresets) { size in
                            SizeRow(size: size, isSelected: selected?.id == size.id, locked: false) {
                                selected = size
                            }
                        }

                        if store.isPro {
                            Text("Pro サイズ")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                                .padding(.horizontal, 4)

                            ForEach(IDPhotoSize.proPresets) { size in
                                SizeRow(size: size, isSelected: selected?.id == size.id, locked: false) {
                                    selected = size
                                }
                            }
                        } else {
                            // Show locked pro sizes
                            Text("Pro サイズ")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                                .padding(.horizontal, 4)

                            ForEach(IDPhotoSize.proPresets) { size in
                                SizeRow(size: size, isSelected: false, locked: true) {}
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }

                // Next button
                VStack(spacing: 0) {
                    Divider()
                    Button {
                        if let s = selected {
                            state.selectedSize = s
                            state.screen = .capture
                        }
                    } label: {
                        Text(selected == nil ? "サイズを選んでください" : "次へ　→")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                selected == nil
                                ? AnyShapeStyle(Color.gray.opacity(0.4))
                                : AnyShapeStyle(LinearGradient(
                                    colors: [Color(red: 0.22, green: 0.20, blue: 0.64), Color(red: 0.39, green: 0.40, blue: 0.95)],
                                    startPoint: .leading, endPoint: .trailing))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(selected == nil)
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
}

struct SizeRow: View {
    let size: IDPhotoSize
    let isSelected: Bool
    let locked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(locked ? Color.gray.opacity(0.15)
                              : (isSelected
                                 ? Color(red: 0.39, green: 0.40, blue: 0.95)
                                 : Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.1)))
                        .frame(width: 48, height: 48)
                    Image(systemName: locked ? "lock.fill" : size.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(locked ? .gray
                                         : (isSelected ? .white : Color(red: 0.39, green: 0.40, blue: 0.95)))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(size.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(locked ? .secondary : .primary)
                    Text(size.subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if locked {
                    Text("PRO")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22))
                        .foregroundStyle(isSelected ? Color(red: 0.39, green: 0.40, blue: 0.95) : Color.gray.opacity(0.4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(red: 0.39, green: 0.40, blue: 0.95) : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(isSelected ? 0.08 : 0.04), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
        .disabled(locked)
    }
}
