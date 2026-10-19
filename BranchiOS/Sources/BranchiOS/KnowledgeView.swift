import SwiftUI

// MARK: - Knowledge View (Living Project Repository)
public struct KnowledgeView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    public var isLiveSession: Bool = false
    public var sessionClock: Double = 0.0
    public var passedContext: ContributionCellContext? = nil
    public var onDismissContext: () -> Void = {}
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Media zoom sheet state
    @State private var selectedMedia: KnowledgeMedia? = nil
    
    // Highlighted entry ID for Takeaways handoff
    @State private var highlightedEntryID: String? = nil
    @State private var highlightOpacity: Double = 0.0
    
    // User manual scroll detection
    @State private var userHasScrolledUp: Bool = false
    @State private var livePulse: Bool = false
    
    public init(
        store: DemoStore = DemoStore.shared,
        isLiveSession: Bool = false,
        sessionClock: Double = 0.0,
        passedContext: ContributionCellContext? = nil,
        onDismissContext: @escaping () -> Void = {}
    ) {
        self.store = store
        self.isLiveSession = isLiveSession
        self.sessionClock = sessionClock
        self.passedContext = passedContext
        self.onDismissContext = onDismissContext
    }
    
    // Active project filter title
    private var currentProjectTitle: String {
        if isLiveSession {
            return "Ya Ya"
        }
        guard let pid = store.selectedKnowledgeProjectID else {
            return "All projects"
        }
        switch pid {
        case "yaya": return "Ya Ya"
        case "critical_p3": return "Critical design P3"
        default: return "All projects"
        }
    }
    
    // Filtered entries according to mode and project picker
    private var displayedEntries: [KnowledgeEntry] {
        if isLiveSession {
            return store.liveKnowledgeEntries
        }
        guard let pid = store.selectedKnowledgeProjectID else {
            return store.knowledgeEntries
        }
        return store.knowledgeEntries.filter { $0.projectID == pid }
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let totalWidth = proxy.size.width
            let statusWidth: CGFloat = 44.0
            let availableForContent = max(totalWidth - statusWidth, 200.0)
            let ideaWidth = availableForContent * 0.55
            let mediaWidth = availableForContent - ideaWidth
            
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        // 1. Top Project Title & Dropdown Picker (scrolls away normally)
                        VStack(spacing: 0) {
                            projectTitleHeader
                                .frame(width: totalWidth, alignment: .leading)
                                .padding(.top, 10)
                                .padding(.bottom, 14)
                                .id("projectTitleHeader")
                            
                            // Context handoff notification if arrived from Takeaways
                            if let ctx = passedContext {
                                contextHandoffBanner(ctx: ctx)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)
                            }
                        }
                        
                        // 2 & 3. Pinned Column Header Row and Table Rows
                        Section {
                            ForEach(displayedEntries) { entry in
                                knowledgeEntryRow(
                                    entry: entry,
                                    totalWidth: totalWidth,
                                    statusWidth: statusWidth,
                                    ideaWidth: ideaWidth,
                                    mediaWidth: mediaWidth
                                )
                                .id(entry.id)
                            }
                            
                            // Empty state if filtered project has no entries
                            if displayedEntries.isEmpty {
                                emptyStateView
                                    .frame(width: totalWidth)
                                    .padding(.top, 40)
                            }
                        } header: {
                            pinnedColumnHeaderRow(
                                totalWidth: totalWidth,
                                statusWidth: statusWidth,
                                ideaWidth: ideaWidth,
                                mediaWidth: mediaWidth
                            )
                        }
                    }
                }
                .clipped()
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 110)
                }
                .onAppear {
                    if CommandLine.arguments.contains("-tabKnowledgeTop") {
                        // Stay at top to verify project title header & picker
                    } else if displayedEntries.count > 5, let lastID = displayedEntries.last?.id {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            scrollProxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                    
                    // Handle Takeaways cell handoff
                    if let ctx = passedContext {
                        handleHandoffContext(ctx: ctx, scrollProxy: scrollProxy)
                    }
                }
                .onChange(of: store.liveKnowledgeEntries.count) { _, newCount in
                    if isLiveSession, !userHasScrolledUp, newCount > 5, let lastID = store.liveKnowledgeEntries.last?.id {
                        let animation: Animation = reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.82)
                        withAnimation(animation) {
                            scrollProxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: passedContext) { _, newCtx in
                    if let ctx = newCtx {
                        handleHandoffContext(ctx: ctx, scrollProxy: scrollProxy)
                    }
                }
            }
            .clipped()
            .background((colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea())
        }
        .clipped()
        .sheet(item: $selectedMedia) { media in
            MediaZoomViewerSheet(media: media)
        }
        .onAppear {
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    livePulse = true
                }
            }
        }
    }
    
    // MARK: - 1. Project Title & Picker Header
    private var projectTitleHeader: some View {
        HStack(alignment: .center, spacing: 10) {
            if isLiveSession {
                // Live Session Header: "Ya Ya" with LIVE badge
                HStack(spacing: 8) {
                    Text("Ya Ya")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(red: 0.12, green: 0.75, blue: 0.35))
                            .frame(width: 7, height: 7)
                            .opacity(reduceMotion ? 1.0 : (livePulse ? 1.0 : 0.3))
                            .scaleEffect(reduceMotion ? 1.0 : (livePulse ? 1.2 : 0.9))
                        
                        Text("LIVE")
                            .font(Font.yaya(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.12, green: 0.75, blue: 0.35))
                            .tracking(0.6)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(red: 0.12, green: 0.75, blue: 0.35).opacity(0.12))
                    )
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Ya Ya, session is live")
            } else {
                // Normal Mode: Project Picker Dropdown
                Menu {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            store.selectedKnowledgeProjectID = nil
                        }
                    } label: {
                        HStack {
                            Text("All projects")
                            if store.selectedKnowledgeProjectID == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            store.selectedKnowledgeProjectID = "yaya"
                        }
                    } label: {
                        HStack {
                            Text("Ya Ya")
                            if store.selectedKnowledgeProjectID == "yaya" {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            store.selectedKnowledgeProjectID = "critical_p3"
                        }
                    } label: {
                        HStack {
                            Text("Critical design P3")
                            if store.selectedKnowledgeProjectID == "critical_p3" {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(currentProjectTitle)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(currentProjectTitle), project picker")
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - 2. Pinned Column Header Row
    private func pinnedColumnHeaderRow(
        totalWidth: CGFloat,
        statusWidth: CGFloat,
        ideaWidth: CGFloat,
        mediaWidth: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            // Top border
            Rectangle()
                .fill(Color.primary.opacity(0.10))
                .frame(height: 1)
            
            HStack(spacing: 0) {
                // Status Header Column
                ZStack {
                    if isLiveSession {
                        Circle()
                            .fill(Color(red: 0.12, green: 0.75, blue: 0.35))
                            .frame(width: 8, height: 8)
                            .opacity(reduceMotion ? 1.0 : (livePulse ? 1.0 : 0.3))
                    }
                }
                .frame(width: statusWidth, height: 38)
                
                // Vertical divider 1
                Rectangle()
                    .fill(Color.primary.opacity(0.10))
                    .frame(width: 1, height: 38)
                
                // Idea / Concept Header Column
                HStack {
                    Text("IDEA  /  CONCEPT")
                        .font(Font.yaya(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(0.6)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(width: ideaWidth, height: 38)
                
                // Vertical divider 2
                Rectangle()
                    .fill(Color.primary.opacity(0.10))
                    .frame(width: 1, height: 38)
                
                // Media Header Column
                HStack {
                    Text("MEDIA")
                        .font(Font.yaya(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(0.6)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(width: mediaWidth, height: 38)
            }
            .background(
                colorScheme == .dark ? Color.black : Color.white
            )
            
            // Bottom border
            Rectangle()
                .fill(Color.primary.opacity(0.10))
                .frame(height: 1)
        }
        .frame(width: totalWidth)
    }
    
    // MARK: - 3. Knowledge Entry Row
    private func knowledgeEntryRow(
        entry: KnowledgeEntry,
        totalWidth: CGFloat,
        statusWidth: CGFloat,
        ideaWidth: CGFloat,
        mediaWidth: CGFloat
    ) -> some View {
        let isHighlighted = highlightedEntryID == entry.id
        
        return VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                // Status Column
                VStack {
                    statusBadge(type: entry.type)
                        .padding(.top, 14)
                    Spacer()
                }
                .frame(width: statusWidth)
                
                // Vertical divider 1
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 1)
                
                // Idea / Concept Column
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.dateDisplay)
                        .font(Font.yaya(size: 11, weight: .bold))
                        .foregroundStyle(.secondary)
                        .tracking(0.5)
                    
                    Text(entry.text)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .frame(width: ideaWidth, alignment: .topLeading)
                
                // Vertical divider 2
                Rectangle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 1)
                
                // Media Column
                VStack(alignment: .leading, spacing: 6) {
                    if let media = entry.media {
                        mediaCellView(media: media, maxWidth: mediaWidth - 24)
                    } else {
                        // Empty cell
                        Spacer()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
                .frame(width: mediaWidth, alignment: .topLeading)
            }
            .frame(width: totalWidth)
            .background(
                isHighlighted ?
                    (entry.agentSprite?.gradientColors.first ?? Color.accentColor).opacity(highlightOpacity) :
                    Color.clear
            )
            
            // Horizontal row separator extending edge-to-edge
            Rectangle()
                .fill(Color.primary.opacity(0.08))
                .frame(height: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(entry.accessibilitySummary)
    }
    
    // MARK: - Status Badge
    private func statusBadge(type: KnowledgeEntryType) -> some View {
        ZStack {
            Circle()
                .fill(type.badgeColor)
                .frame(width: 28, height: 28)
            
            Text(type.symbolString)
                .font(.system(size: type == .reframe ? 12 : 16, weight: .bold))
                .foregroundStyle(Color.white)
        }
        .frame(width: 44, height: 44) // 44pt accessible touch target
        .contentShape(Rectangle())
        .accessibilityLabel(type.accessibilityLabel)
    }
    
    // MARK: - Media Cell View
    private func mediaCellView(media: KnowledgeMedia, maxWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                selectedMedia = media
            } label: {
                thumbnailView(media: media, maxWidth: maxWidth)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("View \(media.title) media")
            
            Text(media.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("\(media.source)  ·  \(media.dateString)")
                .font(Font.yaya(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(0.5)
        }
    }
    
    // MARK: - Thumbnail Rendering
    @ViewBuilder
    private func thumbnailView(media: KnowledgeMedia, maxWidth: CGFloat) -> some View {
        let width = min(maxWidth, 140)
        let height: CGFloat = 80
        
        #if canImport(UIKit)
        let loadedImage: UIImage? = {
            guard let assetName = media.assetName else { return nil }
            if let path = Bundle.module.path(forResource: assetName, ofType: "png") ?? Bundle.module.path(forResource: assetName, ofType: nil) {
                return UIImage(contentsOfFile: path)
            }
            return UIImage(named: assetName, in: Bundle.module, with: nil) ?? UIImage(named: assetName)
        }()
        
        if let uiImage = loadedImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
        } else {
            fallbackGraphicThumbnail(media: media, width: width, height: height)
        }
        #else
        fallbackGraphicThumbnail(media: media, width: width, height: height)
        #endif
    }
    
    // Fallback procedural graphic thumbnail styled like real Miro/Whiteboard/Figma cards
    private func fallbackGraphicThumbnail(media: KnowledgeMedia, width: CGFloat, height: CGFloat) -> some View {
        ZStack(alignment: .topLeading) {
            if media.source.uppercased().contains("WHITEBOARD") {
                // Whiteboard canvas with diagram lines
                Color(red: 0.96, green: 0.97, blue: 0.98)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color(red: 0.20, green: 0.40, blue: 0.85), lineWidth: 1.5)
                            .frame(width: 36, height: 18)
                            .overlay(Text("IDEA").font(.system(size: 6, weight: .bold)).foregroundStyle(Color(red: 0.20, green: 0.40, blue: 0.85)))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 7))
                            .foregroundStyle(Color.secondary)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color(red: 0.80, green: 0.25, blue: 0.25), lineWidth: 1.5)
                            .frame(width: 36, height: 18)
                    }
                    
                    if let snippet = media.previewSnippet {
                        Text(snippet)
                            .font(.system(size: 7, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.black.opacity(0.65))
                            .lineLimit(3)
                    }
                }
                .padding(8)
            } else if media.source.uppercased().contains("MIRO") {
                // Miro sticky / narrative style
                Color(red: 0.99, green: 0.98, blue: 0.95)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(media.title)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Color.black)
                    
                    if let snippet = media.previewSnippet {
                        Text(snippet)
                            .font(.system(size: 6, weight: .regular))
                            .foregroundStyle(Color.black.opacity(0.60))
                            .lineLimit(4)
                    }
                }
                .padding(8)
            } else {
                // Figma schematic style
                Color(red: 0.94, green: 0.94, blue: 0.96)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 3) {
                        Circle().fill(Color.purple).frame(width: 5, height: 5)
                        Circle().fill(Color.blue).frame(width: 5, height: 5)
                        Circle().fill(Color.orange).frame(width: 5, height: 5)
                    }
                    if let snippet = media.previewSnippet {
                        Text(snippet)
                            .font(.system(size: 6.5, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.70))
                            .lineLimit(3)
                    }
                }
                .padding(8)
            }
        }
        .frame(width: width, height: height)
    }
    
    // MARK: - Context Handoff Banner from Takeaways
    private func contextHandoffBanner(ctx: ContributionCellContext) -> some View {
        HStack(spacing: 12) {
            SpriteView(sprite: ctx.agentSprite, isBlinking: false, showsArms: false)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(ctx.agentName) · \(ctx.timeRangeString)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(ctx.actionsSummary)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    onDismissContext()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.10), lineWidth: 1)
        )
    }
    
    // Empty state when project has no items
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("No entries in \(currentProjectTitle)")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.secondary)
        }
    }
    
    // Handle scrolling & soft pulsing gradient highlight for Takeaways cell handoff
    private func handleHandoffContext(ctx: ContributionCellContext, scrollProxy: ScrollViewProxy) {
        // Find matching entry from this agent or matching slice
        let matched = displayedEntries.first { entry in
            entry.agentName?.lowercased() == ctx.agentName.lowercased() ||
            entry.agentId == ctx.agentId
        } ?? displayedEntries.last
        
        guard let entry = matched else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                scrollProxy.scrollTo(entry.id, anchor: .center)
            }
            
            highlightedEntryID = entry.id
            withAnimation(.easeIn(duration: 0.3)) {
                highlightOpacity = 0.35
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    highlightOpacity = 0.0
                }
            }
        }
    }
}

