import SwiftUI

// MARK: - Animated Mesh Gradient Background
public struct AnimatedMeshBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let elapsed = reduceMotion ? 0 : Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 120))
            
            // Gentle continuous floating center points
            let p1: Float = 0.5 + 0.12 * sin(elapsed * 0.35)
            let p2: Float = 0.5 + 0.12 * cos(elapsed * 0.42)
            let p3: Float = 0.5 + 0.08 * cos(elapsed * 0.28)
            let p4: Float = 0.5 + 0.08 * sin(elapsed * 0.31)
            
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, p3],  [p1, p2],   [1.0, p4],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: palette
            )
            .ignoresSafeArea()
            // High contrast / reduce transparency accessibility veil
            .overlay {
                if reduceTransparency || colorSchemeContrast == .increased {
                    (colorScheme == .dark ? Color.black.opacity(0.85) : Color.white.opacity(0.88))
                        .ignoresSafeArea()
                }
            }
        }
    }
    
    private var palette: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.08, green: 0.09, blue: 0.14),
                Color(red: 0.12, green: 0.16, blue: 0.26),
                Color(red: 0.15, green: 0.11, blue: 0.24),
                Color(red: 0.06, green: 0.14, blue: 0.20),
                Color(red: 0.18, green: 0.14, blue: 0.30),
                Color(red: 0.09, green: 0.18, blue: 0.22),
                Color(red: 0.05, green: 0.06, blue: 0.10),
                Color(red: 0.07, green: 0.11, blue: 0.18),
                Color(red: 0.06, green: 0.08, blue: 0.14)
            ]
        } else {
            return [
                Color(red: 0.98, green: 0.94, blue: 0.90), // Warm apricot pearl
                Color(red: 0.92, green: 0.94, blue: 0.99), // Soft azure mist
                Color(red: 0.95, green: 0.92, blue: 0.98), // Subtle lavender
                Color(red: 0.90, green: 0.96, blue: 0.94), // Gentle seafoam
                Color(red: 0.99, green: 0.96, blue: 0.92), // Radiant center
                Color(red: 0.94, green: 0.93, blue: 0.98), // Soft lilac
                Color(red: 0.96, green: 0.94, blue: 0.90), // Sandy drafting tint
                Color(red: 0.91, green: 0.95, blue: 0.97), // Calming sky
                Color(red: 0.97, green: 0.95, blue: 0.93)  // Cream ground
            ]
        }
    }
}

// MARK: - Vector Logos (Fallback when image assets are pending)
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
                    .foregroundStyle(.white)
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
            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
    }
}

