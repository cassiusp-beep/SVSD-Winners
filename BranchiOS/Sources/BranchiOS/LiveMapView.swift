import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Filter Chip Option
public enum LiveMapFilterType: Equatable, CaseIterable {
    case additions      // +
    case counterpoints  // −
    case questions      // ?
    case reframes       // //
    case emergent       // ◎
    
    public var symbol: String {
        switch self {
        case .additions: return "+"
        case .counterpoints: return "−"
        case .questions: return "?"
        case .reframes: return "//"
        case .emergent: return "◎"
        }
    }
    
    public var label: String {
        switch self {
        case .additions: return "Additions"
        case .counterpoints: return "Counterpoints"
        case .questions: return "Questions"
        case .reframes: return "Reframes"
        case .emergent: return "Emergent"
        }
    }
}

// MARK: - Node Visual Layout Representation
public struct NodePosition: Identifiable, Equatable {
    public let id: String
    public var x: CGFloat
    public var y: CGFloat
    public var targetX: CGFloat
    public var targetY: CGFloat
    public var scale: CGFloat = 1.0
    public var opacity: Double = 1.0
}

// MARK: - Live Map View (Collective Emergence Actor-Discourse Network)
public struct LiveMapView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    public var isLiveSession: Bool = false
    public var sessionClock: Double = 0.0
    public var peopleCount: Int = 3
    public var onOpenInKnowledge: (String) -> Void = { _ in }
    public var onStartSession: () -> Void = {}
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Zoom & Pan Canvas State
    @State private var zoomScale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    
    // Selection & Filter State
    @State private var activeFilter: LiveMapFilterType? = nil
    @State private var isolatedActor: KnowledgeActor? = nil
    @State private var selectedNode: KnowledgeEntry? = nil
    @State private var selectedFrictionNode: KnowledgeEntry? = nil
    
    // Live Pulse & Combination Moment
    @State private var livePulse: Bool = false
    @State private var combinationHighlightedEntryID: String? = nil
    @State private var combinationRingBloom: Bool = false
    
    // Computed Positions for Graph Nodes
    @State private var nodePositions: [String: CGPoint] = [:]
    @State private var eyeGazeVector: CGSize = .zero
    @State private var blinkToggle: Bool = false
    
    public init(
        store: DemoStore = DemoStore.shared,
        isLiveSession: Bool = false,
        sessionClock: Double = 0.0,
        peopleCount: Int = 3,
        onOpenInKnowledge: @escaping (String) -> Void = { _ in },
        onStartSession: @escaping () -> Void = {}
    ) {
        self.store = store
        self.isLiveSession = isLiveSession
        self.sessionClock = sessionClock
        self.peopleCount = peopleCount
        self.onOpenInKnowledge = onOpenInKnowledge
        self.onStartSession = onStartSession
    }
    
    // MARK: - Active Entries Feed
    private var entries: [KnowledgeEntry] {
        if isLiveSession {
            return store.liveKnowledgeEntries
        }
        return store.entriesForSelectedSession()
    }
    
    // Project title
    private var currentProjectTitle: String {
        if isLiveSession { return store.activeProject.name }
        return DemoProject.name(for: store.selectedKnowledgeProjectID)
    }
    
    // Active session metadata
    private var activeSessionMeta: SessionMeta {
        let sid = store.selectedSessionID
        return KnowledgeEntry.seededSessions.first(where: { $0.id == sid }) ?? KnowledgeEntry.seededSessions[0]
    }
    
    // Throughline: Most recent emergent idea connected to the user's entries
    private var currentThroughline: KnowledgeEntry? {
        let emergentIdeas = entries.filter { entry in
            entry.isEmergent && (entry.actor.isUser || entry.links.contains(where: { link in
                entries.first(where: { $0.id == link.targetEntryID })?.actor.isUser == true
            }))
        }
        return emergentIdeas.last
    }
    
    // Filter chip counts
    private var filterCounts: [LiveMapFilterType: Int] {
        var counts: [LiveMapFilterType: Int] = [
            .additions: 0,
            .counterpoints: 0,
            .questions: 0,
            .reframes: 0,
            .emergent: 0
        ]
        for entry in entries {
            switch entry.type {
            case .addition: counts[.additions, default: 0] += 1
            case .counterpoint: counts[.counterpoints, default: 0] += 1
            case .question: counts[.questions, default: 0] += 1
            case .reframe: counts[.reframes, default: 0] += 1
            }
            if entry.isEmergent {
                counts[.emergent, default: 0] += 1
            }
        }
        return counts
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            
            ZStack(alignment: .top) {
                // Background
                (colorScheme == .dark ? Color.black : Color.white)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isolatedActor = nil
                            activeFilter = nil
                        }
                    }
                
                // 1. Network Canvas (behind pinned headers and floating tab bar)
                if entries.isEmpty && !isLiveSession {
                    emptyStateView(w: w, h: h)
                } else {
                    networkCanvas(w: w, h: h)
                        .scaleEffect(zoomScale)
                        .offset(x: panOffset.width + dragOffset.width, y: panOffset.height + dragOffset.height)
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        zoomScale = max(0.65, min(2.4, value))
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        dragOffset = value.translation
                                    }
                                    .onEnded { value in
                                        panOffset.width += value.translation.width
                                        panOffset.height += value.translation.height
                                        dragOffset = .zero
                                    }
                            )
                        )
                }
                
                // 2. Pinned Top Header & Floating Throughline Card
                VStack(spacing: 10) {
                    headerView(w: w)
                    
                    if !entries.isEmpty || isLiveSession {
                        throughlineCardView
                            .padding(.horizontal, 20)
                        
                        filterChipsRow
                            .padding(.horizontal, 8)
                            .padding(.vertical, -6)
                    }
                }
                .padding(.bottom, 8)
                .background(
                    LinearGradient(
                        colors: [
                            (colorScheme == .dark ? Color.black : Color.white),
                            (colorScheme == .dark ? Color.black : Color.white).opacity(0.95),
                            (colorScheme == .dark ? Color.black : Color.white).opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: (entries.isEmpty && !isLiveSession) ? 90 : 230)
                    .allowsHitTesting(false)
                )
                .zIndex(20)
                
                // 3. Floating Recenter "Fit" Button (bottom right, above tab bar)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        recenterFitButton
                            .padding(.trailing, 22)
                            .padding(.bottom, 16)
                    }
                }
                .zIndex(25)
            }
            .sheet(item: $selectedNode) { entry in
                NodeDetailSheet(entry: entry, allEntries: entries, onOpenKnowledge: { id in
                    selectedNode = nil
                    onOpenInKnowledge(id)
                }, onFocusNode: { targetID in
                    focusNode(targetID, in: CGSize(width: w, height: h))
                })
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedFrictionNode) { entry in
                FrictionResolutionSheet(entry: entry) { chosenResolution in
                    store.resolveFriction(entryID: entry.id, resolution: chosenResolution)
                    #if canImport(UIKit)
                    let feedback = UINotificationFeedbackGenerator()
                    feedback.notificationOccurred(.success)
                    #endif
                    selectedFrictionNode = nil
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                computeLayoutPositions(in: CGSize(width: w, height: h))
                startEyeGazeTimer()
                
                if CommandLine.arguments.contains("-testDetailSheet") {
                    selectedNode = entries.first(where: { $0.id == "s3_08" }) ?? entries.first
                } else if CommandLine.arguments.contains("-testFrictionSheet") {
                    selectedFrictionNode = entries.first(where: { $0.id == "s3_05" }) ?? entries.first(where: { $0.type == .counterpoint })
                } else if CommandLine.arguments.contains("-testActorIsolated") {
                    isolatedActor = .user
                } else if CommandLine.arguments.contains("-testCombinationMoment") {
                    combinationHighlightedEntryID = "s3_08"
                    combinationRingBloom = true
                }
            }
            .onChange(of: entries.map(\.id)) { _, _ in
                withAnimation(reduceMotion ? .none : .spring(response: 0.55, dampingFraction: 0.78)) {
                    computeLayoutPositions(in: CGSize(width: w, height: h))
                }
            }
            .onChange(of: store.selectedSessionID) { _, _ in
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    zoomScale = 1.0
                    panOffset = .zero
                    computeLayoutPositions(in: CGSize(width: w, height: h))
                }
            }
        }
    }
    
    // MARK: - 1. Header View
    private func headerView(w: CGFloat) -> some View {
        ScreenHeader(horizontalPadding: 20) {
            VStack(alignment: .leading, spacing: 3) {
                // Project title + dropdown chevron
                if isLiveSession {
                    HStack(spacing: 8) {
                        Text(store.activeProject.name)
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        liveSessionPill
                    }
                } else {
                    Menu {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                store.selectedKnowledgeProjectID = nil
                            }
                        } label: {
                            HStack {
                                Text("All projects")
                                if store.selectedKnowledgeProjectID == nil {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                store.selectedKnowledgeProjectID = "yaya"
                            }
                        } label: {
                            HStack {
                                Text("Making YaYa")
                                if store.selectedKnowledgeProjectID == "yaya" {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(currentProjectTitle)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                // Subtitle in Berkeley Mono
                if isLiveSession {
                    Text("SESSION 3 · 4 AGENTS · \(peopleCount) PEOPLE")
                        .font(Font.yaya(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)
                } else {
                    // Tap subtitle opens session picker menu
                    Menu {
                        ForEach(KnowledgeEntry.seededSessions) { s in
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    store.selectedSessionID = s.id
                                }
                            } label: {
                                HStack {
                                    Text("\(s.title) (\(s.dateDisplay))")
                                    if store.selectedSessionID == s.id {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Text(activeSessionMeta.subtitle)
                                .font(Font.yaya(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                                .tracking(0.4)
                                .fixedSize(horizontal: true, vertical: false)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
        } trailing: {
            // Avatar cluster at top right
            avatarClusterView
        }
    }
    
    // LIVE Pill
    private var liveSessionPill: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color(red: 0.12, green: 0.75, blue: 0.35))
                .frame(width: 7, height: 7)
                .opacity(reduceMotion ? 1.0 : (livePulse ? 1.0 : 0.3))
                .scaleEffect(reduceMotion ? 1.0 : (livePulse ? 1.2 : 0.9))
            
            Text("LIVE")
                .font(Font.yaya(size: 11, weight: .bold))
                .foregroundStyle(Color(red: 0.12, green: 0.75, blue: 0.35))
                .tracking(0.6)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(red: 0.12, green: 0.75, blue: 0.35).opacity(0.12))
        )
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    livePulse = true
                }
            }
        }
    }
    
    // Top right avatar cluster
    private var avatarClusterView: some View {
        HStack(spacing: -8) {
            // User Avatar (photo or sprite)
            userAvatarCircle(size: 28)
                .overlay(Circle().stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 1.5))
                .zIndex(5)
            
            // 4 Agents
            ForEach(0..<4) { idx in
                let sprite: BranchSprite = [BranchSprite.cloud, .bloom, .prism, .spark][idx]
                ZStack {
                    Circle()
                        .fill(colorScheme == .dark ? Color(white: 0.18) : Color(white: 0.92))
                        .frame(width: 28, height: 28)
                    
                    SpriteView(sprite: sprite, isBlinking: false, showsArms: false)
                        .frame(width: 22, height: 22)
                }
                .overlay(Circle().stroke(colorScheme == .dark ? Color.black : Color.white, lineWidth: 1.5))
                .zIndex(Double(4 - idx))
            }
        }
        .accessibilityLabel("Session participants: You, Maya, Theo, Alex, Sam")
    }
    
    // User avatar helper
    private func userAvatarCircle(size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: KnowledgeActor.user.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            #if canImport(UIKit)
            if let photo = store.loadedPhotoImage, store.profile?.avatarType == .photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                let userSprite = BranchSprite.from(hex: store.profile?.spriteColorHex ?? "")
                SpriteView(sprite: userSprite, isBlinking: blinkToggle, showsArms: false)
                    .frame(width: size * 0.88, height: size * 0.88)
            }
            #else
            let userSprite = BranchSprite.from(hex: store.profile?.spriteColorHex ?? "")
            SpriteView(sprite: userSprite, isBlinking: blinkToggle, showsArms: false)
                .frame(width: size * 0.88, height: size * 0.88)
            #endif
        }
    }
    
    // MARK: - 2. Throughline Card
    private var throughlineCardView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("◎")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(red: 0.388, green: 0.400, blue: 0.945))
                
                Text("YOUR THROUGHLINE")
                    .font(Font.yaya(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
                
                Spacer()
            }
            
            if let tl = currentThroughline {
                Text(tl.text)
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                Text("Your throughline will appear as ideas connect.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.30 : 0.05), radius: 8, x: 0, y: 3)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(currentThroughline != nil ? "Your throughline: \(currentThroughline!.text)" : "Your throughline will appear as ideas connect")
        .accessibilityAction(named: "Open throughline idea") {
            if let tl = currentThroughline {
                selectedNode = tl
            }
        }
    }
    
    // MARK: - 3. Filter Chips Row
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(LiveMapFilterType.allCases, id: \.symbol) { filter in
                    let isSelected = activeFilter == filter
                    let count = filterCounts[filter, default: 0]
                    
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            if activeFilter == filter {
                                activeFilter = nil
                            } else {
                                activeFilter = filter
                                isolatedActor = nil
                            }
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Text(filter.symbol)
                                .font(Font.yaya(size: 12, weight: .bold))
                                .foregroundStyle(badgeColor(for: filter))
                            
                            Text("\(count)")
                                .font(Font.yaya(size: 12, weight: .bold))
                                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .glassEffect(.regular, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.primary : Color.primary.opacity(0.12), lineWidth: isSelected ? 1.5 : 1.0)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(filter.label) filter, \(count) items")
                }
            }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        .scrollClipDisabled()
    }
    
    private func badgeColor(for filter: LiveMapFilterType) -> Color {
        switch filter {
        case .additions: return KnowledgeEntryType.addition.badgeColor
        case .counterpoints: return KnowledgeEntryType.counterpoint.badgeColor
        case .questions: return KnowledgeEntryType.question.badgeColor
        case .reframes: return KnowledgeEntryType.reframe.badgeColor
        case .emergent: return Color(red: 0.388, green: 0.400, blue: 0.945)
        }
    }
    
    // MARK: - 4. Network Canvas
    private func networkCanvas(w: CGFloat, h: CGFloat) -> some View {
        let center = CGPoint(x: w / 2, y: h / 2 + 30)
        
        return ZStack {
            // Edges Layer: Actor-to-idea lines & Idea-to-idea curved links
            networkEdgesLayer(center: center)
            
            // Actor Anchors (Center User + 4 Corners)
            actorAnchorsLayer(w: w, h: h, center: center)
            
            // Idea Nodes Layer
            ForEach(entries) { entry in
                if let pt = nodePositions[entry.id] {
                    ideaNodeView(entry: entry, at: pt, canvasWidth: w)
                        .position(pt)
                        .zIndex(entry.isEmergent ? 15 : 10)
                }
            }
        }
        .frame(width: w, height: h)
    }
    
    // MARK: - Edges Layer
    private func networkEdgesLayer(center: CGPoint) -> some View {
        ZStack {
            // Actor to idea lines (faint hairline)
            ForEach(entries) { entry in
                if let ideaPt = nodePositions[entry.id] {
                    let actorPt = actorAnchorPoint(for: entry.actor, center: center)
                    let isDimmed = isNodeDimmed(entry)
                    
                    Path { p in
                        p.move(to: actorPt)
                        p.addLine(to: ideaPt)
                    }
                    .stroke(
                        Color.primary.opacity(isDimmed ? 0.03 : 0.12),
                        style: StrokeStyle(lineWidth: 1, lineCap: .round)
                    )
                }
            }
            
            // Idea to idea links
            ForEach(entries) { entry in
                ForEach(entry.links) { link in
                    if let sourcePt = nodePositions[entry.id],
                       let targetPt = nodePositions[link.targetEntryID] {
                        let isDimmed = isNodeDimmed(entry)
                        let isHighlightedCombination = (entry.id == combinationHighlightedEntryID)
                        
                        linkPath(from: targetPt, to: sourcePt)
                            .stroke(
                                linkStrokeColor(for: link, author: entry.actor, isHighlighted: isHighlightedCombination),
                                style: linkStrokeStyle(for: link.type, isHighlighted: isHighlightedCombination)
                            )
                            .opacity(isDimmed ? 0.05 : 0.85)
                    }
                }
            }
        }
    }
    
    private func linkPath(from start: CGPoint, to end: CGPoint) -> Path {
        var p = Path()
        p.move(to: start)
        let midX = (start.x + end.x) / 2
        let midY = (start.y + end.y) / 2
        let dx = end.x - start.x
        let dy = end.y - start.y
        let normal = CGPoint(x: -dy * 0.18, y: dx * 0.18)
        let control = CGPoint(x: midX + normal.x, y: midY + normal.y)
        p.addQuadCurve(to: end, control: control)
        return p
    }
    
    private func linkStrokeColor(for link: KnowledgeLink, author: KnowledgeActor, isHighlighted: Bool) -> Color {
        if isHighlighted {
            return Color(red: 0.388, green: 0.400, blue: 0.945)
        }
        switch link.type {
        case .challenges:
            return KnowledgeEntryType.counterpoint.badgeColor
        case .transforms:
            return author.gradientColors[0]
        case .combines:
            return Color.primary
        case .buildsOn:
            return author.gradientColors[0]
        }
    }
    
    private func linkStrokeStyle(for type: KnowledgeLinkType, isHighlighted: Bool) -> StrokeStyle {
        switch type {
        case .transforms:
            return StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [4, 4])
        case .combines:
            return StrokeStyle(lineWidth: isHighlighted ? 3.0 : 2.2, lineCap: .round)
        case .challenges:
            return StrokeStyle(lineWidth: 1.6, lineCap: .round)
        case .buildsOn:
            return StrokeStyle(lineWidth: 1.4, lineCap: .round)
        }
    }
    
    // MARK: - Actor Anchors Layer
    private func actorAnchorsLayer(w: CGFloat, h: CGFloat, center: CGPoint) -> some View {
        ZStack {
            // Center User
            userAnchorView
                .position(center)
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        toggleActorIsolation(.user)
                    }
                }
            
            // Maya (Top Left)
            agentAnchorView(name: "Maya", role: "Strategy", sprite: .cloud, actor: .maya)
                .position(x: w * 0.16, y: h * 0.34)
                .onTapGesture { toggleActorIsolation(.maya) }
            
            // Theo (Top Right)
            agentAnchorView(name: "Theo", role: "Engineering", sprite: .bloom, actor: .theo)
                .position(x: w * 0.84, y: h * 0.34)
                .onTapGesture { toggleActorIsolation(.theo) }
            
            // Alex (Bottom Right)
            agentAnchorView(name: "Alex", role: "Product", sprite: .prism, actor: .alex)
                .position(x: w * 0.84, y: bottomAgentY(h: h))
                .onTapGesture { toggleActorIsolation(.alex) }
            
            // Sam (Bottom Left)
            agentAnchorView(name: "Sam", role: "Research", sprite: .spark, actor: .sam)
                .position(x: w * 0.16, y: bottomAgentY(h: h))
                .onTapGesture { toggleActorIsolation(.sam) }
        }
    }
    
    private func bottomAgentY(h: CGFloat) -> CGFloat {
        h > 880 ? h * 0.78 : (h > 800 ? h * 0.74 : h * 0.72)
    }
    
    private var userAnchorView: some View {
        let isIsolated = (isolatedActor == .user)
        let isDimmed = (isolatedActor != nil && !isIsolated)
        
        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color(white: colorScheme == .dark ? 0.15 : 0.95))
                    .frame(width: 68, height: 68)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.12), radius: 10, x: 0, y: 5)
                
                userAvatarCircle(size: 64)
            }
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(colors: KnowledgeActor.user.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isIsolated ? 3.0 : 1.5
                    )
            )
            
            Text("You")
                .font(Font.yaya(size: 11, weight: .bold))
                .foregroundStyle(isIsolated ? Color.primary : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .glassEffect(.regular, in: Capsule())
        }
        .opacity(isDimmed ? 0.10 : 1.0)
        .contentShape(Circle())
        .accessibilityLabel("User actor: You, tap to isolate your ideas")
    }
    
    private func agentAnchorView(name: String, role: String, sprite: BranchSprite, actor: KnowledgeActor) -> some View {
        let isIsolated = (isolatedActor == actor)
        let isDimmed = (isolatedActor != nil && !isIsolated)
        
        return VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(Color(white: colorScheme == .dark ? 0.15 : 0.95))
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.10), radius: 8, x: 0, y: 4)
                
                SpriteView(
                    sprite: sprite,
                    isBlinking: blinkToggle,
                    showsArms: false,
                    gazeOffset: eyeGazeVector
                )
                .frame(width: 48, height: 48)
            }
            .overlay(
                Circle()
                    .stroke(sprite.gradientColors[0].opacity(isIsolated ? 0.9 : 0.3), lineWidth: isIsolated ? 2.5 : 1.0)
            )
            
            Text(name)
                .font(Font.yaya(size: 10, weight: .bold))
                .foregroundStyle(isIsolated ? Color.primary : .secondary)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .glassEffect(.regular, in: Capsule())
        }
        .opacity(isDimmed ? 0.10 : 1.0)
        .contentShape(Circle())
        .accessibilityLabel("Agent actor: \(name), \(role)")
    }
    
    private func toggleActorIsolation(_ actor: KnowledgeActor) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            if isolatedActor == actor {
                isolatedActor = nil
            } else {
                isolatedActor = actor
                activeFilter = nil
            }
        }
    }
    
    // MARK: - Idea Node View
    private func ideaNodeView(entry: KnowledgeEntry, at pt: CGPoint, canvasWidth: CGFloat) -> some View {
        let isDimmed = isNodeDimmed(entry)
        let isRecencyFaded = isRecencyFaded(entry)
        let isResolved = (entry.resolution != nil && entry.resolution != .unresolved)
        let linksCount = entries.filter { $0.links.contains(where: { $0.targetEntryID == entry.id }) }.count
        let orbSize: CGFloat = min(42, 28 + CGFloat(linksCount) * 4)
        // Labels face outward, but flip inward when the outward side would run off screen (label is 118pt wide).
        let labelOnLeft: Bool = {
            let preferLeft = pt.x < canvasWidth / 2
            let reach = orbSize / 2 + 2 + 118 + 4
            if preferLeft { return pt.x - reach >= 0 }
            return pt.x + reach > canvasWidth
        }()
        
        return ZStack {
            // Node Orb centered exactly at pt
            ZStack {
                // Emergent Ring
                if entry.isEmergent {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: KnowledgeActor.user.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: orbSize + 12, height: orbSize + 12)
                        .scaleEffect(combinationRingBloom && entry.id == combinationHighlightedEntryID ? 1.25 : 1.0)
                }
                
                // Base Orb
                if entry.actor.isAI {
                    // YaYa suggestion: dashed sparkle orb
                    Circle()
                        .stroke(Color.primary.opacity(0.55), style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
                        .background(Circle().fill(colorScheme == .dark ? Color(white: 0.14) : Color.white))
                        .frame(width: orbSize, height: orbSize)
                    
                    Image(systemName: "sparkle")
                        .font(.system(size: orbSize * 0.46, weight: .semibold))
                        .foregroundStyle(Color.primary)
                } else if entry.isCombination {
                    // Combination Node: two merging lines icon in black/white
                    Circle()
                        .fill(colorScheme == .dark ? Color(white: 0.22) : Color.white)
                        .frame(width: orbSize, height: orbSize)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.12), radius: 4, x: 0, y: 2)
                        .overlay(Circle().stroke(Color.primary.opacity(0.3), lineWidth: 1.2))
                    
                    Image(systemName: "point.bottomleft.forward.to.point.topright.scurvepath")
                        .font(.system(size: orbSize * 0.48, weight: .bold))
                        .foregroundStyle(Color.primary)
                } else if entry.type == .counterpoint && isResolved {
                    // Resolved counterpoint: red outline with small check
                    Circle()
                        .stroke(KnowledgeEntryType.counterpoint.badgeColor, lineWidth: 2)
                        .background(Circle().fill(colorScheme == .dark ? Color(white: 0.14) : Color.white))
                        .frame(width: orbSize, height: orbSize)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: orbSize * 0.42, weight: .bold))
                        .foregroundStyle(KnowledgeEntryType.counterpoint.badgeColor)
                } else {
                    // Standard Entry Node
                    Circle()
                        .fill(colorScheme == .dark ? Color(white: 0.18) : Color.white)
                        .frame(width: orbSize, height: orbSize)
                        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.10), radius: 4, x: 0, y: 2)
                        .overlay(Circle().stroke(entry.type.badgeColor.opacity(0.3), lineWidth: 1.0))
                    
                    Text(entry.type.symbolString)
                        .font(Font.yaya(size: orbSize * 0.50, weight: .bold))
                        .foregroundStyle(entry.type.badgeColor)
                }
            }
            .frame(width: 44, height: 44) // 44pt touch target
            .contentShape(Circle())
            
            // Outward-facing label positioned without shifting orb center
            if zoomScale >= 0.82 {
                Text(entry.shortLabel)
                    .font(Font.yaya(size: 9.5, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill((colorScheme == .dark ? Color.black : Color.white).opacity(0.90))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 0.5)
                    )
                    .frame(width: 118, alignment: labelOnLeft ? .trailing : .leading)
                    .allowsHitTesting(false)
                    .offset(x: labelOnLeft ? -(orbSize / 2 + 2 + (entry.isEmergent ? 8 : 0) + 59) : (orbSize / 2 + 2 + (entry.isEmergent ? 8 : 0) + 59))
            }
        }
        .opacity(isDimmed ? 0.10 : (isRecencyFaded ? 0.40 : 1.0))
        .scaleEffect(isRecencyFaded ? 0.70 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture {
            handleNodeTap(entry)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(entry.accessibilitySummary)
        .accessibilityAction(named: "Open node details") {
            handleNodeTap(entry)
        }
    }
    
    private func handleNodeTap(_ entry: KnowledgeEntry) {
        if entry.type == .counterpoint && (entry.resolution == nil || entry.resolution == .unresolved) {
            selectedFrictionNode = entry
        } else {
            selectedNode = entry
        }
    }
    
    // MARK: - Node Dimming & Recency Logic
    private func isNodeDimmed(_ entry: KnowledgeEntry) -> Bool {
        if let isolated = isolatedActor {
            return entry.actor != isolated && !entry.links.contains(where: { link in
                entries.first(where: { $0.id == link.targetEntryID })?.actor == isolated
            })
        }
        if let filter = activeFilter {
            switch filter {
            case .additions: return entry.type != .addition
            case .counterpoints: return entry.type != .counterpoint
            case .questions: return entry.type != .question
            case .reframes: return entry.type != .reframe
            case .emergent: return !entry.isEmergent
            }
        }
        return false
    }
    
    private func isRecencyFaded(_ entry: KnowledgeEntry) -> Bool {
        guard isLiveSession else { return false }
        let total = entries.count
        guard total > 12 else { return false }
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            return idx < (total - 12)
        }
        return false
    }
    
    // MARK: - 5. Recenter Fit Button
    private var recenterFitButton: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                zoomScale = 1.0
                panOffset = .zero
                dragOffset = .zero
            }
        } label: {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color(white: 0.22) : Color.white)
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.15), radius: 6, x: 0, y: 3)
                
                Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Recenter map")
    }
    
    // MARK: - 6. Empty State View
    private func emptyStateView(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Resting actors
            HStack(spacing: 14) {
                userAvatarCircle(size: 52)
                ForEach(0..<4) { idx in
                    let sprite: BranchSprite = [BranchSprite.cloud, .bloom, .prism, .spark][idx]
                    SpriteView(sprite: sprite, isBlinking: false, showsArms: false)
                        .frame(width: 44, height: 44)
                }
            }
            .opacity(0.85)
            
            Text("Nothing's connected yet.")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
            
            Button {
                onStartSession()
            } label: {
                Text("Start a session")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(colorScheme == .dark ? Color.white : Color(red: 0.125, green: 0.122, blue: 0.125))
                    )
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
        .frame(width: w, height: h)
        .padding(.bottom, 12)
    }
    
    // MARK: - Force-Directed Graph Layout Simulation
    /// Real on-canvas avatar position for each actor (mirrors `actorAnchorsLayer`).
    private func avatarPoint(for actor: KnowledgeActor, w: CGFloat, h: CGFloat) -> CGPoint {
        switch actor {
        case .user: return CGPoint(x: w / 2, y: h / 2 + 30)
        case .maya: return CGPoint(x: w * 0.16, y: h * 0.34)
        case .theo: return CGPoint(x: w * 0.84, y: h * 0.34)
        case .alex: return CGPoint(x: w * 0.84, y: bottomAgentY(h: h))
        case .sam:  return CGPoint(x: w * 0.16, y: bottomAgentY(h: h))
        case .yaya: return CGPoint(x: w / 2, y: 238)
        }
    }
    
    /// Estimated width of an idea label (9.5pt semibold mono + 12pt padding), capped at the 118pt frame.
    private func labelWidth(_ entry: KnowledgeEntry) -> CGFloat {
        min(118, 12 + 5.9 * CGFloat(min(entry.shortLabel.count, 20)))
    }
    
    /// Same orb size rule as `ideaNodeView`.
    private func orbSizeFor(_ entry: KnowledgeEntry) -> CGFloat {
        let linksCount = entries.filter { $0.links.contains(where: { $0.targetEntryID == entry.id }) }.count
        return min(42, 28 + CGFloat(linksCount) * 4)
    }
    
    /// Mirrors the label-side rule in `ideaNodeView` exactly so footprints match what is drawn.
    private func labelIsOnLeft(x: CGFloat, orbSize: CGFloat, canvasWidth: CGFloat) -> Bool {
        let reach = orbSize / 2 + 2 + 118 + 4
        if x < canvasWidth / 2 { return x - reach >= 0 }
        return x + reach > canvasWidth
    }
    
    /// The orb (plus emergent ring) and its label as two rects (the label is a thin strip beside the orb).
    private func nodeRects(_ entry: KnowledgeEntry, at p: CGPoint, canvasWidth: CGFloat, orbSize os: CGFloat) -> [CGRect] {
        let ring: CGFloat = entry.isEmergent ? 12 : 0
        let orbD = max(44, os + ring)
        let orb = CGRect(x: p.x - orbD / 2, y: p.y - orbD / 2, width: orbD, height: orbD)
        let lw = labelWidth(entry)
        let onLeft = labelIsOnLeft(x: p.x, orbSize: os, canvasWidth: canvasWidth)
        let edge = os / 2 + 2 + (entry.isEmergent ? 8 : 0)
        let lx = onLeft ? p.x - edge - lw : p.x + edge
        let label = CGRect(x: lx, y: p.y - 11, width: lw, height: 22)
        return [orb, label]
    }
    
    private func computeLayoutPositions(in size: CGSize) {
        let w = size.width
        let h = size.height
        let center = avatarPoint(for: .user, w: w, h: h)
        // Vertical band the ideas may use: below the filter chips, above the floating tab bar.
        let yTop: CGFloat = 232
        let yBot: CGFloat = max(yTop + 120, h - 66)
        
        // Fixed obstacles: actor avatars + name pills, and the You node + its label.
        var obstacles: [CGRect] = [
            CGRect(x: center.x - 46, y: center.y - 48, width: 92, height: 112)
        ]
        // Recenter button (bottom-trailing).
        obstacles.append(CGRect(x: w - 84, y: h - 60, width: 76, height: 70))
        for actor in [KnowledgeActor.maya, .theo, .alex, .sam] {
            let a = avatarPoint(for: actor, w: w, h: h)
            obstacles.append(CGRect(x: a.x - 34, y: a.y - 32, width: 68, height: 92))
        }
        
        let lowerStretch = max(1, min(2.6, (yBot - center.y) / 170))
        // Initial targets: radiate each actor's ideas from their avatar toward the middle of the canvas.
        let perActor = Dictionary(grouping: entries.indices, by: { entries[$0].actor })
        var ids: [String] = []
        var pts: [CGPoint] = []
        var idx: [String: Int] = [:]
        
        for (i, entry) in entries.enumerated() {
            let avatar = avatarPoint(for: entry.actor, w: w, h: h)
            let group = perActor[entry.actor] ?? [i]
            let k = CGFloat(group.firstIndex(of: i) ?? 0)
            let n = CGFloat(group.count)
            var target: CGPoint
            
            if entry.actor == .user {
                // Ring around You, just outside the You rect; captures stay close.
                let ang = Double(k) * (2.0 * .pi / Double(max(n, 4))) + 0.6
                target = CGPoint(x: center.x + CGFloat(cos(ang)) * 118, y: center.y + CGFloat(sin(ang)) * 104)
            } else {
                let toward = atan2(Double(center.y - avatar.y), Double(center.x - avatar.x))
                let ang = toward + Double(k - (n - 1) / 2) * 0.95
                let r: CGFloat = 92 + CGFloat(Int(k) % 2) * 34
                target = CGPoint(x: avatar.x + CGFloat(cos(ang)) * r, y: avatar.y + CGFloat(sin(ang)) * r)
            }
            
            // Pull toward earlier linked nodes so related ideas sit near each other.
            var lx: CGFloat = 0, ly: CGFloat = 0, lc: CGFloat = 0
            for link in entry.links {
                if let j = idx[link.targetEntryID] { lx += pts[j].x; ly += pts[j].y; lc += 1 }
            }
            if lc > 0 {
                target.x = target.x * 0.65 + (lx / lc) * 0.35
                target.y = target.y * 0.65 + (ly / lc) * 0.35
            }
            // Stretch below You so the lower canvas (above the tab bar) is used, not left empty.
            if target.y > center.y { target.y = center.y + (target.y - center.y) * lowerStretch }
            idx[entry.id] = pts.count
            ids.append(entry.id)
            pts.append(target)
        }
        
        // Greedy collision-free placement: each node takes the free grid spot closest to its target,
        // where "free" means neither its orb nor its label touches an obstacle or an already-placed node.
        let gap: CGFloat = 8
        var placedRects: [CGRect] = obstacles
        var finalPts = pts
        // Your own nodes (captures included) claim the space around You first.
        let order = pts.indices.sorted { a, b in
            let ua = entries[a].actor.isUser ? 0 : 1, ub = entries[b].actor.isUser ? 0 : 1
            return ua == ub ? a < b : ua < ub
        }
        let step: CGFloat = 5
        let orbSizes = entries.map { orbSizeFor($0) }
        for i in order {
            let e = entries[i]
            let lw = labelWidth(e)
            let os = orbSizes[i]
            var best: CGPoint? = nil
            var bestScore = CGFloat.greatestFiniteMagnitude
            var x: CGFloat = 8 + 24
            while x <= w - 8 - 24 {
                var y = yTop
                while y <= yBot {
                    let p = CGPoint(x: x, y: y)
                    let onLeft = labelIsOnLeft(x: x, orbSize: os, canvasWidth: w)
                    let edge = os / 2 + 2 + (e.isEmergent ? 8 : 0)
                    let fitsX = onLeft ? (x - edge - lw >= 6) : (x + edge + lw <= w - 6)
                    if fitsX {
                        let rs = nodeRects(e, at: p, canvasWidth: w, orbSize: os).map { $0.insetBy(dx: -gap / 2, dy: -gap / 2) }
                        // Overlap area is penalised so hard that any free spot wins; when the canvas is
                        // genuinely full the least-overlapping spot is used instead of the raw target.
                        var overlap: CGFloat = 0
                        for r in rs {
                            for o in placedRects {
                                let ix = r.intersection(o.insetBy(dx: -gap / 2, dy: -gap / 2))
                                if !ix.isNull { overlap += ix.width * ix.height }
                            }
                        }
                        let dx = x - pts[i].x, dy = y - pts[i].y
                        let score = overlap * 400 + dx * dx + dy * dy
                        if score < bestScore { bestScore = score; best = p }
                    }
                    y += step
                }
                x += step
            }
            let chosen = best ?? CGPoint(x: min(max(pts[i].x, 56), w - 56), y: min(max(pts[i].y, yTop), yBot))
            finalPts[i] = chosen
            placedRects.append(contentsOf: nodeRects(e, at: chosen, canvasWidth: w, orbSize: os))
        }
        pts = finalPts
        
        var positions: [String: CGPoint] = [:]
        for (n, id) in ids.enumerated() { positions[id] = pts[n] }
        self.nodePositions = positions
    }
    
    private func actorAnchorPoint(for actor: KnowledgeActor, center: CGPoint) -> CGPoint {
        switch actor {
        case .user:
            return center
        case .maya:
            return CGPoint(x: center.x - 130, y: center.y - 120)
        case .theo:
            return CGPoint(x: center.x + 130, y: center.y - 120)
        case .alex:
            return CGPoint(x: center.x + 130, y: center.y + 110)
        case .sam:
            return CGPoint(x: center.x - 130, y: center.y + 110)
        case .yaya:
            return CGPoint(x: center.x, y: center.y - 90)
        }
    }
    
    private func focusNode(_ id: String, in size: CGSize) {
        guard let pt = nodePositions[id] else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            panOffset = CGSize(width: center.x - pt.x, height: center.y - pt.y)
            zoomScale = 1.3
        }
    }
    
    private func startEyeGazeTimer() {
        Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { _ in
            Task { @MainActor in
                blinkToggle.toggle()
                if let last = entries.last, let pt = nodePositions[last.id] {
                    // Normalize gaze vector toward last node
                    let dx = max(-1.0, min(1.0, (pt.x - 200) / 200))
                    let dy = max(-1.0, min(1.0, (pt.y - 350) / 250))
                    withAnimation(.easeInOut(duration: 0.6)) {
                        eyeGazeVector = CGSize(width: dx * 4.0, height: dy * 4.0)
                    }
                }
            }
        }
    }
}

