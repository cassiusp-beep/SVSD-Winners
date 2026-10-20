import SwiftUI
import UIKit

// MARK: - Collaboration Screen Mode
public enum CollaborationMode: Equatable {
    case ready          // Recording 1: Edge-cropped sprites, pill tags, Play button
    case meeting        // Recording 2: Live meeting, Stop button, dynamic states, gaze tracking
    case takeaways      // Recording 3: Project Takeaways, 3 marquees, cluster with action labels
}

// MARK: - Navigation Tab Enum
public enum AppTab: String, CaseIterable, Identifiable {
    case session = "Session"
    case liveMap = "Live Map"
    case knowledge = "Knowledge"
    case profile = "Profile"
    
    public var id: String { rawValue }
    
    /// User-facing tab title (raw values stay as internal identifiers).
    public var title: String {
        switch self {
        case .session: return "YaYa"
        case .liveMap: return "Projects"
        case .knowledge: return "Insights"
        case .profile: return "Profile"
        }
    }
    
    public var iconName: String {
        switch self {
        case .session: return "waveform"
        case .liveMap: return "point.3.connected.trianglepath.dotted"
        case .knowledge: return "books.vertical.fill"
        case .profile: return "person.crop.circle"
        }
    }
}

// MARK: - Collaborator Motion State Enum
public enum CollaboratorState: String, CaseIterable {
    case listening = "listening"
    case talking = "talking"
    case friction = "friction"
    case agree = "agree"
    case processing = "processing"
    case question = "question"
    case building = "building"
    case reframing = "reframing"
    
    public var displayName: String {
        switch self {
        case .listening: return "Listening"
        case .talking: return "Speaking"
        case .friction: return "Friction"
        case .agree: return "Agree"
        case .processing: return "Processing"
        case .question: return "Question"
        case .building: return "Building"
        case .reframing: return "Reframing"
        }
    }
}

// MARK: - Collaborator Model
public struct AgentCollaborator: Identifiable {
    public let id: Int
    public let soloName: String
    public let groupName: String
    public let groupHandle: String
    public let role: String
    public let sprite: BranchSprite
    public var state: CollaboratorState
    public var energy: Double
    public var stateStartTime: Double = 0
    public var currentSpin: Double = 0
    public var gaze: CGSize = .zero
    
    // Normalized position in phone canvas
    public let xFraction: CGFloat
    public let yFraction: CGFloat
    public let widthFraction: CGFloat
    public let tagOffset: CGSize
    
    // Curved takeaway label
    public let takeawayLabel: String
    
    public var name: String { soloName }
}

// MARK: - 28-Second Choreography Script Step
public struct ScriptStep {
    public let atSeconds: Double
    public let states: [CollaboratorState]
    public let caption: String
}

// MARK: - Takeaway Action Enum (Tie-break precedence: friction > reframes > questions > agreements)
public enum TakeawayAction: String, CaseIterable, Comparable, Sendable {
    case friction = "friction"
    case reframes = "reframes"
    case questions = "questions"
    case agreements = "agreements"
    
    public var priority: Int {
        switch self {
        case .friction: return 0
        case .reframes: return 1
        case .questions: return 2
        case .agreements: return 3
        }
    }
    
    public static func < (lhs: TakeawayAction, rhs: TakeawayAction) -> Bool {
        lhs.priority < rhs.priority
    }
    
    public func label(for count: Int) -> String {
        switch self {
        case .friction:
            return count == 1 ? "1 point of friction" : "\(count) points of friction"
        case .reframes:
            return count == 1 ? "1 reframe" : "\(count) reframes"
        case .questions:
            return count == 1 ? "1 open question" : "\(count) open questions"
        case .agreements:
            return count == 1 ? "1 agreement" : "\(count) agreements"
        }
    }
}

