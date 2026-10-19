import SwiftUI

// MARK: - Brand geometry
// Source of truth: docs/references/brand/yaya-wordmark-*.svg (viewBox 694x286) and yaya-icon-rounded.svg.
// The wordmark is drawn at `size` = 200 SVG units (eye width 34 = 0.17 x size), trimmed to the glyph + eye extents.

enum YaYaBrand {
    static let eyeLeftGradient = LinearGradient(
        colors: [Color(red: 0xA0 / 255, green: 0x83 / 255, blue: 0xBC / 255), Color(red: 0x45 / 255, green: 0x98 / 255, blue: 0xBB / 255)],
        startPoint: .top, endPoint: .bottom)
    static let eyeRightGradient = LinearGradient(
        colors: [Color(red: 0xE3 / 255, green: 0x9A / 255, blue: 0x57 / 255), Color(red: 0x8A / 255, green: 0xAE / 255, blue: 0x83 / 255)],
        startPoint: .top, endPoint: .bottom)
    static let darkBorder = Color(red: 0x2A / 255, green: 0x2A / 255, blue: 0x2A / 255)

    /// Trimmed wordmark bounds in SVG units at size 200 (x 73...624, y 70...218).
    static let wordmarkWidth: CGFloat = 551
    static let wordmarkHeight: CGFloat = 148
    static let unitsPerSize: CGFloat = 200
}

