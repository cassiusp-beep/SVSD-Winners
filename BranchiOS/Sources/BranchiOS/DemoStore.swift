import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
import LinkPresentation
#endif

// MARK: - Avatar Type
public enum AvatarType: String, Codable, CaseIterable, Sendable {
    case photo = "photo"
    case sprite = "sprite"
}

// MARK: - User Session Model
public struct UserSession: Codable, Sendable, Equatable {
    public let providerName: String
    public let timestamp: Date
    
    public init(providerName: String, timestamp: Date = Date()) {
        self.providerName = providerName
        self.timestamp = timestamp
    }
}

// MARK: - User Profile Model
public struct UserProfile: Codable, Sendable, Equatable {
    public var fullName: String
    public var nickname: String
    public var avatarType: AvatarType
    public var spriteColorHex: String
    public var photoFileName: String?
    
    public init(
        fullName: String,
        nickname: String,
        avatarType: AvatarType = .sprite,
        spriteColorHex: String = "#6366F1",
        photoFileName: String? = nil
    ) {
        self.fullName = fullName
        self.nickname = nickname
        self.avatarType = avatarType
        self.spriteColorHex = spriteColorHex
        self.photoFileName = photoFileName
    }
}

// MARK: - Session Declared Actions Model (for Thinking Style Radar)
public struct SessionDeclaredActions: Codable, Sendable, Equatable {
    public var processing: Int = 0 // Systematic (Cloud)
    public var building: Int = 0   // Tinkering (Spark)
    public var reframing: Int = 0  // Creative (Prism)
    public var questions: Int = 0  // Observant (Bloom)
    
    public init(processing: Int = 0, building: Int = 0, reframing: Int = 0, questions: Int = 0) {
        self.processing = processing
        self.building = building
        self.reframing = reframing
        self.questions = questions
    }
    
    public var total: Int {
        processing + building + reframing + questions
    }
}

// MARK: - Demo Store Persistence & Mock Backend
@Observable
@MainActor
public final class DemoStore {
    public static let shared = DemoStore()
    
    // MARK: - Keys
    private let sessionKey = "branch_demo_user_session"
    private let profileKey = "branch_demo_user_profile"
    private let integrationsKey = "branch_demo_connected_integrations"
    private let integrationTimestampsKey = "branch_demo_integration_timestamps"
    private let integrationsCompletedKey = "branch_demo_integrations_completed"
    private let syncCompletedKey = "branch_demo_sync_completed"
    private let isGuestKey = "branch_demo_is_guest"
    private let quizAnswersKey = "branch_demo_intent_answers"
    
    // MARK: - Published State
    public var session: UserSession?
    public var profile: UserProfile?
    public var connectedIntegrationIds: Set<String> = []
    public var connectedTimestamps: [String: Date] = [:]
    public var hasCompletedIntegrations: Bool = false
    public var hasCompletedSync: Bool = false
    public var isGuest: Bool = false
    /// Families chosen in the onboarding quiz (or the single family from Talk it through). Seeds the Profile radar.
    public var quizAnswers: [ThinkingFamily] = []
    public var completedSessionActions: [SessionDeclaredActions] = []
    public var knowledgeEntries: [KnowledgeEntry] = KnowledgeEntry.seededEntries
    public var selectedKnowledgeProjectID: String? = DemoProject.defaultID // nil = All projects
    /// Project that live sessions and captures are recorded to.
    public var activeProjectID: String = DemoProject.defaultID {
        didSet { selectedKnowledgeProjectID = activeProjectID }
    }
    public var activeProject: DemoProject {
        DemoProject.all.first(where: { $0.id == activeProjectID }) ?? DemoProject.all[0]
    }
    public var liveKnowledgeEntries: [KnowledgeEntry] = []
    /// Entry IDs committed when the most recent live session stopped. Export ("share this session") scopes to these.
    /// Entries keep their existing session id so the Live Map picker is unchanged.
    public var lastFinishedSessionEntryIDs: [String] = []
    
    // Live Map (Collective Emergence) state
    public var selectedSessionID: String = "session_3"
    public var resolvedFrictionEntries: [String: KnowledgeResolution] = [:]
    public var extraResolvedFrictionCount: Int = 0
    
