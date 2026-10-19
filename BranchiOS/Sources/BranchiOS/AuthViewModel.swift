import SwiftUI

public enum AuthProvider: String, CaseIterable, Sendable, Identifiable {
    case apple = "Apple"
    case google = "Google"
    case github = "GitHub"
    
    public var id: String { rawValue }
    
    public var buttonTitle: String {
        switch self {
        case .apple: return "Sign in with Apple"
        case .google: return "Sign in with Google"
        case .github: return "Sign in with GitHub"
        }
    }
    
    public var accessibilityLabel: String {
        buttonTitle
    }
}

@Observable
@MainActor
public final class AuthViewModel {
    public var signedInProvider: AuthProvider? = nil
    public var activeLoadingProvider: AuthProvider? = nil
    
    public var isLoading: Bool {
        activeLoadingProvider != nil
    }
    
    public init(signedInProvider: AuthProvider? = nil) {
        self.signedInProvider = signedInProvider
    }
    
    public func signIn(
        with provider: AuthProvider,
        store: DemoStore = DemoStore.shared,
        delayMs: Int = 300,
        onCompletion: (@MainActor (AuthProvider) -> Void)? = nil
    ) {
        guard !isLoading else { return }
        
        // Immediate tactile response
        triggerImpactFeedback(isMedium: true)
        activeLoadingProvider = provider
        
        Task { @MainActor in
            if delayMs > 0 {
                try? await Task.sleep(for: .milliseconds(delayMs))
            }
            
            withAnimation(BranchMotion.sharedSpring) {
                self.signedInProvider = provider
                self.activeLoadingProvider = nil
                // Persist session to DemoStore
                store.signIn(provider: provider)
            }
            
            triggerSuccessFeedback()
            onCompletion?(provider)
        }
    }
    
    public func signOut(store: DemoStore = DemoStore.shared) {
        triggerImpactFeedback(isMedium: false)
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            self.signedInProvider = nil
            self.activeLoadingProvider = nil
            store.signOut()
        }
    }
    
    private func triggerImpactFeedback(isMedium: Bool = true) {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: isMedium ? .medium : .light)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
    
    private func triggerSuccessFeedback() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
    }
}
