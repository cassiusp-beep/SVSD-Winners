import SwiftUI

// MARK: - Welcome Soft Wash Background
public struct WelcomeSoftWashBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    public init() {}
    
    public var body: some View {
        ZStack {
            if colorScheme == .dark {
                Color.black
                    .ignoresSafeArea()
                
                // Subtle dark lavender glow top-trailing
                RadialGradient(
                    colors: [
                        Color(red: 0.28, green: 0.18, blue: 0.42).opacity(0.40),
                        Color.clear
                    ],
                    center: .topTrailing,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea()
                
                // Subtle dark sage glow mid-trailing
                RadialGradient(
                    colors: [
                        Color(red: 0.16, green: 0.28, blue: 0.18).opacity(0.35),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.95, y: 0.44),
                    startRadius: 30,
                    endRadius: 300
                )
                .ignoresSafeArea()
            } else {
                // Warm off-white base (#FAF9F5)
                Color(red: 0.980, green: 0.976, blue: 0.961)
                    .ignoresSafeArea()
                
                // Soft lavender glow top-trailing behind Cloud
                RadialGradient(
                    colors: [
                        Color(red: 0.82, green: 0.74, blue: 0.94).opacity(0.65),
                        Color(red: 0.82, green: 0.74, blue: 0.94).opacity(0.0)
                    ],
                    center: .topTrailing,
                    startRadius: 60,
                    endRadius: 380
                )
                .ignoresSafeArea()
                
                // Soft sage glow mid-trailing behind Spark
                RadialGradient(
                    colors: [
                        Color(red: 0.76, green: 0.88, blue: 0.76).opacity(0.55),
                        Color(red: 0.76, green: 0.88, blue: 0.76).opacity(0.0)
                    ],
                    center: UnitPoint(x: 0.95, y: 0.42),
                    startRadius: 40,
                    endRadius: 280
                )
                .ignoresSafeArea()
                
                // Gentle warm peach ground tint bottom-leading
                RadialGradient(
                    colors: [
                        Color(red: 0.98, green: 0.95, blue: 0.92).opacity(0.45),
                        Color.clear
                    ],
                    center: .bottomLeading,
                    startRadius: 20,
                    endRadius: 320
                )
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - SSO Provider Logos
public struct ProviderLogoView: View {
    public let provider: AuthProvider
    public let size: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    
    public init(provider: AuthProvider, size: CGFloat = 20) {
        self.provider = provider
        self.size = size
    }
    
    public var body: some View {
        Group {
            switch provider {
            case .apple:
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
            case .google:
                #if canImport(UIKit)
                if let uiImage = UIImage(named: "google_logo") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    GoogleFallbackLogo()
                }
                #else
                GoogleFallbackLogo()
                #endif
            case .github:
                #if canImport(UIKit)
                if let uiImage = UIImage(named: "github_logo") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    GitHubFallbackLogo()
                }
                #else
                GitHubFallbackLogo()
                #endif
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

public struct GoogleFallbackLogo: View {
    public init() {}
    public var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
            Text("G")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.26, green: 0.52, blue: 0.96))
        }
    }
}

public struct GitHubFallbackLogo: View {
    @Environment(\.colorScheme) private var colorScheme
    public init() {}
    public var body: some View {
        Image(systemName: "curlybraces.square.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color.primary)
    }
}

// MARK: - SSO Sign In Sheet
public struct SSOSignInSheet: View {
    @Bindable var store: DemoStore
    public var title: String = "Sign up for YaYa"
    public var subtitle: String = "Choose an account to get started"
    public var onComplete: ((AuthProvider) -> Void)? = nil
    
    @State private var viewModel = AuthViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    public init(
        store: DemoStore = DemoStore.shared,
        title: String = "Sign up for YaYa",
        subtitle: String = "Choose an account to get started",
        onComplete: ((AuthProvider) -> Void)? = nil
    ) {
        self.store = store
        self.title = title
        self.subtitle = subtitle
        self.onComplete = onComplete
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Drag handle clearance
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 4)
            
            VStack(spacing: 12) {
                ssoButton(for: .apple)
                ssoButton(for: .google)
                ssoButton(for: .github)
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            
            Spacer(minLength: 16)
        }
        .presentationDetents([.fraction(0.44), .medium])
        .presentationDragIndicator(.visible)
    }
    
    @ViewBuilder
    private func ssoButton(for provider: AuthProvider) -> some View {
        let isCurrentLoading = viewModel.activeLoadingProvider == provider
        let isApple = provider == .apple
        
        Button {
            viewModel.signIn(with: provider, store: store, delayMs: 250) { signedProvider in
                onComplete?(signedProvider)
                dismiss()
            }
        } label: {
            HStack(spacing: 12) {
                if isCurrentLoading {
                    ProgressView()
                        .tint(isApple ? (colorScheme == .dark ? Color.black : Color.white) : Color.primary)
                } else {
                    ProviderLogoView(provider: provider, size: 20)
                }
                
                Text(provider.buttonTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isApple ? (colorScheme == .dark ? Color.black : Color.white) : Color.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background {
                if isApple {
                    Capsule()
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                } else {
                    Capsule()
                        .fill(colorScheme == .dark ? Color(white: 0.16) : Color(white: 0.95))
                }
            }
            .overlay {
                if !isApple {
                    Capsule()
                        .stroke(colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.10), lineWidth: 1)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
    }
}

// MARK: - Main Welcome Screen (SignInView)
public struct SignInView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    public var showsBackground: Bool = true
    public var onSignedIn: ((AuthProvider) -> Void)? = nil
    
    @State private var isShowingSSOSheet: Bool = false
    @State private var isCloudBlinking: Bool = false
    @State private var isSparkBlinking: Bool = false
    @State private var blinkTimer: Timer? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        store: DemoStore = DemoStore.shared,
        showsBackground: Bool = true,
        onSignedIn: ((AuthProvider) -> Void)? = nil
    ) {
        self.store = store
        self.showsBackground = showsBackground
        self.onSignedIn = onSignedIn
    }
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let topInset = geo.safeAreaInsets.top
            let bottomInset = geo.safeAreaInsets.bottom
            
            ZStack(alignment: .topLeading) {
                // 1. Soft Wash Background (Applies to Welcome screen only)
                if showsBackground {
                    WelcomeSoftWashBackground()
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
                
                // 2. Top Sprites (Cloud + Spark artwork in exact canonical proportions)
                ZStack {
                    // Purple Cloud Sprite at top right (partially edge-cropped)
                    SpriteView(
                        sprite: .cloud,
                        isBlinking: isCloudBlinking,
                        showsArms: false
                    )
                    .frame(width: 250, height: 250)
                    .position(x: w - 95, y: max(topInset, 50) + 120)
                    .accessibilityHidden(true)
                    
                    // Sage Spark Sprite tucked slightly overlapping bottom-right of Cloud
                    SpriteView(
                        sprite: .spark,
                        isBlinking: isSparkBlinking,
                        showsArms: false
                    )
                    .frame(width: 135, height: 135)
                    .position(x: w - 55, y: max(topInset, 50) + 240)
                    .accessibilityHidden(true)
                }
                .allowsHitTesting(false)
                
                // 3. Top-Left Brand Wordmark (decorative: the headline below says the name)
                YaYaWordmark(size: 28, blinks: true, decorative: true)
                    .padding(.top, max(topInset, 50) + 26)
                    .padding(.leading, 28)
                
                // 4. Lower Content Stack: Headline, Body, Guest Button, Sign Up, Sign In
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 24)
                    
                    // Headline: "Ready to YaYa." in Berkeley Mono Bold
                    Text("Ready to YaYa.")
                        .font(.yaya(size: 34, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .padding(.bottom, 14)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Body Text: System font, secondary text color
                    Text("Talk through and import projects that you're working on. YaYa extracts insights in your process to craft your narrative.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.secondary)
                        .lineSpacing(4)
                        .padding(.bottom, 32)
                    
                    // Buttons Stack
                    VStack(spacing: 12) {
                        // Primary Button: "Try YaYa without an account"
                        Button {
                            handleGuestModeTap()
                        } label: {
                            Text("Try YaYa without an account")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    Capsule()
                                        .fill(colorScheme == .dark ? Color.white : Color.black)
                                )
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Try YaYa without an account")
                        .accessibilityHint("Start using YaYa immediately in guest mode")
                        
                        // Secondary Button: "Sign up"
                        Button {
                            isShowingSSOSheet = true
                        } label: {
                            Text("Sign up")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    Capsule()
                                        .stroke(Color.primary, lineWidth: 1.2)
                                )
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Sign up")
                        .accessibilityHint("Open account creation options")
                    }
                    .padding(.bottom, 18)
                    
                    // Sign-In Footer Line: "Already have an account? Sign in"
                    HStack(spacing: 4) {
                        Spacer()
                        Text("Already have an account?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.secondary)
                        
                        Button {
                            isShowingSSOSheet = true
                        } label: {
                            Text("Sign in")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.primary)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding(.bottom, max(bottomInset, 16) + 4)
                }
                .padding(.horizontal, 28)
                .frame(width: w, height: h, alignment: .bottomLeading)
            }
            .frame(width: w, height: h)
            .sheet(isPresented: $isShowingSSOSheet) {
                SSOSignInSheet(store: store) { provider in
                    onSignedIn?(provider)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startBlinkLoop()
        }
        .onDisappear {
            blinkTimer?.invalidate()
        }
    }
    
    private func handleGuestModeTap() {
        withAnimation(BranchMotion.sharedSpring) {
            store.startGuestSession()
        }
    }
    
    private func startBlinkLoop() {
        guard !reduceMotion else { return }
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 3.2, repeats: true) { _ in
            Task { @MainActor in
                // Desynchronized blinks between Cloud and Spark
                withAnimation(.easeInOut(duration: 0.12)) {
                    isCloudBlinking = true
                }
                try? await Task.sleep(nanoseconds: 140_000_000)
                withAnimation(.easeInOut(duration: 0.12)) {
                    isCloudBlinking = false
                }
                
                try? await Task.sleep(nanoseconds: 400_000_000)
                withAnimation(.easeInOut(duration: 0.12)) {
                    isSparkBlinking = true
                }
                try? await Task.sleep(nanoseconds: 140_000_000)
                withAnimation(.easeInOut(duration: 0.12)) {
                    isSparkBlinking = false
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Welcome - Light Mode") {
    SignInView()
        .preferredColorScheme(.light)
}

#Preview("Welcome - Dark Mode") {
    SignInView()
        .preferredColorScheme(.dark)
}
