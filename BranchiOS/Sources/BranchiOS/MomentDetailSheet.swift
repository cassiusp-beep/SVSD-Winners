import SwiftUI

// MARK: - Models for Moment Detail Sheet

public struct MomentDetailModel: Identifiable, Sendable {
    public let id: String
    public let statusBadge: String
    public let title: String
    public let subtitle: String
    public let sessionTimeRange: String
    public let audioDurationString: String
    public let quotes: [MomentQuote]
    public let sources: [MomentSource]
    public let threads: [MomentThread]
    public let linkedThreadsCount: Int
    
    public init(
        id: String = UUID().uuidString,
        statusBadge: String,
        title: String,
        subtitle: String,
        sessionTimeRange: String,
        audioDurationString: String,
        quotes: [MomentQuote],
        sources: [MomentSource],
        threads: [MomentThread],
        linkedThreadsCount: Int = 5
    ) {
        self.id = id
        self.statusBadge = statusBadge
        self.title = title
        self.subtitle = subtitle
        self.sessionTimeRange = sessionTimeRange
        self.audioDurationString = audioDurationString
        self.quotes = quotes
        self.sources = sources
        self.threads = threads
        self.linkedThreadsCount = linkedThreadsCount
    }
    
    /// Canonical moment matching reference frame 08d ("Node: from the session")
    public static let canonical = MomentDetailModel(
        id: "one-person-first",
        statusBadge: "AGREED · YOUR IDEA",
        title: "One person first, teams later",
        subtitle: "Agreed today in a session with Naheel, Alex and Cash",
        sessionTimeRange: "04:12-05:40",
        audioDurationString: "1:28",
        quotes: [
            MomentQuote(
                speakerName: "NAHEEL",
                timestamp: "04:12",
                quoteText: "“Is this for one person, or the whole team?”",
                avatarKind: .naheel
            ),
            MomentQuote(
                speakerName: "BHARGS",
                timestamp: "05:31",
                quoteText: "“One person first. Teams can come later.”",
                avatarKind: .bhargs
            )
        ],
        sources: [
            MomentSource(
                title: "Core idea: the individual",
                imageName: "whiteboard_1"
            ),
            MomentSource(
                title: "Granola for individuals or teams?",
                imageName: "whiteboard_2"
            ),
            MomentSource(
                title: "competitors already record",
                imageName: "whiteboard_3"
            )
        ],
        threads: [
            MomentThread(
                title: "Granola, but for teams",
                statusBadge: "RESOLVED FRICTION"
            ),
            MomentThread(
                title: "competitors already record",
                statusBadge: "BACKS THIS UP"
            )
        ]
    )
}

public struct MomentQuote: Identifiable, Sendable {
    public let id: String
    public let speakerName: String
    public let timestamp: String
    public let quoteText: String
    public let avatarKind: AvatarKind
    
    public enum AvatarKind: Sendable {
        case naheel
        case bhargs
        case sprite(BranchSprite)
        case custom(imageName: String)
    }
    
    public init(
        id: String = UUID().uuidString,
        speakerName: String,
        timestamp: String,
        quoteText: String,
        avatarKind: AvatarKind
    ) {
        self.id = id
        self.speakerName = speakerName
        self.timestamp = timestamp
        self.quoteText = quoteText
        self.avatarKind = avatarKind
    }
}

public struct MomentSource: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let imageName: String
    
    public init(id: String = UUID().uuidString, title: String, imageName: String) {
        self.id = id
        self.title = title
        self.imageName = imageName
    }
}

public struct MomentThread: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let statusBadge: String
    
    public init(id: String = UUID().uuidString, title: String, statusBadge: String) {
        self.id = id
        self.title = title
        self.statusBadge = statusBadge
    }
}

// MARK: - MomentDetailSheet View

public struct MomentDetailSheet: View {
    public let model: MomentDetailModel
    public var onSelectThreadOrSource: ((String) -> Void)? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    // Playback state
    @State private var isPlaying: Bool = false
    @State private var playbackProgress: CGFloat = 0.28
    @State private var playbackTimer: Timer? = nil
    
    public init(
        model: MomentDetailModel = .canonical,
        onSelectThreadOrSource: ((String) -> Void)? = nil
    ) {
        self.model = model
        self.onSelectThreadOrSource = onSelectThreadOrSource
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Drag handle spacing / top breathing room
                Color.clear.frame(height: 8)
                
                // Status / Provenance Line (AGREED · YOUR IDEA)
                Text(model.statusBadge)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .padding(.top, 10)
                
                // Title (One person first, teams later)
                Text(model.title)
                    .font(.system(size: 26, weight: .bold, design: .default))
                    .foregroundStyle(.primary)
                    .padding(.top, 6)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Subhead
                Text(model.subtitle)
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Section: FROM THE SESSION · 04:12-05:40
                Text("FROM THE SESSION · \(model.sessionTimeRange)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .padding(.top, 22)
                    .padding(.bottom, 8)
                
                // Audio + Dialogue Card
                audioDialogueCard
                
                // Section: SOURCES · 3
                Text("SOURCES · \(model.sources.count)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .padding(.top, 24)
                    .padding(.bottom, 10)
                
                // Horizontal Sources Row
                sourcesRow
                
                // Section: LINKED THREADS · 5
                Text("LINKED THREADS · \(model.linkedThreadsCount)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .padding(.top, 24)
                    .padding(.bottom, 10)
                
                // Linked Threads list
                linkedThreadsList
                
                // Bottom spacing for comfortable scrolling
                Color.clear.frame(height: 36)
            }
            .padding(.horizontal, 20)
        }
        .background(sheetBackground.ignoresSafeArea())
        .onDisappear {
            stopPlayback()
        }
    }
    
    // MARK: - Sheet Background
    private var sheetBackground: Color {
        colorScheme == .dark ? Color(white: 0.08) : Color.white
    }
    
    private var cardFill: Color {
        colorScheme == .dark
            ? Color(white: 0.14)
            : Color(hex: "F7F6F3") // Warm off-white from 08d reference
    }
    
    // MARK: - Audio + Dialogue Card
    private var audioDialogueCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Audio Scrubber Row
            HStack(alignment: .center, spacing: 12) {
                // Play / Pause Circle Button
                Button {
                    togglePlayback()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "232336"))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .offset(x: isPlaying ? 0 : 1)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isPlaying ? "Pause session audio" : "Play session audio")
                
