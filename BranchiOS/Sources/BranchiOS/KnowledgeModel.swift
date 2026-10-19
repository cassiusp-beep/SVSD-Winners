import SwiftUI

// MARK: - Knowledge Entry Type
public enum KnowledgeEntryType: String, CaseIterable, Sendable {
    case addition
    case counterpoint
    case question
    case reframe
    
    public var accessibilityLabel: String {
        switch self {
        case .addition: return "Addition"
        case .counterpoint: return "Counterpoint"
        case .question: return "Open question"
        case .reframe: return "Reframe, an addition"
        }
    }
    
    public var countsAsAddition: Bool {
        switch self {
        case .addition, .reframe: return true
        case .counterpoint, .question: return false
        }
    }
    
    public var symbolString: String {
        switch self {
        case .addition: return "+"
        case .counterpoint: return "−"
        case .question: return "?"
        case .reframe: return "//"
        }
    }
    
    // WCAG >= 3:1 contrast against white symbol in light and dark mode
    public var badgeColor: Color {
        switch self {
        case .addition:
            return Color(red: 0.12, green: 0.55, blue: 0.28) // Deep emerald green
        case .counterpoint:
            return Color(red: 0.78, green: 0.18, blue: 0.18) // Deep crimson red
        case .question:
            return Color(red: 0.72, green: 0.48, blue: 0.02) // Deep golden yellow
        case .reframe:
            return Color(red: 0.12, green: 0.36, blue: 0.72) // Deep cobalt blue
        }
    }
}

// MARK: - Demo Project
public struct DemoProject: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    
    public static let all: [DemoProject] = [
        DemoProject(id: "yaya", name: "Making YaYa"),
        DemoProject(id: "critical_p3", name: "Critical design P3")
    ]
    
    public static let defaultID = "yaya"
    
    public static func name(for id: String?) -> String {
        guard let id else { return "All projects" }
        return all.first(where: { $0.id == id })?.name ?? "All projects"
    }
}

// MARK: - Knowledge Media
public struct KnowledgeMedia: Identifiable, Equatable, Sendable {
    public var id: String { "\(source)_\(title)_\(dateString)" }
    public var title: String
    public let source: String           // "MIRO", "FIGMA", "WHITEBOARD"
    public let dateString: String       // "OCT 15", "OCT 17", "TODAY"
    public let assetName: String?       // e.g. "whiteboard_1", "miro_narrative"
    public let previewSnippet: String?  // Optional text excerpt preview
    public var linkURL: URL? = nil      // Captured web link (nil for images)
    
    public init(title: String, source: String, dateString: String, assetName: String? = nil, previewSnippet: String? = nil, linkURL: URL? = nil) {
        self.linkURL = linkURL
        self.title = title
        self.source = source
        self.dateString = dateString
        self.assetName = assetName
        self.previewSnippet = previewSnippet
    }
}

// MARK: - Knowledge Actor (Collective Emergence Actor-Discourse Network)
public enum KnowledgeActor: String, CaseIterable, Identifiable, Sendable {
    case user = "user"
    case maya = "maya"
    case theo = "theo"
    case alex = "alex"
    case sam = "sam"
    case yaya = "yaya"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .user: return "You"
        case .maya: return "Maya"
        case .theo: return "Theo"
        case .alex: return "Alex"
        case .sam: return "Sam"
        case .yaya: return "YaYa"
        }
    }
    
    public var role: String {
        switch self {
        case .user: return "You"
        case .maya: return "Strategy"
        case .theo: return "Engineering"
        case .alex: return "Product"
        case .sam: return "Research"
        case .yaya: return "Suggestions"
        }
    }
    
    public var sprite: BranchSprite? {
        switch self {
        case .user: return nil
        case .maya: return .cloud
        case .theo: return .bloom
        case .alex: return .prism
        case .sam: return .spark
        case .yaya: return nil
        }
    }
    
    public var isUser: Bool { self == .user }
    public var isAI: Bool { self == .yaya }
    
    public var gradientColors: [Color] {
        switch self {
        case .user:
            return [Color(red: 0.388, green: 0.400, blue: 0.945), Color(red: 0.655, green: 0.545, blue: 0.980)]
        case .maya:
            return BranchSprite.cloud.gradientColors
        case .theo:
            return BranchSprite.bloom.gradientColors
        case .alex:
            return BranchSprite.prism.gradientColors
        case .sam:
            return BranchSprite.spark.gradientColors
        case .yaya:
            return [Color.primary.opacity(0.85), Color.primary.opacity(0.40)]
        }
    }
}

