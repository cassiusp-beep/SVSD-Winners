import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Coordinated Sprite & Juggling Stage
public struct JuggleView: View {
    public let connectedIntegrations: [Integration]
    public let userProfile: UserProfile?
    public let activeSprite: CMYKSprite
    public let accentColor: Color
    public var isBlinking: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Continuous time clock driving synchronized arms and orbs
    @State private var time: Double = 0
    @State private var timer: Timer? = nil
    
    // Fumble state
    @State private var isFumbling: Bool = false
    @State private var fumbleStartTime: Double = 0
    
    public init(
        connectedIntegrations: [Integration],
        userProfile: UserProfile?,
        activeSprite: CMYKSprite,
        accentColor: Color = Color(red: 0.15, green: 0.78, blue: 0.85),
        isBlinking: Bool = false
    ) {
        self.connectedIntegrations = connectedIntegrations
        self.userProfile = userProfile
        self.activeSprite = activeSprite
        self.accentColor = accentColor
        self.isBlinking = isBlinking
    }
    
    // Up to 5 items to juggle
    private var juggleItems: [JuggleItem] {
        if connectedIntegrations.isEmpty {
            return [.avatar(userProfile, activeSprite)]
        } else {
            return connectedIntegrations.prefix(5).map { .integration($0) }
        }
    }
    
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let count = max(juggleItems.count, 1)
            let domeWidth: CGFloat = 220
            let domeHeight: CGFloat = 135
            
            // Calculate synchronized arm poses
            let (leftArmPose, rightArmPose) = calculateArmPoses(
                time: time,
                totalOrbs: count,
                isFumbling: isFumbling,
                fumbleElapsed: max(0, time - fumbleStartTime)
            )
            
