import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct IntegrationOrbView: View {
    public let integration: Integration
    public let isConnected: Bool
    public let isConnecting: Bool
    public let connectionProgress: CGFloat
    public let accentColor: Color
    public let onToggle: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        integration: Integration,
        isConnected: Bool,
        isConnecting: Bool = false,
        connectionProgress: CGFloat = 0,
        accentColor: Color = Color(red: 0.15, green: 0.78, blue: 0.85),
        onToggle: @escaping () -> Void
    ) {
        self.integration = integration
        self.isConnected = isConnected
        self.isConnecting = isConnecting
        self.connectionProgress = connectionProgress
        self.accentColor = accentColor
        self.onToggle = onToggle
    }
    
    private var isDarkMonochromeLogo: Bool {
        let id = integration.id
        return id == "autodesk_fusion" || id == "github" || id == "arena" || id == "cosmos" || id == "savee" || id == "thingiverse"
    }
    
    private var orbFillColor: Color {
        // Light plate in both modes so every original-colour logo reads (dark logos like Miro / Are.na / Savee
        // vanish on a dark plate and template-tinting turns opaque-background PNGs into grey squares).
        Color.white
    }
    
    public var body: some View {
        Button(action: onToggle) {
            ZStack {
                // Orb circular base
                Circle()
                    .fill(orbFillColor)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(
                        color: isConnected
                        ? Color.black.opacity(colorScheme == .dark ? 0.50 : 0.28)
                        : Color.black.opacity(colorScheme == .dark ? 0.35 : 0.16),
                        radius: isConnected ? 8 : 5,
                        x: 0,
                        y: isConnected ? 5 : 2
                    )
                
                // Connecting progress ring
                if isConnecting {
                    Circle()
                        .trim(from: 0, to: connectionProgress)
                        .stroke(
                            accentColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .padding(2)
                }
                
                // Service Logo Image / Fallback Initial
                logoView
            }
            .frame(width: 62, height: 62)
            .scaleEffect(isConnecting ? 1.05 : 1.0)
            // Dark mode keeps the plate light, so inactive needs more presence than 40% or Figma / Printables / Pinterest vanish.
        .opacity(isConnected || isConnecting ? 1.0 : (colorScheme == .dark ? 0.62 : 0.40))
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(integration.name) integration")
        .accessibilityValue(isConnected ? "Connected" : (isConnecting ? "Connecting" : "Not connected"))
        .accessibilityHint(isConnected ? "Double tap to disconnect" : "Double tap to connect")
    }
    
    @ViewBuilder
    private var logoView: some View {
        if let image = resolvedLogoImage {
            IntegrationLogoBadge(
                image: image,
                isOpaqueTile: IntegrationLogoBadge.isOpaqueTile(named: integration.logoAssetName),
                diameter: 40
            )
        } else {
            fallbackInitialView
        }
    }
    
    private var resolvedLogoImage: Image? {
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
    
    private var fallbackInitialView: some View {
        Text(integration.initial)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(isConnected ? accentColor : Color.secondary)
    }
}


// MARK: - Logo badge
/// Logos always read as a circular badge. Full-bleed opaque tiles (Are.na, Cosmos, Onshape, Savee) fill the
/// circle instead of showing as a light square inside it; transparent glyphs sit centred on the white plate.
struct IntegrationLogoBadge: View {
    let image: Image
    let isOpaqueTile: Bool
    let diameter: CGFloat

    var body: some View {
        if isOpaqueTile {
            image
                .resizable()
                .scaledToFill()
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())
        } else {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: diameter * 0.8, height: diameter * 0.8)
        }
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var cache: [String: Bool] = [:]

    /// True when the PNG is opaque at the centre of all four edges, i.e. a full-bleed tile.
    static func isOpaqueTile(named name: String) -> Bool {
        lock.lock(); defer { lock.unlock() }
        if let v = cache[name] { return v }
        var result = false
        #if canImport(UIKit)
        let ui: UIImage? = {
            if let path = Bundle.module.path(forResource: name, ofType: "png") { return UIImage(contentsOfFile: path) }
            return UIImage(named: name, in: .module, with: nil)
        }()
        if let cg = ui?.cgImage {
            let n = 16
            var data = [UInt8](repeating: 0, count: n * n * 4)
            if let ctx = CGContext(data: &data, width: n, height: n, bitsPerComponent: 8, bytesPerRow: n * 4,
                                   space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                ctx.draw(cg, in: CGRect(x: 0, y: 0, width: n, height: n))
                func a(_ x: Int, _ y: Int) -> UInt8 { data[(y * n + x) * 4 + 3] }
                let m = n / 2
                result = a(0, m) > 230 && a(n - 1, m) > 230 && a(m, 0) > 230 && a(m, n - 1) > 230
            }
        }
        #endif
        cache[name] = result
        return result
    }
}
