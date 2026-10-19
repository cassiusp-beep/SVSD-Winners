import SwiftUI

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
    public let name: String
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
    
    // Guest Mode SSO & Profile Setup Sheets
    @State private var isShowingSSOSheet: Bool = false
    @State private var isShowingProfileSetupSheet: Bool = false
    
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
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Play / Primary Button Layout Tuning
    /// Tuning offset for the primary play / stop button from canvas anchor (x: w * 0.35, y: h * 0.52).
    /// Defaults to 24pt up and 24pt left as requested.
    public static let playButtonOffset: CGSize = CGSize(width: -24, height: -24)
    
    // Collaborator definitions matching the motion study & SVG frames
    @State private var collaborators: [AgentCollaborator] = [
        AgentCollaborator(
            id: 0,
            name: "Maya",
            role: "Strategy",
            sprite: .cloud,
            state: .talking,
            energy: 0.55,
            xFraction: 0.17,
            yFraction: 0.18,
            widthFraction: 0.58,
            tagOffset: CGSize(width: 45, height: 50),
            takeawayLabel: "most artifacts added"
        ),
        AgentCollaborator(
            id: 1,
            name: "Theo",
            role: "Engineering",
            sprite: .bloom,
            state: .friction,
            energy: 0.40,
            xFraction: 0.82,
            yFraction: 0.28,
            widthFraction: 0.60,
            tagOffset: CGSize(width: -50, height: 60),
            takeawayLabel: "solutions expert"
        ),
        AgentCollaborator(
            id: 2,
            name: "Alex",
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
            name: "Sam",
            role: "Research",
            sprite: .spark,
            state: .agree,
            energy: 0.45,
            xFraction: 0.16,
            yFraction: 0.77,
            widthFraction: 0.62,
            tagOffset: CGSize(width: 50, height: -72),
            takeawayLabel: "top conversationalist"
        )
    ]
    
    // Canonical 28s Script Sequence
    private let scriptSteps: [ScriptStep] = [
        ScriptStep(
            atSeconds: 0,
            states: [.talking, .listening, .processing, .listening],
            caption: "Maya introduces an idea. The room follows her voice."
        ),
        ScriptStep(
            atSeconds: 4,
            states: [.listening, .question, .processing, .listening],
            caption: "Theo asks for a turn. A question is not disagreement."
        ),
        ScriptStep(
            atSeconds: 7,
            states: [.listening, .talking, .listening, .building],
            caption: "Theo speaks. Sam explicitly builds on the idea."
        ),
        ScriptStep(
            atSeconds: 11,
            states: [.friction, .talking, .listening, .listening],
            caption: "Maya flags a constraint. Friction can make the idea richer."
        ),
        ScriptStep(
            atSeconds: 15,
            states: [.listening, .listening, .talking, .reframing],
            caption: "Alex takes the turn. Sam offers a reframing."
        ),
        ScriptStep(
            atSeconds: 19,
            states: [.agree, .listening, .talking, .agree],
            caption: "Two explicit agreement gestures. Neither came from silence."
        ),
        ScriptStep(
            atSeconds: 23,
            states: [.processing, .listening, .listening, .talking],
            caption: "Sam adds the last thought. Others remain free to respond."
        ),
        ScriptStep(
            atSeconds: 28,
            states: [.listening, .listening, .listening, .listening],
            caption: "A pause in the room. No speaker is selected; eyes return to neutral."
        )
    ]
    
    public init(store: DemoStore = DemoStore.shared, initialMode: CollaborationMode = .ready) {
        self.store = store
        var resolvedMode = initialMode
        if CommandLine.arguments.contains("-modeMeeting") || CommandLine.arguments.contains("-sessionLive") {
            resolvedMode = .meeting
            self._isSequenceRunning = State(initialValue: true)
        }
        self._mode = State(initialValue: resolvedMode)
        if CommandLine.arguments.contains("-tabKnowledgeLive") || CommandLine.arguments.contains("-knowledgeLive") {
            self._selectedTab = State(initialValue: .knowledge)
            self._mode = State(initialValue: .meeting)
            store.liveKnowledgeEntries = [
                KnowledgeEntry(
                    id: "live_04",
                    projectID: "yaya",
                    type: .question,
                    text: "What if individuals need spatial synthesis before the room gathers?",
                    timestamp: Date().addingTimeInterval(-24),
                    dateDisplay: "0:04",
                    agentId: 1,
                    agentName: "Theo",
                    agentSprite: .bloom,
                    elapsedSeconds: 4.0
                ),
                KnowledgeEntry(
                    id: "live_07",
                    projectID: "yaya",
                    type: .addition,
                    text: "Auto-link whiteboards when two people cite the same diagram",
                    timestamp: Date().addingTimeInterval(-21),
                    dateDisplay: "0:07",
                    agentId: 3,
                    agentName: "Sam",
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
                    projectID: "yaya",
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
                    projectID: "yaya",
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
            ]
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
        
        if initialMode == .takeaways {
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
    
    public var body: some View {
        ZStack {
            // Background: plain white in light mode, plain black in dark mode (global rule)
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            // Main Content Area depending on selected tab
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let topInset = geo.safeAreaInsets.top
                let bottomInset = geo.safeAreaInsets.bottom
                
                ZStack {
                    switch selectedTab {
                    case .session:
                        switch mode {
                        case .ready:
                            readyCanvas(w: w, h: h, topInset: topInset, bottomInset: bottomInset)
                                .transition(.opacity)
                        case .meeting:
                            meetingCanvas(w: w, h: h, topInset: topInset, bottomInset: bottomInset)
                                .transition(.opacity)
                        case .takeaways:
                            takeawaysCanvas(w: w, h: h)
                                .transition(.opacity)
                        }
                    case .liveMap:
                        liveMapCanvas(w: w, h: h, topInset: topInset)
                            .transition(.opacity)
                    case .knowledge:
                        knowledgeCanvas(w: w, h: h, topInset: topInset)
                            .transition(.opacity)
                    case .profile:
                        profileCanvas(w: w, h: h)
                            .transition(.opacity)
                    }
                }
                .frame(width: w, height: h)
            }
            .zIndex(1)
            
            // Liquid Glass Navigation Bar: always visible, highest zIndex, strictly hit-testable only on its capsule
            VStack {
                Spacer()
                liquidGlassTabBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .allowsHitTesting(false)
            .overlay(alignment: .bottom) {
                liquidGlassTabBar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                    .allowsHitTesting(true)
            }
            .zIndex(100)
        }
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
        .onAppear {
            startPhysicsClock()
        }
        .onDisappear {
            stopPhysicsClock()
        }
    }
    
    // MARK: - 1. Ready Canvas (Recording_1.png)
    private func readyCanvas(w: CGFloat, h: CGFloat, topInset: CGFloat, bottomInset: CGFloat) -> some View {
        ZStack {
            // Edge-cropped decorative sprites (non-interactive)
            ForEach(collaborators) { collab in
                collaboratorSpriteNode(collab: collab, in: CGSize(width: w, height: h), isLive: false)
                    .allowsHitTesting(false)
            }
            
            // Top Right Wordmark (decorative, Berkeley Mono Bold, reads once as "Ya Ya")
            VStack {
                HStack {
                    Spacer()
                    YaYaWordmark(size: 24, showsPeriod: false)
                        .padding(.top, max(topInset, 44) + 6)
                        .padding(.trailing, 24)
                }
                Spacer()
            }
            .allowsHitTesting(false)
            .zIndex(20)
            
            // Centered Play Button (large circle)
            VStack(spacing: 10) {
                Button {
                    startMeeting()
                } label: {
                    ZStack {
                        Circle()
                            .fill(colorScheme == .dark ? Color.white : Color(red: 0.125, green: 0.122, blue: 0.125))
                            .frame(width: 88, height: 88)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15), radius: 16, x: 0, y: 8)
                        
                        Image(systemName: "play.fill")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .offset(x: 3)
                    }
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .accessibilityLabel("Start session")
                
                Text("Ready")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .allowsHitTesting(false)
            }
            .position(
                x: w * 0.35 + Self.playButtonOffset.width,
                y: h * 0.52 + Self.playButtonOffset.height
            )
            .zIndex(10)
            
            // People Counter in Bottom Right, just above the tab bar, aligned to right content margin
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PeopleCounterView(peopleCount: $peopleCount)
                        .padding(.trailing, 24)
                        .padding(.bottom, max(bottomInset, 16) + 74)
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
            
            // Top Right Wordmark (decorative, Berkeley Mono Bold, reads once as "Ya Ya")
            VStack {
                HStack {
                    Spacer()
                    YaYaWordmark(size: 24, showsPeriod: false)
                        .padding(.top, max(topInset, 44) + 6)
                        .padding(.trailing, 24)
                }
                Spacer()
            }
            .allowsHitTesting(false)
            .zIndex(20)
            
            // Centered Stop Button (circle with solid square)
            VStack(spacing: 10) {
                Button {
                    stopMeeting()
                } label: {
                    ZStack {
                        Circle()
                            .fill(colorScheme == .dark ? Color.white : Color(red: 0.125, green: 0.122, blue: 0.125))
                            .frame(width: 88, height: 88)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15), radius: 16, x: 0, y: 8)
                        
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .frame(width: 28, height: 28)
                    }
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .accessibilityLabel("Stop Collaboration Meeting")
                
                // Label is removed during live session
            }
            .position(
                x: w * 0.35 + Self.playButtonOffset.width,
                y: h * 0.52 + Self.playButtonOffset.height
            )
            .zIndex(10)
            
            // People Counter in Bottom Right, just above the tab bar, aligned to right content margin
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    PeopleCounterView(peopleCount: $peopleCount)
                        .padding(.trailing, 24)
                        .padding(.bottom, max(bottomInset, 16) + 74)
                }
            }
            .zIndex(15)
        }
    }
    
    // MARK: - 3. Project Takeaways Canvas (Contribution Grid)
    private func takeawaysCanvas(w: CGFloat, h: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 18) {
                // Header Title
                Text("Project Takeaways")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 28)
                    .padding(.top, 52)
                    .allowsHitTesting(false)
                
                // 3 Horizontal Continuous Marquee Rows (stat numbers populated directly from session)
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
                        keywords: ["Motion Guide", "Vector Specs", "Color Token Vault", "Living Story Script", "Figma Map"],
                        agentSprite: .cloud,
                        flowsRight: true
                    )
                }
                .frame(width: w, alignment: .leading)
                
                Spacer().frame(height: 18)
                
                // GitHub-Style Contribution Grid
                TakeawaysContributionGridView(
                    rows: buildAgentGridRows(),
                    sessionDuration: (frictionCount == 1 && sessionQuestionsCount == 3) ? 10.0 : 28.0,
                    timeSlice: ContributionGridConstants.takeawayTimeSliceSeconds,
                    onSelectCell: { cellContext in
                        passedKnowledgeContext = cellContext
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                            selectedTab = .knowledge
                        }
                    }
                )
                
                Spacer()
            }
            .frame(width: w, alignment: .leading)
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
            .position(x: w - 46, y: h - 98)
            .zIndex(15)
            .accessibilityLabel("Return to Collaboration Ready")
        }
        .frame(width: w, height: h)
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
    
    // MARK: - Build Agent Grid Rows (Session Time Slices)
    private func buildAgentGridRows() -> [AgentGridRow] {
        let isShortRun = (frictionCount == 1 && sessionQuestionsCount == 3)
        let totalDuration = isShortRun ? 10.0 : 28.0
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
            
        func makeCells(agentId: Int, name: String, sprite: BranchSprite, map: [Int: [TakeawayAction: Int]]) -> [ContributionCellContext] {
            (0..<totalCols).map { col in
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
        
        return [
            AgentGridRow(
                id: 0,
                name: "Maya",
                role: "Design",
                sprite: .cloud,
                cells: makeCells(agentId: 0, name: "Maya", sprite: .cloud, map: mayaActionsByCol)
            ),
            AgentGridRow(
                id: 1,
                name: "Theo",
                role: "Engineering",
                sprite: .bloom,
                cells: makeCells(agentId: 1, name: "Theo", sprite: .bloom, map: theoActionsByCol)
            ),
            AgentGridRow(
                id: 2,
                name: "Alex",
                role: "Product",
                sprite: .prism,
                cells: makeCells(agentId: 2, name: "Alex", sprite: .prism, map: alexActionsByCol)
            ),
            AgentGridRow(
                id: 3,
                name: "Sam",
                role: "Research",
                sprite: .spark,
                cells: makeCells(agentId: 3, name: "Sam", sprite: .spark, map: samActionsByCol)
            )
        ]
    }
    
    // MARK: - Live Map Canvas (Collective Emergence Actor-Discourse Network)
    private func liveMapCanvas(w: CGFloat, h: CGFloat, topInset: CGFloat) -> some View {
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
            .frame(width: w, height: max(0, h - topInset))
        }
        .frame(width: w, height: h)
    }
    
    // MARK: - Knowledge Canvas (Living Project Repository)
    private func knowledgeCanvas(w: CGFloat, h: CGFloat, topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: topInset)
            
            KnowledgeView(
                store: store,
                isLiveSession: mode == .meeting,
                sessionClock: max(0, clock - sequenceStartTime),
                passedContext: passedKnowledgeContext,
                onDismissContext: {
                    passedKnowledgeContext = nil
                }
            )
            .frame(width: w, height: max(0, h - topInset))
            .clipped()
        }
        .frame(width: w, height: h)
    }
        // MARK: - Profile Canvas & Reset Demo Button
    private func profileCanvas(w: CGFloat, h: CGFloat) -> some View {
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
        .frame(width: w, height: h)
    }
    
    // MARK: - Collaborator Node Rendering (Transforms + Eyes + Tag)
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
            
            // Liquid Glass Pill Tag: `Name · Role` in Ready, `Name · State` in Meeting
            HStack(spacing: 5) {
                Text(collab.name)
                    .font(.system(size: 12, weight: .bold))
                Text("·")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Text(isLive ? collab.state.displayName : collab.role)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .fixedSize()
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .glassEffect(.regular, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(collab.sprite.gradientColors[0].opacity(collab.state == .talking ? 0.7 : 0.25), lineWidth: 1)
            )
            .offset(x: collab.tagOffset.width, y: collab.tagOffset.height)
        }
        .position(x: w * collab.xFraction, y: h * collab.yFraction)
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
            let dx = speaker.xFraction - collab.xFraction
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
    
    // MARK: - Liquid Glass Tab Bar (4 Tabs)
    private var liquidGlassTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selectedTab == tab
                Button {
                    handleTabSelection(tab)
                } label: {
                    VStack(spacing: 4) {
                        if tab == .profile {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.primary.opacity(0.15) : Color.primary.opacity(0.06))
                                    .frame(width: 20, height: 20)
                                
                                let sprite = BranchSprite.from(hex: store.profile?.spriteColorHex ?? "")
                                SpriteView(sprite: sprite, isBlinking: false, showsArms: false)
                                    .frame(width: 17, height: 17)
                            }
                            .frame(height: 19)
                        } else {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                        }
                        
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.primary.opacity(colorScheme == .dark ? 0.16 : 0.08) : Color.clear)
                    )
                    .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .contentShape(Capsule())
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: 360)
        .glassEffect(.regular, in: Capsule())
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .contentShape(Capsule())
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 14, x: 0, y: 6)
    }
    
    // MARK: - Tab Switching (Sessions Run Across Tabs)
    private func handleTabSelection(_ tab: AppTab) {
        if selectedTab == tab { return }
        
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            selectedTab = tab
        }
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
            store.commitLiveKnowledgeEntriesToSeeded(for: "yaya")
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
                projectID: "yaya",
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
                projectID: "yaya",
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
                projectID: "yaya",
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
                projectID: "yaya",
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
                projectID: "yaya",
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
                projectID: "yaya",
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
                projectID: "yaya",
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
                projectID: "yaya",
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
    @State private var measuredUnitWidth: CGFloat = 720
    
    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width
            
            TimelineView(.animation(paused: reduceMotion)) { timeline in
                let elapsed = reduceMotion ? 0 : Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 120))
                let cycle = max(measuredUnitWidth, 420)
                
                let offset: CGFloat = {
                    if reduceMotion {
                        return 28
                    }
                    if flowsRight {
                        // Flows right: smoothly scrolls toward positive x, wrapped by cycle
                        let progress = CGFloat(elapsed * Float(speed)).truncatingRemainder(dividingBy: cycle)
                        return progress - cycle
                    } else {
                        // Flows left: smoothly scrolls toward negative x, wrapped by cycle
                        let progress = CGFloat(elapsed * Float(speed)).truncatingRemainder(dividingBy: cycle)
                        return -progress
                    }
                }()
                
                HStack(spacing: 24) {
                    ForEach(0..<4, id: \.self) { copyIndex in
                        rowContentUnit
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            if copyIndex == 0 {
                                                measuredUnitWidth = geo.size.width + 24
                                            }
                                        }
                                }
                            )
                    }
                }
                .offset(x: offset)
                .frame(width: screenWidth, alignment: .leading)
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

