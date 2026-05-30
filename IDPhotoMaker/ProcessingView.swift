import SwiftUI

struct ProcessingView: View {
    @EnvironmentObject var state: AppState
    @State private var progress: CGFloat = 0
    @State private var statusText = "画像を解析中..."
    @State private var errorMessage: String? = nil
    @State private var dots = ""
    @State private var dotTimer: Timer? = nil

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Animated icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0.39, green: 0.40, blue: 0.95).opacity(0.1))
                        .frame(width: 140, height: 140)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [Color(red: 0.22, green: 0.20, blue: 0.64), Color(red: 0.39, green: 0.40, blue: 0.95)],
                                startPoint: .leading, endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: progress)

                    Image(systemName: "scissors")
                        .font(.system(size: 48))
                        .foregroundStyle(Color(red: 0.39, green: 0.40, blue: 0.95))
                }

                VStack(spacing: 12) {
                    Text(statusText + dots)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    Text("背景を自動で除去しています")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }

                if let err = errorMessage {
                    VStack(spacing: 16) {
                        Text(err)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)

                        Button {
                            state.screen = .capture
                        } label: {
                            Text("やり直す")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.39, green: 0.40, blue: 0.95))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 40)
                }

                Spacer()
            }
        }
        .onAppear {
            startDotAnimation()
            processImage()
        }
        .onDisappear {
            dotTimer?.invalidate()
        }
    }

    private func startDotAnimation() {
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            dots = dots.count >= 3 ? "" : dots + "."
        }
    }

    private func processImage() {
        guard let image = state.capturedImage else {
            state.screen = .capture
            return
        }

        Task {
            do {
                await MainActor.run {
                    statusText = "人物を検出中"
                    progress = 0.3
                }
                try await Task.sleep(nanoseconds: 300_000_000)

                await MainActor.run {
                    statusText = "背景を除去中"
                    progress = 0.6
                }

                let result = try await PhotoProcessor.removeBackground(from: image)

                await MainActor.run {
                    statusText = "仕上げ中"
                    progress = 0.9
                }
                try await Task.sleep(nanoseconds: 200_000_000)

                await MainActor.run {
                    progress = 1.0
                    state.processedImage = result
                    dotTimer?.invalidate()
                    state.screen = .editor
                }
            } catch {
                await MainActor.run {
                    dotTimer?.invalidate()
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
