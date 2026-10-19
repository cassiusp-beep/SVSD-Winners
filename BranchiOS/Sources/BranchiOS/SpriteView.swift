import SwiftUI
import CoreGraphics

// MARK: - New Sprite Shapes (App-wide canonical sprite system)
public enum BranchSprite: String, CaseIterable, Identifiable, Sendable {
    case cloud = "Cloud"
    case bloom = "Bloom"
    case prism = "Prism"
    case spark = "Spark"
    
    public var id: String { rawValue }
    
    // Canonical artwork viewBox sizes
    public var viewBoxSize: CGSize {
        switch self {
        case .cloud: return CGSize(width: 67.30, height: 67.71)
        case .bloom: return CGSize(width: 76.16, height: 67.58)
        case .prism: return CGSize(width: 71.01, height: 65.71)
        case .spark: return CGSize(width: 74.14, height: 74.14)
        }
    }
    
    // Normalized eye centers (0.0 to 1.0)
    public var leftEyeNormalized: CGPoint {
        switch self {
        case .cloud: return CGPoint(x: 24.48 / 67.30, y: 34.43 / 67.71)
        case .bloom: return CGPoint(x: 28.91 / 76.16, y: 34.37 / 67.58)
        case .prism: return CGPoint(x: 26.33 / 71.01, y: 38.28 / 65.71)
        case .spark: return CGPoint(x: 27.90 / 74.14, y: 37.65 / 74.14)
        }
    }
    
    public var rightEyeNormalized: CGPoint {
        switch self {
        case .cloud: return CGPoint(x: 42.82 / 67.30, y: 34.43 / 67.71)
        case .bloom: return CGPoint(x: 47.26 / 76.16, y: 34.37 / 67.58)
        case .prism: return CGPoint(x: 44.68 / 71.01, y: 38.28 / 65.71)
        case .spark: return CGPoint(x: 46.24 / 74.14, y: 37.65 / 74.14)
        }
    }
    
    // Normalized eye radius (0.0 to 1.0)
    public var eyeRadiusNormalized: (rx: CGFloat, ry: CGFloat) {
        let vb = viewBoxSize
        return (rx: 2.87 / vb.width, ry: 4.84 / vb.height)
    }
    
    // Normalized arm anchor points (sides of body near mid-height)
    public var leftArmAnchorNormalized: CGPoint {
        switch self {
        case .cloud: return CGPoint(x: 0.06, y: 0.50)
        case .bloom: return CGPoint(x: 0.04, y: 0.50)
        case .prism: return CGPoint(x: 0.12, y: 0.54)
        case .spark: return CGPoint(x: 0.05, y: 0.50)
        }
    }
    
    public var rightArmAnchorNormalized: CGPoint {
        switch self {
        case .cloud: return CGPoint(x: 0.94, y: 0.50)
        case .bloom: return CGPoint(x: 0.96, y: 0.50)
        case .prism: return CGPoint(x: 0.88, y: 0.54)
        case .spark: return CGPoint(x: 0.95, y: 0.50)
        }
    }
    
    // Primary gradient colors
    public var gradientColors: [Color] {
        switch self {
        case .cloud:
            return [Color(red: 0.627, green: 0.514, blue: 0.737), Color(red: 0.839, green: 0.780, blue: 0.886)] // #a083bc -> #d6c7e2
        case .bloom:
            return [Color(red: 0.839, green: 0.467, blue: 0.275), Color(red: 0.910, green: 0.733, blue: 0.408)] // #d67746 -> #e8bb68
        case .prism:
            return [Color(red: 0.271, green: 0.596, blue: 0.733), Color(red: 0.557, green: 0.831, blue: 0.855)] // #4598bb -> #8ed4da
        case .spark:
            return [Color(red: 0.541, green: 0.682, blue: 0.514), Color(red: 0.816, green: 0.894, blue: 0.667)] // #8aae83 -> #d0e4aa
        }
    }
    
    public var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    public var primaryHex: String {
        switch self {
        case .cloud: return "#A083BC"
        case .bloom: return "#D67746"
        case .prism: return "#4598BB"
        case .spark: return "#8AAE83"
        }
    }
    
