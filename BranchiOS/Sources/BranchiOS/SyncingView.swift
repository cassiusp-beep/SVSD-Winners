import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Sync Timing Constants
public struct SyncTimingConstants: Sendable {
    public static let beat0HandoffDuration: Double = 1.00      // Hand-off juggle with avatar orb
    public static let beat1BigTossDuration: Double = 0.65      // Both arms push up, hub ring trims, sprite slides right
    public static let beat2GatheringDuration: Double = 1.50    // Orbs bobbing & clockwise orbit (25% opacity)
    public static let beat3PullingInDuration: Double = 2.00    // Orbs drift inward & lift to 100% opacity
    public static let beat4LockInDuration: Double = 0.85       // Hub fills, arrow appears, flex, double blink
    
    public static var totalDuration: Double {
        beat0HandoffDuration + beat1BigTossDuration + beat2GatheringDuration + beat3PullingInDuration + beat4LockInDuration
    }
}

// MARK: - Sync Beats
public enum SyncBeat: Int, CaseIterable, Comparable, Sendable {
    case beat0Handoff = 0   // Frame 1: Still juggling + avatar orb in loop
    case beat1BigToss = 1   // Launch into center, hub draws, sprite slides
    case beat2Gathering = 2 // Frame 2: "Gathering your things...", loose orbs bobbing & clockwise orbit
    case beat3PullingIn = 3 // Frame 3: "Mixing it all together...", orbs drift closer, 100% opacity
    case beat4Complete = 4  // Frame 4: "Yummy! Delicious!", hub fills with sprite color, arrow, bicep flex
    
    public static func < (lhs: SyncBeat, rhs: SyncBeat) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - SyncingView
public struct SyncingView: View {
    @Bindable public var store: DemoStore = DemoStore.shared
    public var startFromBeat: SyncBeat = .beat0Handoff
    public var onComplete: (() -> Void)? = nil
    
    // Beat & Progress State
    @State private var currentBeat: SyncBeat = .beat0Handoff
    @State private var progress: Double = 0.0
    
    // Hub Animations
    @State private var strokeTrim: CGFloat = 0.0
    @State private var hubFillProgress: CGFloat = 0.0
    @State private var arrowScale: CGFloat = 0.0
    @State private var arrowOpacity: Double = 0.0
    
    // Satellite Orbs Motion
    @State private var orbitAngle: Double = 0.0
    @State private var orbsInwardProgress: [CGFloat] = [0, 0, 0, 0, 0]
    @State private var orbsOpacity: [Double] = [0.25, 0.25, 0.25, 0.25, 0.25]
    @State private var orbsScale: [CGFloat] = [1.0, 1.0, 1.0, 1.0, 1.0]
    
    // Sprite State
    @State private var spriteSlideProgress: CGFloat = 0.0 // 0.0 = centered bottom, 1.0 = shifted down-right
    @State private var tossArmsProgress: CGFloat = 0.0    // Arms big toss push up
    @State private var leftArmFlexProgress: CGFloat = 0.0 // 0.0 = relaxed curve, 1.0 = bicep flex
    @State private var isSpriteBlinking: Bool = false
    @State private var isDoubleBlinking: Bool = false
    
    // Continuous Physics Loop
    @State private var animationTime: Double = 0.0
    @State private var loopTimer: Timer? = nil
    @State private var syncTask: Task<Void, Never>? = nil
    @State private var blinkTimer: Timer? = nil
    
    // VoiceOver Announcement Tracking
    @State private var lastAnnouncedCopy: String = ""
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        store: DemoStore = DemoStore.shared,
        startFromBeat: SyncBeat = .beat0Handoff,
        onComplete: (() -> Void)? = nil
    ) {
        self.store = store
        self.startFromBeat = startFromBeat
        self.onComplete = onComplete
    }
    
