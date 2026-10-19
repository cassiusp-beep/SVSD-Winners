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
        if CommandLine.arguments.contains("-logoSheet") {
            LogoSheetView()
        } else if CommandLine.arguments.contains("-signIn") {
            SignInView(store: DemoStore())
        } else if CommandLine.arguments.contains("-onboardingProfileEmpty") {
            OnboardingFlowView(store: emptySessionStore, initialStep: .profile)
        } else if CommandLine.arguments.contains("-onboardingProfileKeyboardEmpty") {
            OnboardingFlowView(store: emptySessionStore, initialStep: .profile)
        } else if CommandLine.arguments.contains("-onboardingProfileKeyboardMidTyping") {
            OnboardingFlowView(store: mockFilledStore, initialStep: .profile)
        } else if CommandLine.arguments.contains("-onboardingProfileFilled") || CommandLine.arguments.contains("-onboardingProfile") {
            OnboardingFlowView(store: mockFilledStore, initialStep: .profile)
        } else if let intentStep = intentLaunchStep {
            OnboardingFlowView(store: intentStore, initialStep: intentStep)
        } else if CommandLine.arguments.contains("-onboardingIntegrations") {
            OnboardingFlowView(
                store: CommandLine.arguments.contains("-integrationsConnected") ? mockConnectedStore : mockFilledStore,
                initialStep: .integrations
            )
        } else if CommandLine.arguments.contains("-onboardingSyncing") {
            OnboardingFlowView(
                store: mockConnectedStore,
                initialStep: .syncing,
                startFromSyncBeat: CommandLine.arguments.contains("-syncingComplete") ? .beat4Complete : .beat0Handoff
            )
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
            CollaborationSessionView(store: mockFilledStore, initialMode: .ready)
        } else if CommandLine.arguments.contains("-collaborationMeeting") {
            CollaborationSessionView(initialMode: .meeting)
        } else if CommandLine.arguments.contains("-collaborationTakeaways") {
            CollaborationSessionView(store: mockFilledStore, initialMode: .takeaways)
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
                  CommandLine.arguments.contains("-tabKnowledgeHandoff") ||
                  CommandLine.arguments.contains("-seedCapturePhoto") ||
                  CommandLine.arguments.contains("-seedCaptureLink") {
            CollaborationSessionView(store: mockFilledStore, initialMode: .ready)
        } else {
            // Standard end-to-end launch routing:
            // Continuous OnboardingFlowView -> HomeView
            AppRootView(store: DemoStore.shared)
        }
    }
    
    /// Launch args for the intent steps: -onboardingIntro, -onboardingQuiz (-quizQ2 / -quizQ3 / -quizSelected),
    /// -onboardingTalk / -onboardingTalkSpeaking / -onboardingTalkWrite, -onboardingReveal (-revealSpark etc.).
    private var intentLaunchStep: OnboardingStep? {
        let args = CommandLine.arguments
        if args.contains("-onboardingIntro") { return .intro }
        if args.contains("-onboardingQuiz") { return .quiz }
        if args.contains("-onboardingTalk") || args.contains("-onboardingTalkSpeaking") || args.contains("-onboardingTalkWrite") { return .talk }
        if args.contains("-onboardingReveal") { return .reveal }
        return nil
    }
    
    private var intentStore: DemoStore { Self.intentStoreOnce }
    private static let intentStoreOnce: DemoStore = {
        let store = makeMockFilledStore()
        store.hasCompletedSync = false
        store.profile = UserProfile(fullName: "Cash Palacio", nickname: "cashp", avatarType: .sprite, spriteColorHex: "#4598BB")
        return store
    }()
    
    private var guestStore: DemoStore {
        let store = DemoStore()
        store.startGuestSession()
        return store
    }
    
    private var emptySessionStore: DemoStore { Self.emptySessionStoreOnce }
    private static let emptySessionStoreOnce: DemoStore = {
        let store = DemoStore()
        store.session = UserSession(providerName: "Apple")
        return store
    }()
    
    /// Debug stores are created once per process. Computed properties re-ran on every App body
    /// evaluation, handing views a fresh store (and fresh seeded IDs) each time.
    private var mockFilledStore: DemoStore { Self.mockFilledStoreOnce }
    private static let mockFilledStoreOnce: DemoStore = makeMockFilledStore()
    
    private static func makeMockFilledStore() -> DemoStore {
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
            spriteColorHex: spriteFamilyOverrideHexStatic ?? "#F5A623"
        )
        store.hasCompletedSync = true
        return store
    }
    
    /// Screenshot arg: `-spriteFamily Cloud|Bloom|Prism|Spark` picks the profile's sprite family.
    private static var spriteFamilyOverrideHexStatic: String? {
        let args = CommandLine.arguments
        guard let i = args.firstIndex(of: "-spriteFamily"), i + 1 < args.count else { return nil }
        return BranchSprite(rawValue: args[i + 1].capitalized)?.primaryHex
    }
    
    private var mockConnectedStore: DemoStore { Self.mockConnectedStoreOnce }
    private static let mockConnectedStoreOnce: DemoStore = {
        let store = makeMockFilledStore()
        store.connectedIntegrationIds = ["autodesk_fusion", "pinterest", "github", "printables"]
        store.connectedTimestamps = [
            "autodesk_fusion": Date().addingTimeInterval(-300),
            "pinterest": Date().addingTimeInterval(-200),
            "github": Date().addingTimeInterval(-100),
            "printables": Date()
        ]
        return store
    }()
}