    public var hex: String { primaryHex }
    
    public func color(for colorScheme: ColorScheme? = nil) -> Color {
        gradientColors[0]
    }
    
    public func takeawayGradient(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return self.gradient
        } else {
            // Rich high-contrast gradients for pure white background in light mode
            switch self {
            case .cloud:
                return LinearGradient(
                    colors: [Color(red: 0.490, green: 0.350, blue: 0.630), Color(red: 0.640, green: 0.480, blue: 0.760)],
                    startPoint: .leading, endPoint: .trailing
                )
            case .bloom:
                return LinearGradient(
                    colors: [Color(red: 0.780, green: 0.360, blue: 0.160), Color(red: 0.860, green: 0.540, blue: 0.220)],
                    startPoint: .leading, endPoint: .trailing
                )
            case .prism:
                return LinearGradient(
                    colors: [Color(red: 0.160, green: 0.480, blue: 0.620), Color(red: 0.280, green: 0.640, blue: 0.700)],
                    startPoint: .leading, endPoint: .trailing
                )
            case .spark:
                return LinearGradient(
                    colors: [Color(red: 0.350, green: 0.530, blue: 0.320), Color(red: 0.520, green: 0.680, blue: 0.420)],
                    startPoint: .leading, endPoint: .trailing
                )
            }
        }
    }
    
    // Backward compatibility with older CMYK hexes
    public static func from(hex: String) -> BranchSprite {
        let lower = hex.lowercased()
        if lower.contains("a083bc") || lower.contains("d6c7e2") || lower.contains("cloud") {
            return .cloud
        }
        if lower.contains("d67746") || lower.contains("e8bb68") || lower.contains("bloom") || lower.contains("ffd600") || lower.contains("yellow") || lower.contains("f5a623") || lower.contains("orange") {
            return .bloom
        }
        if lower.contains("4598bb") || lower.contains("8ed4da") || lower.contains("prism") || lower.contains("26c6da") || lower.contains("cyan") {
            return .prism
        }
        if lower.contains("8aae83") || lower.contains("d0e4aa") || lower.contains("spark") || lower.contains("e91e63") || lower.contains("magenta") || lower.contains("key") {
            return .spark
        }
        return .cloud
    }
    
    // Backward-compatibility aliases for CMYK cases
    public static var cyan: BranchSprite { .prism }
    public static var magenta: BranchSprite { .cloud }
    public static var yellow: BranchSprite { .bloom }
    public static var key: BranchSprite { .spark }
}

// Backward-compatibility alias
public typealias CMYKSprite = BranchSprite