    // Connected integrations limited to maximum 5 (most recent)
    private var connectedIntegrations: [Integration] {
        let connectedSet = store.connectedIntegrationIds
        return Integration.allSupported
            .filter { connectedSet.contains($0.id) }
            .sorted { a, b in
                let dateA = store.connectedTimestamps[a.id] ?? .distantPast
                let dateB = store.connectedTimestamps[b.id] ?? .distantPast
                return dateA > dateB
            }
            .prefix(5)
            .map { $0 }
    }
    
    private var activeSprite: CMYKSprite {
        if let hex = store.profile?.spriteColorHex {
            return CMYKSprite.from(hex: hex)
        }
        return .cyan
    }
    
    // Hub Fill Color
    private var hubFillColor: Color {
        if store.profile?.avatarType == .photo {
            return colorScheme == .dark ? Color.white : Color.black
        }
        if activeSprite == .key && colorScheme == .dark {
            return Color(white: 0.85) // Key in dark mode fills with light gray
        }
        return activeSprite.color(for: colorScheme)
    }
    
    // Hub Arrow Contrast Color (minimum 4.5:1 verified)
    private var hubArrowColor: Color {
        if store.profile?.avatarType == .photo {
            return colorScheme == .dark ? Color.black : Color.white
        }
        switch activeSprite {
        case .cyan, .yellow:
            return Color.black
        case .magenta:
            return Color.white
        case .key:
            return colorScheme == .dark ? Color.black : Color.white
        }
    }
    