    public func resolveFriction(entryID: String, resolution: KnowledgeResolution) {
        resolvedFrictionEntries[entryID] = resolution
        if resolution != .unresolved {
            extraResolvedFrictionCount += 1
        }
    }
    
    public func entriesForSelectedSession() -> [KnowledgeEntry] {
        if CommandLine.arguments.contains("-tabLiveMapEmpty") || selectedSessionID == "empty" {
            return []
        }
        
        var entries: [KnowledgeEntry]
        switch selectedSessionID {
        case "session_1":
            entries = KnowledgeEntry.session1Entries
        case "session_2":
            entries = KnowledgeEntry.session2Entries
        case "session_3":
            entries = KnowledgeEntry.session3Entries
        default:
            entries = KnowledgeEntry.session3Entries
        }
        
        // User captures (photos, pasted images, links) join the map as user-linked nodes.
        // Committed live captures have no session id and belong to the latest session.
        let latestSessionID = "session_3"
        entries += knowledgeEntries.filter {
            $0.id.hasPrefix("capture_") && (selectedKnowledgeProjectID == nil || $0.projectID == selectedKnowledgeProjectID) &&
            ($0.sessionID ?? latestSessionID) == selectedSessionID
        }
        
        // Apply any live resolutions
        return entries.map { entry in
            if let res = resolvedFrictionEntries[entry.id] {
                var updated = entry
                updated.resolution = res
                return updated
            }
            return entry
        }
    }
    
    // 8 weeks of historical session action counts (56 days, Mon-Sun across 8 weeks)
    // Seeded with realistic activity pattern, with today (index 55) accumulating new sessions.
    public var sessionHistoryDays: [Int] = [
        0, 1, 3, 0, 4, 2, 0,
        1, 0, 2, 5, 3, 0, 0,
        0, 3, 4, 1, 2, 0, 0,
        2, 4, 0, 3, 6, 1, 0,
        1, 2, 4, 2, 0, 0, 0,
        3, 0, 5, 2, 4, 1, 0,
        0, 2, 3, 6, 4, 0, 0,
        1, 4, 2, 5, 3, 0, 0
    ]
    
    public func recordCompletedSession(declaredActionsCount: Int, actions: SessionDeclaredActions? = nil) {
        if !sessionHistoryDays.isEmpty {
            sessionHistoryDays[sessionHistoryDays.count - 1] += declaredActionsCount
        }
        if let actions = actions {
            completedSessionActions.append(actions)
        }
    }
    
    public func commitLiveKnowledgeEntriesToSeeded(for projectID: String? = nil) {
        let projectID = projectID ?? activeProjectID
        guard !liveKnowledgeEntries.isEmpty else { return }
        let converted = liveKnowledgeEntries.map { entry in
            KnowledgeEntry(
                id: entry.id,
                projectID: projectID,
                type: entry.type,
                text: entry.text,
                timestamp: entry.timestamp,
                dateDisplay: "TODAY",
                sessionID: entry.sessionID,
                agentId: entry.agentId,
                agentName: entry.agentName,
                agentSprite: entry.agentSprite,
                actor: entry.actor,
                links: entry.links,
                shortLabel: entry.shortLabel,
                media: entry.media,
                relatedEntryIDs: entry.relatedEntryIDs
            )
        }
        knowledgeEntries.append(contentsOf: converted)
        lastFinishedSessionEntryIDs = converted.map(\.id)
        liveKnowledgeEntries = []
        selectedKnowledgeProjectID = projectID
    }
    
    // MARK: - Captures (camera photos, pasted images and links)
    #if canImport(UIKit)
    public enum CaptureContent {
        case image(UIImage)
        case link(URL)
    }
    
