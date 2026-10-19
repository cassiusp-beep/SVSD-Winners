import SwiftUI

// MARK: - Thinking Family Model
public enum ThinkingFamily: String, CaseIterable, Sendable {
    case cloud = "Cloud"
    case spark = "Spark"
    case prism = "Prism"
    case bloom = "Bloom"
    
    public var axisName: String {
        switch self {
        case .cloud: return "SYSTEMATIC"
        case .spark: return "TINKERING"
        case .prism: return "CREATIVE"
        case .bloom: return "OBSERVANT"
        }
    }
    
    public var pluralName: String {
        switch self {
        case .cloud: return "Clouds"
        case .spark: return "Sparks"
        case .prism: return "Prisms"
        case .bloom: return "Blooms"
        }
    }
    
    public var sprite: BranchSprite {
        switch self {
        case .cloud: return .cloud
        case .spark: return .spark
        case .prism: return .prism
        case .bloom: return .bloom
        }
    }
    
    public var oneLineDescription: String {
        switch self {
        case .cloud:
            return "You lay ideas out as systems first, then pressure-test them with people."
        case .spark:
            return "You think by making. Ideas get built before they get explained."
        case .prism:
            return "You turn ideas around until they show a new side."
        case .bloom:
            return "You notice first. Your questions shape where the room goes."
        }
    }
}

// MARK: - Radar Values
public struct ThinkingRadarValues: Equatable, Sendable {
    public var systematic: Double  // Processing
    public var tinkering: Double   // Building
    public var creative: Double    // Reframing
    public var observant: Double   // Questions
    
    public init(systematic: Double, tinkering: Double, creative: Double, observant: Double) {
        self.systematic = systematic
        self.tinkering = tinkering
        self.creative = creative
        self.observant = observant
    }
    
    public var strongestFamily: ThinkingFamily {
        let maxVal = max(systematic, tinkering, creative, observant)
        if systematic == maxVal { return .cloud }
        if tinkering == maxVal { return .spark }
        if creative == maxVal { return .prism }
        return .bloom
    }
}

// MARK: - Radar Calculations
public enum ThinkingRadarCalculator {
    public static func computeCurrentProcess(sessions: [SessionDeclaredActions]) -> ThinkingRadarValues {
        guard sessions.count >= 3 else {
            // Seeded demo values from original prompt
            return ThinkingRadarValues(systematic: 0.90, tinkering: 0.55, creative: 0.45, observant: 0.60)
        }
        
        let totalProcessing = sessions.reduce(0) { $0 + $1.processing }
        let totalBuilding = sessions.reduce(0) { $0 + $1.building }
        let totalReframing = sessions.reduce(0) { $0 + $1.reframing }
        let totalQuestions = sessions.reduce(0) { $0 + $1.questions }
        let total = totalProcessing + totalBuilding + totalReframing + totalQuestions
        guard total > 0 else {
            return ThinkingRadarValues(systematic: 0.90, tinkering: 0.55, creative: 0.45, observant: 0.60)
        }
        
        let rawSys = Double(totalProcessing) / Double(total)
        let rawTink = Double(totalBuilding) / Double(total)
        let rawCreat = Double(totalReframing) / Double(total)
        let rawObs = Double(totalQuestions) / Double(total)
        let maxRaw = max(rawSys, rawTink, rawCreat, rawObs)
        let scale = maxRaw > 0 ? (0.9 / maxRaw) : 1.0
        
        return ThinkingRadarValues(
            systematic: rawSys * scale,
            tinkering: rawTink * scale,
            creative: rawCreat * scale,
            observant: rawObs * scale
        )
    }
    
