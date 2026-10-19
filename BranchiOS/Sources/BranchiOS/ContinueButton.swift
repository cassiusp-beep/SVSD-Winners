import SwiftUI

// MARK: - Canonical Shared Continue Button
/// Plain text "Continue" top-right button used on every onboarding screen.
/// Placed below the UsernameBanner, right-aligned to the content margin.
public struct ContinueButton: View {
    public let title: String
    public let isEnabled: Bool
    public let disabledHint: String?
    public let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    public init(
        title: String = "Continue",
        isEnabled: Bool,
        disabledHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.disabledHint = disabledHint
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                #if os(iOS)
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                #endif
                action()
            }
        }) {
            Text(title)
                .font(.system(.body, design: .default, weight: .semibold))
                // Disabled: secondary gray at 25% opacity. Enabled: primary text color, semibold.
                .foregroundStyle(
                    isEnabled
                    ? Color.primary
                    : Color.secondary.opacity(0.25)
                )
                .animation(.easeInOut(duration: 0.22), value: isEnabled)
                .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
                .contentShape(Rectangle())
        }
        .disabled(!isEnabled)
        .accessibilityLabel(title)
        .accessibilityHint(isEnabled ? "" : (disabledHint ?? "Complete this step to continue"))
    }
}
