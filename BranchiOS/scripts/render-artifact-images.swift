// Renders the colourful demo artifact images used inside the Takeaways slabs.
// Run: swiftc -o /tmp/render-art scripts/render-artifact-images.swift && /tmp/render-art Sources/BranchiOS/Resources
import SwiftUI
import AppKit

let S: CGFloat = 512

struct Moodboard: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.97, green: 0.93, blue: 0.86)
            Rectangle().fill(LinearGradient(colors: [Color(red: 1, green: 0.55, blue: 0.3), Color(red: 0.95, green: 0.25, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 250, height: 300).offset(x: 20, y: 24)
            Circle().fill(Color(red: 0.2, green: 0.45, blue: 0.95)).frame(width: 210, height: 210).offset(x: 270, y: 40)
            Rectangle().fill(Color(red: 1, green: 0.85, blue: 0.15)).frame(width: 230, height: 170).offset(x: 250, y: 270)
            RoundedRectangle(cornerRadius: 30).fill(Color(red: 0.1, green: 0.7, blue: 0.55)).frame(width: 200, height: 170).offset(x: 40, y: 330)
            Circle().fill(Color(red: 0.55, green: 0.3, blue: 0.9)).frame(width: 130, height: 130).offset(x: 150, y: 220)
            Rectangle().fill(Color.black.opacity(0.85)).frame(width: 60, height: 200).offset(x: 215, y: 150)
        }.frame(width: S, height: S).clipped()
    }
}

struct FigmaFrame: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.88, green: 0.9, blue: 0.96)
            RoundedRectangle(cornerRadius: 36).fill(.white).frame(width: 300, height: 440).offset(x: 106, y: 36)
            RoundedRectangle(cornerRadius: 24).fill(LinearGradient(colors: [Color(red: 0.4, green: 0.3, blue: 1), Color(red: 0.2, green: 0.7, blue: 1)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 260, height: 150).offset(x: 126, y: 60)
            RoundedRectangle(cornerRadius: 14).fill(Color(red: 1, green: 0.4, blue: 0.35)).frame(width: 120, height: 60).offset(x: 126, y: 240)
            RoundedRectangle(cornerRadius: 14).fill(Color(red: 0.15, green: 0.8, blue: 0.5)).frame(width: 120, height: 60).offset(x: 266, y: 240)
            RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.8, green: 0.82, blue: 0.9)).frame(width: 260, height: 26).offset(x: 126, y: 325)
            RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.8, green: 0.82, blue: 0.9)).frame(width: 180, height: 26).offset(x: 126, y: 365)
            Capsule().fill(Color(red: 0.95, green: 0.3, blue: 0.75)).frame(width: 260, height: 50).offset(x: 126, y: 410)
            Rectangle().stroke(Color(red: 0.1, green: 0.6, blue: 1), lineWidth: 5).frame(width: 330, height: 470).offset(x: 91, y: 21)
            Rectangle().fill(Color(red: 0.1, green: 0.6, blue: 1)).frame(width: 18, height: 18).offset(x: 82, y: 12)
            Rectangle().fill(Color(red: 0.1, green: 0.6, blue: 1)).frame(width: 18, height: 18).offset(x: 412, y: 482)
        }.frame(width: S, height: S).clipped()
    }
}

struct Stickies: View {
    var body: some View {
        let colors: [Color] = [Color(red: 1, green: 0.85, blue: 0.2), Color(red: 1, green: 0.45, blue: 0.6), Color(red: 0.35, green: 0.85, blue: 0.95), Color(red: 0.6, green: 0.9, blue: 0.4), Color(red: 1, green: 0.62, blue: 0.2), Color(red: 0.75, green: 0.55, blue: 1)]
        ZStack(alignment: .topLeading) {
            Color(red: 0.93, green: 0.92, blue: 0.9)
            ForEach(0..<9, id: \.self) { i in
                let c = i % 3, r = i / 3
                Rectangle().fill(colors[(i * 5) % colors.count])
                    .frame(width: 140, height: 140)
                    .shadow(color: .black.opacity(0.25), radius: 6, x: 3, y: 5)
                    .rotationEffect(.degrees(Double((i * 37) % 11) - 5))
                    .offset(x: 28 + CGFloat(c) * 160, y: 28 + CGFloat(r) * 160)
            }
            Circle().fill(Color(red: 0.9, green: 0.15, blue: 0.2)).frame(width: 60, height: 60).offset(x: 210, y: 200)
        }.frame(width: S, height: S).clipped()
    }
}