/// The "YaYa" letterforms from the brand SVG, in a 551 x 148 coordinate space (trimmed), scaled to fit the rect.
struct YaYaGlyphsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 42, y: 146))
        p.addLine(to: CGPoint(x: 42, y: 94))
        p.addLine(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: 31.4, y: 0))
        p.addLine(to: CGPoint(x: 49.8, y: 44))
        p.addQuadCurve(to: CGPoint(x: 54.7, y: 58), control: CGPoint(x: 52.6, y: 50.6))
        p.addQuadCurve(to: CGPoint(x: 57.6, y: 70), control: CGPoint(x: 56.8, y: 65.4))
        p.addQuadCurve(to: CGPoint(x: 60.5, y: 58), control: CGPoint(x: 58.6, y: 65.4))
        p.addQuadCurve(to: CGPoint(x: 65, y: 44), control: CGPoint(x: 62.4, y: 50.6))
        p.addLine(to: CGPoint(x: 82.8, y: 0))
        p.addLine(to: CGPoint(x: 114, y: 0))
        p.addLine(to: CGPoint(x: 72, y: 94))
        p.addLine(to: CGPoint(x: 72, y: 146))
        p.closeSubpath()
        p.move(to: CGPoint(x: 150.8, y: 148))
        p.addQuadCurve(to: CGPoint(x: 124.8, y: 138.5), control: CGPoint(x: 134.4, y: 148))
        p.addQuadCurve(to: CGPoint(x: 115.2, y: 113.6), control: CGPoint(x: 115.2, y: 129))
        p.addQuadCurve(to: CGPoint(x: 127, y: 87.4), control: CGPoint(x: 115.2, y: 97))
        p.addQuadCurve(to: CGPoint(x: 160.2, y: 77.8), control: CGPoint(x: 138.8, y: 77.8))
        p.addLine(to: CGPoint(x: 181.8, y: 77.8))
        p.addLine(to: CGPoint(x: 181.8, y: 70.8))
        p.addQuadCurve(to: CGPoint(x: 177.5, y: 61.1), control: CGPoint(x: 181.8, y: 64.6))
        p.addQuadCurve(to: CGPoint(x: 165.2, y: 57.6), control: CGPoint(x: 173.2, y: 57.6))
        p.addQuadCurve(to: CGPoint(x: 153.1, y: 60.6), control: CGPoint(x: 157.6, y: 57.6))
        p.addQuadCurve(to: CGPoint(x: 148.2, y: 69.4), control: CGPoint(x: 148.6, y: 63.6))
        p.addLine(to: CGPoint(x: 119.8, y: 69.4))
        p.addQuadCurve(to: CGPoint(x: 132.6, y: 43.6), control: CGPoint(x: 120.4, y: 53.2))
        p.addQuadCurve(to: CGPoint(x: 165.6, y: 34), control: CGPoint(x: 144.8, y: 34))
        p.addQuadCurve(to: CGPoint(x: 199.6, y: 44), control: CGPoint(x: 187.4, y: 34))
        p.addQuadCurve(to: CGPoint(x: 211.8, y: 72), control: CGPoint(x: 211.8, y: 54))
        p.addLine(to: CGPoint(x: 211.8, y: 146))
        p.addLine(to: CGPoint(x: 182.8, y: 146))
        p.addLine(to: CGPoint(x: 182.8, y: 127))
        p.addQuadCurve(to: CGPoint(x: 172.3, y: 142.4), control: CGPoint(x: 180.8, y: 136.8))
        p.addQuadCurve(to: CGPoint(x: 150.8, y: 148), control: CGPoint(x: 163.8, y: 148))
        p.closeSubpath()
        p.move(to: CGPoint(x: 161.4, y: 124))
        p.addQuadCurve(to: CGPoint(x: 176.3, y: 119.3), control: CGPoint(x: 170.8, y: 124))
        p.addQuadCurve(to: CGPoint(x: 181.8, y: 107), control: CGPoint(x: 181.8, y: 114.6))
        p.addLine(to: CGPoint(x: 181.8, y: 95.8))
        p.addLine(to: CGPoint(x: 160.8, y: 95.8))
        p.addQuadCurve(to: CGPoint(x: 148.5, y: 99.7), control: CGPoint(x: 152.8, y: 95.8))
        p.addQuadCurve(to: CGPoint(x: 144.2, y: 109.8), control: CGPoint(x: 144.2, y: 103.6))
        p.addQuadCurve(to: CGPoint(x: 148.7, y: 120), control: CGPoint(x: 144.2, y: 116))
        p.addQuadCurve(to: CGPoint(x: 161.4, y: 124), control: CGPoint(x: 153.2, y: 124))
        p.closeSubpath()
        p.move(to: CGPoint(x: 258, y: 146))
        p.addLine(to: CGPoint(x: 258, y: 94))
        p.addLine(to: CGPoint(x: 216, y: 0))
        p.addLine(to: CGPoint(x: 247.4, y: 0))
        p.addLine(to: CGPoint(x: 265.8, y: 44))
        p.addQuadCurve(to: CGPoint(x: 270.7, y: 58), control: CGPoint(x: 268.6, y: 50.6))
        p.addQuadCurve(to: CGPoint(x: 273.6, y: 70), control: CGPoint(x: 272.8, y: 65.4))
        p.addQuadCurve(to: CGPoint(x: 276.5, y: 58), control: CGPoint(x: 274.6, y: 65.4))
        p.addQuadCurve(to: CGPoint(x: 281, y: 44), control: CGPoint(x: 278.4, y: 50.6))
        p.addLine(to: CGPoint(x: 298.8, y: 0))
        p.addLine(to: CGPoint(x: 330, y: 0))
        p.addLine(to: CGPoint(x: 288, y: 94))
        p.addLine(to: CGPoint(x: 288, y: 146))
        p.closeSubpath()
        p.move(to: CGPoint(x: 366.8, y: 148))
        p.addQuadCurve(to: CGPoint(x: 340.8, y: 138.5), control: CGPoint(x: 350.4, y: 148))
        p.addQuadCurve(to: CGPoint(x: 331.2, y: 113.6), control: CGPoint(x: 331.2, y: 129))
        p.addQuadCurve(to: CGPoint(x: 343, y: 87.4), control: CGPoint(x: 331.2, y: 97))
        p.addQuadCurve(to: CGPoint(x: 376.2, y: 77.8), control: CGPoint(x: 354.8, y: 77.8))
        p.addLine(to: CGPoint(x: 397.8, y: 77.8))
        p.addLine(to: CGPoint(x: 397.8, y: 70.8))
        p.addQuadCurve(to: CGPoint(x: 393.5, y: 61.1), control: CGPoint(x: 397.8, y: 64.6))
        p.addQuadCurve(to: CGPoint(x: 381.2, y: 57.6), control: CGPoint(x: 389.2, y: 57.6))
        p.addQuadCurve(to: CGPoint(x: 369.1, y: 60.6), control: CGPoint(x: 373.6, y: 57.6))
        p.addQuadCurve(to: CGPoint(x: 364.2, y: 69.4), control: CGPoint(x: 364.6, y: 63.6))
        p.addLine(to: CGPoint(x: 335.8, y: 69.4))
        p.addQuadCurve(to: CGPoint(x: 348.6, y: 43.6), control: CGPoint(x: 336.4, y: 53.2))
        p.addQuadCurve(to: CGPoint(x: 381.6, y: 34), control: CGPoint(x: 360.8, y: 34))
        p.addQuadCurve(to: CGPoint(x: 415.6, y: 44), control: CGPoint(x: 403.4, y: 34))
        p.addQuadCurve(to: CGPoint(x: 427.8, y: 72), control: CGPoint(x: 427.8, y: 54))
        p.addLine(to: CGPoint(x: 427.8, y: 146))
        p.addLine(to: CGPoint(x: 398.8, y: 146))
        p.addLine(to: CGPoint(x: 398.8, y: 127))
        p.addQuadCurve(to: CGPoint(x: 388.3, y: 142.4), control: CGPoint(x: 396.8, y: 136.8))
        p.addQuadCurve(to: CGPoint(x: 366.8, y: 148), control: CGPoint(x: 379.8, y: 148))
        p.closeSubpath()
        p.move(to: CGPoint(x: 377.4, y: 124))
        p.addQuadCurve(to: CGPoint(x: 392.3, y: 119.3), control: CGPoint(x: 386.8, y: 124))
        p.addQuadCurve(to: CGPoint(x: 397.8, y: 107), control: CGPoint(x: 397.8, y: 114.6))
        p.addLine(to: CGPoint(x: 397.8, y: 95.8))
        p.addLine(to: CGPoint(x: 376.8, y: 95.8))
        p.addQuadCurve(to: CGPoint(x: 364.5, y: 99.7), control: CGPoint(x: 368.8, y: 95.8))
        p.addQuadCurve(to: CGPoint(x: 360.2, y: 109.8), control: CGPoint(x: 360.2, y: 103.6))
        p.addQuadCurve(to: CGPoint(x: 364.7, y: 120), control: CGPoint(x: 360.2, y: 116))
        p.addQuadCurve(to: CGPoint(x: 377.4, y: 124), control: CGPoint(x: 369.2, y: 124))
        p.closeSubpath()
        let s = rect.width / YaYaBrand.wordmarkWidth
        return p.applying(CGAffineTransform(scaleX: s, y: s)).applying(CGAffineTransform(translationX: rect.minX, y: rect.minY))
    }
}