    /// Adds a photo, pasted image or link to the active project. During a live session the entry joins
    /// `liveKnowledgeEntries` at the session clock; otherwise it joins the project's latest session.
    @discardableResult
    public func addCapture(
        _ content: CaptureContent,
        source: String,
        isLive: Bool,
        elapsedSeconds: Double
    ) -> KnowledgeEntry? {
        let elapsed = max(0, elapsedSeconds)
        let dateString = isLive
            ? String(format: "%d:%02d", Int(elapsed) / 60, Int(elapsed) % 60)
            : "TODAY"
        
        let media: KnowledgeMedia
        let text: String
        let label: String
        switch content {
        case .image(let image):
            let downscaled = Self.downscale(image: image, maxDimension: 1024)
            guard let fileName = Self.saveImageToDisk(image: downscaled, existingFileName: "capture_\(UUID().uuidString).jpg") else {
                return nil
            }
            let isCamera = source == "CAMERA"
            text = isCamera ? "Photo added to the project" : "Image pasted into the project"
            label = isCamera ? "Photo" : "Pasted image"
            media = KnowledgeMedia(
                title: isCamera ? "Photo" : "Pasted image",
                source: source,
                dateString: dateString,
                assetName: fileName
            )
        case .link(let url):
            let domain = Self.domain(of: url)
            text = "Link added: \(domain)"
            label = domain
            media = KnowledgeMedia(
                title: domain,
                source: source,
                dateString: dateString,
                previewSnippet: url.absoluteString,
                linkURL: url
            )
        }
        
        var links: [KnowledgeLink] = []
        var sessionID: String? = nil
        if isLive {
            if let latestUser = liveKnowledgeEntries.last(where: { $0.actor.isUser }) {
                links = [KnowledgeLink(targetEntryID: latestUser.id, type: .buildsOn)]
            }
        } else {
            sessionID = knowledgeEntries
                .filter { $0.projectID == activeProjectID }
                .compactMap(\.sessionID)
                .max()
        }
        
        // Deterministic, collision-free ID (sequence number) so reseeding/relayout is reproducible.
        var captureNumber = (liveKnowledgeEntries + knowledgeEntries).filter { $0.id.hasPrefix("capture_") }.count + 1
        while (liveKnowledgeEntries + knowledgeEntries).contains(where: { $0.id == "capture_\(captureNumber)" }) { captureNumber += 1 }
        let entry = KnowledgeEntry(
            id: "capture_\(captureNumber)",
            projectID: activeProjectID,
            type: .addition,
            text: text,
            timestamp: Date(),
            dateDisplay: dateString,
            sessionID: sessionID,
            actor: .user,
            links: links,
            shortLabel: label,
            media: media,
            elapsedSeconds: isLive ? elapsed : nil
        )
        
        if isLive {
            liveKnowledgeEntries.append(entry)
            // Keep the live feed in session-clock order (stable for equal times).
            liveKnowledgeEntries = liveKnowledgeEntries.enumerated().sorted {
                let a = $0.element.elapsedSeconds ?? .greatestFiniteMagnitude
                let b = $1.element.elapsedSeconds ?? .greatestFiniteMagnitude
                return a == b ? $0.offset < $1.offset : a < b
            }.map(\.element)
        } else {
            knowledgeEntries.append(entry)
        }
        
        if case .link(let url) = content {
            fetchLinkTitle(entryID: entry.id, url: url)
        }
        return entry
    }
    
    public static func domain(of url: URL) -> String {
        let host = url.host(percentEncoded: false) ?? url.absoluteString
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }
    
    /// Resolves the page title with LinkPresentation and swaps it into the entry's media.
    private func fetchLinkTitle(entryID: String, url: URL) {
        Task { @MainActor in
            let provider = LPMetadataProvider()
            provider.timeout = 8
            guard let metadata = try? await provider.startFetchingMetadata(for: url),
                  let title = metadata.title, !title.isEmpty else { return }
            if let i = liveKnowledgeEntries.firstIndex(where: { $0.id == entryID }) {
                liveKnowledgeEntries[i].media?.title = title
            }
            if let i = knowledgeEntries.firstIndex(where: { $0.id == entryID }) {
                knowledgeEntries[i].media?.title = title
            }
        }
    }
    #endif
    
    // Loaded avatar image cached in memory
    #if canImport(UIKit)
    public var loadedPhotoImage: UIImage?
    #endif
    
    public var isSessionActive: Bool {
        session != nil
    }
    
    public var hasCompletedProfile: Bool {
        profile != nil && !(profile?.nickname.isEmpty ?? true)
    }
    
