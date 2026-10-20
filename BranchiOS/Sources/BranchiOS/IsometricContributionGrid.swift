import SwiftUI

// MARK: - Constants (every isometric tunable lives here)
public enum TakeawaysIsoConstants {
    /// Rotation applied at t = 1 (flat grid is t = 0).
    public static let angle: Angle = .degrees(45)
    /// scaleY = 1 - compression * t.
    public static let compression: CGFloat = 0.32

    // Geometry, in units of the pitch p.
    /// Length of one 2s slice along a lane, as a fraction of p (smaller = shorter, squarer grid).
    public static let columnPitchFactor: CGFloat = 0.7
    public static let laneThickness: CGFloat = 1.15
    public static let laneGap: CGFloat = 0.85
    /// Gap between consecutive pieces along a lane.
    public static let alongGap: CGFloat = 0.26
    /// An active slab absorbs up to this many empty slices between two active runs.
    public static let bridgeEmptySlices: Int = 2
    /// All slabs share one low height (fraction of p).
    public static let slabHeightFactor: CGFloat = 0.55
    public static let maxPitch: CGFloat = 46
    public static let sideMargin: CGFloat = 6
    /// Columns shown at rest; longer sessions scroll along the lane.
    public static let visibleColumns: Int = 14

    // Corners
    public static let cornerRadiusFactor: CGFloat = 0.30   // of lane thickness
    // Glass slab
    public static let glowRadius: CGFloat = 9
    public static let glowOpacityBase: Double = 0.14
    public static let glowOpacityPerAction: Double = 0.04
    public static let glowOpacityCapLight: Double = 0.40
    public static let glowOpacityCapDark: Double = 0.24
    public static let fillOpacityBase: Double = 0.52
    public static let fillOpacityPerAction: Double = 0.07
    public static let fillOpacityMax: Double = 0.88
    public static let blurRadius: CGFloat = 0.8
    public static let sheenTop: Double = 0.55
    public static let sheenBottom: Double = 0.06
    public static let rimOpacityLight: Double = 0.70
    public static let rimOpacityDark: Double = 0.38
    public static let rimWidth: CGFloat = 0.8
    // Empty tiles
    public static let tileStrokeWidth: CGFloat = 1
    public static let tileStrokeOpacityLight: Double = 0.70
    public static let tileStrokeOpacityDark: Double = 0.34
    // Artifact slabs
    public static let artifactBlur: CGFloat = 2.2
    /// Zoom into the artifact so its colour blocks survive the blur as soft patches.
    public static let artifactZoom: CGFloat = 1.25
    public static let artifactContrast: Double = 1.12
    public static let artifactSaturation: Double = 1.35
    /// Agent colour laid over the image (normal blend) and a multiply pass; the image stays readable underneath.
    public static let artifactTintOverlay: Double = 0.50
    public static let artifactTintMultiply: Double = 0.35
    /// Fraction of a tick label's half-width kept inside the screen edge.
    public static let tickEdgeInset: CGFloat = 4
    // Tags
    public static let tagCount: Int = 4
    public static let tagFontSize: CGFloat = 8.5
    public static let tagTimeFontSize: CGFloat = 8
    public static let tagCornerRadius: CGFloat = 4
    public static let tagStrokeWidth: CGFloat = 0.8
    public static let tagHPad: CGFloat = 4
    public static let tagVPad: CGFloat = 2
    public static let tagNameCharWidth: CGFloat = 4.6
    public static let tagTimeCharWidth: CGFloat = 4.9
    public static let tagHeight: CGFloat = 25
    public static let tagClearance: CGFloat = 8
    /// Stem lengths tried in order; anchors tried along the slab (fractions of its length).
    public static let stemCandidates: [CGFloat] = [14, 22, 30, 40, 52, 64, 78, 94, 112, 132, 150]
    public static let anchorFractions: [CGFloat] = [0.5, 0.38, 0.62, 0.26, 0.74, 0.14, 0.86, 0.06, 0.94]
    public static let stemWidth: CGFloat = 0.8
    public static let headroom: CGFloat = 86
    // Ticks
    public static let tickFontSize: CGFloat = 10
    public static let tickSpace: CGFloat = 22
    // Flat-view row labels
    public static let spriteSize: CGFloat = 22
    // Scrolling window edge softness
    public static let windowFeather: CGFloat = 5
    // Interaction
    public static let minHitSize: CGFloat = 44
    public static let dimmedLaneOpacity: Double = 0.30
    // Toggle
    public static let toggleFontSize: CGFloat = 12
}

/// Remembers the chosen grid view for the rest of the app session (resets to ISOMETRIC on launch).
enum TakeawaysViewMemory {
    nonisolated(unsafe) static var isometric: Bool = !CommandLine.arguments.contains("-takeawaysFlat")
    nonisolated(unsafe) static var receiptIsometric: Bool = CommandLine.arguments.contains("-receiptIso")
}

// MARK: - Projection
/// Maps flat grid coordinates to screen: rotate 45 degrees * t, then scaleY (1 - compression * t).
public struct IsoProjection {
    public var t: CGFloat
    public init(t: CGFloat = 1) { self.t = t }

    public var transform: CGAffineTransform {
        CGAffineTransform(rotationAngle: CGFloat(TakeawaysIsoConstants.angle.radians) * t)
            .concatenating(CGAffineTransform(scaleX: 1, y: 1 - TakeawaysIsoConstants.compression * t))
    }

    public func point(_ flat: CGPoint) -> CGPoint { flat.applying(transform) }
}

// MARK: - Artifacts shown inside slabs
public struct TakeawaysArtifact: Identifiable, Equatable {
    public let id: String
    public let agentId: Int
    public let start: Double
    public let end: Double
    public let name: String
    public let assetName: String?
    public let entryID: String?

