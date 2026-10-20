import SwiftUI

// MARK: - Session Scope Enum
public enum SessionScope: String, CaseIterable, Identifiable, Sendable {
    case solo = "Solo"
    case group = "Group"
    public var id: String { rawValue }
}

// MARK: - Teammate Thinker Model
public struct TeammateThinker: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let sprite: BranchSprite
    public let thinkerTitle: String
    public let role: String
    public let hexLight: String
    public let hexDark: String
    public let momentCount: Int
    
    public func accentColor(for colorScheme: ColorScheme) -> Color {
        Color(hex: colorScheme == .dark ? hexDark : hexLight)
    }
    
    public static let team: [TeammateThinker] = [
        TeammateThinker(
            id: "cash",
            name: "Cash",
            sprite: .cloud,
            thinkerTitle: "Cloud Thinker",
            role: "Synthesizer · Vision",
            hexLight: "7E5FA6",
            hexDark: "A083BC",
            momentCount: 4
        ),
        TeammateThinker(
            id: "bhargs",
            name: "Bhargs",
            sprite: .bloom,
            thinkerTitle: "Bloom Thinker",
            role: "Architectural · Systems",
            hexLight: "C9652F",
            hexDark: "E39A57",
            momentCount: 3
        ),
        TeammateThinker(
            id: "alex",
            name: "Alex",
            sprite: .prism,
            thinkerTitle: "Prism Thinker",
            role: "Analytical · Product",
            hexLight: "2F7FA3",
            hexDark: "4598BB",
            momentCount: 4
        ),
        TeammateThinker(
            id: "naheel",
            name: "Naheel",
            sprite: .spark,
            thinkerTitle: "Spark Thinker",
            role: "Catalyst · Strategy",
            hexLight: "5E8A56",
            hexDark: "8AAE83",
            momentCount: 3
        )
    ]
}

// MARK: - Scope Switcher Pill
public struct ScopeSwitcherPill: View {
    @Binding public var scope: SessionScope
    @Environment(\.colorScheme) private var colorScheme
    
    public init(scope: Binding<SessionScope>) {
        self._scope = scope
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(SessionScope.allCases) { item in
                let isSelected = scope == item
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                        scope = item
                    }
                } label: {
                    Text(item.rawValue)
                        .font(.yaya(size: 12, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? (colorScheme == .dark ? Color.black : Color.white) : Color.primary.opacity(0.65))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Group {
                                if isSelected {
                                    Capsule()
                                        .fill(colorScheme == .dark ? Color.white : Color(red: 0.137, green: 0.122, blue: 0.125))
                                } else {
                                    Color.clear
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityLabel("\(item.rawValue) view")
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        .padding(3)
        .background(
            Capsule()
                .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05))
        )
        .overlay(
            Capsule()
                .stroke(colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.10), lineWidth: 0.8)
        )
    }
}

// MARK: - Team Receipt View
public struct TeamReceiptView: View {
    @Bindable var store: DemoStore
    public let width: CGFloat
    public let topInset: CGFloat
    public let bottomInset: CGFloat
    public let rows: [AgentGridRow]
    public let sessionArtifacts: [TakeawaysArtifact]
    public let sessionDuration: Double
    public let frictionCount: Int
    public let futureOpportunitiesCount: Int
    public let artifactsAddedCount: Int
    public let sessionQuestionsCount: Int
    public let sessionAgreementsCount: Int
    
    @Binding public var sessionScope: SessionScope
    @Binding public var receiptIsometric: Bool
    
    public let onSelectCell: (ContributionCellContext) -> Void
    public let onDismiss: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTeammate: String? = nil
    
