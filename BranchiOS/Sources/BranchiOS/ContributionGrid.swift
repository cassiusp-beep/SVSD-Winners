import SwiftUI

// MARK: - Constants
public enum ContributionGridConstants {
    public static let takeawayTimeSliceSeconds: Double = 2.0
    public static let cellSize: CGFloat = 15.0
    public static let cellCornerRadius: CGFloat = 4.0
    public static let cellGap: CGFloat = 5.0
    public static let rowHeight: CGFloat = 28.0
    public static let rowGap: CGFloat = 6.0
    public static let waveDuration: Double = 3.0
    public static let waveWidth: Double = 0.20
    public static let waveBrightnessLift: Double = 0.15
}

// MARK: - Action Event Model
public struct GridDeclaredAction: Identifiable, Sendable {
    public let id = UUID()
    public let actionType: TakeawayAction
    public let timestamp: Double
    
    public init(actionType: TakeawayAction, timestamp: Double) {
        self.actionType = actionType
        self.timestamp = timestamp
    }
}

// MARK: - Cell Context for Knowledge Handoff
public struct ContributionCellContext: Identifiable, Equatable, Sendable {
    public var id: String { "\(agentId)_\(sliceIndex)" }
    public let agentId: Int
    public let agentName: String
    public let agentSprite: BranchSprite
    public let sliceIndex: Int
    public let startTime: Double
    public let endTime: Double
    public let actions: [TakeawayAction: Int]
    
    public var timeRangeString: String {
        let startMin = Int(startTime) / 60
        let startSec = Int(startTime) % 60
        let endMin = Int(endTime) / 60
        let endSec = Int(endTime) % 60
        return String(format: "%d:%02d to %d:%02d", startMin, startSec, endMin, endSec)
    }
    
    public var actionsSummary: String {
        let parts = actions.compactMap { (action, count) -> String? in
            guard count > 0 else { return nil }
            return action.label(for: count)
        }
        return parts.isEmpty ? "No actions" : parts.joined(separator: ", ")
    }
}

// MARK: - Agent Grid Row Data
public struct AgentGridRow: Identifiable {
    public let id: Int // agentId
    public let name: String
    public let role: String
    public let sprite: BranchSprite
    public let cells: [ContributionCellContext]
    
    public var totalActionsCount: Int {
        cells.reduce(0) { total, cell in
            total + cell.actions.values.reduce(0, +)
        }
    }
    
    public var rowSummary: String {
        var tallies: [TakeawayAction: Int] = [:]
        for cell in cells {
            for (action, count) in cell.actions {
                tallies[action, default: 0] += count
            }
        }
        let priorityOrder: [TakeawayAction] = [.friction, .reframes, .questions, .agreements]
        let segments = priorityOrder.compactMap { action -> String? in
            guard let count = tallies[action], count > 0 else { return nil }
            return action.label(for: count)
        }
        return segments.isEmpty ? "\(name): No declared actions" : "\(name): " + segments.joined(separator: ", ")
    }
}

// MARK: - Takeaways Contribution Grid View
public struct TakeawaysContributionGridView: View {
    public let rows: [AgentGridRow]
    public let sessionDuration: Double
    public let timeSlice: Double
    public let onSelectCell: (ContributionCellContext) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var replayProgressColumns: Int = 0
    @State private var isReplayDone: Bool = false
    @State private var spriteNodOffsets: [CGFloat] = [0, 0, 0, 0]
    
    public init(
        rows: [AgentGridRow],
        sessionDuration: Double = 28.0,
        timeSlice: Double = ContributionGridConstants.takeawayTimeSliceSeconds,
        onSelectCell: @escaping (ContributionCellContext) -> Void
    ) {
        self.rows = rows
        self.sessionDuration = sessionDuration
        self.timeSlice = timeSlice
        self.onSelectCell = onSelectCell
    }
    
    private var totalColumns: Int {
        max(1, Int(ceil(sessionDuration / timeSlice)))
    }
    