// MARK: - Exact SVG Vector Path Provider
public enum SpritePathVault {
    public static func path(for sprite: BranchSprite, in rect: CGRect) -> Path {
        let vb = sprite.viewBoxSize
        let scale = min(rect.width / vb.width, rect.height / vb.height)
        let offsetX = (rect.width - vb.width * scale) / 2
        let offsetY = (rect.height - vb.height * scale) / 2
        
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: offsetX + x * scale, y: offsetY + y * scale)
        }
        
        var path = Path()
        
        switch sprite {
        case .cloud:
            path.move(to: pt(65.73, 34.1))
            path.addCurve(
                to: pt(65.73 - 1.04, 34.1 + 7.84),
                control1: pt(65.73 - 1.62, 34.1 + 2.29),
                control2: pt(65.73 - 2.01, 34.1 + 5.22)
            )
            var cur = pt(65.73 - 1.04, 34.1 + 7.84)
            
            func addC(_ dc1x: CGFloat, _ dc1y: CGFloat, _ dc2x: CGFloat, _ dc2y: CGFloat, _ dx: CGFloat, _ dy: CGFloat) {
                let end = CGPoint(x: cur.x + dx * scale, y: cur.y + dy * scale)
                path.addCurve(
                    to: end,
                    control1: CGPoint(x: cur.x + dc1x * scale, y: cur.y + dc1y * scale),
                    control2: CGPoint(x: cur.x + dc2x * scale, y: cur.y + dc2y * scale)
                )
                cur = end
            }
            
            addC(0.36, 0.97, 0.53, 1.97, 0.53, 2.94)
            addC(0, 3.53, -2.22, 6.83, -5.77, 8.03)
            addC(-2.65, 0.89, -4.69, 3.04, -5.45, 5.73)
            addC(-1.05, 3.75, -4.46, 6.18, -8.16, 6.18)
            addC(-0.84, 0, -1.69, -0.13, -2.53, -0.39)
            addC(-2.67, -0.83, -5.58, -0.3, -7.78, 1.44)
            addC(-1.56, 1.23, -3.41, 1.82, -5.24, 1.82)
            addC(-2.58, 0, -5.14, -1.17, -6.81, -3.41)
            addC(-1.67, -2.25, -4.34, -3.52, -7.14, -3.41)
            addC(-0.12, 0, -0.23, 0, -0.35, 0)
            addC(-4.62, 0, -8.41, -3.72, -8.46, -8.38)
            addC(-0.03, -2.8, -1.44, -5.4, -3.77, -6.95)
            addC(-3.97, -2.65, -4.97, -8.06, -2.21, -11.95)
            addC(1.03, -1.45, 1.56, -3.17, 1.56, -4.9)
            addC(0, -0.99, -0.18, -1.99, -0.53, -2.95)
            addC(-1.65, -4.48, 0.71, -9.44, 5.24, -10.97)
            addC(1.33, -0.45, 2.5, -1.21, 3.44, -2.19)
            addC(0.94, -0.99, 1.64, -2.2, 2.01, -3.54)
            addC(1.29, -4.59, 6.13, -7.22, 10.69, -5.8)
            addC(0.83, 0.26, 1.69, 0.39, 2.54, 0.39)
            addC(1.88, 0, 3.73, -0.63, 5.24, -1.82)
            addC(3.75, -2.96, 9.2, -2.24, 12.05, 1.59)
            addC(1.67, 2.25, 4.34, 3.52, 7.14, 3.41)
            addC(0.12, 0, 0.23, 0, 0.35, 0)
            addC(4.62, 0, 8.41, 3.72, 8.47, 8.38)
            addC(0.01, 1.4, 0.38, 2.75, 1.03, 3.94)
            addC(0.64, 1.19, 1.58, 2.23, 2.75, 3.01)
            addC(2.45, 1.64, 3.77, 4.32, 3.77, 7.06)
            addC(0, 1.69, -0.51, 3.41, -1.57, 4.9)
            path.closeSubpath()
            
        case .bloom:
            path.move(to: pt(73.64, 38.68))
            var cur = pt(73.64, 38.68)
            
            func addL(_ dx: CGFloat, _ dy: CGFloat) {
                let end = CGPoint(x: cur.x + dx * scale, y: cur.y + dy * scale)
                path.addLine(to: end)
                cur = end
            }
            func addC(_ dc1x: CGFloat, _ dc1y: CGFloat, _ dc2x: CGFloat, _ dc2y: CGFloat, _ dx: CGFloat, _ dy: CGFloat) {
                let end = CGPoint(x: cur.x + dx * scale, y: cur.y + dy * scale)
                path.addCurve(
                    to: end,
                    control1: CGPoint(x: cur.x + dc1x * scale, y: cur.y + dc1y * scale),
                    control2: CGPoint(x: cur.x + dc2x * scale, y: cur.y + dc2y * scale)
                )
                cur = end
            }
            
            addL(-8.95, 6.37)
            addC(-2.02, 1.44, -3.31, 3.68, -3.55, 6.14)
            addL(-1.04, 10.94)
            addC(-0.39, 4.11, -4.72, 6.61, -8.47, 4.9)
            addL(-10, -4.57)
            addC(-2.25, -1.03, -4.84, -1.03, -7.1, 0)
            addL(-9.99, 4.57)
            addC(-3.76, 1.72, -8.09, -0.78, -8.47, -4.9)
            addL(-1.04, -10.94)
            addC(-0.23, -2.47, -1.53, -4.71, -3.55, -6.14)
            addL(-8.95, -6.37)
            addC(-3.37, -2.39, -3.37, -7.39, 0, -9.79)
            addL(8.95, -6.37)
            addC(2.02, -1.44, 3.32, -3.68, 3.55, -6.14)
            addL(1.04, -10.94)
            addC(0.39, -4.11, 4.72, -6.61, 8.47, -4.9)
            addL(9.99, 4.57)
            addC(2.25, 1.03, 4.84, 1.03, 7.1, 0)
            
            // L51.63, 0.55
            cur = pt(51.63, 0.55)
            path.addLine(to: cur)
            
            addC(3.76, -1.72, 8.08, 0.78, 8.47, 4.9)
            addL(1.04, 10.94)
            addC(0.24, 2.46, 1.53, 4.71, 3.55, 6.14)
            addL(8.95, 6.37)
            addC(3.36, 2.39, 3.36, 7.39, 0, 9.79)
            path.closeSubpath()
            
        case .prism:
            path.move(to: pt(52.75, 65.54))
            var cur = pt(52.75, 65.54)
            
            func addL(_ dx: CGFloat, _ dy: CGFloat) {
                let end = CGPoint(x: cur.x + dx * scale, y: cur.y + dy * scale)
                path.addLine(to: end)
                cur = end
            }
            func addC(_ dc1x: CGFloat, _ dc1y: CGFloat, _ dc2x: CGFloat, _ dc2y: CGFloat, _ dx: CGFloat, _ dy: CGFloat) {
                let end = CGPoint(x: cur.x + dx * scale, y: cur.y + dy * scale)
                path.addCurve(
                    to: end,
                    control1: CGPoint(x: cur.x + dc1x * scale, y: cur.y + dc1y * scale),
                    control2: CGPoint(x: cur.x + dc2x * scale, y: cur.y + dc2y * scale)
                )
                cur = end
            }
            
            addL(-11.12, -1.57)
            addC(-4.06, -0.58, -8.2, -0.58, -12.26, 0)
            addL(-11.12, 1.57)
            addC(-14.24, 2.01, -23.68, -14.34, -14.81, -25.66)
            addL(6.92, -8.84)
            addC(2.53, -3.23, 4.59, -6.81, 6.13, -10.62)
            addL(4.19, -10.41)
            addC(5.37, -13.34, 24.26, -13.34, 29.63, 0)
            addL(4.19, 10.41)
            addC(1.54, 3.81, 3.6, 7.39, 6.13, 10.62)
            addL(6.92, 8.84)
            addC(8.86, 11.32, -0.58, 27.68, -14.81, 25.66)
            path.closeSubpath()
            
        case .spark:
            path.move(to: pt(67.42, 46.74))
            var cur = pt(67.42, 46.74)
            
            func addL(_ dx: CGFloat, _ dy: CGFloat) {
                let end = CGPoint(x: cur.x + dx * scale, y: cur.y + dy * scale)
                path.addLine(to: end)
                cur = end
            }
            func addC(_ dc1x: CGFloat, _ dc1y: CGFloat, _ dc2x: CGFloat, _ dc2y: CGFloat, _ dx: CGFloat, _ dy: CGFloat) {
                let end = CGPoint(x: cur.x + dx * scale, y: cur.y + dy * scale)
                path.addCurve(
                    to: end,
                    control1: CGPoint(x: cur.x + dc1x * scale, y: cur.y + dc1y * scale),
                    control2: CGPoint(x: cur.x + dc2x * scale, y: cur.y + dc2y * scale)
                )
                cur = end
            }
            
            addL(-6.33, 2.34)
            addC(-5.56, 2.06, -9.95, 6.45, -12, 12.01)
            addL(-2.35, 6.33)
            addC(-3.32, 8.97, -16, 8.97, -19.33, 0)
            addL(-2.34, -6.33)
            addC(-2.06, -5.56, -6.44, -9.95, -12, -12.01)
            addL(-6.33, -2.34)
            addC(-8.97, -3.32, -8.97, -16.01, 0, -19.33)
            addL(6.33, -2.34)
            addC(5.56, -2.06, 9.95, -6.45, 12, -12.01)
            addL(2.34, -6.33)
            addC(3.32, -8.97, 16.01, -8.97, 19.33, 0)
            addL(2.35, 6.33)
            addC(2.06, 5.56, 6.44, 9.95, 12, 12.01)
            addL(6.33, 2.34)
            addC(8.97, 3.32, 8.97, 16, 0, 19.33)
        }
        
        return path
    }
}