// MARK: - Wordmark
/// "YaYa" with two gradient eyes standing on the baseline. Drawn in SwiftUI, not an image.
/// `size` is the font-size equivalent: each eye is 0.17 x size wide and 0.34 x size tall.
public struct YaYaWordmark: View {
    public var size: CGFloat
    public var blinks: Bool
    public var decorative: Bool
    public var isHeader: Bool

    @State private var clock = BlinkClock()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(size: CGFloat = 28, blinks: Bool = false, decorative: Bool = false, isHeader: Bool = false) {
        self.size = size
        self.blinks = blinks
        self.decorative = decorative
        self.isHeader = isHeader
    }

    private var scale: CGFloat { size / YaYaBrand.unitsPerSize }
    private var eyeW: CGFloat { 0.17 * size }
    private var eyeH: CGFloat { 0.34 * size }

    public var body: some View {
        let w = YaYaBrand.wordmarkWidth * scale
        let h = YaYaBrand.wordmarkHeight * scale
        ZStack(alignment: .topLeading) {
            YaYaGlyphsShape()
                .fill(Color.primary)
                .frame(width: w, height: h)
            eye(YaYaBrand.eyeLeftGradient)
                .offset(x: (536 - 73) * scale, y: (148 - 70) * scale)
            eye(YaYaBrand.eyeRightGradient)
                .offset(x: (590 - 73) * scale, y: (148 - 70) * scale)
        }
        .frame(width: w, height: h, alignment: .topLeading)
        .modifier(WordmarkAccessibility(decorative: decorative, isHeader: isHeader))
        .task(id: blinks && !reduceMotion) {
            if blinks && !reduceMotion { clock.start() } else { clock.stop() }
        }
        .onDisappear { clock.stop() }
    }