    public var timestampDisplay: String {
        let s = start
        return String(format: "%d:%02d", Int(s) / 60, Int(s) % 60)
    }

    public var timeRange: String {
        func f(_ s: Double) -> String { String(format: "%d:%02d", Int(s) / 60, Int(s) % 60) }
        return "\(f(start))\u{2013}\(f(end))"
    }

    /// Canonical demo artifacts using the bundled whiteboard assets
    public static let canonicalDemoBase: [(Int, Double, Double, String, String)] = [
        (0, 10, 12, "Moodboard", "whiteboard_1"),
        (0, 20, 22, "Signal map", "whiteboard_2"),
        (1, 8, 10, "Core idea", "whiteboard_3"),
        (2, 6, 8, "UI frame", "whiteboard_1"),
        (3, 6, 8, "Field photo", "whiteboard_2")
    ]

    public static var canonicalNames: [String] {
        canonicalDemoBase.map { $0.3 }
    }

    /// Seeded demo artifacts (bundled whiteboards) so 3-5 slabs always carry one; the long run repeats the pattern.
    public static func demo(long: Bool) -> [TakeawaysArtifact] {
        let shifts: [Double] = long ? [0, 28, 56] : [0]
        return shifts.flatMap { shift in
            canonicalDemoBase.map { TakeawaysArtifact(id: "demo_\($0.0)_\(Int($0.1 + shift))", agentId: $0.0, start: $0.1 + shift,
                                         end: $0.2 + shift, name: $0.3, assetName: $0.4, entryID: nil) }
        }
    }

    /// Live session entries that carry media (KnowledgeEntry.media) with an agent and elapsed time.
    public static func live(_ entries: [KnowledgeEntry]) -> [TakeawaysArtifact] {
        entries.compactMap { e in
            guard let m = e.media, let a = e.agentId, let t = e.elapsedSeconds else { return nil }
            return TakeawaysArtifact(id: "live_\(e.id)", agentId: a, start: t, end: t + 2, name: m.title, assetName: m.assetName, entryID: e.id)
        }
    }
}

@MainActor enum TakeawaysArtifactImages {
    private static var cache: [String: UIImage] = [:]
    static func image(_ name: String?) -> UIImage? {
        guard let name else { return nil }
        if let c = cache[name] { return c }
        let img: UIImage? = DemoStore.loadImageFromDisk(fileName: name)
            ?? (Bundle.module.path(forResource: name, ofType: "png") ?? Bundle.module.path(forResource: name, ofType: nil)).flatMap { UIImage(contentsOfFile: $0) }
            ?? UIImage(named: name, in: Bundle.module, with: nil)
        if let img { cache[name] = img }
        return img
    }
}

// MARK: - Piece model (merged moments)
struct IsoPiece: Identifiable {
    let id: String
    let lane: Int
    let startCol: Int
    let endCol: Int          // exclusive
    let cell: ContributionCellContext?   // merged context; nil for empty tiles
    let total: Int
    var isActive: Bool { cell != nil }

    var timeTag: String {
        guard let c = cell else { return "" }
        func f(_ s: Double) -> String { String(format: "%d:%02d", Int(s) / 60, Int(s) % 60) }
        return "\(f(c.startTime))\u{2013}\(f(c.endTime))"
    }

    var isOpenQuestion: Bool {
        guard let c = cell else { return false }
        return (c.actions[.questions] ?? 0) > 0
    }

    /// Consecutive active slices merge into one slab (bridging short empty gaps); each remaining run of empty time is one tile.
    static func build(rows: [AgentGridRow], columns: Int) -> [IsoPiece] {
        var out: [IsoPiece] = []
        let bridge = TakeawaysIsoConstants.bridgeEmptySlices
        for (lane, row) in rows.enumerated() {
            func count(_ c: Int) -> Int { c < row.cells.count ? row.cells[c].actions.values.reduce(0, +) : 0 }
            var col = 0
            while col < columns {
                if count(col) > 0 {
                    var end = col + 1
                    while end < columns {
                        if count(end) > 0 { end += 1; continue }
                        // empty at `end`: bridge if an active slice follows within `bridge` empties
                        if let j = (end..<min(columns, end + bridge + 1)).first(where: { count($0) > 0 }) { end = j + 1; continue }
                        break
                    }
                    let slice = (col..<end).compactMap { $0 < row.cells.count ? row.cells[$0] : nil }
                    var actions: [TakeawayAction: Int] = [:]
                    for c in slice { for (a, n) in c.actions { actions[a, default: 0] += n } }
                    let first = slice.first!, last = slice.last!
                    let merged = ContributionCellContext(agentId: first.agentId, agentName: first.agentName,
                                                         agentSprite: first.agentSprite, sliceIndex: first.sliceIndex,
                                                         startTime: first.startTime, endTime: last.endTime, actions: actions)
                    out.append(IsoPiece(id: "\(row.id)_s\(col)", lane: lane, startCol: col, endCol: end,
                                        cell: merged, total: actions.values.reduce(0, +)))
                    col = end
                } else {
                    var end = col + 1
                    while end < columns, count(end) == 0 { end += 1 }
                    out.append(IsoPiece(id: "\(row.id)_e\(col)", lane: lane, startCol: col, endCol: end, cell: nil, total: 0))
                    col = end
                }
            }
        }
        return out
    }
}

// MARK: - Layout
struct IsoLayout {
    let p: CGFloat
    let columns: Int
    let visible: Int
    let laneCount: Int
    let size: CGSize
    let screenCenter: CGPoint      // fixed on screen; the plane rotates about it

