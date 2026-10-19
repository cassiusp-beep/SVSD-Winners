import SwiftUI

public struct AppRootView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    
    public init(store: DemoStore = DemoStore.shared) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            if !store.isSessionActive {
                SignInView(store: store)
                    .transition(.opacity)
            } else if !store.hasCompletedProfile {
                ProfileSetupView(store: store, isEditing: false)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.96)),
                        removal: .opacity.combined(with: .scale(scale: 1.04))
                    ))
            } else if !store.hasCompletedIntegrations {
                IntegrationsView(store: store)
                    .transition(.opacity)
            } else if !store.hasCompletedSync {
                SyncingView(store: store)
                    .transition(.opacity)
            } else {
                HomeView(store: store)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.96)),
                        removal: .opacity.combined(with: .scale(scale: 1.04))
                    ))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: store.isSessionActive)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: store.hasCompletedProfile)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: store.hasCompletedIntegrations)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: store.hasCompletedSync)
    }
}

// MARK: - Previews
#Preview("AppRootView - No Session") {
    let store = DemoStore()
    store.session = nil
    store.profile = nil
    return AppRootView(store: store)
}

#Preview("AppRootView - Session No Profile") {
    let store = DemoStore()
    store.session = UserSession(providerName: "Apple")
    store.profile = nil
    return AppRootView(store: store)
}

#Preview("AppRootView - Full Profile") {
    let store = DemoStore()
    store.session = UserSession(providerName: "Apple")
    store.profile = UserProfile(
        fullName: "Alex Mercer",
        nickname: "alexm",
        avatarType: .sprite,
        spriteColorHex: "#6366F1"
    )
    return AppRootView(store: store)
}
