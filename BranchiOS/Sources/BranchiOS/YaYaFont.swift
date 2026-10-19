import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public extension Font {
    /// Font helper for "Ya Ya" brand name.
    /// Uses Berkeley Mono if available in the application bundle/system,
    /// falling back gracefully to Apple's system monospaced font.
    static func yaya(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String = {
            switch weight {
            case .bold, .heavy, .black, .semibold:
                return "BerkeleyMono-Bold"
            default:
                return "BerkeleyMono-Regular"
            }
        }()
        
        #if canImport(UIKit)
        if UIFont(name: fontName, size: size) != nil {
            return Font.custom(fontName, size: size)
        }
        #endif
        
        return Font.system(size: size, weight: weight, design: .monospaced)
    }
}

// MARK: - Reusable Ya Ya Wordmark Component
public struct YaYaWordmark: View {
    public var size: CGFloat = 28
    public var showsPeriod: Bool = false
    public var isHeader: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    public init(size: CGFloat = 28, showsPeriod: Bool = false, isHeader: Bool = false) {
        self.size = size
        self.showsPeriod = showsPeriod
        self.isHeader = isHeader
    }
    
    public var body: some View {
        Text(showsPeriod ? "Ya Ya." : "Ya Ya")
            .font(.yaya(size: size, weight: .bold))
            .foregroundStyle(Color.primary)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Ya Ya")
            .accessibilityAddTraits(isHeader ? .isHeader : [])
    }
}