struct Scene: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.98, green: 0.78, blue: 0.4), Color(red: 1, green: 0.45, blue: 0.4), Color(red: 0.5, green: 0.25, blue: 0.7)], startPoint: .top, endPoint: .bottom)
            Circle().fill(Color(red: 1, green: 0.95, blue: 0.7)).frame(width: 190, height: 190).offset(x: 70, y: -40)
            Path { p in
                p.move(to: CGPoint(x: 0, y: 330)); p.addLine(to: CGPoint(x: 120, y: 230)); p.addLine(to: CGPoint(x: 230, y: 320)); p.addLine(to: CGPoint(x: 360, y: 210)); p.addLine(to: CGPoint(x: 512, y: 330)); p.addLine(to: CGPoint(x: 512, y: 512)); p.addLine(to: CGPoint(x: 0, y: 512)); p.closeSubpath()
            }.fill(Color(red: 0.25, green: 0.12, blue: 0.4))
            Path { p in
                p.move(to: CGPoint(x: 0, y: 420)); p.addQuadCurve(to: CGPoint(x: 512, y: 410), control: CGPoint(x: 250, y: 330)); p.addLine(to: CGPoint(x: 512, y: 512)); p.addLine(to: CGPoint(x: 0, y: 512)); p.closeSubpath()
            }.fill(Color(red: 0.08, green: 0.3, blue: 0.4))
        }.frame(width: S, height: S).clipped()
    }
}

struct DataMap: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.08, green: 0.1, blue: 0.2)
            let pts: [(CGFloat, CGFloat, CGFloat, Color)] = [(120, 130, 80, Color(red: 0.2, green: 0.9, blue: 0.8)), (330, 110, 110, Color(red: 1, green: 0.3, blue: 0.6)), (250, 280, 70, Color(red: 1, green: 0.8, blue: 0.2)), (110, 350, 100, Color(red: 0.5, green: 0.4, blue: 1)), (390, 380, 80, Color(red: 0.3, green: 0.8, blue: 1))]
            Path { p in
                p.move(to: CGPoint(x: pts[0].0, y: pts[0].1))
                for q in pts.dropFirst() { p.addLine(to: CGPoint(x: q.0, y: q.1)) }
                p.addLine(to: CGPoint(x: pts[0].0, y: pts[0].1))
            }.stroke(Color.white.opacity(0.7), lineWidth: 6)
            ForEach(0..<pts.count, id: \.self) { i in
                Circle().fill(pts[i].3).frame(width: pts[i].2 * 1.6, height: pts[i].2 * 1.6).position(x: pts[i].0, y: pts[i].1)
            }
        }.frame(width: S, height: S).clipped()
    }
}

@MainActor func render<V: View>(_ v: V, _ name: String, _ dir: URL) {
    let r = ImageRenderer(content: v); r.scale = 1
    guard let cg = r.cgImage else { fatalError(name) }
    let rep = NSBitmapImageRep(cgImage: cg)
    let url = dir.appendingPathComponent(name + ".png")
    try! rep.representation(using: .png, properties: [:])!.write(to: url)
    print("wrote", url.path)
}

@MainActor func main() {
    let dir = URL(fileURLWithPath: CommandLine.arguments[1])
    render(Moodboard(), "artifact_moodboard", dir)
    render(FigmaFrame(), "artifact_figma", dir)
    render(Stickies(), "artifact_stickies", dir)
    render(Scene(), "artifact_scene", dir)
    render(DataMap(), "artifact_data", dir)
}
MainActor.assumeIsolated { main() }