// MARK: - Zoomable Full Screen Media Viewer Sheet
public struct MediaZoomViewerSheet: View {
    public let media: KnowledgeMedia
    @Environment(\.dismiss) private var dismiss
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top header bar with title and close button
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(media.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("\(media.source) · \(media.dateString)")
                            .font(Font.yaya(size: 11, weight: .bold))
                            .foregroundStyle(.white.opacity(0.65))
                            .tracking(0.6)
                    }
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .accessibilityLabel("Close media viewer")
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                Spacer()
                
                // Zoomable Image
                GeometryReader { geo in
                    ZStack {
                        #if canImport(UIKit)
                        let loadedImage: UIImage? = {
                            guard let assetName = media.assetName else { return nil }
                            if let path = Bundle.module.path(forResource: assetName, ofType: "png") ?? Bundle.module.path(forResource: assetName, ofType: nil) {
                                return UIImage(contentsOfFile: path)
                            }
                            return UIImage(named: assetName, in: Bundle.module, with: nil) ?? UIImage(named: assetName)
                        }()
                        
                        if let uiImage = loadedImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            fallbackExpandedGraphic(geo: geo)
                        }
                        #else
                        fallbackExpandedGraphic(geo: geo)
                        #endif
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { val in
                                scale = lastScale * val
                            }
                            .onEnded { _ in
                                lastScale = max(scale, 1.0)
                                if scale < 1.0 {
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                        lastScale = 1.0
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { val in
                                if scale > 1.0 {
                                    offset = CGSize(
                                        width: lastOffset.width + val.translation.width,
                                        height: lastOffset.height + val.translation.height
                                    )
                                }
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                }
                
                Spacer()
                
                if let snippet = media.previewSnippet {
                    Text(snippet)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 36)
                }
            }
        }
    }
    
    private func fallbackExpandedGraphic(geo: GeometryProxy) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: 0.15))
                .frame(width: min(geo.size.width - 40, 340), height: 260)
            
            VStack(spacing: 12) {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 52))
                    .foregroundStyle(.white.opacity(0.5))
                
                Text(media.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(media.source)
                    .font(Font.yaya(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}