// MARK: - Knowledge Link Type & Model
public enum KnowledgeLinkType: String, CaseIterable, Sendable {
    case buildsOn = "buildsOn"
    case transforms = "transforms"     // reframe
    case challenges = "challenges"     // counterpoint
    case combines = "combines"         // combination of 2+ threads
}

public struct KnowledgeLink: Identifiable, Equatable, Sendable {
    public let id: String
    public let targetEntryID: String   // earlier entry being linked to
    public let type: KnowledgeLinkType
    
    public init(id: String = UUID().uuidString, targetEntryID: String, type: KnowledgeLinkType) {
        self.id = id
        self.targetEntryID = targetEntryID
        self.type = type
    }
}

// MARK: - Friction Resolution State
public enum KnowledgeResolution: String, CaseIterable, Sendable {
    case unresolved = "unresolved"
    case keptMine = "keptMine"
    case usedSuggestion = "usedSuggestion"
    case keptBoth = "keptBoth"
}

// MARK: - Knowledge Entry Model
public struct KnowledgeEntry: Identifiable, Equatable, Sendable {
    public let id: String
    public let projectID: String        // "yaya" or "critical_p3"
    public let type: KnowledgeEntryType
    public let text: String
    public let timestamp: Date
    public let dateDisplay: String      // "OCT 15", "OCT 17", "TODAY", or elapsed "0:12"
    public let sessionID: String?
    public let agentId: Int?            // 0: Maya, 1: Theo, 2: Alex, 3: Sam
    public let agentName: String?
    public let agentSprite: BranchSprite?
    public var media: KnowledgeMedia?
    public let relatedEntryIDs: [String]
    public let elapsedSeconds: Double?
    
    // Live Map Network Extensions
    public let actor: KnowledgeActor
    public let links: [KnowledgeLink]
    public var resolution: KnowledgeResolution?
    public let shortLabel: String
    public let frictionSuggestion: String?
    private let explicitIsCombination: Bool?
    private let explicitIsEmergent: Bool?
    
    public init(
        id: String = UUID().uuidString,
        projectID: String,
        type: KnowledgeEntryType,
        text: String,
        timestamp: Date = Date(),
        dateDisplay: String,
        sessionID: String? = nil,
        agentId: Int? = nil,
        agentName: String? = nil,
        agentSprite: BranchSprite? = nil,
        actor: KnowledgeActor? = nil,
        links: [KnowledgeLink] = [],
        resolution: KnowledgeResolution? = nil,
        shortLabel: String? = nil,
        media: KnowledgeMedia? = nil,
        frictionSuggestion: String? = nil,
        isCombination: Bool? = nil,
        isEmergent: Bool? = nil,
        relatedEntryIDs: [String] = [],
        elapsedSeconds: Double? = nil
    ) {
        self.id = id
        self.projectID = projectID
        self.type = type
        self.text = text
        self.timestamp = timestamp
        self.dateDisplay = dateDisplay
        self.sessionID = sessionID
        self.agentId = agentId
        self.agentName = agentName
        self.agentSprite = agentSprite
        self.media = media
        self.relatedEntryIDs = relatedEntryIDs.isEmpty ? links.map(\.targetEntryID) : relatedEntryIDs
        self.elapsedSeconds = elapsedSeconds
        
        if let act = actor {
            self.actor = act
        } else if let aid = agentId {
            switch aid {
            case 0: self.actor = .maya
            case 1: self.actor = .theo
            case 2: self.actor = .alex
            case 3: self.actor = .sam
            default: self.actor = .user
            }
        } else {
            self.actor = .user
        }
        
        self.links = links
        self.resolution = resolution
        
        if let label = shortLabel {
            self.shortLabel = label
        } else {
            let words = text.split(separator: " ")
            self.shortLabel = words.prefix(3).joined(separator: " ")
        }
        
        self.frictionSuggestion = frictionSuggestion
        self.explicitIsCombination = isCombination
        self.explicitIsEmergent = isEmergent
    }
    
