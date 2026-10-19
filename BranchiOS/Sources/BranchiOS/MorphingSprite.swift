import SwiftUI
import CoreGraphics
import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Eye Style
public enum SpriteEyeStyle: Sendable {
    /// Two solid ellipses that blink.
    case open
    /// Two gently curved lines (like a closed, content smile) used while the sprite is listening.
    case listening
}

// MARK: - Shared Eye Pair
/// Eyes always stay level and upright. Positions are in the parent's coordinate space.
struct SpriteEyePair: View {
    let left: CGPoint
    let right: CGPoint
    let size: CGSize
    let isBlinking: Bool
    let style: SpriteEyeStyle
    let color: Color

    var body: some View {
        ZStack {
            eye(at: left)
            eye(at: right)
        }
        .animation(.easeInOut(duration: 0.22), value: style == .listening)
    }

    private func eye(at point: CGPoint) -> some View {
        let isListening = style == .listening
        return ZStack {
            Ellipse()
                .fill(color)
                .frame(width: size.width, height: size.height)
                .scaleEffect(y: isBlinking ? 0.08 : 1.0, anchor: .center)
                .opacity(isListening ? 0 : 1)

            ListeningEyeArc()
                .stroke(color, style: StrokeStyle(lineWidth: max(size.width * 0.62, 2.2), lineCap: .round))
                .frame(width: size.width * 2.1, height: size.height * 0.62)
                .opacity(isListening ? 1 : 0)
        }
        .position(x: point.x, y: point.y)
    }
}

/// Bowl-shaped arc (like ‿) used for closed, listening eyes.
struct ListeningEyeArc: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.midX, y: rect.maxY * 1.9)
        )
        return p
    }
}

// MARK: - Morph Sampling
/// Samples each family silhouette into the same number of arc-length-spaced points, in a shared
/// 100 x 100 box, so any two silhouettes can be interpolated point by point.
enum SpriteMorphSampler {
    static let count = 192
    static let box: CGFloat = 100

    private final class Cache: @unchecked Sendable {
        private let lock = NSRecursiveLock()
        private var singles: [BranchSprite: [CGPoint]] = [:]
        private var pairs: [String: [CGPoint]] = [:]

        func single(_ s: BranchSprite, make: () -> [CGPoint]) -> [CGPoint] {
            lock.lock(); defer { lock.unlock() }
            if let v = singles[s] { return v }
            let v = make()
            singles[s] = v
            return v
        }

        func pair(_ key: String, make: () -> [CGPoint]) -> [CGPoint] {
            lock.lock(); defer { lock.unlock() }
            if let v = pairs[key] { return v }
            let v = make()
            pairs[key] = v
            return v
        }
    }

    private static let cache = Cache()

    /// Counter-clockwise (positive area), evenly spaced points for one silhouette.
    static func points(for sprite: BranchSprite) -> [CGPoint] {
        cache.single(sprite) {
            let path = SpritePathVault.path(for: sprite, in: CGRect(x: 0, y: 0, width: box, height: box))
            var poly = flatten(path.cgPath)
            if signedArea(poly) < 0 { poly.reverse() }
            return resample(poly, to: count)
        }
    }

    /// `to` rotated so its points line up with `from` (minimum summed squared distance).
    static func alignedTarget(from: BranchSprite, to: BranchSprite) -> [CGPoint] {
        cache.pair("\(from.rawValue)>\(to.rawValue)") {
            let a = points(for: from)
            let b = points(for: to)
            var best = 0
            var bestCost = CGFloat.greatestFiniteMagnitude
            for shift in 0..<count {
                var cost: CGFloat = 0
                for i in 0..<count {
                    let q = b[(i + shift) % count]
                    let dx = a[i].x - q.x, dy = a[i].y - q.y
                    cost += dx * dx + dy * dy
                }
                if cost < bestCost { bestCost = cost; best = shift }
            }
            return (0..<count).map { b[($0 + best) % count] }
        }
    }

    /// Eye geometry in the same 100 box (original proportions preserved via the sprite's viewBox).
    static func eyes(for sprite: BranchSprite) -> (left: CGPoint, right: CGPoint, rx: CGFloat, ry: CGFloat) {
        let vb = sprite.viewBoxSize
        let scale = min(box / vb.width, box / vb.height)
        let ox = (box - vb.width * scale) / 2
        let oy = (box - vb.height * scale) / 2
        func map(_ n: CGPoint) -> CGPoint {
            CGPoint(x: ox + n.x * vb.width * scale, y: oy + n.y * vb.height * scale)
        }
        return (map(sprite.leftEyeNormalized), map(sprite.rightEyeNormalized), 2.87 * scale, 4.84 * scale)
    }

