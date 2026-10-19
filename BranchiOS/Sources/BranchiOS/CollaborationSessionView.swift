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

// MARK: - CollaborationSessionView
public struct CollaborationSessionView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    
    @State public var mode: CollaborationMode = .ready
    @State public var selectedTab: AppTab = .session
    
    // Extra attendees counter (0 to 9)
    @State private var extraAttendees: Int = 2
    
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
    
    // Collaborator definitions matching the motion study & SVG frames
    @State private var collaborators: [AgentCollaborator] = [
        AgentCollaborator(
            id: 0,
            name: "Maya",
            role: "Strategy",
            sprite: .cloud,
            state: .talking,
            energy: 0.55,
            xFraction: -0.04,
            yFraction: 0.16,
            widthFraction: 0.58,
            tagOffset: CGSize(width: 85, height: 45),
            takeawayLabel: "most artifacts added"
        ),
        AgentCollaborator(
            id: 1,
            name: "Theo",
            role: "Engineering",
            sprite: .bloom,
            state: .friction,
            energy: 0.40,
            xFraction: 0.88,
            yFraction: 0.26,
            widthFraction: 0.60,
            tagOffset: CGSize(width: -60, height: 55),
            takeawayLabel: "solutions expert"
        ),
        AgentCollaborator(
            id: 2,
            name: "Alex",
            role: "Product",
            sprite: .prism,
            state: .processing,
            energy: 0.35,
            xFraction: 0.86,
            yFraction: 0.62,
            widthFraction: 0.58,
            tagOffset: CGSize(width: -60, height: 55),
            takeawayLabel: "observer extraordinaire"
        ),
        AgentCollaborator(
            id: 3,
            name: "Sam",
            role: "Research",
            sprite: .spark,
            state: .agree,
            energy: 0.45,
            xFraction: -0.04,
            yFraction: 0.74,
            widthFraction: 0.62,
            tagOffset: CGSize(width: 85, height: -45),
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
        self._mode = State(initialValue: initialMode)
    }
    
    public var body: some View {
        ZStack {
            // Background: plain white in light mode, plain black in dark mode (global rule)
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
            // Main Content Area depending on mode
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack {
                    switch mode {
                    case .ready:
                        readyCanvas(w: w, h: h)
                            .transition(.opacity)
                    case .meeting:
                        meetingCanvas(w: w, h: h)
                            .transition(.opacity)
                    case .takeaways:
                        takeawaysCanvas(w: w, h: h)
                            .transition(.opacity)
                    }
                }
                .frame(width: w, height: h)
            }
            
            // Overlay Navigation Bar (Frosted Liquid Glass)
            if mode != .takeaways {
                VStack {
                    Spacer()
                    liquidGlassTabBar
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: mode)
        .onAppear {
            startPhysicsClock()
        }
        .onDisappear {
            stopPhysicsClock()
        }
    }
    
    // MARK: - 1. Ready Canvas (Recording_1.png)
    private func readyCanvas(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // Edge-cropped sprites with Role pill tags
            ForEach(collaborators) { collab in
                collaboratorSpriteNode(collab: collab, in: CGSize(width: w, height: h), isLive: false)
            }
            
            // Centered Play Button (large circle)
            VStack(spacing: 12) {
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
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Start Collaboration Session")
                
                Text("Ready")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .position(x: w * 0.35, y: h * 0.52)
            
            // Extra Attendees Stepper Pill (e.g. 2+ / 0–9)
            HStack(spacing: 8) {
                Button {
                    if extraAttendees > 0 { extraAttendees -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                
                Text("\(extraAttendees)+")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .frame(minWidth: 26)
                
                Button {
                    if extraAttendees < 9 { extraAttendees += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .glassEffect(.regular, in: Capsule())
            .overlay(Capsule().stroke(Color.primary.opacity(0.12), lineWidth: 1))
            .position(x: w * 0.76, y: h * 0.44)
        }
    }
    
    // MARK: - 2. Meeting Canvas (Recording_2.png)
    private func meetingCanvas(w: CGFloat, h: CGFloat) -> some View {
        ZStack {
            // Collaborators in Live Motion with dynamic state tags
            ForEach(collaborators) { collab in
                collaboratorSpriteNode(collab: collab, in: CGSize(width: w, height: h), isLive: true)
            }
            
            // Center Room Copy & Active Collaborator Count
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(collaborators.count + extraAttendees)")
                        .font(.system(size: 64, weight: .bold, design: .serif))
                        .foregroundStyle(.primary)
                }
                
                Text("collaborators\nin current meeting")
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .lineSpacing(2)
                    .foregroundStyle(.primary)
            }
            .position(x: w * 0.44, y: h * 0.36)
            
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
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Stop Collaboration Meeting")
                
                Text("Stop")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .position(x: w * 0.35, y: h * 0.54)
            
            // Extra Attendees Stepper Pill
            HStack(spacing: 8) {
                Button {
                    if extraAttendees > 0 { extraAttendees -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
                
                Text("\(extraAttendees)+")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .frame(minWidth: 26)
                
                Button {
                    if extraAttendees < 9 { extraAttendees += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .frame(width: 22, height: 22)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .glassEffect(.regular, in: Capsule())
            .overlay(Capsule().stroke(Color.primary.opacity(0.12), lineWidth: 1))
            .position(x: w * 0.76, y: h * 0.44)
            
            // Bottom Stage Caption
            VStack {
                Spacer()
                Text(currentCaption)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 84)
            }
        }
    }
    
    // MARK: - 3. Project Takeaways Canvas (Recording_3.png)
    // MARK: - 3. Project Takeaways Canvas (Recording_3.png)
    private func takeawaysCanvas(w: CGFloat, h: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 20) {
                // Header Title
                Text("Project Takeaways")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 28)
                    .padding(.top, 48)
                
                // 3 Horizontal Continuous Marquee Rows
                VStack(alignment: .leading, spacing: 12) {
                    // Row 1: 3 • Resolved Points of Friction
                    takeawayMarqueeRow(
                        statNumber: "3",
                        statTitle: "Resolved Points of Friction",
                        keywords: ["Timeline sync", "Design token hierarchy", "System architecture", "Model handoff"],
                        agentColor: BranchSprite.bloom.gradientColors[0],
                        width: w
                    )
                    
                    // Row 2: 2 • Future Opportunities
                    takeawayMarqueeRow(
                        statNumber: "2",
                        statTitle: "Future Opportunities",
                        keywords: ["Spatial audio canvas", "Cross-device multi-peer", "Dynamic clustering", "Export transcript"],
                        agentColor: BranchSprite.prism.gradientColors[0],
                        width: w
                    )
                    
                    // Row 3: 5 • Artifacts Added
                    takeawayMarqueeRow(
                        statNumber: "5",
                        statTitle: "Artifacts Added",
                        keywords: ["Motion Guide", "Vector Specs", "Color Token Vault", "Living Story Script", "Figma Map"],
                        agentColor: BranchSprite.cloud.gradientColors[0],
                        width: w
                    )
                }
                .frame(width: w, alignment: .leading)
                
                Spacer()
            }
            .frame(width: w, alignment: .leading)
            
            // Bottom Overlapping 4-Sprite Cluster (matches Recording_3.png)
            bottomTakeawayCluster(w: w, h: h)
            
            // Up-chevron return button in bottom right (Recording_3.png)
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                    mode = .ready
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.08))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "chevron.up.circle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
            .position(x: w * 0.82, y: h * 0.88)
            .accessibilityLabel("Return to Collaboration Ready")
        }
        .frame(width: w, height: h)
    }
    
    // MARK: - Takeaway Marquee Row Component
    private func takeawayMarqueeRow(
        statNumber: String,
        statTitle: String,
        keywords: [String],
        agentColor: Color,
        width: CGFloat
    ) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Frosted Glass Stat Pill with crisp border matching Recording_3.png
                HStack(spacing: 8) {
                    Text(statNumber)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Circle()
                        .fill(Color.primary.opacity(0.4))
                        .frame(width: 4, height: 4)
                    
                    Text(statTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .stroke(Color.primary, lineWidth: 1.8)
                )
                .fixedSize(horizontal: true, vertical: true)
                
                // Keyword Pills with Agent Gradient Colors
                ForEach(keywords, id: \.self) { word in
                    Text(word)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.primary)
                        .lineLimit(1)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(agentColor.opacity(colorScheme == .dark ? 0.35 : 0.18))
                        )
                        .overlay(
                            Capsule()
                                .stroke(agentColor.opacity(0.4), lineWidth: 1)
                        )
                        .fixedSize(horizontal: true, vertical: true)
                }
            }
            .padding(.horizontal, 28)
        }
        .frame(width: width, alignment: .leading)
    }
    
    // MARK: - Bottom Overlapping 4-Sprite Cluster with Curved Labels
    private func bottomTakeawayCluster(w: CGFloat, h: CGFloat) -> some View {
        let clusterBaseY = h * 0.65
        
        return ZStack {
            // Sprite 0: Maya (Cloud, left back - lavender)
            ZStack {
                CurvedText(text: "most artifacts added", radius: 78, isTop: true, color: BranchSprite.cloud.gradientColors[0])
                    .offset(y: -84)
                
                SpriteView(
                    sprite: .cloud,
                    isBlinking: false,
                    showsArms: false,
                    bodyScale: isTakeawaysNodding ? 1.08 : 1.0
                )
                .frame(width: 150, height: 140)
            }
            .position(x: w * 0.28, y: clusterBaseY - 10)
            
            // Sprite 1: Alex (Prism, center back - blue)
            ZStack {
                CurvedText(text: "observer extraordinaire", radius: 80, isTop: true, color: BranchSprite.prism.gradientColors[0])
                    .offset(y: -88)
                
                SpriteView(
                    sprite: .prism,
                    isBlinking: false,
                    showsArms: false,
                    bodyScale: isTakeawaysNodding ? 1.08 : 1.0
                )
                .frame(width: 145, height: 135)
            }
            .position(x: w * 0.58, y: clusterBaseY - 40)
            
            // Sprite 2: Theo (Bloom, right foreground - orange)
            ZStack {
                SpriteView(
                    sprite: .bloom,
                    isBlinking: false,
                    showsArms: false,
                    bodyScale: isTakeawaysNodding ? 1.08 : 1.0
                )
                .frame(width: 145, height: 135)
                
                CurvedText(text: "solutions expert", radius: 76, isTop: false, color: BranchSprite.bloom.gradientColors[0])
                    .offset(y: 84)
            }
            .position(x: w * 0.72, y: clusterBaseY + 10)
            
            // Sprite 3: Sam (Spark, center foreground - green)
            ZStack {
                SpriteView(
                    sprite: .spark,
                    isBlinking: false,
                    showsArms: false,
                    bodyScale: isTakeawaysNodding ? 1.08 : 1.0
                )
                .frame(width: 150, height: 140)
                
                CurvedText(text: "top conversationalist", radius: 80, isTop: false, color: BranchSprite.spark.gradientColors[0])
                    .offset(y: 88)
            }
            .position(x: w * 0.44, y: clusterBaseY + 25)
        }
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
            
            // Liquid Glass Pill Tag: `Name • Role` in Ready, `Name • State` in Meeting
            HStack(spacing: 5) {
                Text(collab.name)
                    .font(.system(size: 12, weight: .bold))
                Text("•")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                Text(isLive ? collab.state.displayName : collab.role)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
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
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        selectedTab = tab
                        if tab == .session && mode == .takeaways {
                            mode = .ready
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                            .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                        
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
                }
                .buttonStyle(.plain)
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
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 14, x: 0, y: 6)
    }
    
    // MARK: - Physics & Script Sequence Clock
    private func startPhysicsClock() {
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
            Task { @MainActor in
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
                        isSequenceRunning = false
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
        withAnimation {
            mode = .meeting
            isSequenceRunning = true
            sequenceStartTime = clock
            currentStepIndex = -1
        }
    }
    
    private func stopMeeting() {
        withAnimation {
            isSequenceRunning = false
            mode = .ready
        }
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
    }
    
    private func triggerTakeawaysOpeningNod() {
        isTakeawaysNodding = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            isTakeawaysNodding = false
        }
    }
}

// MARK: - Curved Text Component for Recording 3
private struct CurvedText: View {
    let text: String
    let radius: CGFloat
    let isTop: Bool
    let color: Color
    
    var body: some View {
        let chars = Array(text)
        let anglePerChar: Double = isTop ? 6.5 : 6.8
        let totalAngle: Double = Double(chars.count - 1) * anglePerChar
        
        ZStack {
            ForEach(0..<chars.count, id: \.self) { i in
                let charAngle = -totalAngle / 2.0 + Double(i) * anglePerChar
                let rad = charAngle * .pi / 180.0
                let x = radius * sin(rad)
                let y = isTop ? -radius * cos(rad) + radius : radius * cos(rad) - radius
                
                Text(String(chars[i]))
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .rotationEffect(.degrees(charAngle))
                    .offset(x: x, y: y)
            }
        }
    }
}