    public var isCombination: Bool {
        if let explicit = explicitIsCombination { return explicit }
        return links.filter { $0.type == .combines || $0.type == .buildsOn }.count >= 2
    }
    
    public var isEmergent: Bool {
        if let explicit = explicitIsEmergent { return explicit }
        return false
    }
    
    public var accessibilitySummary: String {
        var base = "\(type.accessibilityLabel), \(actor.displayName), \(text)."
        if !links.isEmpty {
            base += " Builds on \(links.count) ideas."
        }
        if let media = media {
            base += " Media: \(media.title), \(media.source)."
        }
        return base
    }
}

// MARK: - Session Metadata
public struct SessionMeta: Identifiable, Equatable, Sendable {
    public let id: String
    public let sessionNumber: Int
    public let title: String
    public let subtitle: String
    public let agentCount: Int
    public let peopleCount: Int
    public let dateDisplay: String
    
    public init(id: String, sessionNumber: Int, title: String, subtitle: String, agentCount: Int = 4, peopleCount: Int = 2, dateDisplay: String) {
        self.id = id
        self.sessionNumber = sessionNumber
        self.title = title
        self.subtitle = subtitle
        self.agentCount = agentCount
        self.peopleCount = peopleCount
        self.dateDisplay = dateDisplay
    }
}

// MARK: - Seeded Project Knowledge Entries & Multi-Session History
extension KnowledgeEntry {
    public static let seededSessions: [SessionMeta] = [
        SessionMeta(id: "session_3", sessionNumber: 3, title: "Living Project Stories", subtitle: "SESSION 3 · 4 AGENTS · 3 PEOPLE", agentCount: 4, peopleCount: 3, dateDisplay: "TODAY"),
        SessionMeta(id: "session_2", sessionNumber: 2, title: "Individual-First Canvas", subtitle: "SESSION 2 · 4 AGENTS · 2 PEOPLE", agentCount: 4, peopleCount: 2, dateDisplay: "OCT 17"),
        SessionMeta(id: "session_1", sessionNumber: 1, title: "Initial Genesis & Probes", subtitle: "SESSION 1 · 4 AGENTS · 2 PEOPLE", agentCount: 4, peopleCount: 2, dateDisplay: "OCT 15")
    ]
    
