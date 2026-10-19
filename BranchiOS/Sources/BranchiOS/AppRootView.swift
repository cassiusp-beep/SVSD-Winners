import SwiftUI

public struct AppRootView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    
    public init(store: DemoStore = DemoStore.shared) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            if store.hasCompletedSync || store.isGuest {
                HomeView(store: store)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.98)),
                        removal: .opacity
                    ))
            } else {
                OnboardingFlowView(store: store)
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .opacity.combined(with: .scale(scale: 0.98))
                    ))
            }
        }
        .animation(BranchMotion.sharedSpring, value: store.hasCompletedSync || store.isGuest)
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