// MARK: - Sprite Body Shape
public struct SpriteBodyShape: Shape {
    public let sprite: BranchSprite
    
    public init(sprite: BranchSprite) {
        self.sprite = sprite
    }
    
    public func path(in rect: CGRect) -> Path {
        SpritePathVault.path(for: sprite, in: rect)
    }
}

// MARK: - Silhouette-based arm attachment (arms live in the SAME square as MorphingSpriteView's body)
extension BranchSprite {
    /// Attach point for an arm in a `side` x `side` square that holds the body exactly as
    /// `MorphingSpriteView` draws it. Found on the real silhouette at the mid-height of the VISIBLE body
    /// (`crop` = fraction of the square height that is on screen), then moved `inset` pt inside the
    /// body so the joint is hidden when the arm is drawn behind the body.
    func armAttachPoint(isLeft: Bool, side: CGFloat, crop: CGFloat, inset: CGFloat = 10) -> CGPoint {
        let pts = SpriteMorphSampler.points(for: self)
        let top = pts.map(\.y).min() ?? 0
        let bottom = min(pts.map(\.y).max() ?? 100, crop * 100)
        let ym = (top + bottom) / 2
        var xs: [CGFloat] = []
        for i in 0..<pts.count {
            let a = pts[i], b = pts[(i + 1) % pts.count]
            if (a.y - ym) * (b.y - ym) <= 0, a.y != b.y {
                xs.append(a.x + (b.x - a.x) * (ym - a.y) / (b.y - a.y))
            }
        }
        let k = side / 100
        let edge = (isLeft ? xs.min() : xs.max()) ?? (isLeft ? 10 : 90)
        let x = edge * k + (isLeft ? inset : -inset)
        return CGPoint(x: x, y: ym * k)
    }
}