    // MARK: - Session 1 Entries (Genesis & Probes)
    public static let session1Entries: [KnowledgeEntry] = [
        KnowledgeEntry(
            id: "s1_01",
            projectID: "yaya",
            type: .addition,
            text: "What could YaYa become in someone else’s hands?",
            timestamp: Date().addingTimeInterval(-86400 * 4),
            dateDisplay: "OCT 15",
            sessionID: "session_1",
            agentId: 0,
            actor: .maya,
            shortLabel: "Someone else's hands",
            media: KnowledgeMedia(
                title: "Project narrative",
                source: "MIRO",
                dateString: "OCT 15",
                assetName: "miro_narrative",
                previewSnippet: "A project's story becomes an invitation for someone else to continue it."
            )
        ),
        KnowledgeEntry(
            id: "s1_02",
            projectID: "yaya",
            type: .addition,
            text: "Portfolios only document dead conclusions instead of living journeys",
            timestamp: Date().addingTimeInterval(-86400 * 4 + 120),
            dateDisplay: "OCT 15",
            sessionID: "session_1",
            actor: .user,
            links: [KnowledgeLink(targetEntryID: "s1_01", type: .buildsOn)],
            shortLabel: "Portfolios document dead"
        ),
        KnowledgeEntry(
            id: "s1_03",
            projectID: "yaya",
            type: .question,
            text: "Can we capture tacit decision rationale without burdensome note taking?",
            timestamp: Date().addingTimeInterval(-86400 * 4 + 240),
            dateDisplay: "OCT 15",
            sessionID: "session_1",
            agentId: 1,
            actor: .theo,
            links: [KnowledgeLink(targetEntryID: "s1_02", type: .buildsOn)],
            shortLabel: "Tacit decision rationale"
        ),
        KnowledgeEntry(
            id: "s1_04",
            projectID: "yaya",
            type: .reframe,
            text: "Conversational turns are the natural unit of thought creation",
            timestamp: Date().addingTimeInterval(-86400 * 4 + 360),
            dateDisplay: "OCT 15",
            sessionID: "session_1",
            agentId: 2,
            actor: .alex,
            links: [KnowledgeLink(targetEntryID: "s1_03", type: .transforms)],
            shortLabel: "Conversational turns unit"
        ),
        KnowledgeEntry(
            id: "s1_05",
            projectID: "yaya",
            type: .addition,
            text: "Extracting emergent narratives through multi-agent resonance",
            timestamp: Date().addingTimeInterval(-86400 * 4 + 480),
            dateDisplay: "OCT 15",
            sessionID: "session_1",
            agentId: 3,
            actor: .sam,
            links: [
                KnowledgeLink(targetEntryID: "s1_02", type: .combines),
                KnowledgeLink(targetEntryID: "s1_04", type: .combines)
            ],
            shortLabel: "Multi-agent resonance",
            isCombination: true,
            isEmergent: true
        )
    ]
    
    // MARK: - Session 2 Entries (Individual vs Team Canvas)
    public static let session2Entries: [KnowledgeEntry] = [
        KnowledgeEntry(
            id: "s2_01",
            projectID: "yaya",
            type: .counterpoint,
            text: "The category already has strong alternatives like Granola",
            timestamp: Date().addingTimeInterval(-86400 * 2),
            dateDisplay: "OCT 17",
            sessionID: "session_2",
            agentId: 0,
            actor: .maya,
            shortLabel: "Strong Granola alternatives",
            media: KnowledgeMedia(
                title: "What competitors don't do",
                source: "WHITEBOARD",
                dateString: "OCT 17",
                assetName: "whiteboard_1",
                previewSnippet: "Existing tools transcribe meetings; none reveal living project lineage."
            )
        ),
        KnowledgeEntry(
            id: "s2_02",
            projectID: "yaya",
            type: .addition,
            text: "Granola transcribes for teams; we cultivate individual thinking style first",
            timestamp: Date().addingTimeInterval(-86400 * 2 + 100),
            dateDisplay: "OCT 17",
            sessionID: "session_2",
            actor: .user,
            links: [KnowledgeLink(targetEntryID: "s2_01", type: .challenges)],
            shortLabel: "Cultivate individual first"
        ),
        KnowledgeEntry(
            id: "s2_03",
            projectID: "yaya",
            type: .counterpoint,
            text: "I simplify complex things",
            timestamp: Date().addingTimeInterval(-86400 * 2 + 200),
            dateDisplay: "OCT 17",
            sessionID: "session_2",
            actor: .user,
            links: [KnowledgeLink(targetEntryID: "s2_02", type: .buildsOn)],
            resolution: .unresolved,
            shortLabel: "Simplify complex things",
            frictionSuggestion: "you design for stressful moments"
        ),
        KnowledgeEntry(
            id: "s2_04",
            projectID: "yaya",
            type: .question,
            text: "Team-first, or one person first?",
            timestamp: Date().addingTimeInterval(-86400 * 2 + 300),
            dateDisplay: "OCT 17",
            sessionID: "session_2",
            agentId: 1,
            actor: .theo,
            links: [KnowledgeLink(targetEntryID: "s2_03", type: .challenges)],
            shortLabel: "Team-first or person?"
        ),
        KnowledgeEntry(
            id: "s2_05",
            projectID: "yaya",
            type: .reframe,
            text: "Treat AI agents as conversational mirrors rather than generative co-pilots",
            timestamp: Date().addingTimeInterval(-86400 * 2 + 400),
            dateDisplay: "OCT 17",
            sessionID: "session_2",
            agentId: 3,
            actor: .sam,
            links: [KnowledgeLink(targetEntryID: "s2_04", type: .transforms)],
            shortLabel: "Conversational mirrors"
        )
    ]
    