    public static func computeWhereHeading(sessions: [SessionDeclaredActions]) -> ThinkingRadarValues {
        guard sessions.count >= 3 else {
            // Seeded demo values from original prompt
            return ThinkingRadarValues(systematic: 0.50, tinkering: 0.40, creative: 0.85, observant: 0.65)
        }
        
        let recent3 = sessions.suffix(3)
        let totalProcessing = recent3.reduce(0) { $0 + $1.processing }
        let totalBuilding = recent3.reduce(0) { $0 + $1.building }
        let totalReframing = recent3.reduce(0) { $0 + $1.reframing }
        let totalQuestions = recent3.reduce(0) { $0 + $1.questions }
        let total = totalProcessing + totalBuilding + totalReframing + totalQuestions
        guard total > 0 else {
            return ThinkingRadarValues(systematic: 0.50, tinkering: 0.40, creative: 0.85, observant: 0.65)
        }
        
        let rawSys = Double(totalProcessing) / Double(total)
        let rawTink = Double(totalBuilding) / Double(total)
        let rawCreat = Double(totalReframing) / Double(total)
        let rawObs = Double(totalQuestions) / Double(total)
        let maxRaw = max(rawSys, rawTink, rawCreat, rawObs)
        let scale = maxRaw > 0 ? (0.9 / maxRaw) : 1.0
        
        return ThinkingRadarValues(
            systematic: rawSys * scale,
            tinkering: rawTink * scale,
            creative: rawCreat * scale,
            observant: rawObs * scale
        )
    }
}

// MARK: - Thinking Radar Chart View
public struct ThinkingRadarChartView: View {
    public let currentProcess: ThinkingRadarValues
    public let whereHeading: ThinkingRadarValues
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let chartRadius: CGFloat = 68.0
    