// MARK: - CollaborationSessionView
public struct CollaborationSessionView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    
    @State public var mode: CollaborationMode = .ready
    @State public var selectedTab: AppTab = .session
    
    // Total people in room counter (min 1, max 9, includes user)
    @State private var peopleCount: Int = 3
    
    // Live Session Counts (frozen on stop)
    @State private var frictionCount: Int = 0
    @State private var futureOpportunitiesCount: Int = 0
    @State private var artifactsAddedCount: Int = 0
    @State private var sessionQuestionsCount: Int = 0
    @State private var sessionAgreementsCount: Int = 0
    @State private var agentActionTallies: [Int: [TakeawayAction: Int]] = [:]
    
    // Knowledge handoff context from contribution grid tap
    @State private var passedKnowledgeContext: ContributionCellContext? = nil
    @State private var gridIsometric: Bool = TakeawaysViewMemory.isometric
    
    // Session Scope: Solo vs Group (team receipt)
    @State private var sessionScope: SessionScope = (CommandLine.arguments.contains("-sessionGroup") || CommandLine.arguments.contains("-receipt") || CommandLine.arguments.contains("-teamReceipt")) ? .group : .solo
    @State private var receiptIsometric: Bool = TakeawaysViewMemory.receiptIsometric
    
    // Moment Detail Sheet (Reference 08d: Node from the session)
    @State private var isShowingMomentDetail: Bool = false
    @State private var activeMomentDetail: MomentDetailModel = .canonical
    
    @State private var isShowingSSOSheet: Bool = false
    @State private var isShowingProfileSetupSheet: Bool = false
    @State private var isShowingExportFlow: Bool = false
    @State private var sessionAutoplayTask: Task<Void, Never>? = nil
    @State private var highlightedAgentID: String? = TakeawaysLaunch.highlight
    
    // Virtual animation clock
    @State private var clock: Double = 0
    @State private var isPaused: Bool = false
    @State private var animationTimer: Timer? = nil
    
    // 28-second scripted sequence state
    @State private var isSequenceRunning: Bool = false
    @State private var sequenceStartTime: Double = 0
    @State private var currentStepIndex: Int = -1
    @State private var currentCaption: String = "A simulated room. Every state is a choice."
    
    // Takeaways Opening Nod State
    @State private var isTakeawaysNodding: Bool = false
    
    // Capture toast (photo / link added, or empty-clipboard hint)
    @State private var captureToast: CaptureToastItem? = nil
    @State private var knowledgeFocusEntryID: String? = nil
    @State private var captureSuccessTick: Int = 0
    @State private var captureHintTick: Int = 0
    
    // Profile tab icon: the user's sprite rendered once to a bitmap
    @State private var profileTabImage: UIImage? = nil
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Capture Cluster Layout Tuning
    /// Tuning offset for the capture cluster from canvas anchor (x: w * 0.35, y: h * 0.52).
    /// Defaults to 24pt up and 24pt left as requested.
    public static let playButtonOffset: CGSize = CGSize(width: -24, height: -24)
    
    // Collaborator definitions matching the motion study & SVG frames
    @State private var collaborators: [AgentCollaborator] = [
        AgentCollaborator(
            id: 0,
            soloName: "Cloud",
            groupName: "Bhargs",
            groupHandle: "@bhargs",
            role: "Engineering",
            sprite: .cloud,
            state: .listening,
            energy: 0.40,
            xFraction: 0.82,
            yFraction: 0.28,
            widthFraction: 0.60,
            tagOffset: CGSize(width: -50, height: 60),
            takeawayLabel: "solutions expert"
        ),
        AgentCollaborator(
            id: 1,
            soloName: "Bloom",
            groupName: "Cash",
            groupHandle: "@cassiusp",
            role: "Design",
            sprite: .bloom,
            state: .talking,
            energy: 0.55,
            xFraction: 0.17,
            yFraction: 0.77,
            widthFraction: 0.58,
            tagOffset: CGSize(width: 45, height: -60),
            takeawayLabel: "most artifacts added"
        ),
        AgentCollaborator(
            id: 2,
            soloName: "Prism",
            groupName: "Alex",
            groupHandle: "@al3xxli",
            role: "Product",
            sprite: .prism,
            state: .processing,
            energy: 0.35,
            xFraction: 0.81,
            yFraction: 0.59,
            widthFraction: 0.58,
            tagOffset: CGSize(width: -45, height: 50),
            takeawayLabel: "observer extraordinaire"
        ),
        AgentCollaborator(
            id: 3,
            soloName: "Spark",
            groupName: "Naheel",
            groupHandle: "@greatideanaheel",
            role: "Strategy",
            sprite: .spark,
            state: .listening,
            energy: 0.45,
            xFraction: 0.17,
            yFraction: 0.30,
            widthFraction: 0.62,
            tagOffset: CGSize(width: 50, height: 50),
            takeawayLabel: "top conversationalist"
        )
    ]
    
    // Canonical 28s Script Sequence
    private let scriptSteps: [ScriptStep] = [
        ScriptStep(
            atSeconds: 0,
            states: [.listening, .talking, .listening, .listening],
            caption: "Cash introduces an idea. The room follows his voice."
        ),
        ScriptStep(
            atSeconds: 4,
            states: [.listening, .listening, .listening, .question],
            caption: "Naheel asks: “Is this for one person, or the whole team?”"
        ),
        ScriptStep(
            atSeconds: 7,
            states: [.talking, .listening, .listening, .listening],
            caption: "Bhargs responds: “One person first. Teams can come later.”"
        ),
        ScriptStep(
            atSeconds: 11,
            states: [.listening, .friction, .listening, .listening],
            caption: "Cash flags a constraint. Friction can make the idea richer."
        ),
        ScriptStep(
            atSeconds: 15,
            states: [.listening, .listening, .talking, .listening],
            caption: "Alex takes the turn. The tension is explored collaboratively."
        ),
        ScriptStep(
            atSeconds: 19,
            states: [.listening, .listening, .talking, .question],
            caption: "Naheel clarifies: “What would you need to see to decide?”"
        ),
        ScriptStep(
            atSeconds: 23,
            states: [.listening, .agree, .agree, .listening],
            caption: "Two explicit agreement gestures. Neither came from silence."
        ),
        ScriptStep(
            atSeconds: 28,
            states: [.listening, .listening, .listening, .listening],
            caption: "A pause in the room. No speaker is selected; eyes return to neutral."
        )
    ]
    
    @MainActor private static var seededStores: Set<ObjectIdentifier> = []
    
    public init(store: DemoStore = DemoStore.shared, initialMode: CollaborationMode = .ready) {
        self.store = store
        var resolvedMode = initialMode
        if CommandLine.arguments.contains("-modeMeeting") || CommandLine.arguments.contains("-sessionLive") {
            resolvedMode = .meeting
            self._isSequenceRunning = State(initialValue: true)
        } else if CommandLine.arguments.contains("-receipt") || CommandLine.arguments.contains("-teamReceipt") {
            resolvedMode = .takeaways
            self._sessionScope = State(initialValue: .group)
        }
        if CommandLine.arguments.contains("-receiptIso") {
            self._receiptIsometric = State(initialValue: true)
        }
        self._mode = State(initialValue: resolvedMode)
        if CommandLine.arguments.contains("-tabKnowledgeLive") || CommandLine.arguments.contains("-knowledgeLive") {
            self._selectedTab = State(initialValue: .knowledge)
            self._mode = State(initialValue: .meeting)
            let existingCaptures = store.liveKnowledgeEntries.filter { $0.id.hasPrefix("capture_") }
            store.liveKnowledgeEntries = [
                KnowledgeEntry(
                    id: "live_04",
                    projectID: store.activeProjectID,
                    type: .question,
                    text: "What if individuals need spatial synthesis before the room gathers?",
                    timestamp: Date().addingTimeInterval(-24),
                    dateDisplay: "0:04",
                    agentId: 1,
                    agentName: "Bhargs",
                    agentSprite: .bloom,
                    elapsedSeconds: 4.0
                ),
                KnowledgeEntry(
                    id: "live_07",
                    projectID: store.activeProjectID,
                    type: .addition,
                    text: "Auto-link whiteboards when two people cite the same diagram",
                    timestamp: Date().addingTimeInterval(-21),
                    dateDisplay: "0:07",
                    agentId: 3,
                    agentName: "Naheel",
                    agentSprite: .spark,
                    media: KnowledgeMedia(
                        title: "Spatial linking diagram",
                        source: "WHITEBOARD",
                        dateString: "0:07",
                        assetName: "whiteboard_1",
                        previewSnippet: "Link whiteboards when citations match."
                    ),
                    elapsedSeconds: 7.0
                ),
                KnowledgeEntry(
                    id: "live_11",
                    projectID: store.activeProjectID,
                    type: .counterpoint,
                    text: "Real-time speech transcription creates premature convergence",
                    timestamp: Date().addingTimeInterval(-17),
                    dateDisplay: "0:11",
                    agentId: 0,
                    agentName: "Maya",
                    agentSprite: .cloud,
                    elapsedSeconds: 11.0
                ),
                KnowledgeEntry(
                    id: "live_15",
                    projectID: store.activeProjectID,
                    type: .reframe,
                    text: "Treat session logs as living branches rather than meeting minutes",
                    timestamp: Date().addingTimeInterval(-13),
                    dateDisplay: "0:15",
                    agentId: 3,
                    agentName: "Sam",
                    agentSprite: .spark,
                    media: KnowledgeMedia(
                        title: "Living branch lineage",
                        source: "FIGMA",
                        dateString: "0:15",
                        assetName: "figma_agents",
                        previewSnippet: "Branches rather than minutes."
                    ),
                    elapsedSeconds: 15.0
                )
            ] + existingCaptures
        } else if CommandLine.arguments.contains("-tabKnowledge") ||
                  CommandLine.arguments.contains("-knowledgeTab") ||
                  CommandLine.arguments.contains("-tabKnowledgeDated") {
            self._selectedTab = State(initialValue: .knowledge)
        } else if CommandLine.arguments.contains("-tabKnowledgeHandoff") {
            self._selectedTab = State(initialValue: .knowledge)
            self._passedKnowledgeContext = State(initialValue: ContributionCellContext(
                agentId: 1,
                agentName: "Theo",
                agentSprite: .bloom,
                sliceIndex: 5,
                startTime: 10.0,
                endTime: 12.0,
                actions: [.friction: 1]
            ))
        } else if CommandLine.arguments.contains("-tabLiveMapLive") || CommandLine.arguments.contains("-liveMapLive") {
            self._selectedTab = State(initialValue: .liveMap)
            self._mode = State(initialValue: .meeting)
            self._isSequenceRunning = State(initialValue: true)
        } else if CommandLine.arguments.contains("-tabLiveMap") ||
                  CommandLine.arguments.contains("-liveMapTab") ||
                  CommandLine.arguments.contains("-tabLiveMapEmpty") ||
                  CommandLine.arguments.contains("-tabLiveMapPast") ||
                  CommandLine.arguments.contains("-testDetailSheet") ||
                  CommandLine.arguments.contains("-testFrictionSheet") ||
                  CommandLine.arguments.contains("-testActorIsolated") ||
                  CommandLine.arguments.contains("-testCombinationMoment") {
            self._selectedTab = State(initialValue: .liveMap)
            if CommandLine.arguments.contains("-tabLiveMapPast") {
                store.selectedSessionID = "session_2"
            }
        } else if CommandLine.arguments.contains("-tabProfile") || CommandLine.arguments.contains("-profileTab") || CommandLine.arguments.contains("-guestProfile") {
            self._selectedTab = State(initialValue: .profile)
        }
        
        if CommandLine.arguments.contains("-momentDetail") || CommandLine.arguments.contains("-nodeFromSession") {
            self._isShowingMomentDetail = State(initialValue: true)
            self._activeMomentDetail = State(initialValue: .canonical)
        }
        
        // Deterministic capture seeding for screenshots (Simulator camera and clipboard can't be scripted)
        let seedPhoto = CommandLine.arguments.contains("-seedCapturePhoto")
        let seedLink = CommandLine.arguments.contains("-seedCaptureLink")
        // View.init can run many times per launch; seed once or captures (and their files) pile up.
        let committed = CommandLine.arguments.contains("-seedCaptureCommitted")
        if (seedPhoto || seedLink) && !committed {
            self._mode = State(initialValue: .meeting)
            self._isSequenceRunning = State(initialValue: true)
        }
        if (seedPhoto || seedLink) && !Self.seededStores.contains(ObjectIdentifier(store)) {
            Self.seededStores.insert(ObjectIdentifier(store))
            let live = !committed
            if seedPhoto,
               let path = Bundle.module.path(forResource: "whiteboard_1", ofType: "png"),
               let image = UIImage(contentsOfFile: path) {
                store.addCapture(.image(image), source: "CAMERA", isLive: live, elapsedSeconds: 9)
            }
            if seedLink, let url = URL(string: "https://svsd.design") {
                store.addCapture(.link(url), source: "PASTED", isLive: live, elapsedSeconds: 12)
            }
        }
        
        if initialMode == .takeaways || resolvedMode == .takeaways {
            if CommandLine.arguments.contains("-sessionRun2") || CommandLine.arguments.contains("-collaborationTakeawaysRun2") {
                self._frictionCount = State(initialValue: 1)
                self._futureOpportunitiesCount = State(initialValue: 4)
                self._artifactsAddedCount = State(initialValue: 2)
                self._sessionQuestionsCount = State(initialValue: 3)
                self._sessionAgreementsCount = State(initialValue: 1)
                self._agentActionTallies = State(initialValue: [
                    0: [.reframes: 2, .agreements: 1],  // Maya: 2 reframes
                    1: [.questions: 3, .reframes: 1],   // Alex: 3 open questions
                    2: [.friction: 1],                  // Theo: 1 point of friction (singular!)
                    3: [.agreements: 1]                 // Sam: 1 agreement (singular!)
                ])
            } else {
                self._frictionCount = State(initialValue: 3)
                self._futureOpportunitiesCount = State(initialValue: 2)
                self._artifactsAddedCount = State(initialValue: 5)
                self._sessionQuestionsCount = State(initialValue: 6)
                self._sessionAgreementsCount = State(initialValue: 5)
                self._agentActionTallies = State(initialValue: [
                    0: [.reframes: 4, .agreements: 2],
                    1: [.questions: 6, .reframes: 2],
                    2: [.friction: 3, .reframes: 1],
                    3: [.agreements: 5, .questions: 2]
                ])
            }
            self._isTakeawaysNodding = State(initialValue: true)
        }
    }
    
    /// Selected-tab accent: the user's family colour (Cloud for guests), a deeper step in light mode and a lighter one in dark.
    private var tabAccent: Color { store.familyAccent(for: colorScheme) }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            Tab(AppTab.session.title, systemImage: AppTab.session.iconName, value: AppTab.session) {
                tabContent(for: .session)
            }
            
            Tab(AppTab.liveMap.title, systemImage: AppTab.liveMap.iconName, value: AppTab.liveMap) {
                tabContent(for: .liveMap)
            }
            
            Tab(AppTab.knowledge.title, systemImage: AppTab.knowledge.iconName, value: AppTab.knowledge) {
                tabContent(for: .knowledge)
            }
            
            Tab(value: AppTab.profile) {
                tabContent(for: .profile)
            } label: {
                Label {
                    Text(AppTab.profile.title)
                } icon: {
                    if let profileTabImage {
                        Image(uiImage: profileTabImage)
                            .renderingMode(.original)
                    } else {
                        Image(systemName: AppTab.profile.iconName)
                    }
                }
            }
        }
        .tint(tabAccent)
        .onChange(of: selectedTab) { _, tab in
            if tab != .knowledge { knowledgeFocusEntryID = nil }
        }
        .overlay(alignment: .top) {
            if let toast = captureToast {
                CaptureToast(item: toast)
                    .padding(.top, 8)
                    .onTapGesture {
                        if !toast.isHint {
                            knowledgeFocusEntryID = toast.entryID
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedTab = .knowledge
                            }
                        }
                        captureToast = nil
                    }
                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                    .id(toast.id)
            }
        }
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.82), value: captureToast?.id)
        .task(id: captureToast?.id) {
            guard captureToast != nil else { return }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            if !Task.isCancelled { captureToast = nil }
        }
        .sensoryFeedback(.success, trigger: captureSuccessTick)
        .sensoryFeedback(.warning, trigger: captureHintTick)
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: mode)
        .sheet(isPresented: $isShowingSSOSheet) {
            SSOSignInSheet(store: store) { provider in
                store.endGuestSessionAndStartSignUp()
                isShowingProfileSetupSheet = true
            }
        }
        .sheet(isPresented: $isShowingProfileSetupSheet) {
            NavigationStack {
                ProfileSetupView(store: store) {
                    isShowingProfileSetupSheet = false
                    store.hasCompletedSync = true
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        selectedTab = .session
                        mode = .ready
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingMomentDetail) {
            MomentDetailSheet(model: activeMomentDetail) { _ in
                withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                    selectedTab = .knowledge
                }
            }
            .presentationDetents([.fraction(0.85), .large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $isShowingExportFlow) {
            ExportFlowView(store: store, scope: .session) { isShowingExportFlow = false }
        }
        .onAppear {
            startPhysicsClock()
            renderProfileTabImage()
            startSessionAutoplayIfRequested()
        }
        .onChange(of: store.profile?.spriteColorHex) { _, _ in
            renderProfileTabImage()
        }
        .onChange(of: colorScheme) { _, _ in
            renderProfileTabImage()
        }
        .onDisappear {
            stopPhysicsClock()
            sessionAutoplayTask?.cancel()
            sessionAutoplayTask = nil
        }
    }
    
    // MARK: - Tab Content (plain background, content runs behind the system tab bar)
    private func tabContent(for tab: AppTab) -> some View {
        ZStack {
            // Background: plain white in light mode, plain black in dark mode (global rule)
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            // Outer reader respects the safe area, so its bottom edge is the top of the system tab bar.
            GeometryReader { safe in
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                // Real system insets (status bar / floating tab bar) come from the outer reader, because the inner reader ignores the safe area.
                let topInset = safe.safeAreaInsets.top
                let bottomInset = safe.safeAreaInsets.bottom
                
                ZStack {
                    switch tab {
                    case .session:
                        switch mode {
                        case .ready:
                            readyCanvas(w: w, h: h, topInset: topInset, bottomInset: bottomInset)
                                .transition(.asymmetric(
                                    insertion: .opacity.animation(.easeInOut(duration: 0.28).delay(0.1)),
                                    removal: .opacity.animation(.easeInOut(duration: 0.15))
                                ))
                        case .meeting:
                            meetingCanvas(w: w, h: h, topInset: topInset, bottomInset: bottomInset)
                                .transition(.asymmetric(
                                    insertion: .opacity.animation(.easeInOut(duration: 0.28).delay(0.1)),
                                    removal: .opacity.animation(.easeInOut(duration: 0.15))
                                ))
                        case .takeaways:
                            takeawaysCanvas(w: w, h: h, topInset: topInset, bottomInset: bottomInset)
                                .transition(.asymmetric(
                                    insertion: .opacity.animation(.easeInOut(duration: 0.28).delay(0.1)),
                                    removal: .opacity.animation(.easeInOut(duration: 0.15))
                                ))
                        }
                    case .liveMap:
                        liveMapCanvas(w: w, h: h, topInset: topInset, bottomInset: bottomInset)
                    case .knowledge:
                        knowledgeCanvas(w: w, h: h, topInset: topInset, bottomInset: bottomInset)
                    case .profile:
                        profileCanvas(w: w, h: h, topInset: topInset, bottomInset: bottomInset)
                    }
                }
                .frame(width: w, height: h)
            }
            .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Profile Tab Icon (sprite rendered to a bitmap)
    private func renderProfileTabImage() {
        guard store.profile != nil else {
            profileTabImage = nil
            return
        }
        let sprite = BranchSprite.from(hex: store.profile?.spriteColorHex ?? "")
        let renderer = ImageRenderer(
            content: SpriteView(sprite: sprite, isBlinking: false, showsArms: false)
                .frame(width: 25, height: 25)
                .environment(\.colorScheme, colorScheme)
        )
        renderer.scale = 3
        profileTabImage = renderer.uiImage?.withRenderingMode(.alwaysOriginal)
    }
    
    // MARK: - Capture Handling
    private func handleCapture(_ content: DemoStore.CaptureContent, source: String) {
        let isLive = mode == .meeting
        let elapsed = max(0, clock - sequenceStartTime)
        guard let entry = store.addCapture(content, source: source, isLive: isLive, elapsedSeconds: elapsed) else { return }
        
        var thumbnail: UIImage? = nil
        var isLink = false
        switch content {
        case .image(let image):
            thumbnail = DemoStore.downscale(image: image, maxDimension: 112)
        case .link:
            isLink = true
        }
        
        captureSuccessTick += 1
        captureToast = CaptureToastItem(
            message: "Added to \(store.activeProject.name)",
            thumbnail: thumbnail,
            isLink: isLink,
            isHint: false,
            entryID: entry.id
        )
    }
    
    private func handleEmptyPaste() {
        captureHintTick += 1
        captureToast = CaptureToastItem(
            message: "Copy a link or image first.",
            thumbnail: nil,
            isLink: false,
            isHint: true
        )
    }
    
    /// Capture cluster + project picker shared by the ready and live Session canvases.
    @ViewBuilder
    private func sessionControls(w: CGFloat, h: CGFloat, topInset: CGFloat, isLive: Bool) -> some View {
        // Top-left "Recording to" picker (locked while live) + Top-right Scope Switcher (Solo / Group)
        VStack {
            HStack {
                ProjectPickerPill(store: store, isLocked: isLive)
                    .padding(.top, max(topInset, 44) + 6)
                    .padding(.leading, 24)
                Spacer()
                if !isLive {
                    ScopeSwitcherPill(scope: $sessionScope)
                        .padding(.top, max(topInset, 44) + 6)
                        .padding(.trailing, 24)
                }
            }
            Spacer()
        }
        .zIndex(20)
        
        // Camera · Record · Paste cluster, same anchor as the old play button, left edge kept >= 24pt
        CaptureCluster(
            isLive: isLive,
            elapsedSeconds: max(0, clock - sequenceStartTime),
            onRecordTap: { isLive ? stopMeeting() : startMeeting() },
            onCapture: { content, source in handleCapture(content, source: source) },
            onEmptyPaste: { handleEmptyPaste() }
        )
        .position(
            x: max(w * 0.35 + Self.playButtonOffset.width, 24 + CaptureCluster.width / 2),
            y: h * 0.52 + Self.playButtonOffset.height
        )
        .zIndex(10)
    }
    
    // MARK: - 1. Ready Canvas (Recording_1.png)
    private func readyCanvas(w: CGFloat, h: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack {
            // Edge-cropped decorative sprites (non-interactive)
            ForEach(collaborators) { collab in
                collaboratorSpriteNode(collab: collab, in: CGSize(width: w, height: h), isLive: false)
                    .allowsHitTesting(false)
            }
            
            sessionControls(w: w, h: h, topInset: topInset, isLive: false)
            
            // People Counter in Bottom Right, anchored to the safe area above the tab bar, aligned to right content margin
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PeopleCounterView(peopleCount: $peopleCount)
                        .padding(.trailing, 24)
                        .padding(.bottom, bottomInset + 12)
                }
            }
            .zIndex(15)
        }
    }
    
    // MARK: - 2. Meeting Canvas (Recording_2.png)
    private func meetingCanvas(w: CGFloat, h: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack {
            // Collaborators in Live Motion with dynamic state tags (non-interactive)
            ForEach(collaborators) { collab in
                collaboratorSpriteNode(collab: collab, in: CGSize(width: w, height: h), isLive: true)
                    .allowsHitTesting(false)
            }
            
            sessionControls(w: w, h: h, topInset: topInset, isLive: true)
            
            // People Counter in Bottom Right, anchored to the safe area above the tab bar, aligned to right content margin
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PeopleCounterView(peopleCount: $peopleCount)
                        .padding(.trailing, 24)
                        .padding(.bottom, bottomInset + 12)
                }
            }
            .zIndex(15)
        }
    }
    
    // MARK: - 3. Project Takeaways Canvas (Contribution Grid / Team Receipt)
    nonisolated(unsafe) private static var replayStarted = false
    private func takeawaysCanvas(w: CGFloat, h: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> some View {
        let selectCell: (ContributionCellContext) -> Void = { cellContext in
            passedKnowledgeContext = cellContext
            activeMomentDetail = MomentDetailModel.canonical
            isShowingMomentDetail = true
        }
        let liveMedia = TakeawaysArtifact.live(store.liveKnowledgeEntries)
        let sessionArtifacts: [TakeawaysArtifact] = liveMedia.isEmpty
            ? TakeawaysArtifact.demo(long: TakeawaysLaunch.long)
            : liveMedia
            
        return Group {
            if sessionScope == .group {
                TeamReceiptView(
                    store: store,
                    width: w,
                    topInset: topInset,
                    bottomInset: bottomInset,
                    rows: buildAgentGridRows(),
                    sessionArtifacts: sessionArtifacts,
                    sessionDuration: takeawaysSessionDuration,
                    frictionCount: frictionCount,
                    futureOpportunitiesCount: futureOpportunitiesCount,
                    artifactsAddedCount: artifactsAddedCount,
                    sessionQuestionsCount: sessionQuestionsCount,
                    sessionAgreementsCount: sessionAgreementsCount,
                    sessionScope: $sessionScope,
                    receiptIsometric: $receiptIsometric,
                    onSelectCell: selectCell,
                    onDismiss: {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                            mode = .ready
                            resetSessionCounts()
                        }
                    }
                )
            } else {
                soloTakeawaysCanvas(
                    w: w,
                    h: h,
                    topInset: topInset,
                    bottomInset: bottomInset,
                    sessionArtifacts: sessionArtifacts,
                    selectCell: selectCell
                )
            }
        }
    }
    
    private func soloTakeawaysCanvas(
        w: CGFloat,
        h: CGFloat,
        topInset: CGFloat,
        bottomInset: CGFloat,
        sessionArtifacts: [TakeawaysArtifact],
        selectCell: @escaping (ContributionCellContext) -> Void
    ) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 14) {
                // Header Title + Scope Switcher + Export Share Button
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 12) {
                        Text("Project Takeaways")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundStyle(.primary)
                            .allowsHitTesting(false)
                        Spacer(minLength: 0)
                        ExportShareButton(store: store, scope: .session)
                    }
                    ScopeSwitcherPill(scope: $sessionScope)
                }
                .padding(.horizontal, 20)
                .padding(.top, topInset + ScreenHeaderLayout.topSpacing)
                
                // 3 Horizontal Continuous Marquee Rows (stat numbers populated directly from session)
                TakeawaysArrivalFade {
                VStack(alignment: .leading, spacing: 14) {
                    // Row 1: Friction stat (flows right)
                    ContinuousTakeawayMarqueeRow(
                        statNumber: "\(frictionCount)",
                        statTitle: "Resolved Points of Friction",
                        keywords: ["Timeline sync", "Design token hierarchy", "System architecture", "Model handoff"],
                        agentSprite: .bloom,
                        flowsRight: true
                    )
                    
                    // Row 2: Future Opportunities / Questions stat (flows left)
                    ContinuousTakeawayMarqueeRow(
                        statNumber: "\(futureOpportunitiesCount)",
                        statTitle: "Future Opportunities",
                        keywords: ["Spatial audio canvas", "Cross-device multi-peer", "Dynamic clustering", "Export transcript"],
                        agentSprite: .prism,
                        flowsRight: false
                    )
                    
                    // Row 3: Artifacts Added stat (flows right)
                    ContinuousTakeawayMarqueeRow(
                        statNumber: "\(artifactsAddedCount)",
                        statTitle: "Artifacts Added",
                        keywords: TakeawaysArtifact.canonicalNames,
                        agentSprite: .cloud,
                        flowsRight: true
                    )
                }
                .frame(width: w, alignment: .leading)
                }
                
                // Grid region: fills the space below the marquee, centred so the screen stays balanced.
                GeometryReader { geo in
                    IsometricContributionGridView(
                        rows: buildAgentGridRows(),
                        sessionDuration: takeawaysSessionDuration,
                        timeSlice: ContributionGridConstants.takeawayTimeSliceSeconds,
                        width: w,
                        maxHeight: geo.size.height,
                        highlightedAgent: highlightedAgentID,
                        isometric: gridIsometric,
                        artifacts: sessionArtifacts,
                        onSelectCell: selectCell
                    )
                    .frame(width: w, height: geo.size.height, alignment: .center)
                }
                .frame(maxHeight: .infinity)
                
                // FLAT / ISOMETRIC toggle (choice is remembered for the app session)
                GridViewModeToggle(isometric: gridIsometric) { iso in
                    TakeawaysViewMemory.isometric = iso
                    gridIsometric = iso
                }
                .frame(width: w, height: 44)
                
                // Row reserved for the up-chevron so it never overlaps the grid or the toggle
                Color.clear.frame(height: 46 + 12 + bottomInset)
            }
            .frame(width: w, height: h, alignment: .topLeading)
            .zIndex(2)
            
            // Up-chevron return button in bottom right (Recording_3.png) - sits above tab bar
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    mode = .ready
                    resetSessionCounts()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color.white : Color(red: 0.137, green: 0.122, blue: 0.125))
                        .frame(width: 46, height: 46)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.20), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: "chevron.up")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                }
                .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
            .position(x: w - 46, y: h - bottomInset - 12 - 23)
            .zIndex(15)
            .accessibilityLabel("Return to Collaboration Ready")
        }
        .frame(width: w, height: h)
        .onAppear {
            // Screenshot aid (-takeawaysReplay): leave Takeaways for Ready and come back, twice, to prove each arrival replays.
            guard CommandLine.arguments.contains("-takeawaysReplay"), !Self.replayStarted else { return }
            Self.replayStarted = true
            Task { @MainActor in
                for _ in 0..<2 {
                    try? await Task.sleep(nanoseconds: 5_000_000_000)
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) { mode = .ready }
                    try? await Task.sleep(nanoseconds: 1_200_000_000)
                    withAnimation(.easeInOut(duration: 0.28)) { mode = .takeaways }
                }
            }
        }
        .task {
            // Screenshot aid: flip the grid view shortly after launch.
            if TakeawaysLaunch.autoToggle {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                gridIsometric.toggle()
            }
        }
        .task {
            if CommandLine.arguments.contains("-demoAutoTapKnowledge") {
                try? await Task.sleep(nanoseconds: 3_200_000_000)
                let rows = buildAgentGridRows()
                if let theoRow = rows.first(where: { $0.name == "Theo" }),
                   let cell = theoRow.cells.first(where: { $0.actions.values.reduce(0, +) > 0 }) {
                    passedKnowledgeContext = cell
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                        selectedTab = .knowledge
                    }
                }
            }
        }
    }
    
    private var takeawaysSessionDuration: Double {
        if TakeawaysLaunch.long { return 60.0 }
        return (frictionCount == 1 && sessionQuestionsCount == 3) ? 10.0 : 28.0
    }
    
    // MARK: - Build Agent Grid Rows (Session Time Slices)
    private func buildAgentGridRows() -> [AgentGridRow] {
        let isShortRun = (frictionCount == 1 && sessionQuestionsCount == 3)
        let totalDuration = takeawaysSessionDuration
        let timeSlice = ContributionGridConstants.takeawayTimeSliceSeconds
        let totalCols = max(1, Int(ceil(totalDuration / timeSlice)))
        
        let mayaActionsByCol: [Int: [TakeawayAction: Int]] = isShortRun
            ? [1: [.reframes: 1], 3: [.reframes: 1]]
            : [5: [.friction: 1], 9: [.agreements: 1], 11: [.reframes: 1], 13: [.reframes: 3]]
            
        let theoActionsByCol: [Int: [TakeawayAction: Int]] = isShortRun
            ? [2: [.friction: 1]]
            : [2: [.questions: 1], 5: [.friction: 2], 8: [.friction: 1], 10: [.agreements: 1]]
            
        let alexActionsByCol: [Int: [TakeawayAction: Int]] = isShortRun
            ? [1: [.questions: 2], 3: [.questions: 1]]
            : [3: [.questions: 2], 7: [.questions: 2], 10: [.questions: 2], 12: [.reframes: 1]]
            
        let samActionsByCol: [Int: [TakeawayAction: Int]] = isShortRun
            ? [3: [.agreements: 1]]
            : [3: [.agreements: 1], 7: [.reframes: 1], 9: [.agreements: 2], 11: [.agreements: 2]]
            
        func makeCells(agentId: Int, name: String, sprite: BranchSprite, map baseMap: [Int: [TakeawayAction: Int]]) -> [ContributionCellContext] {
            // -takeawaysLong: continue the 28s pattern across a 60s session so lanes have something to scroll to.
            var map = baseMap
            if TakeawaysLaunch.long {
                for (col, actions) in baseMap { map[col + 14] = actions }
                for (col, actions) in baseMap where col + 28 < totalCols { map[col + 28] = actions }
            }
            return (0..<totalCols).map { col in
                ContributionCellContext(
                    agentId: agentId,
                    agentName: name,
                    agentSprite: sprite,
                    sliceIndex: col,
                    startTime: Double(col) * timeSlice,
                    endTime: Double(col + 1) * timeSlice,
                    actions: map[col] ?? [:]
                )
            }
        }
        
        let isGroup = (sessionScope == .group)
        let row0Name = isGroup ? "Cash" : "Cloud"
        let row1Name = isGroup ? "Bhargs" : "Bloom"
        let row2Name = isGroup ? "Alex" : "Prism"
        let row3Name = isGroup ? "Naheel" : "Spark"
        
        return [
            AgentGridRow(
                id: 0,
                name: row0Name,
                role: "Design",
                sprite: .cloud,
                cells: makeCells(agentId: 0, name: row0Name, sprite: .cloud, map: mayaActionsByCol)
            ),
            AgentGridRow(
                id: 1,
                name: row1Name,
                role: "Engineering",
                sprite: .bloom,
                cells: makeCells(agentId: 1, name: row1Name, sprite: .bloom, map: theoActionsByCol)
            ),
            AgentGridRow(
                id: 2,
                name: row2Name,
                role: "Product",
                sprite: .prism,
                cells: makeCells(agentId: 2, name: row2Name, sprite: .prism, map: alexActionsByCol)
            ),
            AgentGridRow(
                id: 3,
                name: row3Name,
                role: "Strategy",
                sprite: .spark,
                cells: makeCells(agentId: 3, name: row3Name, sprite: .spark, map: samActionsByCol)
            )
        ]
    }
    
    // MARK: - Live Map Canvas (Collective Emergence Actor-Discourse Network)
    private func liveMapCanvas(w: CGFloat, h: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: topInset)
            
            LiveMapView(
                store: store,
                isLiveSession: mode == .meeting,
                sessionClock: max(0, clock - sequenceStartTime),
                peopleCount: peopleCount,
                onOpenInKnowledge: { entryID in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedTab = .knowledge
                    }
                },
                onStartSession: {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                        selectedTab = .session
                        mode = .ready
                    }
                }
            )
            // Stops at the top of the floating tab bar so the recenter button and chips clear it.
            .frame(width: w, height: max(0, h - topInset - bottomInset))
            Color.clear.frame(height: bottomInset)
        }
        .frame(width: w, height: h)
    }
    
    // MARK: - Knowledge Canvas (Living Project Repository)
    private func knowledgeCanvas(w: CGFloat, h: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: topInset)
            
            KnowledgeView(
                store: store,
                isLiveSession: mode == .meeting,
                sessionClock: max(0, clock - sequenceStartTime),
                passedContext: passedKnowledgeContext,
                onDismissContext: {
                    passedKnowledgeContext = nil
                },
                focusEntryID: knowledgeFocusEntryID
            )
            .frame(width: w, height: max(0, h - topInset))
            // Scroll content margin (not padding, which would grow the frame) so the list scrolls under the floating tab bar but its last row rests above it.
            .contentMargins(.bottom, bottomInset, for: .scrollContent)
            .clipped()
        }
        .frame(width: w, height: h)
    }
        // MARK: - Profile Canvas & Reset Demo Button
    private func profileCanvas(w: CGFloat, h: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: topInset)
        ProfileView(
            store: store,
            onResetDemo: {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    stopMeeting()
                    mode = .ready
                    resetSessionCounts()
                    store.resetDemo()
                }
            },
            onSignUp: {
                isShowingSSOSheet = true
            }
        )
        .frame(width: w, height: max(0, h - topInset))
        .contentMargins(.bottom, bottomInset, for: .scrollContent)
        }
        .frame(width: w, height: h)
    }
    
    // MARK: - Collaborator Node Rendering (Transforms + Eyes + Tag)
    private func collaboratorPosition(for collab: AgentCollaborator, w: CGFloat, h: CGFloat) -> CGPoint {
        if sessionScope == .group {
            // Horizontal swap: Left ⇄ Right
            // Cloud/Cash (0.17 -> 0.83) & Spark/Naheel (0.16 -> 0.84) on right
            // Bloom/Bhargs (0.82 -> 0.18) & Prism/Alex (0.81 -> 0.19) on left
            let xFrac = (1.0 - collab.xFraction)
            return CGPoint(x: w * xFrac, y: h * collab.yFraction)
        } else {
            return CGPoint(x: w * collab.xFraction, y: h * collab.yFraction)
        }
    }
    
    private func collaboratorTagOffset(for collab: AgentCollaborator) -> CGSize {
        if sessionScope == .group {
            // Invert horizontal tag offset so pills point inward toward canvas center
            return CGSize(width: -collab.tagOffset.width, height: collab.tagOffset.height)
        } else {
            return collab.tagOffset
        }
    }
    
    private func collaboratorSpriteNode(
        collab: AgentCollaborator,
        in canvasSize: CGSize,
        isLive: Bool
    ) -> some View {
        let w = canvasSize.width
        let h = canvasSize.height
        let spriteW = w * collab.widthFraction
        let spriteH = spriteW * 0.90
        
        // Compute motion transforms if live
        let motion = calculateMotion(for: collab, isLive: isLive)
        
        let displayName = (sessionScope == .group ? collab.groupName : collab.soloName)
        let secondaryText: String = {
            if isLive {
                return collab.state.displayName
            }
            return sessionScope == .group ? collab.groupHandle : collab.role
        }()
        
        return ZStack {
            // Sprite Body + Eyes
            SpriteView(
                sprite: collab.sprite,
                isBlinking: false,
                showsArms: false,
                bodyRotation: Angle(degrees: motion.rotate),
                bodyScale: motion.scale,
                gazeOffset: motion.gaze,
                haloOpacity: motion.halo
            )
            .frame(width: spriteW, height: spriteH)
            .offset(x: motion.dx, y: motion.dy)
            
            // Liquid Glass Pill Tag: `Name · Role` in Ready (Solo), `Name · @handle` in Ready (Group), `Name · State` in Meeting
            HStack(spacing: 5) {
                Text(displayName)
                    .font(.system(size: 12, weight: .bold))
                Text("·")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(secondaryText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.88) : Color.secondary)
            }
            .fixedSize()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .glassEffect(.regular, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(collab.sprite.gradientColors[0].opacity(collab.state == .talking ? 0.7 : 0.25), lineWidth: 1)
            )
            .offset(x: collaboratorTagOffset(for: collab).width, y: collaboratorTagOffset(for: collab).height)
        }
        .position(collaboratorPosition(for: collab, w: w, h: h))
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: sessionScope)
    }
    
    // MARK: - Motion Physics Computation (Directly from Branch - Collaboration Motion.html)
    private struct MotionResult {
        var rotate: Double = 0
        var scale: Double = 1.0
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        var halo: Double = 0
        var gaze: CGSize = .zero
    }
    
    private func calculateMotion(for collab: AgentCollaborator, isLive: Bool) -> MotionResult {
        guard isLive && !reduceMotion else {
            return MotionResult()
        }
        
        let t = max(0, clock - collab.stateStartTime)
        let lvl = collab.energy
        var res = MotionResult()
        
        switch collab.state {
        case .listening:
            // Resting body
            res.scale = 1.0
            
        case .talking:
            // Continuous rotation based on energy, scale pulse, soft halo
            let spinSpeed = (8.0 + 32.0 * lvl) * lvl
            res.rotate = (t * spinSpeed * 20.0).truncatingRemainder(dividingBy: 360)
            let pulse = lvl * (0.025 + 0.018 * sin(.pi * 2 * t * 1.7))
            res.scale = 1.0 + pulse
            res.halo = 0.06 + 0.17 * lvl
            
        case .friction:
            // Gentle 2.8s opposing stretch and tilt
            let w = sin(.pi * 2 * t / 2.8)
            res.rotate = 3.0 * w
            res.scale = 1.0 + 0.035 * w
            res.halo = 0.12
            
        case .agree:
            // 0.9s single nod and settle
            if t < 0.9 {
                let p = pow(sin(.pi * t / 0.9), 2)
                res.dy = CGFloat(6.0 * p)
                res.scale = 1.0 - 0.06 * p
                res.halo = 0.15 * p
            }
            
        case .processing:
            // Slow breath
            res.scale = 1.0 + 0.02 * sin(.pi * 2 * t / 4.0)
            res.halo = 0.10
            
        case .question:
            // 0.6s gentle lift and tilt
            let progress = min(1.0, t / 0.6)
            let ease = progress * progress * (3.0 - 2.0 * progress)
            res.rotate = -7.0 * ease
            res.dy = CGFloat(-5.0 * ease)
            res.halo = 0.12
            
        case .building:
            // 1.3s outward expansion and settle
            if t < 1.3 {
                let p = pow(sin(.pi * t / 1.3), 2)
                res.scale = 1.0 + 0.07 * p
                res.halo = 0.20 * p
            }
            
        case .reframing:
            // 1.2s quarter-turn of body
            let progress = min(1.0, t / 1.2)
            let ease = progress * progress * (3.0 - 2.0 * progress)
            res.rotate = 90.0 * ease
            res.halo = (t < 1.2) ? 0.13 * sin(.pi * progress) : 0
        }
        
        // Eye Tracking: Turn gaze towards the single active speaker
        if let speakerIndex = resolveSingleSpeaker(), speakerIndex != collab.id {
            let speaker = collaborators[speakerIndex]
            let speakerX = sessionScope == .group ? (1.0 - speaker.xFraction) : speaker.xFraction
            let collabX = sessionScope == .group ? (1.0 - collab.xFraction) : collab.xFraction
            let dx = speakerX - collabX
            let dy = speaker.yFraction - collab.yFraction
            let dist = max(0.001, hypot(dx, dy))
            let maxGazeOffset: CGFloat = 2.8
            res.gaze = CGSize(
                width: (dx / dist) * maxGazeOffset,
                height: (dy / dist) * maxGazeOffset
            )
        }
        
        return res
    }
    
    private func resolveSingleSpeaker() -> Int? {
        let talking = collaborators.filter { $0.state == .talking }
        return talking.count == 1 ? talking.first?.id : nil
    }
    
    // MARK: - Physics & Script Sequence Clock
    private func startPhysicsClock() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
            Task { @MainActor in
                guard !isPaused else { return }
                
                clock += 0.033
                
                if isSequenceRunning {
                    let elapsed = clock - sequenceStartTime
                    var nextStep = scriptSteps.count - 1
                    while nextStep > 0 && scriptSteps[nextStep].atSeconds > elapsed {
                        nextStep -= 1
                    }
                    if nextStep != currentStepIndex {
                        currentStepIndex = nextStep
                        applyScriptStep(scriptSteps[nextStep])
                    }
                    
                    if nextStep == scriptSteps.count - 1 && elapsed > 29.0 {
                        stopMeeting()
                    }
                }
            }
        }
    }
    
    private func stopPhysicsClock() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func startMeeting() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            mode = .meeting
            isSequenceRunning = true
            isPaused = false
            sequenceStartTime = clock
            currentStepIndex = -1
            store.liveKnowledgeEntries = []
            resetSessionCounts()
        }
    }
    
    private func stopMeeting() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            isSequenceRunning = false
            isPaused = false
            freezeSessionCounts()
            store.commitLiveKnowledgeEntriesToSeeded(for: store.activeProjectID)
            mode = .takeaways
            triggerTakeawaysOpeningNod()
        }
    }
    
    private func freezeSessionCounts() {
        let elapsed = max(0, clock - sequenceStartTime)
        if elapsed < 8.0 {
            // Early stop: lower numbers & singular actions
            frictionCount = 1
            futureOpportunitiesCount = 1
            artifactsAddedCount = 1
            sessionQuestionsCount = 1
            sessionAgreementsCount = 1
            agentActionTallies = [
                0: [.reframes: 1, .agreements: 1],  // Maya: 1 reframe (tie-breaker: reframes > agreements)
                1: [.questions: 1],                 // Alex: 1 open question
                2: [.friction: 1],                  // Theo: 1 point of friction
                3: [.agreements: 1]                 // Sam: 1 agreement
            ]
        } else if elapsed < 18.0 {
            // Mid-session stop
            frictionCount = 2
            futureOpportunitiesCount = 3
            artifactsAddedCount = 3
            sessionQuestionsCount = 3
            sessionAgreementsCount = 3
            agentActionTallies = [
                0: [.reframes: 2, .agreements: 1],  // Maya: 2 reframes
                1: [.questions: 3, .reframes: 1],   // Alex: 3 open questions
                2: [.friction: 2, .reframes: 1],    // Theo: 2 points of friction
                3: [.agreements: 3, .questions: 1]  // Sam: 3 agreements
            ]
        } else {
            // Fully completed session
            frictionCount = 3
            futureOpportunitiesCount = 2
            artifactsAddedCount = 5
            sessionQuestionsCount = 6
            sessionAgreementsCount = 5
            agentActionTallies = [
                0: [.reframes: 4, .agreements: 2],  // Maya: 4 reframes
                1: [.questions: 6, .reframes: 2],   // Alex: 6 open questions
                2: [.friction: 3, .reframes: 1],    // Theo: 3 points of friction
                3: [.agreements: 5, .questions: 2]  // Sam: 5 agreements
            ]
        }
        
        let totalDeclaredActions = frictionCount + futureOpportunitiesCount + artifactsAddedCount
        let sessionActions = SessionDeclaredActions(
            processing: max(1, sessionAgreementsCount),
            building: max(1, artifactsAddedCount),
            reframing: max(1, futureOpportunitiesCount),
            questions: max(1, sessionQuestionsCount)
        )
        store.recordCompletedSession(declaredActionsCount: totalDeclaredActions, actions: sessionActions)
    }
    
    private func resetSessionCounts() {
        frictionCount = 0
        futureOpportunitiesCount = 0
        artifactsAddedCount = 0
        sessionQuestionsCount = 0
        sessionAgreementsCount = 0
        agentActionTallies = [:]
    }
    
    private func applyScriptStep(_ step: ScriptStep) {
        currentCaption = step.caption
        for i in 0..<min(collaborators.count, step.states.count) {
            let newState = step.states[i]
            if collaborators[i].state != newState {
                collaborators[i].state = newState
                collaborators[i].stateStartTime = clock
            }
        }
        emitLiveKnowledgeEntryForStep(step)
    }
    
    private func emitLiveKnowledgeEntryForStep(_ step: ScriptStep) {
        let elapsedSec = step.atSeconds
        let elapsedString = String(format: "0:%02d", elapsedSec)
        
        switch elapsedSec {
        case 0:
            // Maya introduces problem space
            let entry = KnowledgeEntry(
                id: "live_00",
                projectID: store.activeProjectID,
                type: .addition,
                text: "How do we bridge individual reflection with team synthesis?",
                timestamp: Date(),
                dateDisplay: elapsedString,
                agentId: 0,
                agentName: "Maya",
                agentSprite: .cloud,
                actor: .maya,
                shortLabel: "Bridge reflection & synthesis",
                elapsedSeconds: Double(elapsedSec)
            )
            if !store.liveKnowledgeEntries.contains(where: { $0.id == entry.id }) {
                store.liveKnowledgeEntries.append(entry)
            }
        case 4:
            // Theo asks question
            let entry = KnowledgeEntry(
                id: "live_04",
                projectID: store.activeProjectID,
                type: .question,
                text: "What if individuals need spatial synthesis before the room gathers?",
                timestamp: Date(),
                dateDisplay: elapsedString,
                agentId: 1,
                agentName: "Theo",
                agentSprite: .bloom,
                actor: .theo,
                links: [KnowledgeLink(targetEntryID: "live_00", type: .buildsOn)],
                shortLabel: "Spatial synthesis need",
                elapsedSeconds: Double(elapsedSec)
            )
            if !store.liveKnowledgeEntries.contains(where: { $0.id == entry.id }) {
                store.liveKnowledgeEntries.append(entry)
            }
        case 7:
            // User speaks: establish Branch for individuals first (~25% of moves from user)
            let entry = KnowledgeEntry(
                id: "live_07",
                projectID: store.activeProjectID,
                type: .addition,
                text: "Establish Branch for individuals first. Team integration comes later.",
                timestamp: Date(),
                dateDisplay: elapsedString,
                actor: .user,
                links: [KnowledgeLink(targetEntryID: "live_04", type: .buildsOn)],
                shortLabel: "One person first",
                media: KnowledgeMedia(
                    title: "Core idea: the individual",
                    source: "WHITEBOARD",
                    dateString: elapsedString,
                    assetName: "whiteboard_3",
                    previewSnippet: "Establish Branch for individuals first. Team integration comes later."
                ),
                elapsedSeconds: Double(elapsedSec)
            )
            if !store.liveKnowledgeEntries.contains(where: { $0.id == entry.id }) {
                store.liveKnowledgeEntries.append(entry)
            }
        case 11:
            // Maya flags constraint / friction
            let entry = KnowledgeEntry(
                id: "live_11",
                projectID: store.activeProjectID,
                type: .counterpoint,
                text: "Real-time speech transcription creates premature convergence",
                timestamp: Date(),
                dateDisplay: elapsedString,
                agentId: 0,
                agentName: "Maya",
                agentSprite: .cloud,
                actor: .maya,
                links: [KnowledgeLink(targetEntryID: "live_07", type: .challenges)],
                resolution: .unresolved,
                shortLabel: "Premature convergence",
                frictionSuggestion: "visual markers protect unvoiced ideas",
                elapsedSeconds: Double(elapsedSec)
            )
            if !store.liveKnowledgeEntries.contains(where: { $0.id == entry.id }) {
                store.liveKnowledgeEntries.append(entry)
            }
        case 15:
            // Sam offers reframing
            let entry = KnowledgeEntry(
                id: "live_15",
                projectID: store.activeProjectID,
                type: .reframe,
                text: "Treat session logs as living branches rather than meeting minutes",
                timestamp: Date(),
                dateDisplay: elapsedString,
                agentId: 3,
                agentName: "Sam",
                agentSprite: .spark,
                actor: .sam,
                links: [KnowledgeLink(targetEntryID: "live_07", type: .transforms)],
                shortLabel: "Branches not minutes",
                media: KnowledgeMedia(
                    title: "Living branch lineage",
                    source: "FIGMA",
                    dateString: elapsedString,
                    assetName: "figma_agents",
                    previewSnippet: "Branches rather than minutes."
                ),
                elapsedSeconds: Double(elapsedSec)
            )
            if !store.liveKnowledgeEntries.contains(where: { $0.id == entry.id }) {
                store.liveKnowledgeEntries.append(entry)
            }
        case 19:
            // Combination moment & Emergence! User combines Sam's reframing (live_15) with individual-first (live_07)
            let entry = KnowledgeEntry(
                id: "live_19",
                projectID: store.activeProjectID,
                type: .addition,
                text: "Living project stories emerge from dialogue, not retroactive documentation",
                timestamp: Date(),
                dateDisplay: elapsedString,
                actor: .user,
                links: [
                    KnowledgeLink(targetEntryID: "live_07", type: .combines),
                    KnowledgeLink(targetEntryID: "live_15", type: .combines)
                ],
                shortLabel: "Stories from dialogue",
                media: KnowledgeMedia(
                    title: "Living stories dialectic",
                    source: "MIRO",
                    dateString: elapsedString,
                    assetName: "miro_stories",
                    previewSnippet: "Every critique session is a branch on the project's living story."
                ),
                isCombination: true,
                isEmergent: true,
                elapsedSeconds: Double(elapsedSec)
            )
            if !store.liveKnowledgeEntries.contains(where: { $0.id == entry.id }) {
                store.liveKnowledgeEntries.append(entry)
                #if canImport(UIKit)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                #endif
            }
        case 23:
            // Maya agrees and builds on emergent node
            let entry = KnowledgeEntry(
                id: "live_23",
                projectID: store.activeProjectID,
                type: .addition,
                text: "Shared nodes bloom when both contributors validate the constraint",
                timestamp: Date(),
                dateDisplay: elapsedString,
                agentId: 0,
                agentName: "Maya",
                agentSprite: .cloud,
                actor: .maya,
                links: [KnowledgeLink(targetEntryID: "live_19", type: .buildsOn)],
                shortLabel: "Shared nodes bloom",
                elapsedSeconds: Double(elapsedSec)
            )
            if !store.liveKnowledgeEntries.contains(where: { $0.id == entry.id }) {
                store.liveKnowledgeEntries.append(entry)
            }
        case 28:
            // Sam adds last thought / builds on emergent node
            let entry = KnowledgeEntry(
                id: "live_28",
                projectID: store.activeProjectID,
                type: .addition,
                text: "Expose unresolved questions as hot corners for the next session",
                timestamp: Date(),
                dateDisplay: elapsedString,
                agentId: 3,
                agentName: "Sam",
                agentSprite: .spark,
                actor: .sam,
                links: [KnowledgeLink(targetEntryID: "live_19", type: .buildsOn)],
                shortLabel: "Hot corners next",
                media: KnowledgeMedia(
                    title: "Hot corner synthesis",
                    source: "WHITEBOARD",
                    dateString: elapsedString,
                    assetName: "whiteboard_3",
                    previewSnippet: "Unresolved questions become genesis nodes."
                ),
                elapsedSeconds: Double(elapsedSec)
            )
            if !store.liveKnowledgeEntries.contains(where: { $0.id == entry.id }) {
                store.liveKnowledgeEntries.append(entry)
            }
        default:
            break
        }
    }
    
    private func triggerTakeawaysOpeningNod() {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.55)) {
            isTakeawaysNodding = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.68)) {
                isTakeawaysNodding = false
            }
        }
    }
}

