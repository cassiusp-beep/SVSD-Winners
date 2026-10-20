import SwiftUI

/// The user's family accent. One source for the selected-tab tint and the Export headline,
/// so the colour cannot drift. Light values are the deeper step, dark the lighter step (all at least 3:1).
public enum FamilyAccent {
    public static func color(for family: BranchSprite, scheme: ColorScheme) -> Color {
        let hex: (light: UInt32, dark: UInt32)
        switch family {
        case .cloud: hex = (0x7E5FA6, 0xA083BC)
        case .bloom: hex = (0xC9652F, 0xE39A57)
        case .prism: hex = (0x2F7FA3, 0x4598BB)
        case .spark: hex = (0x5E8A56, 0x8AAE83)
        }
        let v = scheme == .dark ? hex.dark : hex.light
        return Color(red: Double((v >> 16) & 0xFF) / 255, green: Double((v >> 8) & 0xFF) / 255, blue: Double(v & 0xFF) / 255)
    }
}

public extension DemoStore {
    /// The signed-in user's family (Cloud for guests).
    var accentFamily: BranchSprite {
        isGuest ? .cloud : BranchSprite.from(hex: profile?.spriteColorHex ?? "")
    }
    
    func familyAccent(for scheme: ColorScheme) -> Color {
        FamilyAccent.color(for: accentFamily, scheme: scheme)
    }
}

public extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch clean.count {
        case 3:
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6:
            (r, g, b, a) = (int >> 16, (int >> 8) & 0xFF, int & 0xFF, 255)
        case 8:
            (r, g, b, a) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, int >> 24)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