// MARK: - Tailored Animatable Sprite Arm Shape (Attached per-silhouette)
public struct SpriteArmShape: Shape {
    public var pose: CGFloat // 0.0 (lowered) to 1.0 (raised), supports -0.15 (dip) and 1.10 (overshoot)
    public let isLeft: Bool
    public let sprite: BranchSprite
    /// When set, the shape is drawn in the body's own square and attached on the real silhouette.
    public let crop: CGFloat?
    
    public var animatableData: CGFloat {
        get { pose }
        set { pose = newValue }
    }
    
    public init(pose: CGFloat = 0.25, isLeft: Bool, sprite: BranchSprite = .cloud, crop: CGFloat? = nil) {
        self.pose = pose
        self.isLeft = isLeft
        self.sprite = sprite
        self.crop = crop
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let p = pose
        
        if let crop {
            let s = min(w, h)
            let st = sprite.armAttachPoint(isLeft: isLeft, side: s, crop: crop)
            let d: CGFloat = isLeft ? -1 : 1
            let r = 1.5 // reach: the arm is drawn in the sprite square, so scale the horizontal reach
            // Balanced reach: the raised hand tops out about head-height, never a long cane above the head.
            let q = min(max(p, -0.15), 1.1)
            path.move(to: st)
            path.addCurve(
                to: CGPoint(x: st.x + d * s * r * (0.17 + 0.04 * q), y: st.y - s * (0.12 + 0.23 * q)),
                control1: CGPoint(x: st.x + d * s * r * (0.10 + 0.05 * q), y: st.y + s * (0.12 - 0.12 * q)),
                control2: CGPoint(x: st.x + d * s * r * (0.24 + 0.03 * q), y: st.y - s * (0.04 + 0.16 * q))
            )
            return path
        }
        
        if isLeft {
            let anchor = sprite.leftArmAnchorNormalized
            let start = CGPoint(x: w * anchor.x, y: h * anchor.y)
            
            // Juggling arm kinematics: reaches outward to the left and upward
            let tipX = start.x - w * (0.16 + 0.08 * p)
            let tipY = start.y - h * (0.20 + 0.45 * p)
            
            let c1X = start.x - w * (0.10 + 0.08 * p)
            let c1Y = start.y + h * (0.14 - 0.18 * p)
            let c2X = start.x - w * (0.24 + 0.04 * p)
            let c2Y = start.y - h * (0.05 + 0.35 * p)
            
            path.move(to: start)
            path.addCurve(
                to: CGPoint(x: tipX, y: tipY),
                control1: CGPoint(x: c1X, y: c1Y),
                control2: CGPoint(x: c2X, y: c2Y)
            )
        } else {
            let anchor = sprite.rightArmAnchorNormalized
            let start = CGPoint(x: w * anchor.x, y: h * anchor.y)
            
            // Juggling arm kinematics: reaches outward to the right and upward
            let tipX = start.x + w * (0.16 + 0.08 * p)
            let tipY = start.y - h * (0.20 + 0.45 * p)
            
            let c1X = start.x + w * (0.10 + 0.08 * p)
            let c1Y = start.y + h * (0.14 - 0.18 * p)
            let c2X = start.x + w * (0.24 + 0.04 * p)
            let c2Y = start.y - h * (0.05 + 0.35 * p)
            
            path.move(to: start)
            path.addCurve(
                to: CGPoint(x: tipX, y: tipY),
                control1: CGPoint(x: c1X, y: c1Y),
                control2: CGPoint(x: c2X, y: c2Y)
            )
        }
        return path
    }
}