private struct MarqueeUnitWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

// MARK: - Continuous Takeaway Marquee Row Component (Recording_3.png)
private struct ContinuousTakeawayMarqueeRow: View {
    let statNumber: String
    let statTitle: String
    let keywords: [String]
    let agentSprite: BranchSprite
    let flowsRight: Bool
    let speed: CGFloat = 26.0
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    private static let unitSpacing: CGFloat = 24
    /// Exact intrinsic width of one content unit; 0 until measured (row stays hidden).
    @State private var measuredUnitWidth: CGFloat = 0
    
    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width
            // Wrap distance is exactly one unit plus the inter-copy spacing.
            let cycle = measuredUnitWidth + Self.unitSpacing
            let copies = measuredUnitWidth > 0 ? Int(ceil(screenWidth / cycle)) + 2 : 1
            
            TimelineView(.animation(paused: reduceMotion)) { timeline in
                // Pure function of time and measured width.
                let seconds = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
                let travelled = CGFloat(seconds * Double(speed)).truncatingRemainder(dividingBy: max(cycle, 1))
                let offset: CGFloat = reduceMotion ? 28 : (flowsRight ? travelled - cycle : -travelled)
                
                HStack(spacing: Self.unitSpacing) {
                    ForEach(0..<copies, id: \.self) { copyIndex in
                        rowContentUnit
                            .fixedSize()
                            .background(
                                Group {
                                    if copyIndex == 0 {
                                        GeometryReader { geo in
                                            Color.clear.preference(key: MarqueeUnitWidthKey.self, value: geo.size.width)
                                        }
                                    }
                                }
                            )
                    }
                }
                .fixedSize()
                .offset(x: offset)
                .frame(width: screenWidth, alignment: .leading)
            }
            .opacity(measuredUnitWidth > 0 ? 1 : 0)
            .onPreferenceChange(MarqueeUnitWidthKey.self) { width in
                if width > 0, abs(width - measuredUnitWidth) > 0.01 { measuredUnitWidth = width }
            }
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .clipped()
    }
    
    private var rowContentUnit: some View {
        HStack(spacing: 24) {
            // Stat Pill
            HStack(spacing: 8) {
                Text(statNumber)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                
                Circle()
                    .fill(Color.primary.opacity(0.45))
                    .frame(width: 4, height: 4)
                
                Text(statTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .stroke(Color.primary, lineWidth: 1.8)
            )
            .fixedSize(horizontal: true, vertical: true)
            
            // Plain text keywords (NO chips, NO pills, NO fill, NO border)
            ForEach(keywords, id: \.self) { word in
                Text(word)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(agentSprite.takeawayGradient(for: colorScheme))
                    .lineLimit(1)
                    .fixedSize()
            }
        }
    }
}

