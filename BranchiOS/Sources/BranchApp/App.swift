import SwiftUI
import BranchiOS

@main
struct BranchApp: App {
    var body: some Scene {
        WindowGroup {
            rootView
        }
        #if os(macOS)
        .defaultSize(width: 420, height: 860)
        #endif
    }
    
    @ViewBuilder
    private var rootView: some View {
        if CommandLine.arguments.contains("-profileSetup") {
            ProfileSetupView(store: DemoStore())
        } else if CommandLine.arguments.contains("-profileSetupFilled") {
            ProfileSetupView(store: mockFilledStore)
        } else if CommandLine.arguments.contains("-integrations") || CommandLine.arguments.contains("-integrationsFumble") {
            IntegrationsView(store: mockFilledStore)
        } else if CommandLine.arguments.contains("-integrationsConnected") {
            IntegrationsView(store: mockConnectedStore)
        } else {
            // Standard end-to-end launch routing:
            // SignInView -> ProfileSetupView -> IntegrationsView -> HomeView
            AppRootView(store: DemoStore.shared)
        }
    }
    
    private var mockFilledStore: DemoStore {
        let store = DemoStore()
        store.session = UserSession(providerName: "Apple")
        store.profile = UserProfile(
            fullName: "Cassius Palacio",
            nickname: CommandLine.arguments.contains("-descenderTest") ? "cassiuspalacio" : "Cash",
            avatarType: .sprite,
            spriteColorHex: "#26C6DA"
        )
        return store
    }
    
    private var mockConnectedStore: DemoStore {
        let store = mockFilledStore
        store.connectedIntegrationIds = ["autodesk_fusion", "pinterest", "github", "printables"]
        store.connectedTimestamps = [
            "autodesk_fusion": Date().addingTimeInterval(-300),
            "pinterest": Date().addingTimeInterval(-200),
            "github": Date().addingTimeInterval(-100),
            "printables": Date()
        ]
        return store
    }
}