                // Scrubber Bar
                GeometryReader { geo in
                    let totalW = geo.size.width
                    let barH: CGFloat = 6
                    let thumbD: CGFloat = 14
                    let currentX = max(0, min(totalW, totalW * playbackProgress))
                    
                    ZStack(alignment: .leading) {
                        // Background track
                        Capsule()
                            .fill(Color.secondary.opacity(0.18))
                            .frame(height: barH)
                        
                        // Active gradient fill
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FBBF24"), // Amber
                                        Color(hex: "F472B6")  // Pink / coral
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: currentX, height: barH)
                        
                        // Scrubber thumb
                        Circle()
                            .fill(Color.white)
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 2, y: 1)
                            .frame(width: thumbD, height: thumbD)
                            .offset(x: max(0, currentX - thumbD / 2))
                    }
                    .frame(height: geo.size.height, alignment: .center)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let clampedX = max(0, min(totalW, value.location.x))
                                playbackProgress = clampedX / totalW
                            }
                    )
                }
                .frame(height: 20)
                
                // Time Display
                Text(model.audioDurationString)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            
            // Dialogue Rows
            VStack(alignment: .leading, spacing: 14) {
                ForEach(model.quotes) { quote in
                    dialogueRow(for: quote)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cardFill)
        )
    }
    
    // MARK: - Dialogue Row
    private func dialogueRow(for quote: MomentQuote) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            switch quote.avatarKind {
            case .naheel:
                naheelAvatar
            case .bhargs:
                bhargsAvatar
            case .sprite(let s):
                SpriteView(sprite: s, isBlinking: false, showsArms: false)
                    .frame(width: 32, height: 32)
            case .custom(let img):
                if let ui = TakeawaysArtifactImages.image(img) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 34, height: 34)
                        .clipShape(Circle())
                }
            }
            
            // Name + Timestamp + Quote Text
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(quote.speakerName)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                    
                    Text("·")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary.opacity(0.6))
                    
                    Text(quote.timestamp)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                
                Text(quote.quoteText)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.primary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    // Naheel Photo Avatar with Spark Sprite Ear
    private var naheelAvatar: some View {
        ZStack(alignment: .topTrailing) {
            // Spark ear behind avatar
            SpriteBodyShape(sprite: .spark)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "8AAE83"), Color(hex: "A3E635")],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
                .frame(width: 20, height: 20)
                .offset(x: 4, y: -4)
            
            if let ui = TakeawaysArtifactImages.image("avatar_naheel") {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(hex: "0091FF"), lineWidth: 2))
            } else {
                Circle()
                    .strokeBorder(Color(hex: "0091FF"), lineWidth: 2)
                    .background(Circle().fill(Color.gray.opacity(0.2)))
                    .frame(width: 34, height: 34)
            }
        }
        .frame(width: 40, height: 40)
    }
    
    // Bhargs Yellow/Amber Bloom Sprite Avatar with cute eyes
    private var bhargsAvatar: some View {
        ZStack {
            SpriteBodyShape(sprite: .bloom)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FBBF24"), Color(hex: "F59E0B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Eye dots
            HStack(spacing: 5) {
                Circle().fill(Color(hex: "232336")).frame(width: 3.2, height: 4.2)
                Circle().fill(Color(hex: "232336")).frame(width: 3.2, height: 4.2)
            }
            .offset(y: -1)
        }
        .frame(width: 32, height: 28)
        .padding(.top, 2)
    }
    
    // MARK: - Sources Row
    private var sourcesRow: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(model.sources) { src in
                Button {
                    onSelectThreadOrSource?(src.title)
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        // Image Thumbnail
                        if let ui = TakeawaysArtifactImages.image(src.imageName) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 104, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.secondary.opacity(0.12))
                                .frame(width: 104, height: 72)
                        }
                        
                        // Caption
                        Text(src.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.primary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: 104, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Linked Threads List
    private var linkedThreadsList: some View {
        VStack(spacing: 10) {
            ForEach(model.threads) { thread in
                Button {
                    onSelectThreadOrSource?(thread.title)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(thread.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            Text(thread.statusBadge)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .tracking(0.5)
                                .textCase(.uppercase)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(colorScheme == .dark ? Color(white: 0.12) : Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.primary.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Audio Playback Engine
    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        isPlaying = true
        playbackTimer?.invalidate()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                if playbackProgress >= 1.0 {
                    playbackProgress = 0.0
                }
                playbackProgress = min(1.0, playbackProgress + 0.008)
            }
        }
    }
    
    private func stopPlayback() {
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}