    var cp: CGFloat { p * TakeawaysIsoConstants.columnPitchFactor }
    var thickness: CGFloat { TakeawaysIsoConstants.laneThickness * p }
    var laneStride: CGFloat { (TakeawaysIsoConstants.laneThickness + TakeawaysIsoConstants.laneGap) * p }
    var slabHeight: CGFloat { TakeawaysIsoConstants.slabHeightFactor * p }
    var windowLength: CGFloat { CGFloat(visible) * cp }
    var flatWidth: CGFloat { CGFloat(laneCount - 1) * laneStride + thickness }
    var cornerRadius: CGFloat { thickness * TakeawaysIsoConstants.cornerRadiusFactor }
    var flatCenter: CGPoint { CGPoint(x: windowLength / 2, y: flatWidth / 2) }

    /// flat -> screen at tilt t (rotation about the plane's centre, which stays put on screen).
    func xf(_ t: CGFloat) -> CGAffineTransform {
        CGAffineTransform(translationX: -flatCenter.x, y: -flatCenter.y)
            .concatenating(IsoProjection(t: t).transform)
            .concatenating(CGAffineTransform(translationX: screenCenter.x, y: screenCenter.y))
    }

    func flatRect(_ piece: IsoPiece, scrollCols: CGFloat = 0) -> CGRect {
        let inset = TakeawaysIsoConstants.alongGap * p / 2
        return CGRect(x: (CGFloat(piece.startCol) - scrollCols) * cp + inset, y: CGFloat(piece.lane) * laneStride,
                      width: CGFloat(piece.endCol - piece.startCol) * cp - 2 * inset, height: thickness)
    }

    func screen(_ flat: CGPoint, t: CGFloat, lift: CGFloat = 0) -> CGPoint {
        let s = flat.applying(xf(t))
        return CGPoint(x: s.x, y: s.y - lift)
    }

    static func make(width: CGFloat, maxHeight: CGFloat?, columns: Int, laneCount: Int) -> IsoLayout {
        let C = TakeawaysIsoConstants.self
        let visible = min(columns, C.visibleColumns)
        let L = CGFloat(visible) * C.columnPitchFactor
        let W = CGFloat(laneCount - 1) * (C.laneThickness + C.laneGap) + C.laneThickness
        let corners = [CGPoint(x: -L / 2, y: -W / 2), CGPoint(x: L / 2, y: -W / 2),
                       CGPoint(x: L / 2, y: W / 2), CGPoint(x: -L / 2, y: W / 2)].map { IsoProjection().point($0) }
        let ew = corners.map(\.x).max()! - corners.map(\.x).min()!
        let eh = corners.map(\.y).max()! - corners.map(\.y).min()! + C.slabHeightFactor
        var pitch = (width - 2 * C.sideMargin) / ew
        if let maxHeight { pitch = min(pitch, (maxHeight - C.headroom - C.tickSpace) / eh) }
        pitch = max(6, min(C.maxPitch, pitch))
        let contentH = C.headroom + eh * pitch + C.tickSpace
        let totalH = max(contentH, maxHeight ?? contentH)
        let cy = (totalH - contentH) / 2 + C.headroom + C.slabHeightFactor * pitch + (eh - C.slabHeightFactor) * pitch / 2
        return IsoLayout(p: pitch, columns: columns, visible: visible, laneCount: laneCount,
                         size: CGSize(width: width, height: totalH), screenCenter: CGPoint(x: width / 2, y: cy))
    }
}

/// Rounded-rect footprint pushed through the plane transform (2D only), raised by `lift` on screen.
func isoFootprintPath(flat: CGRect, radius: CGFloat, xf: CGAffineTransform, lift: CGFloat) -> Path {
    let r = min(radius, min(flat.width, flat.height) / 2 * 0.92)
    return Path(roundedRect: flat, cornerRadius: max(0, r), style: .continuous)
        .applying(xf.concatenating(CGAffineTransform(translationX: 0, y: -lift)))
}

/// All empty tiles of one lane in one stroked path.
struct IsoTilesShape: Shape {
    let rects: [CGRect]
    let radius: CGFloat
    let xf: CGAffineTransform
    func path(in rect: CGRect) -> Path {
        var p = Path()
        for r in rects { p.addPath(isoFootprintPath(flat: r, radius: radius, xf: xf, lift: 0)) }
        return p
    }
}

/// A slab footprint at a given lift, or the swept volume from the ground to `height` (union of 1pt slices).
struct IsoSlabShape: Shape {
    let flat: CGRect
    let radius: CGFloat
    let xf: CGAffineTransform
    let height: CGFloat
    let sweep: Bool
    func path(in rect: CGRect) -> Path {
        guard sweep, height > 0.5 else { return isoFootprintPath(flat: flat, radius: radius, xf: xf, lift: height) }
        var p = Path()
        var y: CGFloat = 0
        while y < height { p.addPath(isoFootprintPath(flat: flat, radius: radius, xf: xf, lift: y)); y += 1 }
        p.addPath(isoFootprintPath(flat: flat, radius: radius, xf: xf, lift: height))
        return p
    }
}