// MARK: - Node Detail Sheet
public struct NodeDetailSheet: View {
    public let entry: KnowledgeEntry
    public let allEntries: [KnowledgeEntry]
    public var onOpenKnowledge: (String) -> Void
    public var onFocusNode: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Top status icon & type
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(entry.type.badgeColor.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Text(entry.type.symbolString)
                            .font(Font.yaya(size: 16, weight: .bold))
                            .foregroundStyle(entry.type.badgeColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.type.accessibilityLabel.uppercased())
                            .font(Font.yaya(size: 11, weight: .bold))
                            .foregroundStyle(entry.type.badgeColor)
                        
                        Text("\(entry.actor.displayName) · \(entry.dateDisplay)")
                            .font(Font.yaya(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Full Entry Text
                Text(entry.text)
                    .font(.system(size: 19, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Media preview snippet if any
                if let media = entry.media {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            if media.linkURL != nil {
                                Image(systemName: "link")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            Text(media.source)
                                .font(Font.yaya(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.primary.opacity(0.08)))
                            
                            Text(media.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                        
                        if let snippet = media.previewSnippet {
                            Text(snippet)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.primary.opacity(0.04))
                    )
                }
                
                Divider()
                
                // Builds on List
                if !entry.links.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BUILDS ON")
                            .font(Font.yaya(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        ForEach(entry.links) { link in
                            if let linkedEntry = allEntries.first(where: { $0.id == link.targetEntryID }) {
                                Button {
                                    dismiss()
                                    onFocusNode(linkedEntry.id)
                                } label: {
                                    HStack(spacing: 8) {
                                        Text(linkedEntry.type.symbolString)
                                            .font(Font.yaya(size: 12, weight: .bold))
                                            .foregroundStyle(linkedEntry.type.badgeColor)
                                        
                                        Text(linkedEntry.text)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                // Built on by List
                let builtOnBy = allEntries.filter { $0.links.contains(where: { $0.targetEntryID == entry.id }) }
                if !builtOnBy.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BUILT ON BY")
                            .font(Font.yaya(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        ForEach(builtOnBy) { child in
                            Button {
                                dismiss()
                                onFocusNode(child.id)
                            } label: {
                                HStack(spacing: 8) {
                                    Text(child.type.symbolString)
                                        .font(Font.yaya(size: 12, weight: .bold))
                                        .foregroundStyle(child.type.badgeColor)
                                    
                                    Text(child.text)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer().frame(height: 12)
                
                // Open in Insights Button
                Button {
                    onOpenKnowledge(entry.id)
                } label: {
                    HStack {
                        Image(systemName: "books.vertical.fill")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Open in Insights")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(colorScheme == .dark ? Color.white : Color(red: 0.125, green: 0.122, blue: 0.125))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
    }
}

// MARK: - Friction Resolution Sheet (Teammate Frame M4)
public struct FrictionResolutionSheet: View {
    public let entry: KnowledgeEntry
    public var onResolve: (KnowledgeResolution) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header badge
                HStack(spacing: 6) {
                    Text("⚡")
                        .font(.system(size: 12))
                    Text("FRICTION · 2 VIEWS")
                        .font(Font.yaya(size: 11, weight: .bold))
                        .foregroundStyle(KnowledgeEntryType.counterpoint.badgeColor)
                        .tracking(0.6)
                }
                
                Text("Which one leads your story?")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                
                // Card 1: YOU SAID
                VStack(alignment: .leading, spacing: 8) {
                    Text("YOU SAID")
                        .font(Font.yaya(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    Text(entry.text)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Text("From your intro, session 2")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.primary.opacity(0.04))
                )
                
                // vs label
                HStack {
                    Spacer()
                    Text("vs")
                        .font(Font.yaya(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                
                // Card 2: YA YA SUGGESTED
                VStack(alignment: .leading, spacing: 8) {
                    Text("YA YA SUGGESTED")
                        .font(Font.yaya(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.primary)
                        
                        Text(entry.frictionSuggestion ?? "you design for stressful moments")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                    
                    Text("Based on your fraud alert flow and onboarding study")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.primary.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                )
                
                Text("Both can be true. Resolving friction reveals which idea anchors the throughline.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // 4 Action Buttons
                VStack(spacing: 10) {
                    // 1. Keep mine (Primary)
                    Button {
                        onResolve(.keptMine)
                        dismiss()
                    } label: {
                        Text("Keep mine")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(colorScheme == .dark ? Color.white : Color(red: 0.125, green: 0.122, blue: 0.125))
                            )
                    }
                    .buttonStyle(.plain)
                    
                    HStack(spacing: 10) {
                        // 2. Use YaYa's
                        Button {
                            onResolve(.usedSuggestion)
                            dismiss()
                        } label: {
                            Text("Use YaYa's")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        
                        // 3. Keep both
                        Button {
                            onResolve(.keptBoth)
                            dismiss()
                        } label: {
                            Text("Keep both")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // 4. Not now
                    Button {
                        dismiss()
                    } label: {
                        Text("Not now")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
    }
}