    public init(
        store: DemoStore,
        width: CGFloat,
        topInset: CGFloat,
        bottomInset: CGFloat,
        rows: [AgentGridRow],
        sessionArtifacts: [TakeawaysArtifact],
        sessionDuration: Double,
        frictionCount: Int,
        futureOpportunitiesCount: Int,
        artifactsAddedCount: Int,
        sessionQuestionsCount: Int,
        sessionAgreementsCount: Int,
        sessionScope: Binding<SessionScope>,
        receiptIsometric: Binding<Bool>,
        onSelectCell: @escaping (ContributionCellContext) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.store = store
        self.width = width
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.rows = rows
        self.sessionArtifacts = sessionArtifacts
        self.sessionDuration = sessionDuration
        self.frictionCount = frictionCount
        self.futureOpportunitiesCount = futureOpportunitiesCount
        self.artifactsAddedCount = artifactsAddedCount
        self.sessionQuestionsCount = sessionQuestionsCount
        self.sessionAgreementsCount = sessionAgreementsCount
        self._sessionScope = sessionScope
        self._receiptIsometric = receiptIsometric
        self.onSelectCell = onSelectCell
        self.onDismiss = onDismiss
        
        if CommandLine.arguments.contains("-receiptHighlight") {
            _selectedTeammate = State(initialValue: "Bhargs")
        }
    }
    
    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: Date()).uppercased()
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: 1. Header & Share Action
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .center, spacing: 12) {
                        Text("Team Receipt")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundStyle(.primary)
                        
                        Spacer(minLength: 0)
                        
                        ExportShareButton(store: store, scope: .session)
                    }
                    
                    // Metadata eyebrow line (Duration · Project · Date)
                    HStack(spacing: 8) {
                        Text("12 MIN")
                            .font(.yaya(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Text("·")
                            .font(.yaya(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Text(store.activeProject.name.uppercased())
                            .font(.yaya(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Text("·")
                            .font(.yaya(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Text(formattedDateString)
                            .font(.yaya(size: 11, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    
                    // Scope Switcher (Solo / Group)
                    HStack {
                        ScopeSwitcherPill(scope: $sessionScope)
                        Spacer()
                        
                        if let selected = selectedTeammate {
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                    selectedTeammate = nil
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Showing \(selected)")
                                        .font(.yaya(size: 10, weight: .semibold))
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 11))
                                }
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.primary.opacity(0.06)))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, topInset + ScreenHeaderLayout.topSpacing)
                
                // MARK: 2. Teammates Thinker Cards
                VStack(alignment: .leading, spacing: 10) {
                    Text("TEAM PERSPECTIVES")
                        .font(.yaya(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TeammateThinker.team) { teammate in
                                let isSelected = selectedTeammate == teammate.name
                                let accent = teammate.accentColor(for: colorScheme)
                                
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                                        if selectedTeammate == teammate.name {
                                            selectedTeammate = nil
                                        } else {
                                            selectedTeammate = teammate.name
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        // Profile Thinker Sprite
                                        ZStack {
                                            Circle()
                                                .fill(accent.opacity(colorScheme == .dark ? 0.22 : 0.14))
                                                .frame(width: 38, height: 38)
                                            
                                            SpriteView(sprite: teammate.sprite, isBlinking: false, showsArms: false)
                                                .frame(width: 24, height: 24)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 5) {
                                                Text(teammate.name)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundStyle(.primary)
                                                
                                                Circle()
                                                    .fill(accent)
                                                    .frame(width: 6, height: 6)
                                            }
                                            
                                            Text(teammate.thinkerTitle)
                                                .font(.yaya(size: 10, weight: .medium))
                                                .foregroundStyle(.secondary)
                                            
                                            Text("\(teammate.momentCount) moments")
                                                .font(.yaya(size: 9, weight: .semibold))
                                                .foregroundStyle(accent)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(colorScheme == .dark ? Color(white: 0.10) : Color(white: 0.97))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(
                                                isSelected ? accent : (colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08)),
                                                lineWidth: isSelected ? 2.0 : 0.8
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(teammate.name), \(teammate.thinkerTitle), \(teammate.momentCount) moments. Tap to filter.")
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // MARK: 3. Stats Bento Grid (Strictly NO NEXT STEP CARD)
                VStack(alignment: .leading, spacing: 10) {
                    Text("SESSION TAKEAWAYS")
                        .font(.yaya(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 10) {
                        // Top Hero Bento Card: Agreed Emergent Idea
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("AGREED · YOUR IDEA")
                                    .font(.yaya(size: 9.5, weight: .bold))
                                    .foregroundStyle(Color(hex: "0D8F5B"))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Color(hex: "0D8F5B").opacity(0.12))
                                    .clipShape(Capsule())
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(hex: "0D8F5B"))
                            }
                            
                            Text("One person first, teams later")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundStyle(.primary)
                            
                            Text("Agreed today in session with Naheel, Alex and Cash")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(colorScheme == .dark ? Color(white: 0.08) : Color(white: 0.96))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(colorScheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.08), lineWidth: 0.8)
                        )
                        .padding(.horizontal, 20)
                        
                        // 3-Column Bento Metric Row
                        HStack(spacing: 10) {
                            // Bento Metric 1: Resolved Friction
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(frictionCount)")
                                    .font(.system(size: 26, weight: .bold, design: .default))
                                    .foregroundStyle(.primary)
                                
                                Text("FRICTION")
                                    .font(.yaya(size: 9, weight: .bold))
                                    .foregroundStyle(Color(hex: "E23D28"))
                                
                                Text("Granola, but for teams")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(colorScheme == .dark ? Color(white: 0.08) : Color(white: 0.96))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(colorScheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.08), lineWidth: 0.8)
                            )
                            
                            // Bento Metric 2: Artifacts Added
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(artifactsAddedCount)")
                                    .font(.system(size: 26, weight: .bold, design: .default))
                                    .foregroundStyle(.primary)
                                
                                Text("ARTIFACTS")
                                    .font(.yaya(size: 9, weight: .bold))
                                    .foregroundStyle(Color(hex: "7E5FA6"))
                                
                                Text("Whiteboards & audio clips")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(colorScheme == .dark ? Color(white: 0.08) : Color(white: 0.96))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(colorScheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.08), lineWidth: 0.8)
                            )
                            
                            // Bento Metric 3: Open Question (Dashed block styling)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(sessionQuestionsCount)")
                                    .font(.system(size: 26, weight: .bold, design: .default))
                                    .foregroundStyle(.primary)
                                
                                Text("OPEN QUESTION")
                                    .font(.yaya(size: 9, weight: .bold))
                                    .foregroundStyle(Color(hex: "2F7FA3"))
                                
                                Text("Dashed timeline block")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(colorScheme == .dark ? Color(white: 0.08) : Color(white: 0.96))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(
                                        Color(hex: "2F7FA3").opacity(0.7),
                                        style: StrokeStyle(lineWidth: 1.2, dash: [4, 3])
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // MARK: 4. Contribution Timeline Strip
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("CONTRIBUTION TIMELINE")
                            .font(.yaya(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("Tap block for details")
                            .font(.yaya(size: 9, weight: .medium))
                            .foregroundStyle(.secondary.opacity(0.7))
                    }
                    .padding(.horizontal, 20)
                    
                    // The Grid (defaults to FLAT)
                    IsometricContributionGridView(
                        rows: rows,
                        sessionDuration: sessionDuration,
                        timeSlice: ContributionGridConstants.takeawayTimeSliceSeconds,
                        width: width,
                        maxHeight: 280,
                        highlightedAgent: selectedTeammate,
                        isometric: receiptIsometric,
                        playsArrival: false,
                        artifacts: sessionArtifacts,
                        onSelectCell: onSelectCell
                    )
                    .frame(width: width, height: 280)
                    
                    // FLAT / ISOMETRIC toggle
                    GridViewModeToggle(isometric: receiptIsometric) { iso in
                        TakeawaysViewMemory.receiptIsometric = iso
                        receiptIsometric = iso
                    }
                    .frame(width: width, height: 44)
                }
                
                // Clearance for floating up-chevron and tab bar
                Color.clear.frame(height: 130 + bottomInset)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // Up-chevron return button matching Solo Takeaways (sits above tab bar)
            Button {
                onDismiss()
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
            .padding(.trailing, 24)
            .padding(.bottom, bottomInset + 68)
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
