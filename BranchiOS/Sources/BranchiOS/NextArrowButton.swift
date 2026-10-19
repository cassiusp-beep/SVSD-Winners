import SwiftUI

// MARK: - Canonical Shared Next Arrow Button
/// A 56pt circular navigation button with an SF Symbol "arrow.right" inside.
/// Primary way forward on onboarding screens (ProfileSetupView, IntegrationsView).
public struct NextArrowButton: View {
    public let isEnabled: Bool
    public let accessibilityLabel: String
    public let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        isEnabled: Bool = true,
        accessibilityLabel: String = "Continue to next step",
        action: @escaping () -> Void
    ) {
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                #if os(iOS)
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                #endif
                action()
            }
        }) {
            ZStack {
                // Circle matching integration orb styling
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
                    // Lifted soft shadow when enabled, flat/none when disabled
                    .shadow(
                        color: isEnabled
                            ? Color.black.opacity(colorScheme == .dark ? 0.35 : 0.15)
                            : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }
            .frame(width: 56, height: 56)
            // Disabled: 25% opacity. Enabled: 100% opacity with spring.
            .opacity(isEnabled ? 1.0 : 0.25)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isEnabled)
        }
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isEnabled ? "" : "Complete the required inputs to continue")
    }
}
