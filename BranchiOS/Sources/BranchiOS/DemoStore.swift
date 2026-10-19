import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
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
    
    // MARK: - Published State
    public var session: UserSession?
    public var profile: UserProfile?
    public var connectedIntegrationIds: Set<String> = []
    public var connectedTimestamps: [String: Date] = [:]
    public var hasCompletedIntegrations: Bool = false
    public var hasCompletedSync: Bool = false
    
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
        
        // 2. Clear state
        self.session = nil
        self.profile = nil
        self.connectedIntegrationIds = []
        self.connectedTimestamps = [:]
        self.hasCompletedIntegrations = false
        self.hasCompletedSync = false
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