    // MARK: Geometry helpers
    private static func flatten(_ cg: CGPath) -> [CGPoint] {
        var pts: [CGPoint] = []
        var start = CGPoint.zero
        var cur = CGPoint.zero
        let steps = 28
        cg.applyWithBlock { ptr in
            let e = ptr.pointee
            let p = e.points
            switch e.type {
            case .moveToPoint:
                cur = p[0]; start = cur; pts.append(cur)
            case .addLineToPoint:
                cur = p[0]; pts.append(cur)
            case .addQuadCurveToPoint:
                let c = p[0], end = p[1], s = cur
                for i in 1...steps {
                    let t = CGFloat(i) / CGFloat(steps), u = 1 - t
                    pts.append(CGPoint(x: u*u*s.x + 2*u*t*c.x + t*t*end.x, y: u*u*s.y + 2*u*t*c.y + t*t*end.y))
                }
                cur = end
            case .addCurveToPoint:
                let c1 = p[0], c2 = p[1], end = p[2], s = cur
                for i in 1...steps {
                    let t = CGFloat(i) / CGFloat(steps), u = 1 - t
                    let x = u*u*u*s.x + 3*u*u*t*c1.x + 3*u*t*t*c2.x + t*t*t*end.x
                    let y = u*u*u*s.y + 3*u*u*t*c1.y + 3*u*t*t*c2.y + t*t*t*end.y
                    pts.append(CGPoint(x: x, y: y))
                }
                cur = end
            case .closeSubpath:
                if hypot(cur.x - start.x, cur.y - start.y) > 0.001 { pts.append(start) }
                cur = start
            @unknown default:
                break
            }
        }
        return pts
    }

    private static func signedArea(_ pts: [CGPoint]) -> CGFloat {
        var a: CGFloat = 0
        for i in 0..<pts.count {
            let p = pts[i], q = pts[(i + 1) % pts.count]
            a += p.x * q.y - q.x * p.y
        }
        return a / 2
    }

    private static func resample(_ pts: [CGPoint], to n: Int) -> [CGPoint] {
        var closed = pts
        if let f = pts.first, let l = pts.last, hypot(f.x - l.x, f.y - l.y) > 0.001 { closed.append(f) }
        var cum: [CGFloat] = [0]
        for i in 1..<closed.count {
            cum.append(cum[i - 1] + hypot(closed[i].x - closed[i - 1].x, closed[i].y - closed[i - 1].y))
        }
        let total = cum.last ?? 1
        var out: [CGPoint] = []
        out.reserveCapacity(n)
        var seg = 1
        for k in 0..<n {
            let target = total * CGFloat(k) / CGFloat(n)
            while seg < cum.count - 1 && cum[seg] < target { seg += 1 }
            let span = max(cum[seg] - cum[seg - 1], 0.0001)
            let f = (target - cum[seg - 1]) / span
            let a = closed[seg - 1], b = closed[seg]
            out.append(CGPoint(x: a.x + (b.x - a.x) * f, y: a.y + (b.y - a.y) * f))
        }
        return out
    }
}

// MARK: - OKLCH colour blend
enum SpriteColorBlend {
    private struct LCH { var l: Double; var c: Double; var h: Double }

    private static func toLCH(_ color: Color) -> LCH {
        #if canImport(UIKit)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        let r: CGFloat = 0.5, g: CGFloat = 0.5, b: CGFloat = 0.5
        #endif
        func lin(_ v: CGFloat) -> Double {
            let d = Double(v)
            return d <= 0.04045 ? d / 12.92 : pow((d + 0.055) / 1.055, 2.4)
        }
        let lr = lin(r), lg = lin(g), lb = lin(b)
        let l = cbrt(0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb)
        let m = cbrt(0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb)
        let s = cbrt(0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb)
        let L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
        let A = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
        let B = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
        return LCH(l: L, c: hypot(A, B), h: atan2(B, A))
    }

