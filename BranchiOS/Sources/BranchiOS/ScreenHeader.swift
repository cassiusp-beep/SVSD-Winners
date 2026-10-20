import SwiftUI

public enum ScreenHeaderLayout {
    public static var topSpacing: CGFloat { 12 }
    public static var horizontalPadding: CGFloat { 20 }
}

/// Shared tab-screen header: a title (or title + dropdown) on the leading side and an optional trailing accessory.
/// Tab canvases already reserve the top safe area, so the header's top edge sits exactly 12pt below it.
/// Use this instead of per-screen top padding so every tab title lands at the same height.
public struct ScreenHeader<Leading: View, Trailing: View>: View {
    public static var topSpacing: CGFloat { ScreenHeaderLayout.topSpacing }
    
    private let horizontalPadding: CGFloat
    private let leading: Leading
    private let trailing: Trailing
    
    public init(
        horizontalPadding: CGFloat = 20,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.horizontalPadding = horizontalPadding
        self.leading = leading()
        self.trailing = trailing()
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            leading
            Spacer(minLength: 0)
            trailing
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, Self.topSpacing)
    }
}

public extension ScreenHeader where Trailing == EmptyView {
    init(horizontalPadding: CGFloat = 20, @ViewBuilder leading: () -> Leading) {
        self.init(horizontalPadding: horizontalPadding, leading: leading, trailing: { EmptyView() })
    }
}
