import SwiftUI

#if canImport(UIKit)
import UIKit

// MARK: - Record Button
/// The 64pt solid round primary control shared by the Session capture cluster and Talk it through.
/// The symbol changes with state (play / mic -> stop); the fill always follows the primary ink.
public struct RecordButton: View {
    public let symbol: String
    public var symbolOffset: CGFloat
    public let accessibilityLabel: String
    public let action: () -> Void

    public static let diameter: CGFloat = 64

    public init(
        symbol: String,
        symbolOffset: CGFloat = 0,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) {
        self.symbol = symbol
        self.symbolOffset = symbolOffset
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    public var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.primary)
                    .frame(width: Self.diameter, height: Self.diameter)

                Image(systemName: symbol)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color(.systemBackground))
                    .offset(x: symbolOffset)
                    .contentTransition(.symbolEffect(.replace))
            }
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}
#endif
