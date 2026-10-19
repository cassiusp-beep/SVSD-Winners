import SwiftUI

// MARK: - Unified Motion Constants for Seamless Onboarding Experience
public struct BranchMotion: Sendable {
    /// Canonical smooth spring for spatial layout, screen size transitions, and layer movement
    public static let sharedSpring: Animation = .spring(response: 0.52, dampingFraction: 0.82)
    
    /// Snappy interactive spring for tap responses, haptics, and quick feedback
    public static let quickSpring: Animation = .spring(response: 0.32, dampingFraction: 0.72)
    
    /// Gentle spring for orbital physics, floating elements, and breathing animations
    public static let gentleSpring: Animation = .spring(response: 0.70, dampingFraction: 0.88)
    
    /// Standard fade transition duration for incoming / outgoing step content
    public static let fadeDuration: Double = 0.28
    
    /// Stagger interval for overlapping step transitions so departing and entering content cross-fade
    public static let stepOverlapStagger: Double = 0.08
}
