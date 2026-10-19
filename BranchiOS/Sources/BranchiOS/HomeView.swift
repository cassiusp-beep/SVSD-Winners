import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct HomeView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    
    @State private var isShowingEditProfile: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    @ScaledMetric(relativeTo: .body) private var avatarSize: CGFloat = 92
    @ScaledMetric(relativeTo: .body) private var buttonHeight: CGFloat = 50
    
    public init(store: DemoStore = DemoStore.shared) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            // Ambient soft mesh background matching Liquid Glass environment
            AnimatedMeshBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Profile & Welcome Card with Liquid Glass treatment
                profileCardView
                    .padding(.horizontal, 24)
                
                Spacer()
                
                // Primary & Secondary Actions inside Glass Container
                bottomActionContainer
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
            .padding(.top, 40)
        }
        .sheet(isPresented: $isShowingEditProfile) {
            ProfileSetupView(store: store, isEditing: true)
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Profile Card View
    private var profileCardView: some View {
        VStack(spacing: 18) {
            // Live User Avatar
            userAvatarView
            
            VStack(spacing: 6) {
                // User Nickname (@nickname)
                if let nickname = store.profile?.nickname, !nickname.isEmpty {
                    Text("@\(nickname)")
                        .font(.system(.title2, design: .default, weight: .bold))
                        .foregroundStyle(.primary)
                }
                
                // User Full Name
                if let fullName = store.profile?.fullName, !fullName.isEmpty {
                    Text(fullName)
                        .font(.system(.subheadline, design: .default, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                // Session Badge
                if let session = store.session {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.green)
                        
                        Text("Signed in with \(session.providerName)")
                            .font(.system(.caption, design: .default, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color.primary.opacity(colorScheme == .dark ? 0.08 : 0.04))
                    )
                    .padding(.top, 4)
                }
            }
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 32)
        .frame(maxWidth: 380)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.08), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Live User Avatar View
    private var userAvatarView: some View {
        ZStack {
            Circle()
                .fill(Color.primary.opacity(0.06))
                .frame(width: avatarSize, height: avatarSize)
            
            if store.profile?.avatarType == .photo {
                #if canImport(UIKit)
                if let image = store.loadedPhotoImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: avatarSize, height: avatarSize)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: avatarSize * 0.75))
                        .foregroundStyle(.secondary)
                }
                #endif
            } else {
                // CMYK Sprite avatar matching Figma frame 4
                let colorHex = store.profile?.spriteColorHex ?? "#26C6DA"
                let sprite = CMYKSprite.from(hex: colorHex)
                
                VStack {
                    Spacer()
                    DomeSpriteView(sprite: sprite, isBlinking: false)
                        .frame(width: avatarSize * 0.85, height: avatarSize * 0.75)
                        .offset(y: 8)
                }
                .frame(width: avatarSize, height: avatarSize)
                .clipShape(Circle())
            }
            
            // Glass Rim Stroke
            Circle()
                .stroke(Color.primary.opacity(0.16), lineWidth: 2)
                .frame(width: avatarSize, height: avatarSize)
        }
        .glassEffect(.regular, in: Circle())
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 10, x: 0, y: 4)
        .accessibilityHidden(true)
    }
    
    // MARK: - Actions
    private var bottomActionContainer: some View {
        VStack(spacing: 12) {
            GlassEffectContainer {
                VStack(spacing: 10) {
                    // Edit Profile Button
                    Button {
                        isShowingEditProfile = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "pencil")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Edit Profile")
                                .font(.system(.body, design: .default, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: max(buttonHeight, 44))
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.glass)
                    .clipShape(Capsule())
                    .accessibilityLabel("Edit Profile")
                    
                    // Sign Out Button
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            store.signOut()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Sign Out")
                                .font(.system(.body, design: .default, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: max(buttonHeight, 44))
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.glass)
                    .clipShape(Capsule())
                    .accessibilityLabel("Sign Out")
                    .accessibilityHint("Returns to sign-in while preserving profile")
                }
                .frame(maxWidth: 400)
            }
        }
    }
}

// MARK: - Previews
#Preview("HomeView - Sprite Avatar") {
    let store = DemoStore()
    store.session = UserSession(providerName: "Apple")
    store.profile = UserProfile(
        fullName: "Alex Mercer",
        nickname: "alexm",
        avatarType: .sprite,
        spriteColorHex: "#10B981"
    )
    return HomeView(store: store)
        .preferredColorScheme(.light)
}

#Preview("HomeView - Dark Mode") {
    let store = DemoStore()
    store.session = UserSession(providerName: "GitHub")
    store.profile = UserProfile(
        fullName: "Cassius P.",
        nickname: "cash",
        avatarType: .sprite,
        spriteColorHex: "#6366F1"
    )
    return HomeView(store: store)
        .preferredColorScheme(.dark)
}

#Preview("HomeView - Accessibility Large Text") {
    let store = DemoStore()
    store.session = UserSession(providerName: "Google")
    store.profile = UserProfile(
        fullName: "Alex Mercer",
        nickname: "alexm",
        avatarType: .sprite,
        spriteColorHex: "#F59E0B"
    )
    return HomeView(store: store)
        .environment(\.dynamicTypeSize, .accessibility3)
}