// MARK: - Tailored Animatable Sprite Flex Arm Shape (Sync & Complete)
public struct SpriteFlexArmShape: Shape {
    public var flexProgress: CGFloat
    public let sprite: BranchSprite
    public let crop: CGFloat?
    
    public var animatableData: CGFloat {
        get { flexProgress }
        set { flexProgress = newValue }
    }
    
    public init(flexProgress: CGFloat = 0.0, sprite: BranchSprite = .cloud, crop: CGFloat? = nil) {
        self.flexProgress = flexProgress
        self.sprite = sprite
        self.crop = crop
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let p = flexProgress
        
        if let crop {
            // One smooth U-shaped curl: out to the side, up, and the tip curls slightly inward.
            let s = min(w, h)
            let st = sprite.armAttachPoint(isLeft: true, side: s, crop: crop)
            func lerp(_ a: CGFloat, _ b: CGFloat) -> CGFloat { a + (b - a) * min(max(p, 0), 1.1) }
            func pt(_ rx: CGFloat, _ ry: CGFloat, _ fx: CGFloat, _ fy: CGFloat) -> CGPoint {
                CGPoint(x: st.x + s * lerp(rx, fx), y: st.y + s * lerp(ry, fy))
            }
            // Rest: arm hangs. Flexed: out to the side, elbow rounds under, forearm rises and the tip curls inward.
            path.move(to: st)
            path.addCurve(
                to: pt(-0.18, 0.26, -0.17, -0.31),
                control1: pt(-0.13, 0.05, -0.36, 0.10),
                control2: pt(-0.20, 0.12, -0.44, -0.27)
            )
            return path
        }
        
        let anchor = sprite.leftArmAnchorNormalized
        let start = CGPoint(x: w * anchor.x, y: h * anchor.y)
        
        let tipX = start.x - w * (0.08 + 0.10 * p)
        let tipY = start.y - h * (0.10 + 0.45 * p)
        
        let c1X = start.x - w * (0.16 + 0.02 * p)
        let c1Y = start.y + h * (0.18 - 0.06 * p)
        let c2X = start.x - w * (0.24 - 0.06 * p)
        let c2Y = start.y - h * (0.05 + 0.28 * p)
        
        path.move(to: start)
        path.addCurve(
            to: CGPoint(x: tipX, y: tipY),
            control1: CGPoint(x: c1X, y: c1Y),
            control2: CGPoint(x: c2X, y: c2Y)
        )
        return path
    }
}