    private static func fromLCH(_ v: LCH) -> Color {
        let A = v.c * cos(v.h), B = v.c * sin(v.h)
        let l = pow(v.l + 0.3963377774 * A + 0.2158037573 * B, 3)
        let m = pow(v.l - 0.1055613458 * A - 0.0638541728 * B, 3)
        let s = pow(v.l - 0.0894841775 * A - 1.2914855480 * B, 3)
        let r = 4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
        let g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
        let b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
        func enc(_ x: Double) -> Double {
            let c = min(max(x, 0), 1)
            return c <= 0.0031308 ? 12.92 * c : 1.055 * pow(c, 1 / 2.4) - 0.055
        }
        return Color(red: enc(r), green: enc(g), blue: enc(b))
    }

    private static let cache: [BranchSprite: [LCH]] = {
        var d: [BranchSprite: [LCH]] = [:]
        for s in BranchSprite.allCases { d[s] = s.gradientColors.map(toLCH) }
        return d
    }()

    static func gradient(from: BranchSprite, to: BranchSprite, t: CGFloat) -> LinearGradient {
        let k = Double(min(max(t, 0), 1))
        guard from != to, let a = cache[from], let b = cache[to] else { return to.gradient }
        let colors: [Color] = (0..<min(a.count, b.count)).map { i in
            var dh = b[i].h - a[i].h
            if dh > .pi { dh -= 2 * .pi } else if dh < -.pi { dh += 2 * .pi }
            return fromLCH(LCH(
                l: a[i].l + (b[i].l - a[i].l) * k,
                c: a[i].c + (b[i].c - a[i].c) * k,
                h: a[i].h + dh * k
            ))
        }
        return LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
    }
}

// MARK: - Morph body (shape + colour driven by one animated t)
struct SpriteMorphBody: View, @preconcurrency Animatable {
    var from: BranchSprite
    var to: BranchSprite
    var t: CGFloat
    var trueMorph: Bool

    var animatableData: CGFloat {
        get { t }
        set { t = newValue }
    }

    var body: some View {
        let k = max(0, min(1, t))
        let fill = SpriteColorBlend.gradient(from: from, to: to, t: k)
        ZStack {
            if trueMorph {
                SpriteMorphShape(from: from, to: to, t: t).fill(fill)
            } else {
                SpriteBodyShape(sprite: from).fill(fill).opacity(1 - Double(k))
                SpriteBodyShape(sprite: to).fill(fill).opacity(Double(k))
            }
        }
    }
}

// MARK: - Morph Shape
/// Interpolates between two sampled silhouettes. `t` is animatable, so a spring gives a gooey,
/// slightly overshooting flow from one shape into the next.
struct SpriteMorphShape: Shape {
    var from: BranchSprite
    var to: BranchSprite
    var t: CGFloat