    public init() {
        // Every cold launch starts fresh at sign-in with all data cleared
        resetDemo()
        
        if CommandLine.arguments.contains("-skipAuth") ||
           CommandLine.arguments.contains("-sessionLive") ||
           CommandLine.arguments.contains("-modeMeeting") ||
           CommandLine.arguments.contains("-tabKnowledge") ||
           CommandLine.arguments.contains("-tabProfile") {
            self.hasCompletedSync = true
            self.session = UserSession(providerName: "Apple")
            self.profile = UserProfile(fullName: "Alex Mercer", nickname: "alexm", avatarType: .sprite, spriteColorHex: "#6366F1")
        }
        
        // Screenshot launch states that run through the real AppRootView -> OnboardingFlowView path:
        // -flowIntegrations / -flowSyncing (+ -flowConnected, -spriteFamily Cloud|Bloom|Prism|Spark).
        let args = CommandLine.arguments
        if args.contains("-flowIntegrations") || args.contains("-flowSyncing") {
            var hex = "#4598BB"
            if let i = args.firstIndex(of: "-spriteFamily"), i + 1 < args.count,
               let family = BranchSprite(rawValue: args[i + 1].capitalized) {
                hex = family.primaryHex
            }
            self.session = UserSession(providerName: "Apple")
            self.profile = UserProfile(fullName: "Cassius Palacio", nickname: "cassiuspalacio", avatarType: .sprite, spriteColorHex: hex)
            if args.contains("-flowConnected") || args.contains("-flowSyncing") {
                self.connectedIntegrationIds = ["autodesk_fusion", "pinterest", "github"]
                self.connectedTimestamps = [
                    "autodesk_fusion": Date().addingTimeInterval(-300),
                    "pinterest": Date().addingTimeInterval(-200),
                    "github": Date().addingTimeInterval(-100)
                ]
            }
            self.hasCompletedIntegrations = args.contains("-flowSyncing")
            self.hasCompletedSync = false
        }
    }
    
    // MARK: - Persistence Lifecycle
    public func loadFromPersistence() {
        let defaults = UserDefaults.standard
        
        // 1. Load Session (supports raw Data or string encoding)
        let rawSessionData = defaults.data(forKey: sessionKey) ?? defaults.string(forKey: sessionKey)?.data(using: .utf8)
        if let sessionData = rawSessionData,
           let decodedSession = try? JSONDecoder().decode(UserSession.self, from: sessionData) {
            self.session = decodedSession
        } else {
            self.session = nil
        }
        
        // 2. Load Profile (supports raw Data or string encoding)
        let rawProfileData = defaults.data(forKey: profileKey) ?? defaults.string(forKey: profileKey)?.data(using: .utf8)
        if let profileData = rawProfileData,
           let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: profileData) {
            self.profile = decodedProfile
            
            // 3. Load photo if present
            #if canImport(UIKit)
            if let photoFileName = decodedProfile.photoFileName {
                self.loadedPhotoImage = Self.loadImageFromDisk(fileName: photoFileName)
            } else {
                self.loadedPhotoImage = nil
            }
            #endif
        } else {
            self.profile = nil
            #if canImport(UIKit)
            self.loadedPhotoImage = nil
            #endif
        }
        
        // 3. Load Connected Integrations
        if let storedIds = defaults.stringArray(forKey: integrationsKey) {
            self.connectedIntegrationIds = Set(storedIds)
        } else {
            self.connectedIntegrationIds = []
        }
        
        if let timestampsData = defaults.data(forKey: integrationTimestampsKey),
           let decodedTimestamps = try? JSONDecoder().decode([String: Date].self, from: timestampsData) {
            self.connectedTimestamps = decodedTimestamps
        } else {
            self.connectedTimestamps = [:]
        }
        
