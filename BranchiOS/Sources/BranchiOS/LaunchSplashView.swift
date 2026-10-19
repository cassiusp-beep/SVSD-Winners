import SwiftUI

/// Matches the static launch screen (UILaunchScreen: LaunchMark on LaunchBackground) pixel-for-pixel,
/// blinks once, then hands over to the app. No blink under Reduce Motion.
struct LaunchSplashView: View {
    var onFinish: () -> Void

    @State private var closed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color(.systemBackground)
            YaYaMark(size: 96, blinks: false, closed: closed)
        }
        .ignoresSafeArea()
        .task {
            if reduceMotion {
                try? await Task.sleep(nanoseconds: 500_000_000)
            } else {
                try? await Task.sleep(nanoseconds: 450_000_000)
                withAnimation(.easeInOut(duration: 0.1)) { closed = true }
                try? await Task.sleep(nanoseconds: 140_000_000)
                withAnimation(.easeInOut(duration: 0.12)) { closed = false }
                try? await Task.sleep(nanoseconds: 450_000_000)
            }
            onFinish()
        }
    }
}
