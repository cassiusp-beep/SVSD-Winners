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
        if CommandLine.arguments.contains("-signIn") {
            SignInView(store: DemoStore())
        } else if CommandLine.arguments.contains("-onboardingProfileEmpty") {
            OnboardingFlowView(store: emptySessionStore, initialStep: .profile)
        } else if CommandLine.arguments.contains("-onboardingProfile") {
            OnboardingFlowView(store: mockFilledStore, initialStep: .profile)
        } else if CommandLine.arguments.contains("-onboardingIntegrations") {
            OnboardingFlowView(store: mockFilledStore, initialStep: .integrations)
        } else if CommandLine.arguments.contains("-onboardingSyncing") {
            OnboardingFlowView(store: mockConnectedStore, initialStep: .syncing)
        } else if CommandLine.arguments.contains("-profileSetup") {
            ProfileSetupView(store: DemoStore())
        } else if CommandLine.arguments.contains("-profileSetupFilled") {
            ProfileSetupView(store: mockFilledStore)
        } else if CommandLine.arguments.contains("-integrations") || CommandLine.arguments.contains("-integrationsFumble") {
            IntegrationsView(store: mockFilledStore)
        } else if CommandLine.arguments.contains("-integrationsConnected") {
            IntegrationsView(store: mockConnectedStore)
        } else if CommandLine.arguments.contains("-syncing") {
            SyncingView(store: mockConnectedStore)
        } else if CommandLine.arguments.contains("-syncingBeat1") {
            SyncingView(store: mockConnectedStore, startFromBeat: .beat1BigToss)
        } else if CommandLine.arguments.contains("-syncingBeat2") {
            SyncingView(store: mockConnectedStore, startFromBeat: .beat2Gathering)
        } else if CommandLine.arguments.contains("-syncingBeat3") {
            SyncingView(store: mockConnectedStore, startFromBeat: .beat3PullingIn)
        } else if CommandLine.arguments.contains("-syncingComplete") {
            SyncingView(store: mockConnectedStore, startFromBeat: .beat4Complete)
        } else if CommandLine.arguments.contains("-syncingZeroComplete") {
            SyncingView(store: mockFilledStore, startFromBeat: .beat4Complete)
        } else if CommandLine.arguments.contains("-syncingZero") {
            SyncingView(store: mockFilledStore)
        } else if CommandLine.arguments.contains("-collaborationReady") {
            CollaborationSessionView(initialMode: .ready)
        } else if CommandLine.arguments.contains("-collaborationMeeting") {
            CollaborationSessionView(initialMode: .meeting)
        } else if CommandLine.arguments.contains("-collaborationTakeaways") {
            CollaborationSessionView(initialMode: .takeaways)
        } else {
            // Standard end-to-end launch routing:
            // Continuous OnboardingFlowView -> HomeView
            AppRootView(store: DemoStore.shared)
        }
    }
    
    private var emptySessionStore: DemoStore {
        let store = DemoStore()
        store.session = UserSession(providerName: "Apple")
        return store
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