    private func eye(_ gradient: LinearGradient) -> some View {
        Capsule()
            .fill(gradient)
            .frame(width: eyeW, height: eyeH)
            .scaleEffect(y: clock.isBlinking ? 0.1 : 1, anchor: .center)
            .accessibilityHidden(true)
    }
}

private struct WordmarkAccessibility: ViewModifier {
    let decorative: Bool
    let isHeader: Bool
    func body(content: Content) -> some View {
        if decorative {
            content.accessibilityHidden(true)
        } else {
            content
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("YaYa")
                .accessibilityAddTraits(isHeader ? .isHeader : [])
        }
    }
}

// MARK: - Icon mark
/// Black rounded square with two white eyes. Proportions match yaya-icon-rounded.svg.
/// Dark mode adds a 1pt #2A2A2A border. `fullBleed` drops the corners (app icon artwork; iOS applies its own mask).
public struct YaYaMark: View {
    public var size: CGFloat
    public var blinks: Bool
    var fullBleed: Bool = false

    @State private var clock = BlinkClock()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    public init(size: CGFloat = 96, blinks: Bool = false) {
        self.size = size
        self.blinks = blinks
    }

    /// Forces the eyes closed; lets the launch splash drive a single scripted blink.
    var externalBlink: Bool = false

    init(size: CGFloat, blinks: Bool = false, fullBleed: Bool = false, closed: Bool = false) {
        self.size = size
        self.blinks = blinks
        self.fullBleed = fullBleed
        self.externalBlink = closed
    }

    public var body: some View {
        ZStack {
            shape.fill(Color.black)
            HStack(spacing: 0.15 * size) {
                eye
                eye
            }
            if colorScheme == .dark && !fullBleed {
                shape.strokeBorder(YaYaBrand.darkBorder, lineWidth: 1)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("YaYa")
        .task(id: blinks && !reduceMotion) {
            if blinks && !reduceMotion { clock.start() } else { clock.stop() }
        }
        .onDisappear { clock.stop() }
    }

    private var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: fullBleed ? 0 : 0.225 * size, style: .continuous)
    }

    private var eye: some View {
        Ellipse()
            .fill(Color.white)
            .frame(width: 0.115 * size, height: 0.23 * size)
            .scaleEffect(y: (clock.isBlinking || externalBlink) ? 0.1 : 1, anchor: .center)
    }
}

// MARK: - Logo sheet (-logoSheet verification screen)
public struct LogoSheetView: View {
    public init() {}
    public var body: some View {
        HStack(spacing: 0) {
            panel.environment(\.colorScheme, .light)
            panel.environment(\.colorScheme, .dark)
        }
        .ignoresSafeArea()
    }

    private var panel: some View {
        ModePanel()
    }

    private struct ModePanel: View {
        @Environment(\.colorScheme) private var scheme
        var body: some View {
            VStack(alignment: .leading, spacing: 28) {
                Spacer(minLength: 0)
                ForEach([17, 34, 64] as [CGFloat], id: \.self) { s in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(Int(s)) pt").font(.caption2.monospaced()).foregroundStyle(.secondary)
                        YaYaWordmark(size: s, blinks: true)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("mark 96 / 40").font(.caption2.monospaced()).foregroundStyle(.secondary)
                    HStack(spacing: 16) {
                        YaYaMark(size: 96, blinks: true)
                        YaYaMark(size: 40)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(scheme == .dark ? Color.black : Color.white)
        }
    }
}