// MARK: - Glass slab
struct IsoSlabView: View {
    let piece: IsoPiece
    let layout: IsoLayout
    let t: CGFloat
    let rise: CGFloat           // 0...1, how far the slab has extruded
    let scrollCols: CGFloat
    var artifact: TakeawaysArtifact? = nil
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let C = TakeawaysIsoConstants.self
        let dark = colorScheme == .dark
        let sprite = piece.cell!.agentSprite
        let flat = layout.flatRect(piece, scrollCols: scrollCols)
        let h = layout.slabHeight * rise
        let xf = layout.xf(t)
        let full = IsoSlabShape(flat: flat, radius: layout.cornerRadius, xf: xf, height: h, sweep: true).path(in: .zero).boundingRect
        let pad = C.glowRadius * 2 + 4
        let bb = full.insetBy(dx: -pad, dy: -pad)
        let local = xf.concatenating(CGAffineTransform(translationX: -bb.minX, y: -bb.minY))
        let body = IsoSlabShape(flat: flat, radius: layout.cornerRadius, xf: local, height: h, sweep: true)
        let top = IsoSlabShape(flat: flat, radius: layout.cornerRadius, xf: local, height: h, sweep: false)
        let n = Double(piece.total)
        let fillOp = min(C.fillOpacityMax, C.fillOpacityBase + C.fillOpacityPerAction * n)
        let glow = min(dark ? C.glowOpacityCapDark : C.glowOpacityCapLight, C.glowOpacityBase + C.glowOpacityPerAction * n)
        let glowColor = sprite.gradientColors.first ?? .gray

