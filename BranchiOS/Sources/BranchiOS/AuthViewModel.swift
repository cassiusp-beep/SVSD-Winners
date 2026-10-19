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
    
    public func signIn(with provider: AuthProvider, store: DemoStore = DemoStore.shared) {
        guard !isLoading else { return }
        
        // Immediate tactile response
        triggerImpactFeedback(isMedium: true)
        activeLoadingProvider = provider
        
        Task { @MainActor in
            // Simulated authentication delay (1.5 seconds)
            try? await Task.sleep(for: .milliseconds(1500))
            
            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                self.signedInProvider = provider
                self.activeLoadingProvider = nil
                // Persist session to DemoStore
                store.signIn(provider: provider)
            }
            
            triggerSuccessFeedback()
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