// MARK: - People Counter Component
public struct PeopleCounterView: View {
    @Binding var peopleCount: Int
    @Environment(\.colorScheme) private var colorScheme
    
    public init(peopleCount: Binding<Int>) {
        self._peopleCount = peopleCount
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // People icon + number indicator in frosted glass pill
            HStack(spacing: 5) {
                Image(systemName: peopleCount == 1 ? "person.fill" : "person.2.fill")
                    .font(.system(size: 13, weight: .semibold))
                
                Text("\(peopleCount)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .glassEffect(.regular, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
            )
            .foregroundStyle(Color.primary)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(peopleCount) \(peopleCount == 1 ? "person" : "people") in the room")
            
            // Frosted glass stepper pill (minus & plus)
            HStack(spacing: 2) {
                Button {
                    if peopleCount > 1 {
                        peopleCount -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .disabled(peopleCount <= 1)
                .opacity(peopleCount <= 1 ? 0.35 : 1.0)
                .accessibilityLabel("Remove a person")
                
                Button {
                    if peopleCount < 9 {
                        peopleCount += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .disabled(peopleCount >= 9)
                .opacity(peopleCount >= 9 ? 0.35 : 1.0)
                .accessibilityLabel("Add a person")
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 3)
            .glassEffect(.regular, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
            )
        }
    }
}

// MARK: - Scripted Session Autoplay (-autoplayStory B|C|D|E)
extension CollaborationSessionView {
    private func startSessionAutoplayIfRequested() {
        let args = CommandLine.arguments
        guard let flag = args.firstIndex(of: "-autoplayStory"), args.indices.contains(flag + 1) else { return }
        let story = args[flag + 1]
        guard sessionAutoplayTask == nil else { return }
        
        func pause(_ seconds: Double) async {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        }
        
        sessionAutoplayTask = Task { @MainActor in
            switch story {
            case "B":
                // Story B: Solo ready -> record 22s (whiteboard at 8s, link at 14s) -> stop -> takeaways -> select sprite -> moment sheet -> export
                sessionScope = .solo
                mode = .ready
                selectedTab = .session
                await pause(1.5)
                guard !Task.isCancelled else { return }
                startMeeting()
                
                await pause(8.0)
                guard !Task.isCancelled else { return }
                if let path = Bundle.module.path(forResource: "whiteboard_1", ofType: "png"),
                   let image = UIImage(contentsOfFile: path) {
                    handleCapture(.image(image), source: "CAMERA")
                }
                
                await pause(6.0)
                guard !Task.isCancelled else { return }
                if let url = URL(string: "https://www.figma.com/file/yaya-flows") {
                    handleCapture(.link(url), source: "PASTED")
                }
                
                await pause(8.0)
                guard !Task.isCancelled else { return }
                stopMeeting()
                
                await pause(3.5)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    highlightedAgentID = "cloud"
                }
                
                await pause(1.8)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    activeMomentDetail = .canonical
                    isShowingMomentDetail = true
                }
                
                await pause(2.5)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    isShowingMomentDetail = false
                }
                
                await pause(1.5)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    isShowingExportFlow = true
                }
                
            case "C":
                // Story C: Solo -> Team -> Consent -> 26s Meeting -> Receipt -> Moment Sheet -> Projects Map -> Resolve Friction -> Insights
                sessionScope = .solo
                mode = .ready
                selectedTab = .session
                await pause(1.5)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    sessionScope = .group
                }
                await pause(2.0)
                guard !Task.isCancelled else { return }
                startMeeting()
                
                await pause(26.0)
                guard !Task.isCancelled else { return }
                stopMeeting()
                
                await pause(3.0)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    activeMomentDetail = .canonical
                    isShowingMomentDetail = true
                }
                
                await pause(3.0)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    isShowingMomentDetail = false
                }
                
