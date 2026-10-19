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
        } else if CommandLine.arguments.contains("-onboardingProfileKeyboardEmpty") {
            OnboardingFlowView(store: emptySessionStore, initialStep: .profile)
        } else if CommandLine.arguments.contains("-onboardingProfileKeyboardMidTyping") {
            OnboardingFlowView(store: mockFilledStore, initialStep: .profile)
        } else if CommandLine.arguments.contains("-onboardingProfileFilled") || CommandLine.arguments.contains("-onboardingProfile") {
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
        } else if CommandLine.arguments.contains("-guestReady") {
            CollaborationSessionView(store: guestStore, initialMode: .ready)
        } else if CommandLine.arguments.contains("-guestTakeaways") {
            CollaborationSessionView(store: guestStore, initialMode: .takeaways)
        } else if CommandLine.arguments.contains("-profileTab") || CommandLine.arguments.contains("-tabProfile") {
            CollaborationSessionView(store: mockFilledStore, initialMode: .ready)
        } else if CommandLine.arguments.contains("-tabLiveMap") ||
                  CommandLine.arguments.contains("-liveMapTab") ||
                  CommandLine.arguments.contains("-tabLiveMapLive") ||
                  CommandLine.arguments.contains("-liveMapLive") ||
                  CommandLine.arguments.contains("-tabLiveMapEmpty") ||
                  CommandLine.arguments.contains("-tabLiveMapPast") ||
                  CommandLine.arguments.contains("-testDetailSheet") ||
                  CommandLine.arguments.contains("-testFrictionSheet") ||
                  CommandLine.arguments.contains("-testActorIsolated") ||
                  CommandLine.arguments.contains("-testCombinationMoment") {
            let store = CommandLine.arguments.contains("-tabLiveMapEmpty") ? emptySessionStore : mockFilledStore
            CollaborationSessionView(store: store, initialMode: .ready)
        } else if CommandLine.arguments.contains("-tabKnowledge") ||
                  CommandLine.arguments.contains("-knowledgeTab") ||
                  CommandLine.arguments.contains("-tabKnowledgeDated") ||
                  CommandLine.arguments.contains("-tabKnowledgeLive") ||
                  CommandLine.arguments.contains("-tabKnowledgeHandoff") {
            CollaborationSessionView(store: mockFilledStore, initialMode: .ready)
        } else {
            // Standard end-to-end launch routing:
            // Continuous OnboardingFlowView -> HomeView
            AppRootView(store: DemoStore.shared)
        }
    }
    
    private var guestStore: DemoStore {
        let store = DemoStore()
        store.startGuestSession()
        return store
    }
    
    private var emptySessionStore: DemoStore {
        let store = DemoStore()
        store.session = UserSession(providerName: "Apple")
        return store
    }
    
    private var mockFilledStore: DemoStore {
        let store = DemoStore()
        store.session = UserSession(providerName: "Apple")
        let (name, nick): (String, String) = {
            if CommandLine.arguments.contains("-profileShort") {
                return ("CJ", "cj")
            } else if CommandLine.arguments.contains("-profileLong") {
                return ("Cassius Palacio", "cassiuspalacio_22")
            } else if CommandLine.arguments.contains("-descenderTest") {
                return ("Cassius Palacio", "cassiuspalacio")
            } else {
                return ("Cassius", "cassius")
            }
        }()
        store.profile = UserProfile(
            fullName: name,
            nickname: nick,
            avatarType: .sprite,
            spriteColorHex: "#F5A623"
        )
        store.hasCompletedSync = true
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