    private var timeAxisEndString: String {
        let mins = Int(sessionDuration) / 60
        let secs = Int(sessionDuration) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    public var body: some View {
        TimelineView(.animation(paused: reduceMotion || !isReplayDone)) { timeline in
            let currentTime = timeline.date.timeIntervalSinceReferenceDate
            let waveHead = (currentTime / ContributionGridConstants.waveDuration).truncatingRemainder(dividingBy: 1.0)
            
            VStack(alignment: .leading, spacing: 10) {
                // Main Grid Layout: Pinned left agent column + horizontally scrolling cells
                HStack(alignment: .top, spacing: 12) {
                    // Left Pinned Agent Column (Sprite + Name)
                    VStack(alignment: .leading, spacing: ContributionGridConstants.rowGap) {
                        ForEach(0..<rows.count, id: \.self) { rowIndex in
                            let row = rows[rowIndex]
                            HStack(spacing: 8) {
                                SpriteView(sprite: row.sprite, isBlinking: false, showsArms: false)
                                    .frame(width: 28, height: 28)
                                    .offset(y: spriteNodOffsets.indices.contains(rowIndex) ? spriteNodOffsets[rowIndex] : 0)
                                
                                Text(row.name)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                    .frame(width: 48, alignment: .leading)
                            }
                            .frame(height: ContributionGridConstants.rowHeight)
                            .accessibilityHidden(true)
                        }
                    }
                    
                    // Horizontally Scrolling Contribution Cells
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: ContributionGridConstants.rowGap) {
                            ForEach(0..<rows.count, id: \.self) { rowIndex in
                                let row = rows[rowIndex]
                                HStack(spacing: ContributionGridConstants.cellGap) {
                                    ForEach(0..<totalColumns, id: \.self) { colIndex in
                                        let cell = (colIndex < row.cells.count) ? row.cells[colIndex] : nil
                                        let isVisible = reduceMotion || (colIndex < replayProgressColumns)
                                        
                                        cellView(
                                            cell: cell,
                                            sprite: row.sprite,
                                            colIndex: colIndex,
                                            isVisible: isVisible,
                                            waveHead: waveHead
                                        )
                                    }
                                }
                                .frame(height: ContributionGridConstants.rowHeight)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel(row.rowSummary)
                            }
                        }
                    }
                }
                
                // Light Time Axis: 0:00 on the left, end time on the right
                HStack {
                    // Align start with left margin of the grid cells
                    Spacer().frame(width: 96)
                    Text("0:00")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(timeAxisEndString)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .padding(.trailing, 16)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            startArrivalReplay()
        }
    }
    
    // MARK: - Cell View
    @ViewBuilder
    private func cellView(
        cell: ContributionCellContext?,
        sprite: BranchSprite,
        colIndex: Int,
        isVisible: Bool,
        waveHead: Double
    ) -> some View {
        let actionCount = cell?.actions.values.reduce(0, +) ?? 0
        let isActive = actionCount > 0
        
        let intensityOpacity: Double = {
            switch actionCount {
            case 0: return 0.0
            case 1: return 0.30
            case 2: return 0.55
            case 3: return 0.80
            default: return 1.00
            }
        }()
        
        // Wave brightness lift: subtle 10-15% passing sweep over active cells
        let waveLift: Double = {
            guard isReplayDone, !reduceMotion, isActive else { return 0.0 }
            let normalizedCol = Double(colIndex) / Double(max(1, totalColumns - 1))
            let dist = abs(normalizedCol - waveHead)
            let wrappedDist = min(dist, 1.0 - dist)
            if wrappedDist < ContributionGridConstants.waveWidth {
                let factor = cos(wrappedDist / ContributionGridConstants.waveWidth * (.pi / 2.0))
                return factor * ContributionGridConstants.waveBrightnessLift
            }
            return 0.0
        }()
        
        let emptyColor = colorScheme == .dark
            ? Color.white.opacity(0.10)
            : Color.black.opacity(0.07)
        
        ZStack {
            // Background neutral square for empty/base cell
            RoundedRectangle(cornerRadius: ContributionGridConstants.cellCornerRadius, style: .continuous)
                .fill(emptyColor)
            
            // Active cell layer with agent's gradient at specified intensity
            if isActive {
                RoundedRectangle(cornerRadius: ContributionGridConstants.cellCornerRadius, style: .continuous)
                    .fill(sprite.takeawayGradient(for: colorScheme))
                    .opacity(min(1.0, intensityOpacity + waveLift))
            }
        }
        .frame(width: ContributionGridConstants.cellSize, height: ContributionGridConstants.cellSize)
        .opacity(isVisible ? 1.0 : 0.0)
        .scaleEffect(isVisible ? 1.0 : 0.4)
        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: isVisible)
        .contentShape(Rectangle())
        .onTapGesture {
            if let cell = cell, isActive {
                onSelectCell(cell)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            isActive && cell != nil
                ? "\(cell!.agentName), \(cell!.timeRangeString), \(cell!.actionsSummary)"
                : "Empty time slice"
        )
        .accessibilityHint(isActive ? "Opens in Knowledge." : "")
        .accessibilityAddTraits(isActive ? .isButton : [])
    }
    
    // MARK: - Replay Cascade & Staggered Agree Animation
    private func startArrivalReplay() {
        if reduceMotion {
            replayProgressColumns = totalColumns
            isReplayDone = true
            return
        }
        
        replayProgressColumns = 0
        isReplayDone = false
        spriteNodOffsets = [0, 0, 0, 0]
        
        let totalDuration: Double = 1.2
        let stepInterval = totalDuration / Double(max(1, totalColumns))
        
        for col in 1...totalColumns {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(col) * stepInterval) {
                withAnimation(.spring(response: 0.24, dampingFraction: 0.75)) {
                    self.replayProgressColumns = col
                }
            }
        }
        
        // After grid completes, trigger staggered Agree gesture for the 4 pinned sprites
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration + 0.05) {
            self.isReplayDone = true
            for (idx, _) in self.rows.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx) * 0.15) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.50)) {
                        if self.spriteNodOffsets.indices.contains(idx) {
                            self.spriteNodOffsets[idx] = 4.0
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                            if self.spriteNodOffsets.indices.contains(idx) {
                                self.spriteNodOffsets[idx] = 0.0
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Profile Session History Grid View (GitHub Calendar: 7 Days x 8 Weeks)
public struct ProfileHistoryGridView: View {
    public let historyDays: [Int] // 56 counts (0 = Mon 8 weeks ago, 55 = Today)
    public let userSprite: BranchSprite
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let numWeeks = 8
    private let numDaysPerWeek = 7
    
    public var headerTitle: String = "SESSIONS"
    
    public init(historyDays: [Int], userSprite: BranchSprite, headerTitle: String = "SESSIONS") {
        self.historyDays = historyDays
        self.userSprite = userSprite
        self.headerTitle = headerTitle
    }
    
    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { timeline in
            let currentTime = timeline.date.timeIntervalSinceReferenceDate
            let waveHead = (currentTime / ContributionGridConstants.waveDuration).truncatingRemainder(dividingBy: 1.0)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    if headerTitle == "SESSIONS" {
                        Text("SESSIONS")
                            .font(Font.yaya(size: 13, weight: .bold))
                            .foregroundStyle(.primary)
                            .tracking(0.5)
                    } else {
                        Text(headerTitle)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Last 8 weeks")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                }
                
                // 7 Rows (Days) x 8 Columns (Weeks)
                HStack(spacing: ContributionGridConstants.cellGap) {
                    // Day of week labels (M, W, F)
                    VStack(alignment: .leading, spacing: ContributionGridConstants.cellGap) {
                        Text("M").font(.system(size: 9, weight: .bold)).foregroundStyle(.tertiary)
                            .frame(height: ContributionGridConstants.cellSize)
                        Text("").frame(height: ContributionGridConstants.cellSize)
                        Text("W").font(.system(size: 9, weight: .bold)).foregroundStyle(.tertiary)
                            .frame(height: ContributionGridConstants.cellSize)
                        Text("").frame(height: ContributionGridConstants.cellSize)
                        Text("F").font(.system(size: 9, weight: .bold)).foregroundStyle(.tertiary)
                            .frame(height: ContributionGridConstants.cellSize)
                        Text("").frame(height: ContributionGridConstants.cellSize)
                        Text("S").font(.system(size: 9, weight: .bold)).foregroundStyle(.tertiary)
                            .frame(height: ContributionGridConstants.cellSize)
                    }
                    .accessibilityHidden(true)
                    
                    // Columns of Weeks
                    ForEach(0..<numWeeks, id: \.self) { week in
                        VStack(spacing: ContributionGridConstants.cellGap) {
                            ForEach(0..<numDaysPerWeek, id: \.self) { day in
                                let index = week * numDaysPerWeek + day
                                let count = (index < historyDays.count) ? historyDays[index] : 0
                                let isActive = count > 0
                                
                                let intensityOpacity: Double = {
                                    switch count {
                                    case 0: return 0.0
                                    case 1...2: return 0.30
                                    case 3...4: return 0.55
                                    case 5...7: return 0.80
                                    default: return 1.00
                                    }
                                }()
                                
                                let waveLift: Double = {
                                    guard !reduceMotion, isActive else { return 0.0 }
                                    let normalizedCol = Double(week) / Double(numWeeks - 1)
                                    let dist = abs(normalizedCol - waveHead)
                                    let wrappedDist = min(dist, 1.0 - dist)
                                    if wrappedDist < ContributionGridConstants.waveWidth {
                                        let factor = cos(wrappedDist / ContributionGridConstants.waveWidth * (.pi / 2.0))
                                        return factor * ContributionGridConstants.waveBrightnessLift
                                    }
                                    return 0.0
                                }()
                                
                                let emptyColor = colorScheme == .dark
                                    ? Color.white.opacity(0.10)
                                    : Color.black.opacity(0.07)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: ContributionGridConstants.cellCornerRadius, style: .continuous)
                                        .fill(emptyColor)
                                    
                                    if isActive {
                                        RoundedRectangle(cornerRadius: ContributionGridConstants.cellCornerRadius, style: .continuous)
                                            .fill(userSprite.takeawayGradient(for: colorScheme))
                                            .opacity(min(1.0, intensityOpacity + waveLift))
                                    }
                                }
                                .frame(width: ContributionGridConstants.cellSize, height: ContributionGridConstants.cellSize)
                                .accessibilityLabel("Week \(week + 1), Day \(day + 1): \(count) actions")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
            )
            .padding(.horizontal, 20)
        }
    }
}
