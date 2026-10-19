import SwiftUI
#if canImport(UIKit)
import UIKit
import CoreText

/// Registers Berkeley Mono from the main bundle or the module bundle at runtime, so the font loads even when
/// the host app's Info.plist `UIAppFonts` is missing (hand-assembled .app). No-op when the files are absent
/// (the font is licensed and not committed); `Font.yaya` then falls back to the system monospaced font.
enum BerkeleyMonoRegistry {
    static let registerOnce: Void = {
        for name in ["BerkeleyMono-Regular", "BerkeleyMono-Bold"] {
            guard UIFont(name: name, size: 12) == nil else { continue }
            let url = [Bundle.main, Bundle.module].lazy
                .compactMap { $0.url(forResource: name, withExtension: "ttf") ?? $0.url(forResource: name, withExtension: "ttf", subdirectory: "Fonts") }
                .first
            if let url {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }()
}
#endif

public extension Font {
    /// Font helper for "YaYa" brand name.
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
        _ = BerkeleyMonoRegistry.registerOnce
        if UIFont(name: fontName, size: size) != nil {
            return Font.custom(fontName, size: size)
        }
        #endif
        
        return Font.system(size: size, weight: weight, design: .monospaced)
    }
}