    public init(currentProcess: ThinkingRadarValues, whereHeading: ThinkingRadarValues) {
        self.currentProcess = currentProcess
        self.whereHeading = whereHeading
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background Guide Diamond Rings & Crosshairs
                Canvas { context, size in
                    let cx = size.width / 2.0
                    let cy = size.height / 2.0
                    
                    // Crosshairs
                    var vLine = Path()
                    vLine.move(to: CGPoint(x: cx, y: cy - chartRadius))
                    vLine.addLine(to: CGPoint(x: cx, y: cy + chartRadius))
                    context.stroke(vLine, with: .color(Color.primary.opacity(0.12)), lineWidth: 1)
                    
                    var hLine = Path()
                    hLine.move(to: CGPoint(x: cx - chartRadius, y: cy))
                    hLine.addLine(to: CGPoint(x: cx + chartRadius, y: cy))
                    context.stroke(hLine, with: .color(Color.primary.opacity(0.12)), lineWidth: 1)
                    
                    // Concentric Diamonds (0.33, 0.66, 1.0)
                    for level in [0.33, 0.66, 1.0] {
                        var diamond = Path()
                        let r = chartRadius * CGFloat(level)
                        diamond.move(to: CGPoint(x: cx, y: cy - r))
                        diamond.addLine(to: CGPoint(x: cx + r, y: cy))
                        diamond.addLine(to: CGPoint(x: cx, y: cy + r))
                        diamond.addLine(to: CGPoint(x: cx - r, y: cy))
                        diamond.closeSubpath()
                        
                        context.stroke(
                            diamond,
                            with: .color(Color.primary.opacity(0.14)),
                            style: StrokeStyle(lineWidth: 1, dash: [3, 3])
                        )
                    }
                    
                    // 1. Where You're Heading Polygon (Dashed Navy/Indigo)
                    var headingPath = Path()
                    let hP0 = CGPoint(x: cx, y: cy - chartRadius * CGFloat(whereHeading.systematic))
                    let hP1 = CGPoint(x: cx + chartRadius * CGFloat(whereHeading.tinkering), y: cy)
                    let hP2 = CGPoint(x: cx, y: cy + chartRadius * CGFloat(whereHeading.creative))
                    let hP3 = CGPoint(x: cx - chartRadius * CGFloat(whereHeading.observant), y: cy)
                    
                    headingPath.move(to: hP0)
                    headingPath.addLine(to: hP1)
                    headingPath.addLine(to: hP2)
                    headingPath.addLine(to: hP3)
                    headingPath.closeSubpath()
                    
                    let headingColor = Color(red: 0.35, green: 0.44, blue: 0.70)
                    context.stroke(
                        headingPath,
                        with: .color(headingColor),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                    )
                    
                    // Small markers for Heading vertices
                    for pt in [hP0, hP1, hP2, hP3] {
                        let rect = CGRect(x: pt.x - 2.5, y: pt.y - 2.5, width: 5, height: 5)
                        context.fill(Path(rect), with: .color(headingColor))
                    }
                    
                    // 2. Your Current Process Polygon (Solid Warm Amber Fill + Ink Stroke)
                    var currentPath = Path()
                    let cP0 = CGPoint(x: cx, y: cy - chartRadius * CGFloat(currentProcess.systematic))
                    let cP1 = CGPoint(x: cx + chartRadius * CGFloat(currentProcess.tinkering), y: cy)
                    let cP2 = CGPoint(x: cx, y: cy + chartRadius * CGFloat(currentProcess.creative))
                    let cP3 = CGPoint(x: cx - chartRadius * CGFloat(currentProcess.observant), y: cy)
                    
                    currentPath.move(to: cP0)
                    currentPath.addLine(to: cP1)
                    currentPath.addLine(to: cP2)
                    currentPath.addLine(to: cP3)
                    currentPath.closeSubpath()
                    
                    let fillColor = Color(red: 0.98, green: 0.78, blue: 0.52).opacity(colorScheme == .dark ? 0.35 : 0.50)
                    context.fill(currentPath, with: .color(fillColor))
                    
                    let strokeColor = (colorScheme == .dark ? Color.white : Color(red: 0.15, green: 0.12, blue: 0.14))
                    context.stroke(currentPath, with: .color(strokeColor), lineWidth: 2.0)
                    
                    // Vertex dots for Current Process
                    for pt in [cP0, cP1, cP2, cP3] {
                        let dot = Path(ellipseIn: CGRect(x: pt.x - 3, y: pt.y - 3, width: 6, height: 6))
                        context.fill(dot, with: .color(strokeColor))
                    }
                }
                .frame(width: 190, height: 190)
                
                // Axis Labels around the diamond
                // Top: SYSTEMATIC / Clouds
                VStack(spacing: 2) {
                    Text("SYSTEMATIC")
                        .font(Font.yaya(size: 9, weight: .bold))
                        .foregroundStyle(.primary)
                        .tracking(0.5)
                    HStack(spacing: 3) {
                        SpriteView(sprite: .cloud, isBlinking: false, showsArms: false)
                            .frame(width: 14, height: 14)
                        Text("Clouds")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .position(x: 125, y: 16)
                
                // Right: TINKERING / Sparks
                VStack(alignment: .leading, spacing: 2) {
                    Text("TINKERING")
                        .font(Font.yaya(size: 9, weight: .bold))
                        .foregroundStyle(.primary)
                        .tracking(0.5)
                    HStack(spacing: 3) {
                        SpriteView(sprite: .spark, isBlinking: false, showsArms: false)
                            .frame(width: 14, height: 14)
                        Text("Sparks")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .position(x: 215, y: 125)
                
                // Bottom: CREATIVE / Prisms
                VStack(spacing: 2) {
                    HStack(spacing: 3) {
                        SpriteView(sprite: .prism, isBlinking: false, showsArms: false)
                            .frame(width: 14, height: 14)
                        Text("Prisms")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    Text("CREATIVE")
                        .font(Font.yaya(size: 9, weight: .bold))
                        .foregroundStyle(.primary)
                        .tracking(0.5)
                }
                .position(x: 125, y: 234)
                
                // Left: OBSERVANT / Blooms
                VStack(alignment: .trailing, spacing: 2) {
                    Text("OBSERVANT")
                        .font(Font.yaya(size: 9, weight: .bold))
                        .foregroundStyle(.primary)
                        .tracking(0.5)
                    HStack(spacing: 3) {
                        SpriteView(sprite: .bloom, isBlinking: false, showsArms: false)
                            .frame(width: 14, height: 14)
                        Text("Blooms")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .position(x: 35, y: 125)
            }
            .frame(width: 250, height: 250)
            
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.98, green: 0.78, blue: 0.52))
                        .frame(width: 14, height: 7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(colorScheme == .dark ? Color.white : Color(red: 0.15, green: 0.12, blue: 0.14), lineWidth: 1)
                        )
                    Text("Your current process")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(Color(red: 0.35, green: 0.44, blue: 0.70), style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                        .frame(width: 14, height: 7)
                    Text("Where you're heading")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - Main ProfileView
public struct ProfileView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    public var onResetDemo: () -> Void = {}
    public var onSignUp: () -> Void = {}
    
    @Environment(\.colorScheme) private var colorScheme
    
    public init(store: DemoStore = DemoStore.shared, onResetDemo: @escaping () -> Void = {}, onSignUp: @escaping () -> Void = {}) {
        self.store = store
        self.onResetDemo = onResetDemo
        self.onSignUp = onSignUp
    }
    
    // Dynamically computed Thinking Style from session history
    private var currentProcessValues: ThinkingRadarValues {
        ThinkingRadarCalculator.computeCurrentProcess(sessions: store.completedSessionActions)
    }
    
    private var whereHeadingValues: ThinkingRadarValues {
        ThinkingRadarCalculator.computeWhereHeading(sessions: store.completedSessionActions)
    }
    
    private var strongestFamily: ThinkingFamily {
        currentProcessValues.strongestFamily
    }
    
    private var headingStrongestFamily: ThinkingFamily {
        whereHeadingValues.strongestFamily
    }
    
    private var shareText: String {
        // Requirement 2: "I'm a [Family] on Ya Ya. [ideas] ideas across [projects] projects."
        "I'm a \(strongestFamily.rawValue) on Ya Ya. 31 ideas across 2 projects."
    }
    
    private var userSprite: BranchSprite {
        if let hex = store.profile?.spriteColorHex {
            return BranchSprite.from(hex: hex)
        }
        return .cloud
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    Spacer().frame(height: 52)
                    
                    // Top Header: "You" on left, Share button on right (No appearance sun button!)
                    HStack(alignment: .center) {
                        Text("You")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        ShareLink(item: shareText) {
                            ZStack {
                                Circle()
                                    .fill(Color.primary.opacity(0.06))
                                    .frame(width: 38, height: 38)
                                
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Share profile")
                    }
                    .padding(.horizontal, 24)
                    .id("topSection")
                    
                    // Hero Sprite Banner Card
                    heroSpriteBanner
                        .padding(.horizontal, 20)
                    
                    // Name & Subtitle
                    VStack(spacing: 5) {
                        // Requirement 3: Name always comes from user's onboarding input and updates if edited. Never hard-code.
                        Text(store.profile?.fullName.isEmpty == false ? store.profile!.fullName : (store.isGuest ? "Guest" : "Your Name"))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Text("MDes @ Berkeley · Idea validation for SVSD")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)
                    
                    // Lock Divider: ONLY YOU SEE BELOW
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.secondary)
                        
                        Text("ONLY YOU SEE BELOW")
                            .font(Font.yaya(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        
                        Rectangle()
                            .fill(Color.primary.opacity(0.10))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    
                    // Stat Cards (31 IDEAS, 12 SOURCES, 2 PROJECTS)
                    statCardsSection
                        .padding(.horizontal, 20)
                    
                    // Requirement 1: SESSIONS History Grid Card (directly below stat cards; guests do not see)
                    if !store.isGuest {
                        sessionsHistoryCard
                            .padding(.horizontal, 20)
                            .id("sessionsCard")
                    }
                    
                    // Thinking Style & Radar Chart Card (Requirements 2 & 5)
                    thinkingStyleCard
                        .padding(.horizontal, 20)
                        .id("thinkingCard")
                    
                    // Bottom Settings & Navigation Links
                    bottomNavigationLinks
                        .padding(.horizontal, 20)
                    
                    // Reset Demo Button
                    Button {
                        onResetDemo()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14, weight: .bold))
                            Text("Reset Demo & Start Over")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color.red)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.red.opacity(0.10))
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 6)
                    .padding(.bottom, 96)
                    .id("bottomReset")
                }
            }
            .onAppear {
                if CommandLine.arguments.contains("-profileScrollThinking") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo("thinkingCard", anchor: .top)
                    }
                } else if CommandLine.arguments.contains("-profileScrollBottom") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        proxy.scrollTo("bottomReset", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - 1. Hero Sprite Banner
    private var heroSpriteBanner: some View {
        ZStack {
            // Soft warm wash
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.88, blue: 0.65).opacity(colorScheme == .dark ? 0.22 : 0.45),
                            Color(red: 0.95, green: 0.70, blue: 0.85).opacity(colorScheme == .dark ? 0.18 : 0.38)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 185)
            
            // Dashed inner placeholder border
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.18), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                .frame(height: 155)
                .padding(.horizontal, 14)
                .overlay {
                    SpriteView(sprite: userSprite, isBlinking: false, showsArms: false)
                        .frame(width: 98, height: 98)
                }
        }
    }
    
    // MARK: - 2. Stat Cards Section
    private var statCardsSection: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left Card: 31 IDEAS
            VStack(alignment: .leading, spacing: 6) {
                Text("31")
                    .font(.system(size: 54, weight: .bold, design: .serif))
                    .foregroundStyle(.primary)
                
                Text("IDEAS")
                    .font(Font.yaya(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                
                Spacer().frame(height: 10)
                
                Text("18 started on a whiteboard. Most land right after a crit.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 142)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            
            // Right Column: SOURCES & PROJECTS
            VStack(spacing: 12) {
                // Top Card: SOURCES
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("12")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("SOURCES")
                            .font(Font.yaya(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)
                    }
                    Text("Miro, Figma, 6 whiteboards")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
                
                // Bottom Card: PROJECTS
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("2")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("PROJECTS")
                            .font(Font.yaya(size: 9, weight: .bold))
                            .foregroundStyle(.secondary)
                            .tracking(0.5)
                    }
                    Text("Ya Ya, Critical design P3")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - 3. SESSIONS History Grid Card (Requirement 1)
    private var sessionsHistoryCard: some View {
        ProfileHistoryGridView(
            historyDays: store.sessionHistoryDays,
            userSprite: userSprite,
            headerTitle: "SESSIONS"
        )
        .allowsHitTesting(false)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - 4. Thinking Style & Radar Chart Card (Requirements 2 & 5)
    private var thinkingStyleCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            // "YOU ARE A" Header
            Text("YOU ARE A")
                .font(Font.yaya(size: 10, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(0.8)
            
            // Family Icon & Title (Strongest Axis)
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(red: 1.0, green: 0.92, blue: 0.75).opacity(colorScheme == .dark ? 0.25 : 0.60))
                        .frame(width: 46, height: 46)
                    
                    // Requirement 2: The icon next to it shows that family's sprite, not the user's own sprite
                    SpriteView(sprite: strongestFamily.sprite, isBlinking: false, showsArms: false)
                        .frame(width: 36, height: 36)
                }
                
                // Requirement 2: Title is the sprite family of the user's strongest axis
                Text(strongestFamily.rawValue)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.primary)
            }
            
            // Requirement 2: Rewrite the one-line description per family
            Text(strongestFamily.oneLineDescription)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.secondary)
                .lineSpacing(2)
            
            // Radar Chart
            ThinkingRadarChartView(
                currentProcess: currentProcessValues,
                whereHeading: whereHeadingValues
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            
            // Card 1: RIGHT NOW · [AXIS]
            VStack(alignment: .leading, spacing: 6) {
                Text("RIGHT NOW · \(strongestFamily.axisName)")
                    .font(Font.yaya(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                
                Text("You map before you decide")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color.primary.opacity(0.18))
                        .frame(width: 2)
                    Text("\"Perception → semantic knowledge → visual cognition → social interaction\"")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                        .lineSpacing(2)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
            )
            
            // Card 2: WHERE YOU'RE HEADING · [AXIS]
            VStack(alignment: .leading, spacing: 6) {
                Text("WHERE YOU'RE HEADING · \(headingStrongestFamily.axisName)")
                    .font(Font.yaya(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                
                Text("You're sketching characters lately")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Starting Sprite, Pixel Pusher and Creative Cloud were being sketched before any specs were finalized.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineSpacing(2)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.20), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
            )
        }
        .padding(18)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - 5. Bottom Navigation Links
    private var bottomNavigationLinks: some View {
        VStack(spacing: 10) {
            // Link 1: What Ya Ya has learned
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                        .frame(width: 36, height: 36)
                    Image(systemName: "circle.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("What Ya Ya has learned")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text("Something off? Forget it here.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            
            // Link 2: Settings
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                        .frame(width: 36, height: 36)
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Settings")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text("Ya Ya's help, sprite, voice, data, account")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
    }
}