            ZStack(alignment: .bottom) {
                // Juggled Orbs (rendered above sprite hands)
                ZStack {
                    ForEach(0..<juggleItems.count, id: \.self) { index in
                        let item = juggleItems[index]
                        let (offset, rotation) = calculateOrbPosition(
                            index: index,
                            total: count,
                            width: w,
                            height: h,
                            time: time,
                            isFumbling: isFumbling,
                            fumbleElapsed: max(0, time - fumbleStartTime)
                        )
                        
                        juggleOrbView(for: item)
                            .offset(offset)
                            .rotationEffect(.degrees(rotation))
                    }
                }
                .frame(width: w, height: h)
                
                // Dome Sprite with animated arms moving in sync with the juggle
                SpriteView(
                    sprite: activeSprite,
                    isBlinking: isBlinking,
                    showsArms: true,
                    leftArmPose: leftArmPose,
                    rightArmPose: rightArmPose
                )
                .frame(width: domeWidth, height: domeHeight)
                .offset(y: domeHeight * 0.20)
                .contentShape(Rectangle())
                .onTapGesture {
                    triggerFumble()
                }
                .accessibilityLabel("\(activeSprite.rawValue) sprite character. Tap to fumble.")
            }
            .frame(width: w, height: h, alignment: .bottom)
        }
        .onAppear {
            startJuggleLoop()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // MARK: - Orb Visual Component
    @ViewBuilder
    private func juggleOrbView(for item: JuggleItem) -> some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? Color(white: 0.22) : Color.white)
                .overlay(
                    Circle()
                        .stroke(
                            colorScheme == .dark
                            ? Color.white.opacity(0.14)
                            : Color.black.opacity(0.07),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.15),
                    radius: 5,
                    x: 0,
                    y: 3
                )
            
            switch item {
            case .avatar(_, let sprite):
                DomeSpriteView(sprite: sprite, isBlinking: false)
                    .frame(width: 24, height: 22)
                    .offset(y: 2)
            case .integration(let integration):
                if let image = resolveLogoImage(for: integration) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                } else {
                    Text(integration.initial)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(accentColor)
                }
            }
        }
        .frame(width: 42, height: 42)
    }
    
    // MARK: - Arm Pose Calculations
    private func calculateArmPoses(
        time: Double,
        totalOrbs: Int,
        isFumbling: Bool,
        fumbleElapsed: Double
    ) -> (CGFloat, CGFloat) {
        if reduceMotion {
            // Symmetrical, still, slightly raised pose (no alternating)
            return (0.25, 0.25)
        }
        
        if isFumbling {
            // Fumble: arms flail erratically out of rhythm
            let fumbleDuration = 1.25
            if fumbleElapsed < fumbleDuration {
                let progress = fumbleElapsed / fumbleDuration
                let decay = 1.0 - progress
                let flailL = sin(fumbleElapsed * 28) * decay
                let flailR = cos(fumbleElapsed * 32 + 1.4) * decay
                let left = max(-0.15, min(1.0, 0.35 + flailL * 0.50))
                let right = max(-0.15, min(1.0, 0.30 + flailR * 0.50))
                return (left, right)
            }
        }
        
        // Single-orb or multi-orb alternating rhythm (Period = 2.0s)
        let period = totalOrbs == 1 ? 2.0 : 1.6
        let u = (time / period).truncatingRemainder(dividingBy: 1.0)
        
        let leftPose = singleArmCycle(u: u)
        let uRight = (u + 0.50).truncatingRemainder(dividingBy: 1.0)
        let rightPose = singleArmCycle(u: uRight)
        
        return (leftPose, rightPose)
    }
    
    // Evaluate a single arm's juggling cycle for normalized phase u in [0, 1)
    private func singleArmCycle(u: Double) -> CGFloat {
        if u < 0.10 {
            // Catch & Dip: absorbs weight with an ease-out dip (down to -0.15)
            let prog = u / 0.10
            let dip = sin(prog * .pi / 2)
            return CGFloat(1.0 - 1.15 * dip)
        } else if u < 0.24 {
            // Push Up & Toss: swift push-up with spring overshoot at release (up to 1.10)
            let prog = (u - 0.10) / 0.14
            let push = 1.0 - cos(prog * .pi / 2)
            let spring = sin(prog * .pi) * 0.10
            return CGFloat(-0.15 + 1.25 * push + spring)
        } else if u < 0.40 {
            // Settle to Lowered: arm relaxes down to 0.0
            let prog = (u - 0.24) / 0.16
            let settle = prog * (2.0 - prog) // ease-out
            return CGFloat(1.10 * (1.0 - settle))
        } else if u < 0.85 {
            // Resting Lowered: relaxed near dome top
            return 0.0
        } else {
            // Rise to Meet incoming orb: smooth rise to 1.0
            let prog = (u - 0.85) / 0.15
            let rise = sin(prog * .pi / 2)
            return CGFloat(rise)
        }
    }
    
    // MARK: - Orb Position Calculations
    private func calculateOrbPosition(
        index: Int,
        total: Int,
        width: CGFloat,
        height: CGFloat,
        time: Double,
        isFumbling: Bool,
        fumbleElapsed: Double
    ) -> (CGSize, Double) {
        let baseHandY: CGFloat = -44
        let handX: CGFloat = 48
        
        if reduceMotion {
            // Static gentle arch when reduce motion is enabled
            let spread = min(width * 0.48, 150)
            let step = total > 1 ? spread / CGFloat(total - 1) : 0
            let startX = -spread / 2
            let x = total == 1 ? 0 : startX + CGFloat(index) * step
            let normX = spread > 0 ? (x / (spread / 2)) : 0
            let y = baseHandY + (normX * normX) * 12
            return (CGSize(width: x, height: y), 0)
        }
        
        // Fumble offset
        var fumbleDrop: CGFloat = 0
        var fumbleTilt: Double = 0
        if isFumbling {
            let fumbleDuration = 1.25
            if fumbleElapsed < fumbleDuration {
                let progress = fumbleElapsed / fumbleDuration
                fumbleDrop = sin(progress * .pi) * 22
                fumbleTilt = sin(fumbleElapsed * 24 + Double(index)) * 16
            }
        }
        
        if total == 1 {
            // 1-Orb: Back-and-forth toss between Left and Right hands (Period = 2.0s)
            let period = 2.0
            let u = (time / period).truncatingRemainder(dividingBy: 1.0)
            
            var x: CGFloat = 0
            var y: CGFloat = baseHandY
            var tilt: Double = 0
            
            if u < 0.10 {
                // In Left Hand: dipping down with arm
                let prog = u / 0.10
                let dip = sin(prog * .pi / 2) * 12
                x = -handX
                y = baseHandY + dip
                tilt = -dip * 0.5
            } else if u < 0.24 {
                // In Left Hand: pushing up swiftly to release
                let prog = (u - 0.10) / 0.14
                let push = (1.0 - cos(prog * .pi / 2)) * 24
                x = -handX + CGFloat(prog * 4)
                y = (baseHandY + 12) - push
                tilt = -prog * 8
            } else if u < 0.50 {
                // In Flight: parabolic arc from Left Hand to Right Hand
                let prog = (u - 0.24) / 0.26
                x = (-handX + 4) + CGFloat(prog) * ((handX - 4) - (-handX + 4))
                let arc = sin(prog * .pi) * 22
                y = (baseHandY - 12) * CGFloat(1.0 - prog) + baseHandY * CGFloat(prog) - arc
                tilt = sin(prog * .pi) * 12
            } else if u < 0.60 {
                // In Right Hand: dipping down with arm
                let prog = (u - 0.50) / 0.10
                let dip = sin(prog * .pi / 2) * 12
                x = handX
                y = baseHandY + dip
                tilt = dip * 0.5
            } else if u < 0.74 {
                // In Right Hand: pushing up swiftly to release
                let prog = (u - 0.60) / 0.14
                let push = (1.0 - cos(prog * .pi / 2)) * 24
                x = handX - CGFloat(prog * 4)
                y = (baseHandY + 12) - push
                tilt = prog * 8
            } else {
                // In Flight: parabolic arc from Right Hand back to Left Hand
                let prog = (u - 0.74) / 0.26
                x = (handX - 4) - CGFloat(prog) * ((handX - 4) - (-handX + 4))
                let arc = sin(prog * .pi) * 22
                y = (baseHandY - 12) * CGFloat(1.0 - prog) + baseHandY * CGFloat(prog) - arc
                tilt = -sin(prog * .pi) * 12
            }
            
            return (CGSize(width: x, height: y + fumbleDrop), tilt + fumbleTilt)
        }
        
        // Multi-Orb Cascade (2 to 5 Orbs)
        let period = 1.6
        let phase = Double(index) * (2 * .pi / Double(total))
        let angle = (time * (2 * .pi / period) + phase).truncatingRemainder(dividingBy: 2 * .pi)
        
        let arcWidth = min(width * 0.24, 78)
        let x = sin(angle) * arcWidth
        let y = baseHandY - cos(angle * 2) * 12 + (cos(angle) > 0 ? 5 : -5)
        let tilt = sin(angle) * 10
        
        return (CGSize(width: x, height: y + fumbleDrop), tilt + fumbleTilt)
    }
    
    private func startJuggleLoop() {
        guard !reduceMotion else { return }
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { _ in
            time += 0.025
        }
        
        if ProcessInfo.processInfo.arguments.contains("-integrationsFumble") {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 350_000_000)
                triggerFumble()
            }
        }
    }
    
    // MARK: - Fumble Action
    private func triggerFumble() {
        guard !reduceMotion, !isFumbling else { return }
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        #endif
        isFumbling = true
        fumbleStartTime = time
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_250_000_000)
            self.isFumbling = false
        }
    }
    
    // MARK: - Asset Resolution
    private func resolveLogoImage(for integration: Integration) -> Image? {
        #if canImport(UIKit)
        if let path = Bundle.module.path(forResource: integration.logoAssetName, ofType: "png"),
           let uiImage = UIImage(contentsOfFile: path) {
            return Image(uiImage: uiImage)
        }
        if let uiImage = UIImage(named: integration.logoAssetName, in: .module, with: nil) {
            return Image(uiImage: uiImage)
        }
        return nil
        #else
        return Image(integration.logoAssetName, bundle: .module)
        #endif
    }
}

// MARK: - Internal Juggle Item Enum
public enum JuggleItem: Sendable {
    case avatar(UserProfile?, CMYKSprite)
    case integration(Integration)
}