// MARK: - Dual-Layer SpriteView (Body layer transforms, eyes stay level and upright)
public struct SpriteView: View {
    public let sprite: BranchSprite
    public let isBlinking: Bool
    public let showsArms: Bool
    public var leftArmPose: CGFloat
    public var rightArmPose: CGFloat
    public var bodyRotation: Angle
    public var bodyScale: CGFloat
    public var gazeOffset: CGSize
    public var haloOpacity: Double
    public var eyeStyle: SpriteEyeStyle
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        sprite: BranchSprite,
        isBlinking: Bool = false,
        showsArms: Bool = false,
        leftArmPose: CGFloat = 0.25,
        rightArmPose: CGFloat = 0.25,
        bodyRotation: Angle = .zero,
        bodyScale: CGFloat = 1.0,
        gazeOffset: CGSize = .zero,
        haloOpacity: Double = 0.0,
        eyeStyle: SpriteEyeStyle = .open
    ) {
        self.sprite = sprite
        self.isBlinking = isBlinking
        self.showsArms = showsArms
        self.leftArmPose = leftArmPose
        self.rightArmPose = rightArmPose
        self.bodyRotation = bodyRotation
        self.bodyScale = bodyScale
        self.gazeOffset = gazeOffset
        self.haloOpacity = haloOpacity
        self.eyeStyle = eyeStyle
    }
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let eyeColor = Color(red: 0.137, green: 0.122, blue: 0.125) // #231f20
            let rad = sprite.eyeRadiusNormalized
            let eyeW = w * rad.rx * 2
            let eyeH = h * rad.ry * 2
            
            ZStack {
                // 1. ARMS LAYER (Behind or aligned with body)
                if showsArms {
                    let effectiveLeft = reduceMotion ? 0.25 : leftArmPose
                    let effectiveRight = reduceMotion ? 0.25 : rightArmPose
                    
                    // Left Arm
                    SpriteArmShape(pose: effectiveLeft, isLeft: true, sprite: sprite)
                        .stroke(
                            sprite.gradient,
                            style: StrokeStyle(lineWidth: max(w * 0.055, 9), lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: w, height: h)
                    
                    // Right Arm
                    SpriteArmShape(pose: effectiveRight, isLeft: false, sprite: sprite)
                        .stroke(
                            sprite.gradient,
                            style: StrokeStyle(lineWidth: max(w * 0.055, 9), lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: w, height: h)
                }
                
                // 2. BODY LAYER (Gradient path transformed by rotation, scale, skew)
                ZStack {
                    // Soft outline halo (when active/talking)
                    if haloOpacity > 0.01 {
                        SpriteBodyShape(sprite: sprite)
                            .stroke(Color.primary.opacity(haloOpacity), lineWidth: 1.5)
                            .scaleEffect(1.08)
                    }
                    
                    SpriteBodyShape(sprite: sprite)
                        .fill(sprite.gradient)
                }
                .rotationEffect(bodyRotation)
                .scaleEffect(bodyScale)
                
                // 3. EYE LAYER (Always stays level and upright, never rotates with body)
                // Translates with gazeOffset; scales vertically on blink.
                let leftEyePt = sprite.leftEyeNormalized
                let rightEyePt = sprite.rightEyeNormalized
                
                SpriteEyePair(
                    left: CGPoint(x: w * leftEyePt.x + gazeOffset.width, y: h * leftEyePt.y + gazeOffset.height),
                    right: CGPoint(x: w * rightEyePt.x + gazeOffset.width, y: h * rightEyePt.y + gazeOffset.height),
                    size: CGSize(width: eyeW, height: eyeH),
                    isBlinking: isBlinking,
                    style: eyeStyle,
                    color: eyeColor
                )
            }
            .frame(width: w, height: h)
        }
    }
}

// Backward-compatibility alias
public typealias DomeSpriteView = SpriteView