        ZStack {
            // Flat plate representation (visible at rest in flat mode, fades out smoothly as rise extrudes)
            if rise < 0.95 {
                top.fill(sprite.takeawayGradient(for: colorScheme)).opacity(min(1, fillOp + 0.1) * max(0, 1.0 - Double(rise) * 2.0))
                    .overlay(
                        Group {
                            if piece.isOpenQuestion {
                                top.stroke(Color.primary.opacity(dark ? 0.80 : 0.85), style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
                            } else {
                                top.stroke(Color.white.opacity(dark ? C.rimOpacityDark : C.rimOpacityLight), lineWidth: C.rimWidth)
                            }
                        }
                    )
            }
            // Extruded glass representation (rises smoothly, side faces softer)
            if rise > 0.01 {
                ZStack {
                    body.fill(glowColor).blur(radius: C.glowRadius).opacity(glow * Double(0.35 + 0.65 * rise))
                    ZStack {
                        body.fill(.ultraThinMaterial)
                        if let ui = TakeawaysArtifactImages.image(artifact?.assetName) {
                            // Blurred artifact, still, inside the frosted glass;
                            // the agent colour multiplies over it so ink reads as shifts of tint.
                            Image(uiImage: ui)
                                .resizable().scaledToFill()
                                .frame(width: bb.width, height: bb.height)
                                .scaleEffect(C.artifactZoom)
                                .clipped()
                                .blur(radius: C.artifactBlur)
                                .saturation(C.artifactSaturation)
                                .contrast(C.artifactContrast)
                                .mask { body.fill(Color.black) }
                            body.fill(sprite.takeawayGradient(for: colorScheme)).opacity(C.artifactTintOverlay)
                            body.fill(sprite.takeawayGradient(for: colorScheme))
                                .blendMode(.multiply)
                                .opacity(dark ? C.artifactTintMultiply * 0.8 : C.artifactTintMultiply)
                        } else {
                            body.fill(sprite.takeawayGradient(for: colorScheme)).opacity(fillOp)
                        }
                        body.fill(LinearGradient(colors: [.white.opacity(C.sheenTop * 0.5), .white.opacity(0)],
                                                 startPoint: .top, endPoint: .bottom))
                    }
                    .blur(radius: C.blurRadius)
                    top.fill(LinearGradient(colors: [.white.opacity(dark ? C.sheenTop * 0.55 : C.sheenTop),
                                                     .white.opacity(C.sheenBottom)],
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
                    if piece.isOpenQuestion {
                        top.stroke(Color.primary.opacity(dark ? 0.80 : 0.85), style: StrokeStyle(lineWidth: 1.2, dash: [4, 3]))
                    } else {
                        top.stroke(Color.white.opacity(dark ? C.rimOpacityDark : C.rimOpacityLight), lineWidth: C.rimWidth)
                    }
                }
                .opacity(min(1.0, Double(rise) * 2.0))
            }
        }
        .frame(width: bb.width, height: bb.height)
        .position(x: bb.midX, y: bb.midY)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Tag
struct IsoTagView: View {
    let artifact: TakeawaysArtifact
    var body: some View {
        let C = TakeawaysIsoConstants.self
        VStack(spacing: 0) {
            Text(artifact.name).font(.system(size: C.tagFontSize, weight: .regular))
            Text(artifact.timestampDisplay).font(.yaya(size: C.tagTimeFontSize)).foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .foregroundStyle(.primary)
        .padding(.horizontal, C.tagHPad).padding(.vertical, C.tagVPad)
        .background(RoundedRectangle(cornerRadius: C.tagCornerRadius, style: .continuous).fill(Color(.systemBackground)))
        .overlay(RoundedRectangle(cornerRadius: C.tagCornerRadius, style: .continuous)
            .stroke(Color.primary.opacity(0.8), lineWidth: C.tagStrokeWidth))
        .fixedSize()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct IsoPlacedTag: Identifiable {
    let piece: IsoPiece
    let artifact: TakeawaysArtifact
    let anchor: CGPoint
    let stem: CGFloat
    /// Horizontal offset of the pill centre from the stem (the stem meets the pill under its middle or an end).
    var shift: CGFloat = 0
    var id: String { piece.id }
    var pillSize: CGSize {
        let C = TakeawaysIsoConstants.self
        let w = max(CGFloat(artifact.name.count) * C.tagNameCharWidth, CGFloat(artifact.timestampDisplay.count) * C.tagTimeCharWidth)
        return CGSize(width: w + 2 * C.tagHPad, height: C.tagHeight)
    }
    var pillRect: CGRect {
        let s = pillSize
        return CGRect(x: anchor.x + shift - s.width / 2, y: anchor.y - stem - s.height, width: s.width, height: s.height)
    }
}

// MARK: - Animation driver (re-evaluates the grid every frame while t / ext animate)
struct IsoAnimating<Content: View>: View, @preconcurrency Animatable {
    var t: CGFloat
    var ext: CGFloat
    let content: (CGFloat, CGFloat) -> Content
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(t, ext) }
        set { t = newValue.first; ext = newValue.second }
    }
    var body: some View { content(t, ext) }
}

// MARK: - Grid View (FLAT at t = 0, ISOMETRIC at t = 1)
public struct IsometricContributionGridView: View {
    public let rows: [AgentGridRow]
    public let sessionDuration: Double
    public let timeSlice: Double
    public let width: CGFloat
    public let maxHeight: CGFloat?
    public var highlightedAgent: String? = nil
    public let isometric: Bool
    /// Plays the arrival sequence once when the view appears (ISOMETRIC only).
    public var playsArrival: Bool = true
    public var artifacts: [TakeawaysArtifact] = []
    public let onSelectCell: (ContributionCellContext) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var t: CGFloat
    @State private var ext: CGFloat
    @State private var tagOpacity: Double
    @State private var gridOpacity: Double
    @State private var scrollColumns: CGFloat = 0
    @State private var dragStartScroll: CGFloat? = nil
    @State private var driver: Task<Void, Never>? = nil

    public init(rows: [AgentGridRow], sessionDuration: Double, timeSlice: Double,
                width: CGFloat, maxHeight: CGFloat? = nil, highlightedAgent: String? = nil,
                isometric: Bool = true, playsArrival: Bool = true, artifacts: [TakeawaysArtifact] = [],
                onSelectCell: @escaping (ContributionCellContext) -> Void) {
        self.rows = rows
        self.sessionDuration = sessionDuration
        self.timeSlice = timeSlice
        self.width = width
        self.maxHeight = maxHeight
        self.highlightedAgent = highlightedAgent
        self.isometric = isometric
        self.artifacts = artifacts
        self.onSelectCell = onSelectCell
        self.playsArrival = playsArrival
        let arriving = isometric && playsArrival
        _t = State(initialValue: isometric ? 1 : 0)
        _ext = State(initialValue: isometric && !arriving ? 1 : 0)
        _tagOpacity = State(initialValue: isometric && !arriving ? 1 : 0)
        _gridOpacity = State(initialValue: arriving ? 0 : 1)
    }

    private var columns: Int { max(1, Int(ceil(sessionDuration / timeSlice))) }

    private func timeString(_ s: Double) -> String {
        String(format: "%d:%02d", Int(s) / 60, Int(s) % 60)
    }

    private func laneOpacity(_ name: String) -> Double {
        guard let h = highlightedAgent, !h.isEmpty else { return 1 }
        return h.caseInsensitiveCompare(name) == .orderedSame ? 1 : TakeawaysIsoConstants.dimmedLaneOpacity
    }

    private func smooth(_ x: CGFloat) -> CGFloat { let c = min(1, max(0, x)); return c * c * (3 - 2 * c) }

    // MARK: Transition
    private func run(_ iso: Bool) {
        let M = BranchMotion.Takeaways.self
        driver?.cancel()
        gridOpacity = 1
        if reduceMotion {
            t = iso ? 1 : 0; ext = iso ? 1 : 0; tagOpacity = iso ? 1 : 0
            return
        }
        driver = Task { @MainActor in
            func pause(_ s: Double) async { try? await Task.sleep(nanoseconds: UInt64(s * 1_000_000_000)) }
            if iso {
                withAnimation(.easeInOut(duration: M.tiltDuration)) { t = 1 }
                await pause(M.tiltDuration)
                guard !Task.isCancelled else { return }
                withAnimation(.linear(duration: M.extrudeDuration)) { ext = 1 }
                await pause(M.extrudeDuration)
                guard !Task.isCancelled else { return }
                withAnimation(.easeOut(duration: M.tagFadeDuration)) { tagOpacity = 1 }
            } else {
                withAnimation(.easeOut(duration: M.tagFadeDuration)) { tagOpacity = 0 }
                await pause(M.tagFadeDuration)
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: M.lowerDuration)) { ext = 0 }
                await pause(M.lowerDuration)
                guard !Task.isCancelled else { return }
                withAnimation(.easeInOut(duration: M.tiltDuration)) { t = 0 }
            }
        }
    }

    // MARK: Arrival (one moment, then calm): grid fades in as isometric tiles, slabs rise column by column,
    // callouts fade in after the last column, then only the marquee keeps moving.
    private func arrive() {
        let M = BranchMotion.Takeaways.self
        guard isometric, playsArrival, gridOpacity < 1 || ext < 1 else { return }
        driver?.cancel()
        if reduceMotion {
            withAnimation(.easeOut(duration: M.reducedMotionFade)) { gridOpacity = 1; ext = 1; tagOpacity = 1 }
            return
        }
        driver = Task { @MainActor in
            func pause(_ s: Double) async { try? await Task.sleep(nanoseconds: UInt64(s * 1_000_000_000)) }
            await pause(M.arrivalGridDelay)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: M.arrivalGridFade)) { gridOpacity = 1 }
            await pause(M.arrivalGridFade + M.arrivalRiseGap)
            guard !Task.isCancelled else { return }
            withAnimation(.linear(duration: M.extrudeDuration)) { ext = 1 }
            await pause(M.extrudeDuration + M.arrivalTagGap)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: M.arrivalTagFade)) { tagOpacity = 1 }
        }
    }

    // MARK: Tag placement (avoids every other slab and the other tags)
    private func artifact(for piece: IsoPiece) -> TakeawaysArtifact? {
        guard let c = piece.cell else { return nil }
        return artifacts.first { $0.agentId == c.agentId && $0.start < c.endTime && $0.end > c.startTime }
    }

    private func placeTags(slabs: [IsoPiece], layout: IsoLayout, scroll: CGFloat, avoid: [CGRect] = []) -> [IsoPlacedTag] {
        let C = TakeawaysIsoConstants.self
        let xf = layout.xf(1)
        let h = layout.slabHeight
        func hull(_ piece: IsoPiece) -> Path {
            let r = layout.flatRect(piece, scrollCols: scroll)
            var p = Path()
            for lift in [0, h / 2, h] { p.addPath(isoFootprintPath(flat: r, radius: layout.cornerRadius, xf: xf, lift: lift)) }
            return p
        }
        let hulls = Dictionary(uniqueKeysWithValues: slabs.map { ($0.id, hull($0)) })
        let windowEnd = layout.windowLength
        let candidates = slabs.enumerated().filter { _, s in
            guard artifact(for: s) != nil else { return false }
            let r = layout.flatRect(s, scrollCols: scroll)
            return r.minX >= -1 && r.maxX <= windowEnd + 1
        }.sorted {
            // Least flexible first: short slabs (one narrow anchor), then front lanes; long slabs adapt around them.
            let a = layout.flatRect($0.element, scrollCols: scroll).width, b = layout.flatRect($1.element, scrollCols: scroll).width
            if abs(a - b) > 0.5 { return a < b }
            return ($0.element.lane, $0.offset) > ($1.element.lane, $1.offset)
        }.map(\.element)

        var placed: [IsoPlacedTag] = []
        let m = C.tagClearance
        let bounds = CGRect(x: 2, y: 2, width: width - 4, height: layout.size.height - 4)
        for piece in candidates {
            let r = layout.flatRect(piece, scrollCols: scroll)
            let others = slabs.filter { $0.id != piece.id }.compactMap { hulls[$0.id] }
            search: for frac in C.anchorFractions {
                let anchorFlat = CGPoint(x: r.minX + r.width * frac, y: r.midY)
                let anchor = layout.screen(anchorFlat, t: 1, lift: h)
                for stem in C.stemCandidates {
                  let pw = IsoPlacedTag(piece: piece, artifact: artifact(for: piece)!, anchor: anchor, stem: stem).pillSize.width
                  for shift in [0, pw / 2 - 10, -(pw / 2 - 10)] {
                    var cand = IsoPlacedTag(piece: piece, artifact: artifact(for: piece)!, anchor: anchor, stem: stem)
                    cand.shift = shift
                    let pill = cand.pillRect.insetBy(dx: -m, dy: -m)
                    guard bounds.contains(cand.pillRect), !avoid.contains(where: { $0.intersects(pill) }) else { continue }
                    // pill vs every slab (own included)
                    var clear = true
                    let ownHull = hulls[piece.id]!
                    for path in others + [ownHull] {
                        if path.boundingRect.intersects(pill) {
                            for ix in 0...6 { for iy in 0...2 {
                                let pt = CGPoint(x: pill.minX + pill.width * CGFloat(ix) / 6, y: pill.minY + pill.height * CGFloat(iy) / 2)
                                if path.contains(pt) { clear = false }
                            } }
                        }
                        if !clear { break }
                    }
                    guard clear else { continue }
                    // stem vs other slabs
                    var y = anchor.y - 6
                    while y > anchor.y - stem && clear {
                        let pt = CGPoint(x: anchor.x, y: y)
                        for path in others where path.contains(pt) { clear = false; break }
                        y -= 3
                    }
                    guard clear else { continue }
                    // vs earlier tags: pills against pills, and stems against pills in both directions
                    func stemHits(_ t: IsoPlacedTag, _ rect: CGRect) -> Bool {
                        rect.minX <= t.anchor.x && rect.maxX >= t.anchor.x
                            && rect.maxY >= t.anchor.y - t.stem && rect.minY <= t.anchor.y
                    }
                    for other in placed {
                        let op = other.pillRect.insetBy(dx: -m, dy: -m)
                        if op.intersects(cand.pillRect) || stemHits(other, pill) || stemHits(cand, op) { clear = false; break }
                    }
                    guard clear else { continue }
                    placed.append(cand)
                    break search
                  }
                }
            }
        }
        return placed
    }

    public var body: some View {
        let layout = IsoLayout.make(width: width, maxHeight: maxHeight, columns: columns, laneCount: rows.count)
        let maxScroll = CGFloat(max(0, columns - layout.visible))
        let scroll = min(max(0, scrollColumns), maxScroll)

        IsoAnimating(t: t, ext: ext) { t, ext in
            content(layout: layout, scroll: scroll, maxScroll: maxScroll, t: t, ext: ext)
        }
        .frame(width: layout.size.width, height: layout.size.height, alignment: .topLeading)
        .simultaneousGesture(
            maxScroll > 0 ? DragGesture(minimumDistance: 8)
                .onChanged { value in
                    if dragStartScroll == nil { dragStartScroll = scroll }
                    let dir = IsoProjection(t: t).point(CGPoint(x: 1, y: 0))
                    let len = hypot(dir.x, dir.y)
                    let along = (value.translation.width * dir.x + value.translation.height * dir.y) / len
                    let cols = along / (layout.cp * len)
                    scrollColumns = min(max(0, (dragStartScroll ?? 0) - cols), maxScroll)
                }
                .onEnded { _ in dragStartScroll = nil } : nil
        )
        .opacity(gridOpacity)
        .onChange(of: isometric) { _, iso in run(iso) }
        .task { arrive() }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Contribution grid, \(isometric ? "isometric" : "flat")")
    }

    private func content(layout: IsoLayout, scroll: CGFloat, maxScroll: CGFloat, t: CGFloat, ext: CGFloat) -> some View {
        let C = TakeawaysIsoConstants.self
        let M = BranchMotion.Takeaways.self
        let dark = colorScheme == .dark
        let xf = layout.xf(t)
        let windowL = layout.windowLength
        let pieces = IsoPiece.build(rows: rows, columns: columns)
        let slabs = pieces.filter(\.isActive)
        func inWindow(_ piece: IsoPiece) -> Bool {
            let r = layout.flatRect(piece, scrollCols: scroll)
            return r.maxX > -layout.cp && r.minX < windowL + layout.cp
        }
        let visibleSlabs = slabs.filter(inWindow)
        let ordered = visibleSlabs.sorted {
            let a = layout.flatRect($0, scrollCols: scroll), b = layout.flatRect($1, scrollCols: scroll)
            return (a.midX + a.midY) < (b.midX + b.midY)
        }
        let s = CGFloat(M.extrudeStagger)
        func rise(_ piece: IsoPiece) -> CGFloat {
            let colFrac = min(1, max(0, (CGFloat(piece.startCol) - scroll) / CGFloat(layout.visible)))
            return smooth((ext - s * colFrac) / (1 - s))
        }
        let moreAhead = scroll < maxScroll - 0.01
        let moreBehind = scroll > 0.01
        let tickY = layout.flatWidth + layout.p * 0.7
        func clampX(_ pt: CGPoint, half: CGFloat) -> CGPoint {
            CGPoint(x: min(max(pt.x, half + C.tickEdgeInset), layout.size.width - half - C.tickEdgeInset), y: pt.y)
        }
        let tickStart = clampX(layout.screen(CGPoint(x: 0.9 * layout.cp, y: tickY), t: t), half: moreBehind ? 24 : 16)
        let tickEnd = clampX(layout.screen(CGPoint(x: windowL - 0.9 * layout.cp, y: tickY), t: t), half: moreAhead ? 24 : 16)
        let tickAvoid = [CGRect(x: tickStart.x - 24, y: tickStart.y - 4, width: 48, height: 22),
                         CGRect(x: tickEnd.x - 30, y: tickEnd.y - 4, width: 60, height: 22)]
        let tags: [IsoPlacedTag] = tagOpacity > 0.001
            ? placeTags(slabs: slabs, layout: layout, scroll: scroll, avoid: tickAvoid) : []
        let startTime = Double(scroll) * timeSlice
        let endTime = min(sessionDuration, Double(scroll + CGFloat(layout.visible)) * timeSlice)

        return ZStack(alignment: .topLeading) {
            ZStack(alignment: .topLeading) {
                ForEach(Array(rows.enumerated()), id: \.element.id) { lane, row in
                    let rects = pieces.filter { !$0.isActive && $0.lane == lane && inWindow($0) }
                        .map { layout.flatRect($0, scrollCols: scroll) }
                    IsoTilesShape(rects: rects, radius: layout.cornerRadius, xf: xf)
                        .stroke(dark ? Color.white.opacity(C.tileStrokeOpacityDark) : Color.primary.opacity(C.tileStrokeOpacityLight),
                                lineWidth: C.tileStrokeWidth)
                        .opacity(laneOpacity(row.name))
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }

                ForEach(ordered) { piece in
                    IsoSlabView(piece: piece, layout: layout, t: t, rise: rise(piece), scrollCols: scroll, artifact: artifact(for: piece))
                        .opacity(laneOpacity(piece.cell!.agentName))
                }

                // Tags on stems
                ForEach(tags) { tag in
                    ZStack(alignment: .topLeading) {
                        Path { p in
                            p.move(to: CGPoint(x: tag.anchor.x, y: tag.anchor.y))
                            p.addLine(to: CGPoint(x: tag.anchor.x, y: tag.anchor.y - tag.stem))
                        }
                        .stroke(Color.primary.opacity(0.8), lineWidth: C.stemWidth)
                        IsoTagView(artifact: tag.artifact)
                            .position(x: tag.pillRect.midX, y: tag.pillRect.midY)
                    }
                    .frame(width: layout.size.width, height: layout.size.height, alignment: .topLeading)
                    .opacity(tagOpacity * laneOpacity(tag.piece.cell!.agentName))
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
            .mask { windowMask(layout: layout, t: t, active: maxScroll > 0) }

            // Row labels (FLAT: full sprite and name; ISO: small mono agent name at start of lane)
            if t < 0.4 {
                ForEach(Array(rows.enumerated()), id: \.element.id) { lane, row in
                    let pos = layout.screen(CGPoint(x: -(C.spriteSize / 2 + 8),
                                                    y: CGFloat(lane) * layout.laneStride + layout.thickness / 2), t: t)
                    VStack(spacing: 1) {
                        SpriteView(sprite: row.sprite, isBlinking: false, showsArms: false)
                            .frame(width: C.spriteSize, height: C.spriteSize)
                        Text(row.name)
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary).lineLimit(1).fixedSize()
                    }
                    .opacity(max(0, 1 - Double(t) * 2.5) * laneOpacity(row.name))
                    .position(x: pos.x, y: pos.y)
                    .allowsHitTesting(false)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(row.rowSummary)
                }
            } else {
                ForEach(Array(rows.enumerated()), id: \.element.id) { lane, row in
                    let pos = layout.screen(CGPoint(x: -4,
                                                    y: CGFloat(lane) * layout.laneStride + layout.thickness / 2), t: t)
                    Text(row.name.uppercased())
                        .font(.yaya(size: 8, weight: .semibold))
                        .foregroundStyle(Color.primary.opacity(0.55))
                        .opacity(min(1.0, Double(t - 0.4) * 2.5) * laneOpacity(row.name))
                        .position(x: pos.x - 14, y: pos.y)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
            }

            // Time ticks
            Text((moreBehind ? "\u{2039} " : "") + timeString(startTime))
                .font(.yaya(size: C.tickFontSize)).foregroundStyle(.secondary).fixedSize()
                .position(x: tickStart.x, y: tickStart.y + 6)
                .allowsHitTesting(false).accessibilityHidden(true)
            Text(timeString(endTime) + (moreAhead ? " \u{203A}" : ""))
                .font(.yaya(size: C.tickFontSize)).foregroundStyle(moreAhead ? Color.primary : Color.secondary).fixedSize()
                .position(x: tickEnd.x, y: tickEnd.y + 6)
                .allowsHitTesting(false).accessibilityHidden(true)

            // Hit areas (>= 44pt) and accessibility, one per slab
            ForEach(ordered) { piece in
                let r = layout.flatRect(piece, scrollCols: scroll)
                let cell = piece.cell!
                let hh = layout.slabHeight * rise(piece)
                let c = layout.screen(CGPoint(x: r.midX, y: r.midY), t: t, lift: hh)
                IsoSlabShape(flat: r, radius: layout.cornerRadius, xf: xf, height: hh, sweep: false)
                    .fill(Color.white.opacity(0.001))
                    .frame(width: layout.size.width, height: layout.size.height)
                    .onTapGesture { onSelectCell(cell) }
                    .overlay(alignment: .topLeading) {
                        Color.clear
                            .frame(width: C.minHitSize, height: C.minHitSize)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelectCell(cell) }
                            .offset(x: c.x - C.minHitSize / 2, y: c.y - C.minHitSize / 2)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(cell.agentName), \(cell.timeRangeString), \(cell.actionsSummary)" + (artifact(for: piece).map { ", artifact \($0.name)" } ?? ""))
                    .accessibilityHint("Opens the moment")
                    .accessibilityAddTraits(.isButton)
            }
        }
    }

    /// Soft parallelogram window (extended upward for slab height and tags) used when a long session scrolls.
    @ViewBuilder
    private func windowMask(layout: IsoLayout, t: CGFloat, active: Bool) -> some View {
        if active {
            let xf = layout.xf(t)
            let L = layout.windowLength, W = layout.flatWidth
            let pad = layout.p * 0.2
            let base = [CGPoint(x: 0, y: -pad), CGPoint(x: L, y: -pad), CGPoint(x: L, y: W + pad), CGPoint(x: 0, y: W + pad)]
                .map { $0.applying(xf) }
            let H = TakeawaysIsoConstants.headroom + layout.slabHeight
            let pts = base + base.map { CGPoint(x: $0.x, y: $0.y - H) }
            Path { p in
                let h = convexHull(pts)
                guard let f = h.first else { return }
                p.move(to: f); for q in h.dropFirst() { p.addLine(to: q) }; p.closeSubpath()
            }
            .fill(Color.black)
            .blur(radius: TakeawaysIsoConstants.windowFeather)
        } else {
            Color.black
        }
    }

    private func convexHull(_ points: [CGPoint]) -> [CGPoint] {
        let pts = points.sorted { $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x }
        func cross(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat { (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x) }
        var lower: [CGPoint] = [], upper: [CGPoint] = []
        for p in pts { while lower.count >= 2 && cross(lower[lower.count - 2], lower[lower.count - 1], p) <= 0 { lower.removeLast() }; lower.append(p) }
        for p in pts.reversed() { while upper.count >= 2 && cross(upper[upper.count - 2], upper[upper.count - 1], p) <= 0 { upper.removeLast() }; upper.append(p) }
        return Array(lower.dropLast() + upper.dropLast())
    }
}

// MARK: - Marquee arrival fade (state is per-instance, so it replays on every Takeaways arrival)
struct TakeawaysArrivalFade<Content: View>: View {
    @ViewBuilder let content: Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false
    var body: some View {
        content
            .opacity(shown ? 1 : 0)
            .onAppear {
                let M = BranchMotion.Takeaways.self
                withAnimation(.easeOut(duration: reduceMotion ? M.reducedMotionFade : M.arrivalMarqueeFade)) { shown = true }
            }
    }
}

// MARK: - FLAT / ISOMETRIC toggle
struct GridViewModeToggle: View {
    let isometric: Bool
    let onSelect: (Bool) -> Void
    var body: some View {
        HStack(spacing: 8) {
            pill("FLAT", selected: !isometric, iso: false)
            pill("ISOMETRIC", selected: isometric, iso: true)
        }
    }

    private func pill(_ title: String, selected: Bool, iso: Bool) -> some View {
        Button { if iso != isometric { onSelect(iso) } } label: {
            Text(title)
                .font(.yaya(size: TakeawaysIsoConstants.toggleFontSize))
                .foregroundStyle(Color.primary.opacity(selected ? 1 : 0.3))
                .padding(.horizontal, 14).padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.primary.opacity(selected ? 1 : 0.0), lineWidth: 1)
                )
                .frame(minWidth: 64, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Grid view, \(title.capitalized)")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }
}

/// Launch arguments for deterministic Takeaways screenshots.
enum TakeawaysLaunch {
    static let flat = CommandLine.arguments.contains("-takeawaysFlat")
    static let long = CommandLine.arguments.contains("-takeawaysLong")
    static let autoToggle = CommandLine.arguments.contains("-takeawaysAutoToggle")
    static let team = CommandLine.arguments.contains("-takeawaysTeam") // stub, step e
    static let highlight: String? = {
        let a = CommandLine.arguments
        guard let i = a.firstIndex(of: "-takeawaysHighlight"), i + 1 < a.count else { return nil }
        return a[i + 1]
    }()
}

