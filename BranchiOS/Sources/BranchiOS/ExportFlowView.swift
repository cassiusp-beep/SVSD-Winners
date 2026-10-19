import SwiftUI
#if canImport(UIKit)
import UIKit

// MARK: - Share button (entry point)

/// 44pt glass circle with the system share glyph. Presents the Export flow full screen (tab bar hidden).
public struct ExportShareButton: View {
    @Bindable var store: DemoStore
    public let scope: ExportScope
    @State private var isPresented = false
    
    public init(store: DemoStore, scope: ExportScope) {
        self.store = store
        self.scope = scope
    }
    
    public var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
        .accessibilityLabel("Share")
        .accessibilityHint(scope == .session ? "Export this session" : "Export this project")
        .fullScreenCover(isPresented: $isPresented, onDismiss: { ExportFileWriter.cleanUp() }) {
            ExportFlowView(store: store, scope: scope) { isPresented = false }
        }
    }
}

// MARK: - Flow

private enum ExportStep: Hashable { case preview }

public struct ExportFlowView: View {
    @Bindable var store: DemoStore
    let scope: ExportScope
    let onClose: () -> Void
    
    @State private var format: ExportFormat
    @State private var selection = ExportSelection()
    @State private var path: [ExportStep]
    @State private var shareItems: ExportShareItems?
    @State private var toast: CaptureToastItem?
    @State private var didAutoShare = false
    @State private var pendingAutoShare: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .caption) private var monoSize: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var tileSize: CGFloat = 72
    
    /// Launch-arg scope for screenshots: `-exportFlow session|project`.
    public static var launchScope: ExportScope? {
        let a = CommandLine.arguments
        guard let i = a.firstIndex(of: "-exportFlow"), i + 1 < a.count else { return nil }
        return a[i + 1] == "project" ? .project(DemoProject.defaultID) : .session
    }
    
    public init(store: DemoStore, scope: ExportScope, onClose: @escaping () -> Void) {
        self.store = store
        self.scope = scope
        self.onClose = onClose
        let a = CommandLine.arguments
        var initial = ExportFormat.map
        if let i = a.firstIndex(of: "-exportOption"), i + 1 < a.count, let f = ExportFormat(rawValue: a[i + 1]) { initial = f }
        _format = State(initialValue: initial)
        let preview = a.contains("-exportPreview") || a.contains("-exportShare")
        _path = State(initialValue: preview ? [.preview] : [])
        _pendingAutoShare = State(initialValue: a.contains("-exportShare"))
    }
    
    private var snapshot: ExportSnapshot { store.exportSnapshot(for: scope) }
    private var background: Color { colorScheme == .dark ? .black : .white }
    private var pickerAnimation: Animation? { reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.85) }
    
    public var body: some View {
        NavigationStack(path: $path) {
            chooseScreen
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: ExportStep.self) { _ in
                    previewScreen
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
        .background(background.ignoresSafeArea())
    }
    
    // MARK: Shared pieces
    
    private func glassButton(symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
        .accessibilityLabel(label)
    }
    
    private func monoLabel(_ text: String) -> some View {
        Text(text)
            .font(Font.yaya(size: monoSize))
            .tracking(1.0)
            .foregroundStyle(.secondary)
    }
    
    private func bottomButton(title: String, enabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(background)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background(Capsule().fill(Color.primary))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
    }
    
    // MARK: Choose
    
    private var headline: Text {
        switch scope {
        case .session:
            return Text("How do you want to share this session?")
        case .project:
            return Text("How do you want to share ")
                + Text(snapshot.name).foregroundStyle(store.familyAccent(for: colorScheme))
                + Text("?")
        }
    }
    
    private var chooseScreen: some View {
        VStack(spacing: 0) {
            HStack {
                glassButton(symbol: "chevron.left", label: "Back", action: close)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    monoLabel("EXPORT")
                        .padding(.top, 20)
                        .accessibilityHidden(true)
                    headline
                        .font(.system(size: 32, weight: .heavy))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 14)
                        .accessibilityAddTraits(.isHeader)
                    
                    VStack(spacing: 12) {
                        ForEach(ExportFormat.allCases) { option in
                            optionCard(option)
                        }
                    }
                    .padding(.top, 28)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomButton(title: "Preview export") {
                path = [.preview]
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(background)
        }
        .background(background.ignoresSafeArea())
    }
    
    private func optionCard(_ option: ExportFormat) -> some View {
        let isSelected = format == option
        return Button {
            guard format != option else { return }
            withAnimation(pickerAnimation) { format = option }
        } label: {
            HStack(alignment: .center, spacing: 14) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.primary.opacity(0.06))
                    .frame(width: tileSize, height: tileSize)
                    .overlay { ExportOptionIcon(option: option) }
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(option.detail)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(option.formatLine)
                        .font(Font.yaya(size: monoSize))
                        .tracking(0.6)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                ExportRadio(isOn: isSelected)
                    .accessibilityHidden(true)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(background))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? Color.primary : Color.primary.opacity(0.14), lineWidth: isSelected ? 2 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: format) { old, new in new == option && old != new }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(option.title), \(option.detail), \(option.formatLine.replacingOccurrences(of: "·", with: "")), \(isSelected ? "selected" : "not selected")")
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: Preview
    
    private var previewScreen: some View {
        let snap = snapshot
        return VStack(spacing: 0) {
            HStack {
                glassButton(symbol: "chevron.left", label: "Back") {
                    path = []
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    monoLabel(format.previewLabel)
                        .padding(.top, 20)
                    Text("Check your export.")
                        .font(.system(size: 32, weight: .heavy))
                        .padding(.top, 14)
                        .accessibilityAddTraits(.isHeader)
                    
                    ExportPreviewCard(format: format, snapshot: snap, selection: selection, store: store)
                        .padding(.top, 20)
                    
                    contentsCard(snap)
                        .padding(.top, 16)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                if selection.isEmpty {
                    Text("Choose at least one thing to include.")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                bottomButton(title: "Export \(format.previewLabel)", enabled: !selection.isEmpty, action: performExport)
                Text("Nothing is shared until you send the file.")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(background)
        }
        .background(background.ignoresSafeArea())
        .overlay(alignment: .top) {
            if let toast {
                CaptureToast(item: toast)
                    .padding(.top, 68)
                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                    .id(toast.id)
            }
        }
        .animation(reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.82), value: toast?.id)
        .task(id: toast?.id) {
            guard toast != nil else { return }
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if !Task.isCancelled { toast = nil }
        }
        .sheet(item: $shareItems) { items in
            ExportActivityView(urls: items.urls)
                .presentationDetents([.medium, .large])
                .ignoresSafeArea()
        }
        .onAppear {
            if pendingAutoShare && !didAutoShare {
                didAutoShare = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { performExport() }
            }
        }
    }
    
    private func contentsCard(_ snap: ExportSnapshot) -> some View {
        VStack(spacing: 0) {
            contentRow("Threads", value: "\(snap.threadCount)", isOn: $selection.threads)
            Divider()
            contentRow("Sources and links", value: "\(snap.sourceCount)", isOn: $selection.sources)
            Divider()
            contentRow("Quotes from your recordings", value: "TEXT ONLY", isOn: $selection.quotes)
            Divider()
            contentRow("Your sprite and direction", value: "PRIVATE", isOn: $selection.sprite)
        }
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(background))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.primary.opacity(0.14), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
    
    private func contentRow(_ label: String, value: String, isOn: Binding<Bool>) -> some View {
        Button {
            withAnimation(pickerAnimation) { isOn.wrappedValue.toggle() }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundStyle(isOn.wrappedValue ? Color.primary : Color.primary.opacity(0.3))
                Text(label)
                    .font(.system(size: 17))
                    .foregroundStyle(isOn.wrappedValue ? Color.primary : Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(value)
                    .font(Font.yaya(size: monoSize))
                    .tracking(0.6)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isOn.wrappedValue)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value.lowercased()), \(isOn.wrappedValue ? "checked" : "not checked")")
        .accessibilityAddTraits(.isButton)
    }
    
    // MARK: Actions
    
    private func close() {
        ExportFileWriter.cleanUp()
        onClose()
    }
    
    private func performExport() {
        guard !selection.isEmpty else { return }
        if format == .video {
            toast = CaptureToastItem(message: "Video export is coming soon", thumbnail: nil, isLink: false, isHint: true)
            AccessibilityNotification.Announcement("Video export is coming soon").post()
            return
        }
        let doc = ExportDocument(snapshot: snapshot, selection: selection)
        do {
            let urls = format == .map ? try ExportFileWriter.writeMap(doc) : try ExportFileWriter.writePackage(doc)
            #if DEBUG
            for u in urls { print("EXPORT_FILE \(u.path)") }
            #endif
            shareItems = ExportShareItems(urls: urls)
        } catch {
            toast = CaptureToastItem(message: "Could not create the file", thumbnail: nil, isLink: false, isHint: true)
            AccessibilityNotification.Announcement("Could not create the file").post()
        }
    }
}

// MARK: - Share sheet

struct ExportShareItems: Identifiable {
    let id = UUID()
    let urls: [URL]
}

struct ExportActivityView: UIViewControllerRepresentable {
    let urls: [URL]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: urls, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

// MARK: - Radio and icons

struct ExportRadio: View {
    let isOn: Bool
    var body: some View {
        ZStack {
            Circle().stroke(Color.primary.opacity(isOn ? 1 : 0.22), lineWidth: isOn ? 0 : 1.5)
            if isOn {
                Circle().fill(Color.primary)
                Circle().fill(Color(.systemBackground)).frame(width: 10, height: 10)
            }
        }
        .frame(width: 28, height: 28)
    }
}

struct ExportOptionIcon: View {
    let option: ExportFormat
    var body: some View {
        switch option {
        case .map:
            Canvas { ctx, size in
                let top = CGPoint(x: size.width * 0.5, y: size.height * 0.2)
                let l = CGPoint(x: size.width * 0.2, y: size.height * 0.78)
                let r = CGPoint(x: size.width * 0.8, y: size.height * 0.78)
                var p = Path()
                p.move(to: top); p.addLine(to: l); p.addLine(to: r); p.closeSubpath()
                ctx.stroke(p, with: .color(.primary.opacity(0.55)), lineWidth: 1.5)
                ctx.fill(Path(ellipseIn: CGRect(x: top.x - 6, y: top.y - 6, width: 12, height: 12)), with: .color(.primary))
                for pt in [l, r] {
                    let c = CGRect(x: pt.x - 6, y: pt.y - 6, width: 12, height: 12)
                    ctx.fill(Path(ellipseIn: c), with: .color(Color(.systemBackground)))
                    ctx.stroke(Path(ellipseIn: c), with: .color(.primary), lineWidth: 1.8)
                }
            }
            .frame(width: 44, height: 44)
        case .video:
            VStack(spacing: 8) {
                Image(systemName: "play.fill").font(.system(size: 20)).foregroundStyle(.primary)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.15))
                    Capsule().fill(Color.primary).frame(width: 14)
                }
                .frame(width: 40, height: 4)
            }
        case .package:
            ZStack {
                RoundedRectangle(cornerRadius: 5).stroke(Color.primary, lineWidth: 1.8)
                    .frame(width: 26, height: 32).offset(x: 6, y: -5)
                RoundedRectangle(cornerRadius: 5).fill(Color(.systemBackground))
                    .frame(width: 26, height: 32).offset(x: -3, y: 3)
                RoundedRectangle(cornerRadius: 5).stroke(Color.primary, lineWidth: 1.8)
                    .frame(width: 26, height: 32).offset(x: -3, y: 3)
                VStack(alignment: .leading, spacing: 4) {
                    Capsule().frame(width: 14, height: 2)
                    Capsule().frame(width: 14, height: 2)
                    Capsule().frame(width: 9, height: 2)
                }
                .foregroundStyle(Color.primary.opacity(0.7))
                .offset(x: -3, y: 3)
            }
            .frame(width: 44, height: 44)
        }
    }
}