    var animatableData: CGFloat {
        get { t }
        set { t = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let a = SpriteMorphSampler.points(for: from)
        let b = SpriteMorphSampler.alignedTarget(from: from, to: to)
        let scale = min(rect.width, rect.height) / SpriteMorphSampler.box
        let ox = rect.minX + (rect.width - SpriteMorphSampler.box * scale) / 2
        let oy = rect.minY + (rect.height - SpriteMorphSampler.box * scale) / 2
        let pts: [CGPoint] = (0..<a.count).map { i in
            CGPoint(
                x: ox + (a[i].x + (b[i].x - a[i].x) * t) * scale,
                y: oy + (a[i].y + (b[i].y - a[i].y) * t) * scale
            )
        }
        var path = Path()
        guard pts.count > 2 else { return path }
        func mid(_ p: CGPoint, _ q: CGPoint) -> CGPoint { CGPoint(x: (p.x + q.x) / 2, y: (p.y + q.y) / 2) }
        path.move(to: mid(pts[pts.count - 1], pts[0]))
        for i in 0..<pts.count {
            path.addQuadCurve(to: mid(pts[i], pts[(i + 1) % pts.count]), control: pts[i])
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Morphing Sprite View
/// The onboarding sprite. `family == nil` means "shapeless": it cycles Cloud, Spark, Prism, Bloom
/// every 2.5s with each family's gradient while the eyes stay level and keep blinking.
/// A non-nil family morphs into that silhouette and stays.
public struct MorphingSpriteView: View {
    public let family: BranchSprite?
    public var isBlinking: Bool
    public var eyeStyle: SpriteEyeStyle
    public var breathing: Bool
    public var cycleInterval: Double

    /// Set false (launch arg `-spriteCrossfade`) to force the crossfade fallback instead of the point-sampled morph.
    public static var usesTrueMorph: Bool {
        !CommandLine.arguments.contains("-spriteCrossfade")
    }

    static let cycleOrder: [BranchSprite] = [.cloud, .spark, .prism, .bloom]

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var from: BranchSprite
    @State private var to: BranchSprite
    @State private var t: CGFloat = 1
    @State private var squash: CGFloat = 1
    @State private var cycleIndex: Int = 0

    public init(
        family: BranchSprite?,
        isBlinking: Bool = false,
        eyeStyle: SpriteEyeStyle = .open,
        breathing: Bool = false,
        cycleInterval: Double = 2.5
    ) {
        self.family = family
        self.isBlinking = isBlinking
        self.eyeStyle = eyeStyle
        self.breathing = breathing
        self.cycleInterval = cycleInterval
        let start = family ?? Self.cycleOrder[0]
        self._from = State(initialValue: start)
        self._to = State(initialValue: start)
    }

    private var target: BranchSprite {
        family ?? Self.cycleOrder[cycleIndex % Self.cycleOrder.count]
    }

    private var trueMorph: Bool { Self.usesTrueMorph && !reduceMotion }

    public var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            Group {
                if breathing && !reduceMotion {
                    TimelineView(.animation) { timeline in
                        let phase = timeline.date.timeIntervalSinceReferenceDate / 4.0 * 2 * .pi
                        sprite(side: side)
                            .scaleEffect(1 + 0.02 * CGFloat(sin(phase)), anchor: .bottom)
                    }
                } else {
                    sprite(side: side)
                }
            }
            .frame(width: side, height: side)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .onChange(of: target) { _, newValue in
            morph(to: newValue)
        }
        .task(id: family == nil) {
            guard family == nil else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(cycleInterval * 1_000_000_000))
                guard !Task.isCancelled else { return }
                cycleIndex += 1
            }
        }
        .accessibilityHidden(true)
    }

    private func sprite(side: CGFloat) -> some View {
        let ink = Color(red: 0.137, green: 0.122, blue: 0.125)
        let k = max(0, min(1, t))
        let eyeT = trueMorph ? t : k
        let a = SpriteMorphSampler.eyes(for: from)
        let b = SpriteMorphSampler.eyes(for: to)
        func lerp(_ p: CGPoint, _ q: CGPoint) -> CGPoint {
            CGPoint(x: p.x + (q.x - p.x) * eyeT, y: p.y + (q.y - p.y) * eyeT)
        }
        let scale = side / SpriteMorphSampler.box
        let l = lerp(a.left, b.left), r = lerp(a.right, b.right)
        let rx = (a.rx + (b.rx - a.rx) * eyeT) * scale
        let ry = (a.ry + (b.ry - a.ry) * eyeT) * scale

        return ZStack {
            // One shape, one gradient whose stops are interpolated in OKLCH: chroma stays high the whole way,
            // so the colour change reads as a saturated hue sweep instead of passing through muddy grey.
            // (An Animatable view, so the colour is recomputed from the animated t every frame; SwiftUI's own
            // gradient interpolation would blend in RGB and go grey.)
            SpriteMorphBody(from: from, to: to, t: t, trueMorph: trueMorph)

            SpriteEyePair(
                left: CGPoint(x: l.x * scale, y: l.y * scale),
                right: CGPoint(x: r.x * scale, y: r.y * scale),
                size: CGSize(width: rx * 2, height: ry * 2),
                isBlinking: isBlinking,
                style: eyeStyle,
                color: ink
            )
        }
        .frame(width: side, height: side)
        .scaleEffect(squash, anchor: .bottom)
    }

    private func morph(to newValue: BranchSprite) {
        guard newValue != to || t < 1 else { return }
        let current = t > 0.5 ? to : from
        var instant = Transaction()
        instant.disablesAnimations = true
        withTransaction(instant) {
            from = current
            to = newValue
            t = 0
            if !reduceMotion { squash = 0.95 }
        }
        Task { @MainActor in
            if reduceMotion {
                withAnimation(.easeInOut(duration: 0.3)) { t = 1 }
            } else if trueMorph {
                withAnimation(.spring(response: 0.62, dampingFraction: 0.68)) { t = 1 }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.45)) { squash = 1 }
            } else {
                withAnimation(.easeInOut(duration: 0.4)) { t = 1 }
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) { squash = 1 }
            }
        }
    }
}