    // MARK: - Session 3 Entries (Current Past / Finished Session - Living Project Stories)
    public static let session3Entries: [KnowledgeEntry] = [
        // 1. Maya opening move
        KnowledgeEntry(
            id: "s3_01",
            projectID: "yaya",
            type: .addition,
            text: "How do we bridge individual reflection with team synthesis?",
            timestamp: Date().addingTimeInterval(-3600 * 5),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            agentId: 0,
            actor: .maya,
            shortLabel: "Bridge reflection & synthesis"
        ),
        // 2. User move (~25% user contribution)
        KnowledgeEntry(
            id: "s3_02",
            projectID: "yaya",
            type: .addition,
            text: "One person first, teams later. Own your thinking graph before sharing.",
            timestamp: Date().addingTimeInterval(-3600 * 4 + 180),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            actor: .user,
            links: [KnowledgeLink(targetEntryID: "s3_01", type: .buildsOn)],
            shortLabel: "One person first",
            media: KnowledgeMedia(
                title: "Core idea: the individual",
                source: "WHITEBOARD",
                dateString: "TODAY",
                assetName: "whiteboard_3",
                previewSnippet: "Establish Branch for individuals first. Team integration comes later."
            )
        ),
        // 3. Theo asks question
        KnowledgeEntry(
            id: "s3_03",
            projectID: "yaya",
            type: .question,
            text: "Can the contribution grid reflect emergence rather than individual output?",
            timestamp: Date().addingTimeInterval(-3600 * 4 + 360),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            agentId: 1,
            actor: .theo,
            links: [KnowledgeLink(targetEntryID: "s3_02", type: .buildsOn)],
            shortLabel: "Grid reflects emergence"
        ),
        // 4. Alex challenge
        KnowledgeEntry(
            id: "s3_04",
            projectID: "yaya",
            type: .counterpoint,
            text: "Showing individual credit risks re-introducing competitive metrics",
            timestamp: Date().addingTimeInterval(-3600 * 3 + 120),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            agentId: 2,
            actor: .alex,
            links: [KnowledgeLink(targetEntryID: "s3_03", type: .challenges)],
            shortLabel: "Competitive metric risk"
        ),
        // 5. User friction point (Unresolved)
        KnowledgeEntry(
            id: "s3_05",
            projectID: "yaya",
            type: .counterpoint,
            text: "I simplify complex things",
            timestamp: Date().addingTimeInterval(-3600 * 3 + 240),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            actor: .user,
            links: [KnowledgeLink(targetEntryID: "s3_04", type: .challenges)],
            resolution: .unresolved,
            shortLabel: "Simplify complex things",
            frictionSuggestion: "you design for stressful moments"
        ),
        // 6. YaYa AI Suggestion
        KnowledgeEntry(
            id: "s3_06",
            projectID: "yaya",
            type: .reframe,
            text: "You design for stressful moments rather than generic simplification",
            timestamp: Date().addingTimeInterval(-3600 * 3 + 300),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            actor: .yaya,
            links: [KnowledgeLink(targetEntryID: "s3_05", type: .transforms)],
            shortLabel: "Design stressful moments"
        ),
        // 7. Sam reframes
        KnowledgeEntry(
            id: "s3_07",
            projectID: "yaya",
            type: .reframe,
            text: "Treat session logs as living branches rather than meeting minutes",
            timestamp: Date().addingTimeInterval(-3600 * 2 + 100),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            agentId: 3,
            actor: .sam,
            links: [KnowledgeLink(targetEntryID: "s3_02", type: .transforms)],
            shortLabel: "Branches not minutes"
        ),
        // 8. Combination & Emergence Node: Links User (s3_02) + Sam (s3_07)
        KnowledgeEntry(
            id: "s3_08",
            projectID: "yaya",
            type: .addition,
            text: "Living project stories emerge from dialogue, not retroactive documentation",
            timestamp: Date().addingTimeInterval(-3600 * 2 + 250),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            actor: .user,
            links: [
                KnowledgeLink(targetEntryID: "s3_02", type: .combines),
                KnowledgeLink(targetEntryID: "s3_07", type: .combines)
            ],
            shortLabel: "Stories from dialogue",
            media: KnowledgeMedia(
                title: "Living stories dialectic",
                source: "MIRO",
                dateString: "TODAY",
                assetName: "miro_stories",
                previewSnippet: "Every critique session is a branch on the project's living story."
            ),
            isCombination: true,
            isEmergent: true
        ),
        // 9. Maya builds on emergent node
        KnowledgeEntry(
            id: "s3_09",
            projectID: "yaya",
            type: .addition,
            text: "Shared nodes bloom when both contributors validate the constraint",
            timestamp: Date().addingTimeInterval(-3600 * 1 + 300),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            agentId: 0,
            actor: .maya,
            links: [KnowledgeLink(targetEntryID: "s3_08", type: .buildsOn)],
            shortLabel: "Shared nodes bloom"
        ),
        // 10. Sam builds on emergent node
        KnowledgeEntry(
            id: "s3_10",
            projectID: "yaya",
            type: .addition,
            text: "Expose unresolved questions as hot corners for the next session",
            timestamp: Date().addingTimeInterval(-3600 * 1 + 450),
            dateDisplay: "TODAY",
            sessionID: "session_3",
            agentId: 3,
            actor: .sam,
            links: [KnowledgeLink(targetEntryID: "s3_08", type: .buildsOn)],
            shortLabel: "Hot corners next"
        )
    ]
    