    // Current Status Copy
    private var statusCopyText: String {
        switch currentBeat {
        case .beat0Handoff:
            return ""
        case .beat1BigToss, .beat2Gathering:
            return "Gathering your things..."
        case .beat3PullingIn:
            return "Mixing it all together..."
        case .beat4Complete:
            return "Yummy! Delicious!"
        }
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack(alignment: .top) {
            // Semantic background: white in light mode, black in dark mode
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
            // Top Shared Username Banner (stays in place through entire transition)
            VStack(spacing: 0) {
                UsernameBanner(nickname: store.profile?.nickname ?? "cash")
                
                // Shared Continue Button at top right (only in Complete)
                HStack {
                    Spacer()
                    if currentBeat == .beat4Complete {
                        ContinueButton(title: "Continue", isEnabled: true) {
                            advanceToHome()
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                .frame(height: 36)
                
                Spacer()
            }
            .zIndex(10)
            
            // Dynamic Interactive Canvas Layer
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                // Hub and orbs centered in the middle of the screen
                let hubCenter = CGPoint(x: w * 0.50, y: h * 0.50)
                let hubDiameter: CGFloat = 136
                let hubRadius: CGFloat = hubDiameter / 2
                
                ZStack {
                    // Status Copy sits ABOVE the hub, centered, in the upper area (primary color, regular weight)
                    if !statusCopyText.isEmpty {
                        Text(statusCopyText)
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .multilineTextAlignment(.center)
                            .position(x: w * 0.50, y: hubCenter.y - hubRadius - 62)
                            .transition(.opacity)
                            .id(statusCopyText)
                            .accessibilityLabel(statusCopyText)
                            .zIndex(8)
                    }
                    
                    // Central Hub Ring + Filled Primary Arrow
                    hubView(center: hubCenter, diameter: hubDiameter, radius: hubRadius)
                        .zIndex(5)
                    
                    // Avatar Orb + Satellite Integration Orbs
                    orbsLayer(hubCenter: hubCenter, hubRadius: hubRadius, w: w, h: h)
                        .zIndex(6)
                    
                    // Bottom Sprite Character
                    bottomSpriteView(w: w, h: h)
                        .zIndex(4)
                }
                .frame(width: w, height: h)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            startSyncSequence()
            startBlinkLoop()
        }
        .onDisappear {
            loopTimer?.invalidate()
            blinkTimer?.invalidate()
            syncTask?.cancel()
        }
        .accessibilityElement(children: .contain)
    }
    
    // MARK: - Hub View
    private func hubView(center: CGPoint, diameter: CGFloat, radius: CGFloat) -> some View {
        let isComplete = currentBeat == .beat4Complete
        
        return Button(action: {
            guard isComplete else { return }
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            #endif
            advanceToHome()
        }) {
            ZStack {
                // Outward growing fill circle (Beat 4)
                Circle()
                    .fill(hubFillColor)
                    .scaleEffect(hubFillProgress)
                
                // Bold outer hub ring stroke (black in light mode, white in dark mode)
                Circle()
                    .trim(from: 0, to: strokeTrim)
                    .stroke(
                        colorScheme == .dark ? Color.white : Color.black,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                // Center bold SF Symbol arrow.right (40% of hub diameter)
                if currentBeat == .beat4Complete {
                    Image(systemName: "arrow.right")
                        .font(.system(size: diameter * 0.40, weight: .bold))
                        .foregroundStyle(hubArrowColor)
                        .scaleEffect(arrowScale)
                        .opacity(arrowOpacity)
                }
            }
            .frame(width: diameter, height: diameter)
        }
        .buttonStyle(HubPressedStyle(isEnabled: isComplete))
        .position(center)
        .opacity(currentBeat == .beat0Handoff ? 0 : 1)
        .disabled(!isComplete)
        .accessibilityLabel(isComplete ? "Continue" : "Syncing in progress")
        .accessibilityAddTraits(isComplete ? .isButton : [])
    }
    
    // MARK: - Orbs Layer
    @ViewBuilder
    private func orbsLayer(hubCenter: CGPoint, hubRadius: CGFloat, w: CGFloat, h: CGFloat) -> some View {
        let orbs = connectedIntegrations
        let totalCount = orbs.count
        let orbSize: CGFloat = 44
        
        ZStack {
            // 1. Avatar Orb (User's photo or active sprite)
            avatarOrbView(size: orbSize)
                .position(avatarOrbPosition(hubCenter: hubCenter, hubRadius: hubRadius, w: w, h: h))
            
            // 2. Integration Orbs (Up to 5)
            ForEach(0..<totalCount, id: \.self) { idx in
                let item = orbs[idx]
                let pos = integrationOrbPosition(
                    index: idx,
                    total: totalCount,
                    hubCenter: hubCenter,
                    hubRadius: hubRadius,
                    w: w,
                    h: h
                )
                let opacity = orbsOpacity.indices.contains(idx) ? orbsOpacity[idx] : 0.25
                let scale = orbsScale.indices.contains(idx) ? orbsScale[idx] : 1.0
                
                orbItemCircle(for: item, size: orbSize, isLifted: currentBeat >= .beat3PullingIn)
                    .opacity(opacity)
                    .scaleEffect(scale)
                    .position(pos)
            }
        }
    }
    
    // MARK: - Avatar Orb Position Calculation
    private func avatarOrbPosition(hubCenter: CGPoint, hubRadius: CGFloat, w: CGFloat, h: CGFloat) -> CGPoint {
        switch currentBeat {
        case .beat0Handoff:
            // Juggling loop at top of stage: sits at top apex of the toss arc
            let u = (animationTime / 2.0).truncatingRemainder(dividingBy: 1.0)
            let tossProgress = (u - 0.24) / 0.50
            let arcX = sin(tossProgress * .pi * 2) * 60
            let arcY = cos(tossProgress * .pi * 2) * 25
            return CGPoint(x: w * 0.50 + arcX, y: h * 0.72 - arcY)
            
        case .beat1BigToss:
            // Flies up into center and settles at top of hub
            let p = CGFloat(min(1.0, progress))
            let start = CGPoint(x: w * 0.50, y: h * 0.72)
            let end = CGPoint(x: hubCenter.x, y: hubCenter.y - hubRadius - 2)
            let currentX = start.x + (end.x - start.x) * p
            let currentY = start.y + (end.y - start.y) * p
            return CGPoint(x: currentX, y: currentY)
            
        case .beat2Gathering, .beat3PullingIn, .beat4Complete:
            // Settled at 12 o'clock apex on top of the hub ring
            return CGPoint(x: hubCenter.x, y: hubCenter.y - hubRadius - 2)
        }
    }
    
    // MARK: - Integration Orb Position Calculation
    private func integrationOrbPosition(
        index: Int,
        total: Int,
        hubCenter: CGPoint,
        hubRadius: CGFloat,
        w: CGFloat,
        h: CGFloat
    ) -> CGPoint {
        guard total > 0 else { return hubCenter }
        
        // Base target angles distributed around remaining ring space (excluding 12 o'clock)
        let baseAngles: [Double] = total == 5
            ? [-150, -30, 150, 30, 90]
            : [ -140, -40, 140, 40, 90 ]
        let baseAngleDeg = baseAngles.indices.contains(index)
            ? baseAngles[index]
            : Double(index) * (360.0 / Double(total))
        
        let bobY = reduceMotion ? 0 : sin(animationTime * 2.8 + Double(index) * 1.3) * 5.0
        let currentOrbit = reduceMotion ? 0 : orbitAngle
        
        switch currentBeat {
        case .beat0Handoff:
            // Sits in lower arc of juggle stage
            let spread = min(w * 0.60, 180)
            let step = total > 1 ? spread / CGFloat(total - 1) : 0
            let startX = (w - spread) / 2
            let x = startX + CGFloat(index) * step
            let normX = spread > 0 ? ((x - w / 2) / (spread / 2)) : 0
            let y = h * 0.80 + (normX * normX) * 14
            return CGPoint(x: x, y: y)
            
        case .beat1BigToss:
            // Fly outward from juggle stage into loose orbit
            let p = CGFloat(min(1.0, progress))
            let startPos = CGPoint(x: w * 0.50 + CGFloat(index - 2) * 24, y: h * 0.78)
            let targetDist: CGFloat = 145 + CGFloat(index % 2) * 18
            let targetRad = (baseAngleDeg) * .pi / 180.0
            let targetPos = CGPoint(
                x: hubCenter.x + cos(targetRad) * targetDist,
                y: hubCenter.y + sin(targetRad) * targetDist
            )
            return CGPoint(
                x: startPos.x + (targetPos.x - startPos.x) * p,
                y: startPos.y + (targetPos.y - startPos.y) * p
            )
            
        case .beat2Gathering:
            // Loose dispersed orbit at varied distances (135pt to 165pt)
            let dist: CGFloat = 142 + CGFloat(index % 2) * 18
            let angleRad = (baseAngleDeg + currentOrbit) * .pi / 180.0
            return CGPoint(
                x: hubCenter.x + cos(angleRad) * dist,
                y: hubCenter.y + sin(angleRad) * dist + bobY
            )
            
        case .beat3PullingIn:
            // Drifting closer inward (105pt to 115pt)
            let inwardP = orbsInwardProgress.indices.contains(index) ? orbsInwardProgress[index] : 0
            let startDist: CGFloat = 142 + CGFloat(index % 2) * 18
            let targetDist: CGFloat = 110
            let currentDist = startDist + (targetDist - startDist) * inwardP
            let angleRad = (baseAngleDeg + currentOrbit) * .pi / 180.0
            return CGPoint(
                x: hubCenter.x + cos(angleRad) * currentDist,
                y: hubCenter.y + sin(angleRad) * currentDist + bobY * (1.0 - inwardP)
            )
            
        case .beat4Complete:
            // Snug against hub ring (hubRadius + orbRadius = 68 + 22 = 90pt)
            let snugDist: CGFloat = hubRadius + 22
            let finalAngleRad = baseAngleDeg * .pi / 180.0
            return CGPoint(
                x: hubCenter.x + cos(finalAngleRad) * snugDist,
                y: hubCenter.y + sin(finalAngleRad) * snugDist
            )
        }
    }
    
    // MARK: - Avatar Orb Visual
    private func avatarOrbView(size: CGFloat) -> some View {
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
                    color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.16),
                    radius: 6,
                    x: 0,
                    y: 3
                )
            
            #if canImport(UIKit)
            if store.profile?.avatarType == .photo, let image = store.loadedPhotoImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size - 4, height: size - 4)
                    .clipShape(Circle())
            } else {
                DomeSpriteView(sprite: activeSprite, isBlinking: false)
                    .frame(width: size * 0.58, height: size * 0.52)
                    .offset(y: 2)
            }
            #else
            DomeSpriteView(sprite: activeSprite, isBlinking: false)
                .frame(width: size * 0.58, height: size * 0.52)
                .offset(y: 2)
            #endif
        }
        .frame(width: size, height: size)
    }
    
    // MARK: - Integration Orb Visual
    private func orbItemCircle(for item: Integration, size: CGFloat, isLifted: Bool) -> some View {
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
                    color: Color.black.opacity(colorScheme == .dark ? (isLifted ? 0.48 : 0.28) : (isLifted ? 0.25 : 0.14)),
                    radius: isLifted ? 7 : 4,
                    x: 0,
                    y: isLifted ? 4 : 2
                )
            
            #if canImport(UIKit)
            if let path = Bundle.module.path(forResource: item.logoAssetName, ofType: "png"),
               let uiImage = UIImage(contentsOfFile: path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.52, height: size * 0.52)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            } else if let uiImage = UIImage(named: item.logoAssetName, in: .module, with: nil) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.52, height: size * 0.52)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            } else {
                Text(item.initial)
                    .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
            }
            #else
            Text(item.initial)
                .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                .foregroundStyle(Color.primary)
            #endif
        }
        .frame(width: size, height: size)
    }
    
    // MARK: - Bottom Sprite View
    private func bottomSpriteView(w: CGFloat, h: CGFloat) -> some View {
        let spriteW: CGFloat = 220
        let spriteH: CGFloat = 140
        let color = activeSprite.color(for: colorScheme)
        
        // Centered position (Beat 0) vs Shifted right position (Beats 1-4)
        let centeredX = w * 0.50
        let shiftedX = w * 0.72
        let currentX = centeredX + (shiftedX - centeredX) * spriteSlideProgress
        
        // Sits at bottom, slides down as orbs launch into orbit, cut off by bottom and right edges
        let startY = h - spriteH * 0.40
        let endY = h - spriteH * 0.06
        let currentY = startY + (endY - startY) * spriteSlideProgress
        
        return ZStack(alignment: .bottom) {
            // Left Arm
            if currentBeat == .beat0Handoff {
                // Juggling arms in rhythm
                SpriteArmShape(pose: 0.85, isLeft: true)
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .frame(width: spriteW * 0.32, height: spriteH * 0.98)
                    .position(x: spriteW * 0.08, y: spriteH * 0.35)
                
                SpriteArmShape(pose: 0.85, isLeft: false)
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .frame(width: spriteW * 0.32, height: spriteH * 0.98)
                    .position(x: spriteW * 0.92, y: spriteH * 0.35)
            } else {
                // Left Arm: resting curve (Beats 1-3) morphing to soft U-curl bicep flex (Beat 4)
                SpriteFlexArmShape(flexProgress: leftArmFlexProgress)
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                    .frame(width: 80, height: 110)
                    .position(x: -30, y: spriteH * 0.44)
            }
            
            // Central Dome Body
            ZStack(alignment: .bottom) {
                UnevenRoundedRectangle(
                    topLeadingRadius: spriteW / 2,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: spriteW / 2,
                    style: .continuous
                )
                .fill(color)
                .overlay(
                    UnevenRoundedRectangle(
                        topLeadingRadius: spriteW / 2,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: spriteW / 2,
                        style: .continuous
                    )
                    .stroke(colorScheme == .dark && activeSprite == .key ? Color.white.opacity(0.35) : Color.clear, lineWidth: 1.5)
                )
                
                // Two tall white vertical oval eyes
                HStack(spacing: spriteW * 0.18) {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: spriteW * 0.088, height: spriteH * 0.34)
                        .scaleEffect(y: (isSpriteBlinking || isDoubleBlinking) ? 0.08 : 1.0, anchor: .center)
                    
                    Capsule()
                        .fill(Color.white)
                        .frame(width: spriteW * 0.088, height: spriteH * 0.34)
                        .scaleEffect(y: (isSpriteBlinking || isDoubleBlinking) ? 0.08 : 1.0, anchor: .center)
                }
                .offset(y: -spriteH * 0.28)
            }
            .frame(width: spriteW, height: spriteH)
        }
        .frame(width: spriteW, height: spriteH)
        .position(x: currentX, y: currentY)
    }
    
    // MARK: - Sync Sequence Driver
    private func startSyncSequence() {
        // Continuous physics loop for orbs and bobbing
        loopTimer?.invalidate()
        loopTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            Task { @MainActor in
                animationTime += 0.03
                if currentBeat >= .beat2Gathering && currentBeat < .beat4Complete && !reduceMotion {
                    orbitAngle += 0.36 // Slow clockwise orbit
                }
            }
        }
        
        syncTask?.cancel()
        syncTask = Task { @MainActor in
            // Direct launch to Complete state
            if startFromBeat == .beat4Complete {
                currentBeat = .beat4Complete
                spriteSlideProgress = 1.0
                strokeTrim = 1.0
                hubFillProgress = 1.0
                arrowScale = 1.0
                arrowOpacity = 1.0
                leftArmFlexProgress = 1.0
                for i in 0..<orbsInwardProgress.count { orbsInwardProgress[i] = 1.0 }
                for i in 0..<orbsOpacity.count { orbsOpacity[i] = 1.0 }
                triggerDoubleBlink()
                return
            }
            
            // Direct launch to Pulling In (Beat 3)
            if startFromBeat == .beat3PullingIn {
                currentBeat = .beat3PullingIn
                spriteSlideProgress = 1.0
                strokeTrim = 1.0
                for i in 0..<orbsInwardProgress.count { orbsInwardProgress[i] = 1.0 }
                for i in 0..<orbsOpacity.count { orbsOpacity[i] = 1.0 }
                return
            }
            
            // Direct launch to Gathering (Beat 2)
            if startFromBeat == .beat2Gathering {
                currentBeat = .beat2Gathering
                spriteSlideProgress = 1.0
                strokeTrim = 1.0
                return
            }
            
            // BEAT 0: HAND-OFF (1.0s)
            if startFromBeat <= .beat0Handoff {
                try? await Task.sleep(nanoseconds: UInt64(SyncTimingConstants.beat0HandoffDuration * 1_000_000_000))
                guard !Task.isCancelled else { return }
            }
            
            // BEAT 1: THE BIG TOSS (0.65s)
            if startFromBeat <= .beat1BigToss {
                currentBeat = .beat1BigToss
                announceForAccessibility("Gathering your things...")
                
                if reduceMotion {
                    spriteSlideProgress = 1.0
                    strokeTrim = 1.0
                    try? await Task.sleep(nanoseconds: UInt64(SyncTimingConstants.beat1BigTossDuration * 1_000_000_000))
                } else {
                    withAnimation(.spring(response: 0.65, dampingFraction: 0.82)) {
                        spriteSlideProgress = 1.0
                        strokeTrim = 1.0
                        progress = 1.0
                    }
                    try? await Task.sleep(nanoseconds: UInt64(SyncTimingConstants.beat1BigTossDuration * 1_000_000_000))
                }
                guard !Task.isCancelled else { return }
            }
            
            // BEAT 2: GATHERING (1.5s)
            currentBeat = .beat2Gathering
            try? await Task.sleep(nanoseconds: UInt64(SyncTimingConstants.beat2GatheringDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            
            // BEAT 3: PULLING IN (2.0s)
            currentBeat = .beat3PullingIn
            announceForAccessibility("Mixing it all together...")
            
            let orbCount = connectedIntegrations.count
            if orbCount > 0 {
                for i in 0..<orbCount {
                    let staggerDelay = UInt64(Double(i) * 0.20 * 1_000_000_000)
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: staggerDelay)
                        if reduceMotion {
                            if orbsInwardProgress.indices.contains(i) { orbsInwardProgress[i] = 1.0 }
                            if orbsOpacity.indices.contains(i) { orbsOpacity[i] = 1.0 }
                        } else {
                            withAnimation(.spring(response: 0.55, dampingFraction: 0.70)) {
                                if orbsInwardProgress.indices.contains(i) { orbsInwardProgress[i] = 1.0 }
                                if orbsOpacity.indices.contains(i) { orbsOpacity[i] = 1.0 }
                            }
                        }
                    }
                }
            }
            
            try? await Task.sleep(nanoseconds: UInt64(SyncTimingConstants.beat3PullingInDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            
            // BEAT 4: LOCK IN / COMPLETE (0.85s)
            currentBeat = .beat4Complete
            announceForAccessibility("Account ready")
            
            // 1. Squeeze orbs landing snug (scale 0.95 and back)
            if !reduceMotion {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                    for i in 0..<orbsScale.count { orbsScale[i] = 0.95 }
                }
                try? await Task.sleep(nanoseconds: 120_000_000)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                    for i in 0..<orbsScale.count { orbsScale[i] = 1.0 }
                }
            }
            
            // 2. Hub fills from center outward, then arrow appears
            if reduceMotion {
                hubFillProgress = 1.0
                arrowScale = 1.0
                arrowOpacity = 1.0
                leftArmFlexProgress = 1.0
            } else {
                withAnimation(.easeOut(duration: 0.38)) {
                    hubFillProgress = 1.0
                }
                try? await Task.sleep(nanoseconds: 220_000_000)
                
                withAnimation(.spring(response: 0.40, dampingFraction: 0.68)) {
                    arrowScale = 1.0
                    arrowOpacity = 1.0
                    leftArmFlexProgress = 1.0
                }
                
                #if os(iOS)
                let notif = UINotificationFeedbackGenerator()
                notif.notificationOccurred(.success)
                #endif
            }
            
            // 3. Happy double blink
            triggerDoubleBlink()
        }
    }
    
    // MARK: - Happy Double Blink
    private func triggerDoubleBlink() {
        Task { @MainActor in
            isDoubleBlinking = true
            try? await Task.sleep(nanoseconds: 100_000_000)
            isDoubleBlinking = false
            try? await Task.sleep(nanoseconds: 85_000_000)
            isDoubleBlinking = true
            try? await Task.sleep(nanoseconds: 100_000_000)
            isDoubleBlinking = false
        }
    }
    
    // MARK: - Natural Blink Loop
    private func startBlinkLoop() {
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            guard currentBeat != .beat4Complete else { return }
            isSpriteBlinking = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                isSpriteBlinking = false
            }
        }
    }
    
    // MARK: - Navigation Action
    private func advanceToHome() {
        store.completeSyncStep()
        onComplete?()
    }
    
    // MARK: - Accessibility Helper
    private func announceForAccessibility(_ message: String) {
        guard message != lastAnnouncedCopy else { return }
        lastAnnouncedCopy = message
        #if os(iOS)
        UIAccessibility.post(notification: .announcement, argument: message)
        #endif
    }
}

// MARK: - Hub Pressed Scale Style (0.96 on press)
struct HubPressedStyle: ButtonStyle {
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isEnabled && configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.70), value: configuration.isPressed)
    }
}
