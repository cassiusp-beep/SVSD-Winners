// Renders the YaYa app icon and launch mark from the real SwiftUI views (YaYaLogo.swift + BlinkClock.swift).
// Run: BranchiOS/scripts/render-app-assets.sh   (compiles this file with the logo sources, then runs it)
import SwiftUI
import AppKit

@MainActor
func render<V: View>(_ view: V, points: CGFloat, scale: CGFloat, scheme: ColorScheme, gray: Bool, opaque: Bool, to url: URL) {
    let renderer = ImageRenderer(content: view.environment(\.colorScheme, scheme))
    renderer.scale = scale
    guard let src = renderer.cgImage else { fatalError("render failed \(url.lastPathComponent)") }
    let px = Int(points * scale)
    let space = gray ? CGColorSpaceCreateDeviceGray() : CGColorSpace(name: CGColorSpace.sRGB)!
    let info: UInt32 = opaque
        ? (gray ? CGImageAlphaInfo.none.rawValue : CGImageAlphaInfo.noneSkipLast.rawValue)
        : CGImageAlphaInfo.premultipliedLast.rawValue
    var ctx = CGContext(data: nil, width: px, height: px, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: info)!
    if gray && !opaque { ctx = CGContext(data: nil, width: px, height: px, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)! }
    ctx.draw(src, in: CGRect(x: 0, y: 0, width: px, height: px))
    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    try! rep.representation(using: .png, properties: [:])!.write(to: url)
    print("wrote", url.path)
}

@MainActor
func main() {
    let out = URL(fileURLWithPath: CommandLine.arguments[1])
    let icon = out.appendingPathComponent("AppIcon.appiconset")
    let mark = out.appendingPathComponent("LaunchMark.imageset")
    for d in [icon, mark] { try! FileManager.default.createDirectory(at: d, withIntermediateDirectories: true) }

    // App icon: full-bleed 1024, no corners (iOS applies its mask). Default and dark are identical.
    let artwork = YaYaMark(size: 1024, fullBleed: true)
    render(artwork, points: 1024, scale: 1, scheme: .light, gray: false, opaque: true, to: icon.appendingPathComponent("AppIcon-1024.png"))
    render(artwork, points: 1024, scale: 1, scheme: .dark, gray: false, opaque: true, to: icon.appendingPathComponent("AppIcon-1024-dark.png"))
    render(artwork, points: 1024, scale: 1, scheme: .light, gray: true, opaque: true, to: icon.appendingPathComponent("AppIcon-1024-tinted.png"))

    // Launch mark: 96pt rounded mark, light and dark (dark has the 1pt border), @2x and @3x.
    for (scheme, tag) in [(ColorScheme.light, ""), (ColorScheme.dark, "-dark")] {
        for s in [2, 3] {
            render(YaYaMark(size: 96), points: 96, scale: CGFloat(s), scheme: scheme, gray: false, opaque: false,
                   to: mark.appendingPathComponent("LaunchMark\(tag)@\(s)x.png"))
        }
    }
}
MainActor.assumeIsolated { main() }
