import SwiftUI

// MARK: - Canonical Shared Username Banner
/// A continuous horizontal marquee banner repeating "@nickname" across the screen.
/// Placed below the status bar on every onboarding screen with identical size, position,
/// speed, and color for visual continuity.
public struct UsernameBanner: View {
    public let nickname: String
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme
    
    // Design constants matching Figma frames
    public static let bannerHeight: CGFloat = 82
    public static let fontSize: CGFloat = 68
    public static var gap: CGFloat { fontSize * 0.5 } // 34pt consistent gap ("@cash  @cash")
    
    public init(nickname: String) {
        self.nickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var body: some View {
        if nickname.isEmpty {
            Color.clear
                .frame(height: Self.bannerHeight)
                .accessibilityHidden(true)
        } else {
            let displayToken = "@\(nickname)"
            
            GeometryReader { proxy in
            let screenWidth = proxy.size.width
            
            TimelineView(.animation(paused: reduceMotion)) { timeline in
                let elapsed = reduceMotion ? 0 : Float(timeline.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 120))
                // Smooth horizontal marquee translation
                let cycleDistance: CGFloat = 400
                let offset = -CGFloat(elapsed * 26).truncatingRemainder(dividingBy: cycleDistance)
                
                HStack(spacing: Self.gap) {
                    ForEach(0..<14, id: \.self) { _ in
                        Text(displayToken)
                            .font(.system(size: Self.fontSize, weight: .heavy, design: .rounded))
                            // Light gray in light mode, dark gray in dark mode
                            .foregroundStyle(Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.12))
                            .lineLimit(1)
                            .fixedSize()
                    }
                }
                .offset(x: offset)
                .frame(width: screenWidth, height: Self.bannerHeight, alignment: .leading)
            }
        }
        .frame(height: Self.bannerHeight)
        // STRICT RULE: Only cut off by the screen's left and right edges, never by its own vertical container
        .frame(maxWidth: .infinity)
        .clipped()
        .accessibilityHidden(true)
        }
    }
}

public typealias NicknameMarqueeBanner = UsernameBanner