// MARK: - Main SignInView
public struct SignInView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    @State private var viewModel = AuthViewModel()
    public var showsBackground: Bool = true
    public var onSignedIn: ((AuthProvider) -> Void)? = nil
    
    @State private var hasCompletedSignIn: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    @ScaledMetric(relativeTo: .body) private var buttonHeight: CGFloat = 50
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 20
    @ScaledMetric(relativeTo: .largeTitle) private var appIconSize: CGFloat = 84
    
    public init(
        store: DemoStore = DemoStore.shared,
        viewModel: AuthViewModel = AuthViewModel(),
        showsBackground: Bool = true,
        onSignedIn: ((AuthProvider) -> Void)? = nil
    ) {
        self.store = store
        self._viewModel = State(initialValue: viewModel)
        self.showsBackground = showsBackground
        self.onSignedIn = onSignedIn
    }
    
    public var body: some View {
        ZStack {
            if hasCompletedSignIn && onSignedIn == nil {
                ProfileSetupView(store: store)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 20)),
                        removal: .opacity.combined(with: .offset(y: -20))
                    ))
            } else {
                signInMainContent
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .opacity.combined(with: .offset(y: -20))
                    ))
            }
        }
        .animation(BranchMotion.sharedSpring, value: hasCompletedSignIn)
        .onChange(of: store.session) { _, newSession in
            if newSession != nil && !hasCompletedSignIn {
                withAnimation(BranchMotion.sharedSpring) {
                    hasCompletedSignIn = true
                }
            }
        }
    }
    
    // MARK: - Main Sign In Content
    private var signInMainContent: some View {
        ZStack {
            // Semantic plain background: white in light mode, black in dark mode
            if showsBackground {
                (colorScheme == .dark ? Color.black : Color.white)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // TOP AREA: App Icon, Large Title & One-Line Subtitle
                topHeaderArea
                    .frame(maxWidth: .infinity)
                    .padding(.top, 48)
                
                Spacer(minLength: 24)
                
                // BOTTOM AREA: Three SSO Buttons in Plain Container + Footnote
                bottomAuthArea
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    // MARK: - Top Header Area
    private var topHeaderArea: some View {
        VStack(spacing: 16) {
            // App Icon Placeholder with Clean Solid Fill
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(colorScheme == .dark ? Color(white: 0.14) : Color(white: 0.95))
                    .frame(width: appIconSize, height: appIconSize)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.08), lineWidth: 1)
                    )
                
                Image(systemName: "point.3.filled.connected.trianglepath.dotted")
                    .font(.system(size: appIconSize * 0.44, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }
            .accessibilityHidden(true)
            .padding(.bottom, 4)
            
            VStack(spacing: 8) {
                Text("Branch")
                    .font(.system(.largeTitle, design: .default, weight: .bold))
                    .foregroundStyle(.primary)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Document thinking. Find your narrative.")
                    .font(.system(.subheadline, design: .default, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Bottom Area
    private var bottomAuthArea: some View {
        VStack(spacing: 14) {
            // Stacked SSO Buttons in Plain Layout
            VStack(spacing: 12) {
                ssoButton(for: .apple)
                ssoButton(for: .google)
                ssoButton(for: .github)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 400)
            
            // Small Footnote
            Text("By continuing, you agree to our Terms and Privacy Policy.")
                .font(.system(.caption2, design: .default, weight: .regular))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 4)
                .accessibilityLabel("Legal disclosure: By continuing, you agree to our Terms and Privacy Policy.")
        }
    }
    
    // MARK: - SSO Button Builder
    @ViewBuilder
    private func ssoButton(for provider: AuthProvider) -> some View {
        let isCurrentLoading = viewModel.activeLoadingProvider == provider
        let isApple = provider == .apple
        
        Button {
            handleSignInTap(provider: provider)
        } label: {
            HStack(spacing: 12) {
                if isCurrentLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(isApple ? (colorScheme == .dark ? Color.black : Color.white) : Color.primary)
                        .accessibilityLabel("Signing in")
                } else {
                    ProviderLogoView(provider: provider, size: iconSize)
                        .foregroundStyle(isApple ? (colorScheme == .dark ? Color.black : Color.white) : Color.primary)
                }
                
                Text(provider.buttonTitle)
                    .font(.system(.body, design: .default, weight: .semibold))
                    .foregroundStyle(isApple ? (colorScheme == .dark ? Color.black : Color.white) : Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: max(buttonHeight, 50))
            .background {
                if isApple {
                    Capsule()
                        .fill(colorScheme == .dark ? Color.white : Color.black)
                } else {
                    Capsule()
                        .fill(colorScheme == .dark ? Color(white: 0.14) : Color(white: 0.96))
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
        .accessibilityLabel(provider.accessibilityLabel)
        .accessibilityValue(isCurrentLoading ? "Signing in" : "")
        .accessibilityHint(viewModel.isLoading ? "Authentication in progress" : "Double tap to sign in with \(provider.rawValue)")
    }
    
    private func handleSignInTap(provider: AuthProvider) {
        viewModel.signIn(with: provider, store: store, delayMs: 300) { signedProvider in
            withAnimation(BranchMotion.sharedSpring) {
                hasCompletedSignIn = true
                onSignedIn?(signedProvider)
            }
        }
    }
}

// MARK: - View Extension Helper for Conditional Modifiers
extension View {
    @ViewBuilder
    func modifyIf<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Previews

#Preview("SignInView - Light Mode") {
    SignInView()
        .preferredColorScheme(.light)
}

#Preview("SignInView - Dark Mode") {
    SignInView()
        .preferredColorScheme(.dark)
}

#Preview("SignInView - Accessibility Large Text") {
    SignInView()
        .environment(\.dynamicTypeSize, .accessibility3)
}