    // MARK: - Combined Seeded Entries across projects
    public static let seededEntries: [KnowledgeEntry] = [
        // Critical design P3 entries
        KnowledgeEntry(
            id: "crit_01",
            projectID: "critical_p3",
            type: .addition,
            text: "Physical artifact as sensory probe for tacit group rituals",
            timestamp: Date().addingTimeInterval(-86400 * 11),
            dateDisplay: "OCT 08",
            actor: .maya,
            shortLabel: "Physical sensory probe",
            media: KnowledgeMedia(
                title: "Sensory probe sketches",
                source: "WHITEBOARD",
                dateString: "OCT 08",
                assetName: "whiteboard_probe",
                previewSnippet: "Probes capture non-verbal conversational friction in design crits."
            )
        ),
        KnowledgeEntry(
            id: "crit_02",
            projectID: "critical_p3",
            type: .reframe,
            text: "Shift from measuring efficiency to capturing conversational texture",
            timestamp: Date().addingTimeInterval(-86400 * 9),
            dateDisplay: "OCT 10",
            actor: .alex,
            shortLabel: "Conversational texture",
            media: KnowledgeMedia(
                title: "Critique ritual schematics",
                source: "FIGMA",
                dateString: "OCT 10",
                assetName: "figma_schematics",
                previewSnippet: "Texture mapping: turns, pauses, and tone markers."
            )
        ),
        KnowledgeEntry(
            id: "crit_03",
            projectID: "critical_p3",
            type: .counterpoint,
            text: "Ambient sensing risks turning a collaborative critique into surveillance",
            timestamp: Date().addingTimeInterval(-86400 * 3),
            dateDisplay: "OCT 16",
            actor: .theo,
            shortLabel: "Surveillance risk",
            media: KnowledgeMedia(
                title: "Surveillance vs synthesis",
                source: "WHITEBOARD",
                dateString: "OCT 16",
                assetName: "whiteboard_surveillance",
                previewSnippet: "If participants feel graded on their speaking time, emergence dies."
            )
        )
    ] + session1Entries + session2Entries + session3Entries
}
