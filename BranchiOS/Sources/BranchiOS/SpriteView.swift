import SwiftUI

// MARK: - CMYK Sprites
public enum CMYKSprite: String, CaseIterable, Identifiable, Sendable {
    case cyan = "Cyan"
    case magenta = "Magenta"
    case yellow = "Yellow"
    case key = "Key"
    
    public var id: String { rawValue }
    
    public var hex: String {
        switch self {
        case .cyan: return "#26C6DA"
        case .magenta: return "#E91E63"
        case .yellow: return "#FFD600"
        case .key: return "#1A1A1A"
        }
    }
    
    public static func from(hex: String) -> CMYKSprite {
        if let match = allCases.first(where: { $0.hex.lowercased() == hex.lowercased() }) {
            return match
        }
        return .cyan
    }
    
    public func color(for colorScheme: ColorScheme) -> Color {
        switch self {
        case .cyan:
            return Color(red: 0.15, green: 0.78, blue: 0.85)
        case .magenta:
            return Color(red: 0.91, green: 0.12, blue: 0.39)
        case .yellow:
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .key:
            return colorScheme == .dark ? Color(white: 0.28) : Color(white: 0.12)
        }
    }
}

// MARK: - Animatable Sprite Arm Shape
public struct SpriteArmShape: Shape {
    public var pose: CGFloat // 0.0 (lowered) to 1.0 (raised), supports -0.15 (dip) and 1.10 (overshoot)
    public let isLeft: Bool
    
    public var animatableData: CGFloat {
        get { pose }
        set { pose = newValue }
    }
    
    public init(pose: CGFloat = 0.25, isLeft: Bool) {
        self.pose = pose
        self.isLeft = isLeft
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let p = pose
        
        if isLeft {
            // Curves out from mid-left body and arches upward
            let start = CGPoint(x: w, y: h * 0.72)
            
            // Interpolate tip and control points smoothly between Lowered (0.0) and Raised (1.0)
            let tipX = w * (0.22 + 0.50 * p)
            let tipY = h * (0.45 - 0.75 * p)
            let c1X = w * (0.42 - 0.26 * p)
            let c1Y = h * (0.84 - 0.18 * p)
            let c2X = w * (-0.06 - 0.08 * p)
            let c2Y = h * (0.58 - 0.52 * p)
            
            path.move(to: start)
            path.addCurve(
                to: CGPoint(x: tipX, y: tipY),
                control1: CGPoint(x: c1X, y: c1Y),
                control2: CGPoint(x: c2X, y: c2Y)
            )
        } else {
            // Curves out from mid-right body and arches upward
            let start = CGPoint(x: 0, y: h * 0.72)
            
            let tipX = w * (0.78 - 0.50 * p)
            let tipY = h * (0.45 - 0.75 * p)
            let c1X = w * (0.58 + 0.26 * p)
            let c1Y = h * (0.84 - 0.18 * p)
            let c2X = w * (1.06 + 0.08 * p)
            let c2Y = h * (0.58 - 0.52 * p)
            
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

// MARK: - Animatable Sprite Flex Arm Shape (Sync & Complete)
public struct SpriteFlexArmShape: Shape {
    public var flexProgress: CGFloat // 0.0 = resting hanging curve (Syncing/Almost there), 1.0 = 90° bicep flex (Complete)
    
    public var animatableData: CGFloat {
        get { flexProgress }
        set { flexProgress = newValue }
    }
    
    public init(flexProgress: CGFloat = 0.0) {
        self.flexProgress = flexProgress
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let p = flexProgress
        
        // Attached to the left side of the sprite body (right edge of arm rect)
        let start = CGPoint(x: w, y: h * (0.70 + 0.02 * p))
        
        // In resting pose (p = 0): gentle outward hanging curve
        // In complete pose (p = 1): smooth U-shaped curl bending up with tip curling slightly inward
        let tipX = w * (0.12 + 0.16 * p)
        let tipY = h * (0.75 - 0.62 * p)
        
        let c1X = w * (0.68 - 0.22 * p)
        let c1Y = h * (0.82 + 0.14 * p)
        let c2X = w * (0.32 - 0.38 * p)
        let c2Y = h * (0.90 - 0.48 * p)
        
        path.move(to: start)
        path.addCurve(
            to: CGPoint(x: tipX, y: tipY),
            control1: CGPoint(x: c1X, y: c1Y),
            control2: CGPoint(x: c2X, y: c2Y)
        )
        return path
    }
}

// MARK: - Canonical SpriteView
public struct SpriteView: View {
    public let sprite: CMYKSprite
    public let isBlinking: Bool
    public let showsArms: Bool
    public var leftArmPose: CGFloat
    public var rightArmPose: CGFloat
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        sprite: CMYKSprite,
        isBlinking: Bool = false,
        showsArms: Bool = false,
        leftArmPose: CGFloat = 0.25,
        rightArmPose: CGFloat = 0.25
    ) {
        self.sprite = sprite
        self.isBlinking = isBlinking
        self.showsArms = showsArms
        self.leftArmPose = leftArmPose
        self.rightArmPose = rightArmPose
    }
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let spriteColor = sprite.color(for: colorScheme)
            
            ZStack(alignment: .bottom) {
                // Curved Arms (Figma Frames 2 & 10) - Raised arm reaches well above the head
                if showsArms {
                    let armWidth = w * 0.32
                    let armHeight = h * 0.98
                    let effectiveLeft = reduceMotion ? 0.25 : leftArmPose
                    let effectiveRight = reduceMotion ? 0.25 : rightArmPose
                    
                    // Left Arm
                    SpriteArmShape(pose: effectiveLeft, isLeft: true)
                        .stroke(
                            spriteColor,
                            style: StrokeStyle(lineWidth: max(w * 0.045, 10), lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: armWidth, height: armHeight)
                        .position(x: w * 0.08, y: h * 0.35)
                    
                    // Right Arm
                    SpriteArmShape(pose: effectiveRight, isLeft: false)
                        .stroke(
                            spriteColor,
                            style: StrokeStyle(lineWidth: max(w * 0.045, 10), lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: armWidth, height: armHeight)
                        .position(x: w * 0.92, y: h * 0.35)
                }
                
                // Central Dome Body
                ZStack(alignment: .bottom) {
                    UnevenRoundedRectangle(
                        topLeadingRadius: w / 2,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: w / 2,
                        style: .continuous
                    )
                    .fill(spriteColor)
                    .overlay(
                        // Outline for Key in dark mode
                        UnevenRoundedRectangle(
                            topLeadingRadius: w / 2,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: w / 2,
                            style: .continuous
                        )
                        .stroke(colorScheme == .dark && sprite == .key ? Color.white.opacity(0.35) : Color.clear, lineWidth: 1.5)
                    )
                    
                    // Two tall white vertical oval eyes
                    HStack(spacing: w * 0.18) {
                        Capsule()
                            .fill(Color.white)
                            .frame(width: w * 0.088, height: h * 0.34)
                            .scaleEffect(y: isBlinking ? 0.08 : 1.0, anchor: .center)
                        
                        Capsule()
                            .fill(Color.white)
                            .frame(width: w * 0.088, height: h * 0.34)
                            .scaleEffect(y: isBlinking ? 0.08 : 1.0, anchor: .center)
                    }
                    .padding(.bottom, h * 0.30)
                }
                .frame(width: w, height: h)
            }
            .frame(width: w, height: h)
        }
    }
}

// Backward compatibility alias
public typealias DomeSpriteView = SpriteView