        self.hasCompletedIntegrations = defaults.bool(forKey: integrationsCompletedKey)
        self.hasCompletedSync = defaults.bool(forKey: syncCompletedKey)
        self.quizAnswers = (defaults.stringArray(forKey: quizAnswersKey) ?? []).compactMap { ThinkingFamily(rawValue: $0) }
    }
    
    // MARK: - Integrations Actions
    public func toggleIntegration(_ id: String) {
        if connectedIntegrationIds.contains(id) {
            connectedIntegrationIds.remove(id)
            connectedTimestamps.removeValue(forKey: id)
        } else {
            connectedIntegrationIds.insert(id)
            connectedTimestamps[id] = Date()
        }
        
        saveIntegrations()
    }
    
    public func completeIntegrationsStep() {
        self.hasCompletedIntegrations = true
        UserDefaults.standard.set(true, forKey: integrationsCompletedKey)
    }
    
    public func completeSyncStep() {
        self.hasCompletedSync = true
        UserDefaults.standard.set(true, forKey: syncCompletedKey)
    }
    
    private func saveIntegrations() {
        UserDefaults.standard.set(Array(connectedIntegrationIds), forKey: integrationsKey)
        if let data = try? JSONEncoder().encode(connectedTimestamps) {
            UserDefaults.standard.set(data, forKey: integrationTimestampsKey)
        }
    }
    
    // MARK: - Authentication Actions
    public func signIn(provider: AuthProvider) {
        let newSession = UserSession(providerName: provider.rawValue, timestamp: Date())
        self.session = newSession
        if let data = try? JSONEncoder().encode(newSession) {
            UserDefaults.standard.set(data, forKey: sessionKey)
        }
    }
    
    public func signOut() {
        self.session = nil
        UserDefaults.standard.removeObject(forKey: sessionKey)
        // Profile and integrations are intentionally preserved so signing back in skips setup!
    }
    
    // MARK: - Guest Mode Actions
    public func startGuestSession() {
        self.isGuest = true
        self.session = nil
        self.profile = nil
        self.hasCompletedIntegrations = true
        self.hasCompletedSync = true
        UserDefaults.standard.set(true, forKey: isGuestKey)
    }
    
    public func endGuestSessionAndStartSignUp() {
        self.isGuest = false
        self.session = nil
        self.profile = nil
        self.hasCompletedIntegrations = false
        self.hasCompletedSync = false
        // Discard sessions from guest period
        self.sessionHistoryDays = [
            0, 1, 3, 0, 4, 2, 0,
            1, 0, 2, 5, 3, 0, 0,
            0, 3, 4, 1, 2, 0, 0,
            2, 4, 0, 3, 6, 1, 0,
            1, 2, 4, 2, 0, 0, 0,
            3, 0, 5, 2, 4, 1, 0,
            0, 2, 3, 6, 4, 0, 0,
            1, 4, 2, 5, 3, 0, 0
        ]
        UserDefaults.standard.removeObject(forKey: isGuestKey)
    }
    
    // MARK: - Profile Actions
    #if canImport(UIKit)
    public func saveProfile(
        fullName: String,
        nickname: String,
        avatarType: AvatarType,
        spriteColorHex: String,
        photoImage: UIImage?
    ) {
        var photoFileName: String? = profile?.photoFileName
        
        if avatarType == .photo, let image = photoImage {
            // Downscale image and save to disk
            let downscaled = Self.downscale(image: image, maxDimension: 512)
            if let savedName = Self.saveImageToDisk(image: downscaled, existingFileName: photoFileName) {
                photoFileName = savedName
                self.loadedPhotoImage = downscaled
            }
        } else if avatarType == .sprite {
            // If switched to sprite, we can keep or clear disk photo
            self.loadedPhotoImage = nil
        }
        
        let newProfile = UserProfile(
            fullName: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            nickname: nickname.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarType: avatarType,
            spriteColorHex: spriteColorHex,
            photoFileName: photoFileName
        )
        
        self.profile = newProfile
        if let data = try? JSONEncoder().encode(newProfile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }
    #endif
    
    // MARK: - Reset Demo
    public func resetDemo() {
        // 1. Remove photo file if any
        #if canImport(UIKit)
        if let fileName = profile?.photoFileName {
            Self.deleteImageFromDisk(fileName: fileName)
        }
        #endif
        
        // Remove captured photo/pasted-image files (including orphans from earlier launches)
        #if canImport(UIKit)
        for entry in knowledgeEntries + liveKnowledgeEntries {
            if let name = entry.media?.assetName, name.hasPrefix("capture_") {
                Self.deleteImageFromDisk(fileName: name)
            }
        }
        let docs = Self.documentsDirectory()
        if let files = try? FileManager.default.contentsOfDirectory(atPath: docs.path) {
            for name in files where name.hasPrefix("capture_") && name.hasSuffix(".jpg") {
                Self.deleteImageFromDisk(fileName: name)
            }
        }
        #endif
        
        // 2. Clear state
        self.session = nil
        self.profile = nil
        self.connectedIntegrationIds = []
        self.connectedTimestamps = [:]
        self.hasCompletedIntegrations = false
        self.hasCompletedSync = false
        self.isGuest = false
        self.quizAnswers = []
        self.completedSessionActions = []
        self.knowledgeEntries = KnowledgeEntry.seededEntries
        self.activeProjectID = DemoProject.defaultID
        self.selectedKnowledgeProjectID = DemoProject.defaultID
        self.liveKnowledgeEntries = []
        self.lastFinishedSessionEntryIDs = []
        #if canImport(UIKit)
        self.loadedPhotoImage = nil
        #endif
        
        // 3. Clear user defaults
        UserDefaults.standard.removeObject(forKey: sessionKey)
        UserDefaults.standard.removeObject(forKey: profileKey)
        UserDefaults.standard.removeObject(forKey: integrationsKey)
        UserDefaults.standard.removeObject(forKey: integrationTimestampsKey)
        UserDefaults.standard.removeObject(forKey: integrationsCompletedKey)
        UserDefaults.standard.removeObject(forKey: syncCompletedKey)
        UserDefaults.standard.removeObject(forKey: isGuestKey)
        UserDefaults.standard.removeObject(forKey: quizAnswersKey)
    }
    
    // MARK: - Onboarding Intent (quiz / talk) Actions
    /// Saves the intent answers and recolours the profile sprite with the revealed family.
    /// A photo avatar stays the avatar; only the stored sprite colour changes.
    public func saveIntent(answers: [ThinkingFamily], revealed: ThinkingFamily, updatesProfile: Bool = false) {
        self.quizAnswers = answers
        UserDefaults.standard.set(answers.map(\.rawValue), forKey: quizAnswersKey)
        if updatesProfile, var updated = profile {
            updated.spriteColorHex = revealed.sprite.hex
            self.profile = updated
            if let data = try? JSONEncoder().encode(updated) {
                UserDefaults.standard.set(data, forKey: profileKey)
            }
        }
    }
    
    // MARK: - Nickname Validation Logic
    public static let takenNicknames: Set<String> = [
        "admin", "apple", "test", "branch", "root", "svsd", "cash", "alex", "bhargs", "system"
    ]
    
    public enum NicknameStatus: Equatable {
        case empty
        case invalidFormat(String)
        case checking
        case taken(String)
        case available
        
        public var isValid: Bool {
            if case .available = self { return true }
            return false
        }
    }
    
    public static func validateNicknameFormat(_ raw: String) -> NicknameStatus {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .empty
        }
        
        if trimmed.count < 3 || trimmed.count > 20 {
            return .invalidFormat("Must be 3 to 20 characters")
        }
        
        if trimmed.hasPrefix(".") || trimmed.hasSuffix(".") {
            return .invalidFormat("Cannot start or end with a period")
        }
        
        if trimmed.contains("..") {
            return .invalidFormat("Cannot contain consecutive periods")
        }
        
        // Allowed characters: lowercase/uppercase letters, digits, underscores, single periods
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.")
        if trimmed.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return .invalidFormat("Only letters, numbers, underscores, and periods allowed")
        }
        
        return .available
    }
    
    // MARK: - Image Disk Helpers
    #if canImport(UIKit)
    public static func documentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public static func saveImageToDisk(image: UIImage, existingFileName: String?) -> String? {
        let fileName = existingFileName ?? "avatar_\(UUID().uuidString).jpg"
        let fileURL = documentsDirectory().appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try data.write(to: fileURL, options: .atomic)
            return fileName
        } catch {
            print("Failed to save avatar to disk: \(error)")
            return nil
        }
    }
    
    public static func loadImageFromDisk(fileName: String) -> UIImage? {
        let fileURL = documentsDirectory().appendingPathComponent(fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    public static func deleteImageFromDisk(fileName: String) {
        let fileURL = documentsDirectory().appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    public static func downscale(image: UIImage, maxDimension: CGFloat = 512) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else { return image }
        
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    #endif
}