                await pause(1.5)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    selectedTab = .liveMap
                }
                
                await pause(2.5)
                guard !Task.isCancelled else { return }
                NotificationCenter.default.post(name: NSNotification.Name("OpenDemoFrictionSheet"), object: nil)
                
                await pause(2.5)
                guard !Task.isCancelled else { return }
                NotificationCenter.default.post(name: NSNotification.Name("ResolveDemoFrictionKeepMine"), object: nil)
                
                await pause(2.5)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    selectedTab = .knowledge
                }
                await pause(3.5)
                
            case "D":
                // Story D: Projects tab -> switch sessions -> filter chip -> reset -> combination bloom -> Insights -> scroll history -> media thumbnail -> Profile -> stats & radar
                selectedTab = .liveMap
                await pause(2.0)
                guard !Task.isCancelled else { return }
                NotificationCenter.default.post(name: NSNotification.Name("DemoCycleSession"), object: nil)
                
                await pause(2.0)
                guard !Task.isCancelled else { return }
                NotificationCenter.default.post(name: NSNotification.Name("DemoFilterChip"), object: nil)
                
                await pause(2.0)
                guard !Task.isCancelled else { return }
                NotificationCenter.default.post(name: NSNotification.Name("DemoResetFilter"), object: nil)
                
                await pause(1.5)
                guard !Task.isCancelled else { return }
                NotificationCenter.default.post(name: NSNotification.Name("DemoTriggerCombination"), object: nil)
                
                await pause(3.0)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    selectedTab = .knowledge
                }
                
                await pause(2.5)
                guard !Task.isCancelled else { return }
                NotificationCenter.default.post(name: NSNotification.Name("DemoTapMediaThumbnail"), object: nil)
                
                await pause(2.5)
                guard !Task.isCancelled else { return }
                NotificationCenter.default.post(name: NSNotification.Name("DemoCloseMediaThumbnail"), object: nil)
                
                await pause(1.5)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    selectedTab = .profile
                }
                await pause(2.0)
                guard !Task.isCancelled else { return }
                NotificationCenter.default.post(name: NSNotification.Name("DemoScrollToRadar"), object: nil)
                await pause(4.0)
                
            case "E":
                // Story E: Guest session ready -> record 5s -> stop -> Profile tab
                selectedTab = .session
                await pause(1.5)
                guard !Task.isCancelled else { return }
                startMeeting()
                await pause(5.5)
                guard !Task.isCancelled else { return }
                stopMeeting()
                await pause(2.5)
                guard !Task.isCancelled else { return }
                withAnimation(BranchMotion.sharedSpring) {
                    selectedTab = .profile
                }
                await pause(3.5)
                
            default:
                break
            }
        }
    }
}