// MARK: - Preview card

struct ExportPreviewCard: View {
    let format: ExportFormat
    let snapshot: ExportSnapshot
    let selection: ExportSelection
    @Bindable var store: DemoStore
    
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .caption) private var monoSize: CGFloat = 12
    
    var body: some View {
        Group {
            switch format {
            case .map: mapCard
            case .video: videoCard
            case .package: packageCard
            }
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color(.secondarySystemBackground)))
        .accessibilityElement(children: .combine)
    }
    
    private var mapCard: some View {
        Group {
            if let map = ExportMiniMap(entries: snapshot.entries) {
                ExportMiniMapView(map: map, store: store)
                    .frame(height: 210)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Preview of the map: \(map.all.count) connected ideas, starting from \(map.main.shortLabel)")
            } else {
                Text("No threads to map yet.")
                    .font(.system(size: 15)).foregroundStyle(.secondary)
                    .frame(height: 210)
            }
        }
    }
    
    private var videoCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.9))
                .overlay(alignment: .bottomLeading) {
                    Text(snapshot.name)
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Color(.systemBackground))
                        .lineLimit(2)
                        .padding(14)
                }
            Image(systemName: "play.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color(.systemBackground))
                .frame(width: 64, height: 64)
                .background(Circle().fill(Color(.systemBackground).opacity(0.18)))
        }
        .frame(height: 150)
        .overlay(alignment: .topTrailing) {
            Text("ABOUT 40 SEC")
                .font(Font.yaya(size: monoSize)).tracking(0.8)
                .foregroundStyle(Color(.systemBackground).opacity(0.8))
                .padding(12)
        }
        .padding(14)
        .accessibilityLabel("Preview of the video, about 40 seconds")
    }
    
    private var packageCard: some View {
        let doc = ExportDocument(snapshot: snapshot, selection: selection)
        var rows: [String] = []
        if doc.hasInsightsContent { rows.append("insights.md") }
        if doc.hasSourcesContent { rows.append("sources.md (\(snapshot.sourceCount))") }
        return VStack(alignment: .leading, spacing: 10) {
            ForEach(rows, id: \.self) { r in
                HStack(spacing: 10) {
                    Image(systemName: "doc.text").font(.system(size: 15)).foregroundStyle(.secondary)
                    Text(r).font(Font.yaya(size: monoSize + 2)).foregroundStyle(.primary)
                }
            }
            if rows.isEmpty {
                Text("Your sprite and direction only").font(Font.yaya(size: monoSize + 2)).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .accessibilityLabel("Files in the package: \(rows.joined(separator: ", "))")
    }
}

// MARK: - Mini network

private struct ExportNodeSizeKey: PreferenceKey {
    static let defaultValue: [String: CGSize] = [:]
    static func reduce(value: inout [String: CGSize], nextValue: () -> [String: CGSize]) { value.merge(nextValue()) { $1 } }
}

struct ExportMiniMapView: View {
    let map: ExportMiniMap
    @Bindable var store: DemoStore
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .caption) private var monoSize: CGFloat = 11
    
    @State private var nodeSizes: [String: CGSize] = [:]
    private let edgeInset: CGFloat = 10
    
    private func position(_ id: String, in size: CGSize) -> CGPoint {
        let f: (CGFloat, CGFloat)
        if id == map.main.id { f = (0.5, 0.17) }
        else if id == map.artifact?.id { f = (0.36, 0.5) }
        else if id == map.colored?.id { f = (0.7, 0.8) }
        else if let i = map.extras.firstIndex(where: { $0.id == id }) { f = i == 0 ? (0.74, 0.4) : (0.25, 0.86) }
        else { f = (0.5, 0.5) }
        var x = size.width * f.0, y = size.height * f.1
        // Keep the whole pill inside the card, with padding (uses measured size).
        if let n = nodeSizes[id] {
            let hw = min(n.width, size.width - 2 * edgeInset) / 2, hh = n.height / 2
            x = min(max(x, hw + edgeInset), size.width - hw - edgeInset)
            y = min(max(y, hh + edgeInset), size.height - hh - edgeInset)
        }
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Canvas { ctx, size in
                    for (a, b) in map.edges {
                        var p = Path()
                        p.move(to: position(a, in: size))
                        p.addLine(to: position(b, in: size))
                        ctx.stroke(p, with: .color(.primary.opacity(0.4)), lineWidth: 1.5)
                    }
                }
                ForEach(map.all) { e in
                    node(e)
                        .background(GeometryReader { g in
                            Color.clear.preference(key: ExportNodeSizeKey.self, value: [e.id: g.size])
                        })
                        .position(position(e.id, in: geo.size))
                }
            }
            .onPreferenceChange(ExportNodeSizeKey.self) { nodeSizes = $0 }
            .clipped()
        }
    }
    
    @ViewBuilder
    private func node(_ e: KnowledgeEntry) -> some View {
        if e.id == map.main.id {
            Text(e.shortLabel)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color(.systemBackground))
                .lineLimit(1)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(Capsule().fill(Color.primary))
                .frame(maxWidth: 240)
        } else if e.id == map.artifact?.id {
            VStack(alignment: .leading, spacing: 3) {
                Text(e.media?.title ?? e.shortLabel)
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(.primary).lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "doc").font(.system(size: 9))
                    Text((e.media?.source ?? "").uppercased()).font(Font.yaya(size: monoSize)).lineLimit(1)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12).padding(.vertical, 9)
            .frame(maxWidth: 190, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.systemBackground)))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.primary.opacity(0.18), lineWidth: 1))
        } else if e.id == map.colored?.id {
            let family = e.actor.sprite ?? store.accentFamily
            Text(e.shortLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 12).padding(.vertical, 9)
                .frame(maxWidth: 170)
                .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(FamilyAccent.color(for: family, scheme: .light)))
        } else {
            Text(e.shortLabel)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .padding(.horizontal, 12).padding(.vertical, 7)
                .frame(maxWidth: 128)
                .background(Capsule().fill(Color(.systemBackground)))
                .overlay(Capsule().stroke(Color.primary.opacity(0.18), lineWidth: 1))
        }
    }
}
#endif
