import SwiftUI
import PhotosUI
import Combine

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Onboarding Step State Machine
public enum OnboardingStep: String, CaseIterable, Sendable {
    case signIn
    case profile
    case integrations
    case syncing
    case complete
}

// MARK: - Unified Onboarding Flow View
public struct OnboardingFlowView: View {
    @Bindable public var store: DemoStore = DemoStore.shared
    
    // Step State Machine
    @State public var currentStep: OnboardingStep = .signIn
    @Namespace private var flowNamespace
    
    // MARK: - Step 1: Sign-In State
    @State private var authViewModel = AuthViewModel()
    
    // MARK: - Step 2: Profile State
    @State private var fullName: String = ""
    @State private var nickname: String = ""
    @State private var avatarType: AvatarType = .sprite
    @State private var activeSprite: CMYKSprite = .cyan
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    #if canImport(UIKit)
    @State private var localPhotoImage: UIImage? = nil
    #endif
    @State private var isPhotoLoading: Bool = false
    @State private var hasSelectedAvatar: Bool = false
    @State private var isEditingNamesInline: Bool = false
    @State private var nicknameStatus: DemoStore.NicknameStatus = .empty
    @State private var validationTask: Task<Void, Never>? = nil
    @State private var spriteDragOffset: CGFloat = 0
    @State private var spriteTapBounce: Bool = false
    
    private enum FocusField: Hashable {
        case fullName, nickname
    }
    @FocusState private var focusedField: FocusField?
    
    // MARK: - Step 3: Integrations State
    @State private var searchText: String = ""
    @State private var currentPage: Int = 0
    @State private var connectingIntegrationId: String? = nil
    @State private var connectionProgress: CGFloat = 0
    @State private var connectionTask: Task<Void, Never>? = nil
    
    // MARK: - Step 4: Syncing State
    @State public var currentSyncBeat: SyncBeat = .beat0Handoff
    @State private var strokeTrim: CGFloat = 0.0
    @State private var hubFillProgress: CGFloat = 0.0
    @State private var arrowScale: CGFloat = 0.0
    @State private var arrowOpacity: Double = 0.0
    @State private var orbitAngle: Double = 0.0
    @State private var orbsInwardProgress: [CGFloat] = [0, 0, 0, 0, 0]
    @State private var orbsOpacity: [Double] = [0.25, 0.25, 0.25, 0.25, 0.25]
    @State private var orbsScale: [CGFloat] = [1.0, 1.0, 1.0, 1.0, 1.0]
    @State private var spriteSlideProgress: CGFloat = 0.0
    @State private var leftArmFlexProgress: CGFloat = 0.0
    @State private var isDoubleBlinking: Bool = false
    @State private var syncTask: Task<Void, Never>? = nil
    @State private var syncPhysicsTimer: Timer? = nil
    @State private var lastAnnouncedCopy: String = ""
    
    // MARK: - Shared Motion & Clock Drivers
    @State private var isSpriteBlinking: Bool = false
    @State private var blinkTimer: Timer? = nil
    @State private var juggleTime: Double = 0.0
    @State private var juggleTimer: Timer? = nil
    @State private var isFumbling: Bool = false
    @State private var fumbleStartTime: Double = 0.0
    
    // Environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    private let avatarCircleDiameter: CGFloat = 96
    
    public init(
        store: DemoStore = DemoStore.shared,
        initialStep: OnboardingStep? = nil,
        startFromSyncBeat: SyncBeat = .beat0Handoff
    ) {
        self.store = store
        let resolvedStep: OnboardingStep
        if let initialStep {
            resolvedStep = initialStep
        } else if !store.isSessionActive {
            resolvedStep = .signIn
        } else if !store.hasCompletedProfile {
            resolvedStep = .profile
        } else if !store.hasCompletedIntegrations {
            resolvedStep = .integrations
        } else if !store.hasCompletedSync {
            resolvedStep = .syncing
        } else {
            resolvedStep = .signIn
        }
        self._currentStep = State(initialValue: resolvedStep)
        self._currentSyncBeat = State(initialValue: startFromSyncBeat)
    }
    
    // MARK: - Body
    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack(alignment: .top) {
                // 1. PERSISTENT BACKGROUND LAYER
                persistentBackgroundLayer
                
                // 2. PERSISTENT TOP USERNAME BANNER & CONTINUE BUTTON (Structured vertically)
                VStack(spacing: 0) {
                    Spacer().frame(height: geo.safeAreaInsets.top)
                    persistentBannerView
                        .frame(height: UsernameBanner.bannerHeight)
                    persistentTopContinueRow
                        .frame(height: 36)
                }
                .zIndex(20)
                
                // 4. STEP-SPECIFIC CONTENT LAYERS (The only things that enter and exit)
                ZStack {
                    if currentStep == .signIn {
                        signInStepContent(w: w, h: h)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .offset(y: 20)),
                                removal: .opacity.combined(with: .offset(y: -20))
                            ))
                            .zIndex(1)
                    }
                    
                    if currentStep == .profile {
                        profileStepContent(w: w, h: h)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .offset(y: 20)),
                                removal: .opacity.combined(with: .offset(y: -20))
                            ))
                            .zIndex(2)
                    }
                    
                    if currentStep == .integrations {
                        integrationsStepContent(w: w, h: h, topInset: geo.safeAreaInsets.top)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .offset(y: 20)),
                                removal: .opacity.combined(with: .offset(y: -20))
                            ))
                            .zIndex(3)
                    }
                    
                    if currentStep == .syncing || currentStep == .complete {
                        syncingStepContent(w: w, h: h)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .offset(y: 20)),
                                removal: .opacity.combined(with: .offset(y: -20))
                            ))
                            .zIndex(4)
                    }
                }
                .animation(BranchMotion.sharedSpring, value: currentStep)
                .frame(width: w, height: h)
                
                // 5. PERSISTENT NEXT ARROW BUTTON (Smoothly travels to current step anchor)
                if currentStep == .profile || currentStep == .integrations {
                    persistentNextArrowButton(w: w, h: h)
                        .zIndex(15)
                }
                
                // 6. PERSISTENT SPRITE INSTANCE (Single instance for the entire flow)
                persistentSpriteLayer(w: w, h: h)
                    .zIndex(12)
            }
            .frame(width: w, height: h)
            .ignoresSafeArea(edges: .bottom)
        }
        .onAppear {
            initializeFlow()
            startContinuousBlinkLoop()
            startJuggleClock()
            if currentStep == .syncing || currentStep == .complete {
                startSyncSequence()
            }
        }
        .onDisappear {
            blinkTimer?.invalidate()
            juggleTimer?.invalidate()
            syncPhysicsTimer?.invalidate()
            syncTask?.cancel()
            connectionTask?.cancel()
        }
        .onChange(of: currentStep) { oldStep, newStep in
            handleStepChange(from: oldStep, to: newStep)
        }
        .onChange(of: store.session) { _, newSession in
            if newSession != nil && currentStep == .signIn {
                withAnimation(BranchMotion.sharedSpring) {
                    currentStep = .profile
                }
            }
        }
    }
    
    // MARK: - 1. Persistent Background Layer
    private var persistentBackgroundLayer: some View {
        (colorScheme == .dark ? Color.black : Color.white)
            .ignoresSafeArea()
    }
    
    // MARK: - 2. Persistent Username Banner
    private var persistentBannerView: some View {
        let displayNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldShowBanner = currentStep != .signIn && !displayNickname.isEmpty
        
        return UsernameBanner(nickname: displayNickname)
            .opacity(shouldShowBanner ? 1.0 : 0.0)
            .allowsHitTesting(shouldShowBanner)
            .animation(BranchMotion.sharedSpring, value: shouldShowBanner)
    }
    
    // MARK: - 3. Persistent Top Continue Button Row
    private var persistentTopContinueRow: some View {
        let isVisible: Bool = {
            switch currentStep {
            case .signIn:
                return false
            case .profile:
                return true
            case .integrations:
                return true
            case .syncing:
                return currentSyncBeat == .beat4Complete
            case .complete:
                return true
            }
        }()
        
        let isEnabled: Bool = {
            switch currentStep {
            case .signIn:
                return false
            case .profile:
                return isProfileValid
            case .integrations:
                return true
            case .syncing, .complete:
                return true
            }
        }()
        
        return HStack {
            Spacer()
            ContinueButton(
                title: "Continue",
                isEnabled: isEnabled,
                disabledHint: "Enter name and nickname to continue"
            ) {
                handleContinueTap()
            }
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(BranchMotion.sharedSpring, value: isVisible)
            .animation(BranchMotion.quickSpring, value: isEnabled)
        }
        .padding(.horizontal, 24)
        .frame(height: 36)
        .allowsHitTesting(isVisible)
    }
    
    // MARK: - 5. Persistent Next Arrow Button
    private var persistentNextArrowButton: some View {
        persistentNextArrowButton(w: 393, h: 852)
    }
    
    private func persistentNextArrowButton(w: CGFloat, h: CGFloat) -> some View {
        let isEnabled: Bool = {
            switch currentStep {
            case .profile:
                return isProfileValid
            case .integrations, .syncing, .complete:
                return true
            case .signIn:
                return false
            }
        }()
        
        // Dynamic position interpolation
        let arrowY: CGFloat = {
            switch currentStep {
            case .profile:
                return h * 0.58
            case .integrations:
                return h * 0.65
            case .syncing, .complete:
                return h * 0.50
            case .signIn:
                return h * 1.2
            }
        }()
        
        return NextArrowButton(
            isEnabled: isEnabled,
            accessibilityLabel: "Continue to next step"
        ) {
            handleContinueTap()
        }
        .position(x: w * 0.50, y: arrowY)
        .animation(BranchMotion.sharedSpring, value: currentStep)
        .animation(BranchMotion.quickSpring, value: isEnabled)
    }
    
    // MARK: - 6. Persistent Sprite Layer
    private func persistentSpriteLayer(w: CGFloat, h: CGFloat) -> some View {
        let color = activeSprite.color(for: colorScheme)
        
        // Sprite geometry computation per step
        let spriteW: CGFloat = (currentStep == .profile) ? min(w * 0.72, 300) : 220
        let spriteH: CGFloat = (currentStep == .profile) ? spriteW * 0.88 : 140
        
        let spriteX: CGFloat = {
            switch currentStep {
            case .signIn:
                return w * 0.50
            case .profile:
                return w * 0.50 + spriteDragOffset
            case .integrations:
                return w * 0.50
            case .syncing, .complete:
                if currentSyncBeat == .beat0Handoff {
                    return w * 0.50
                }
                let centeredX = w * 0.50
                let shiftedX = w * 0.72
                return centeredX + (shiftedX - centeredX) * spriteSlideProgress
            }
        }()
        
        let spriteY: CGFloat = {
            switch currentStep {
            case .signIn:
                return h + 220
            case .profile:
                return h - spriteH * 0.08
            case .integrations:
                return h - spriteH * 0.02
            case .syncing, .complete:
                if currentSyncBeat == .beat0Handoff {
                    return h - spriteH * 0.02
                }
                let startY = h - spriteH * 0.40
                let endY = h - spriteH * 0.06
                return startY + (endY - startY) * spriteSlideProgress
            }
        }()
        
        let spriteOpacity: Double = (currentStep == .signIn) ? 0.0 : 1.0
        let showsArms: Bool = (currentStep != .profile && currentStep != .signIn)
        
        // Arm poses
        let (armL, armR) = calculateArmPoses(totalOrbs: juggleItems.count)
        
        return ZStack(alignment: .bottom) {
            if currentStep == .syncing || currentStep == .complete {
                if currentSyncBeat == .beat1BigToss {
                    // Big toss: both arms push high
                    SpriteArmShape(pose: 1.0, isLeft: true, sprite: activeSprite)
                        .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(spriteW * 0.055, 9), lineCap: .round, lineJoin: .round))
                        .frame(width: spriteW * 0.34, height: spriteH * 0.98)
                        .position(x: spriteW * activeSprite.leftArmAnchorNormalized.x, y: spriteH * activeSprite.leftArmAnchorNormalized.y)
                    
                    SpriteArmShape(pose: 1.0, isLeft: false, sprite: activeSprite)
                        .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(spriteW * 0.055, 9), lineCap: .round, lineJoin: .round))
                        .frame(width: spriteW * 0.34, height: spriteH * 0.98)
                        .position(x: spriteW * activeSprite.rightArmAnchorNormalized.x, y: spriteH * activeSprite.rightArmAnchorNormalized.y)
                } else if currentSyncBeat >= .beat2Gathering {
                    // Beats 2-4: left arm resting -> bicep flex
                    SpriteFlexArmShape(flexProgress: leftArmFlexProgress)
                        .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(spriteW * 0.055, 9), lineCap: .round, lineJoin: .round))
                        .frame(width: 80, height: 110)
                        .position(x: -30, y: spriteH * 0.44)
                }
            } else if showsArms {
                // Juggling arms in Step 3 (Integrations) & Beat 0
                SpriteArmShape(pose: armL, isLeft: true, sprite: activeSprite)
                    .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(spriteW * 0.055, 9), lineCap: .round, lineJoin: .round))
                    .frame(width: spriteW * 0.34, height: spriteH * 0.98)
                    .position(x: spriteW * activeSprite.leftArmAnchorNormalized.x, y: spriteH * activeSprite.leftArmAnchorNormalized.y)
                
                SpriteArmShape(pose: armR, isLeft: false, sprite: activeSprite)
                    .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(spriteW * 0.055, 9), lineCap: .round, lineJoin: .round))
                    .frame(width: spriteW * 0.34, height: spriteH * 0.98)
                    .position(x: spriteW * activeSprite.rightArmAnchorNormalized.x, y: spriteH * activeSprite.rightArmAnchorNormalized.y)
            }
            
            // Central Vector Sprite Body with Dual-Layer Eyes
            SpriteView(
                sprite: activeSprite,
                isBlinking: isSpriteBlinking || isDoubleBlinking,
                showsArms: false
            )
            .frame(width: spriteW, height: spriteH)
            .scaleEffect(spriteTapBounce ? 0.94 : 1.0, anchor: .bottom)
            .contentShape(Rectangle())
            .onTapGesture {
                if currentStep == .profile {
                    selectCurrentSpriteForAvatar()
                } else if currentStep == .integrations {
                    triggerFumble()
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard currentStep == .profile else { return }
                        spriteDragOffset = value.translation.width * 0.4
                    }
                    .onEnded { value in
                        guard currentStep == .profile else { return }
                        let threshold: CGFloat = 40
                        let allSprites = CMYKSprite.allCases
                        let currentIndex = allSprites.firstIndex(of: activeSprite) ?? 0
                        withAnimation(BranchMotion.quickSpring) {
                            if value.translation.width < -threshold {
                                let next = (currentIndex + 1) % allSprites.count
                                activeSprite = allSprites[next]
                                if avatarType == .sprite {
                                    hasSelectedAvatar = true
                                }
                                triggerSelectionFeedback()
                            } else if value.translation.width > threshold {
                                let prev = (currentIndex - 1 + allSprites.count) % allSprites.count
                                activeSprite = allSprites[prev]
                                if avatarType == .sprite {
                                    hasSelectedAvatar = true
                                }
                                triggerSelectionFeedback()
                            }
                            spriteDragOffset = 0
                        }
                    }
            )
        }
        .frame(width: spriteW, height: spriteH)
        .position(x: spriteX, y: spriteY)
        .opacity(spriteOpacity)
        .allowsHitTesting(currentStep == .profile || currentStep == .integrations)
        .animation(BranchMotion.sharedSpring, value: currentStep)
        .animation(BranchMotion.sharedSpring, value: spriteSlideProgress)
        .animation(BranchMotion.quickSpring, value: spriteTapBounce)
    }
    
    // MARK: - STEP CONTENT 1: Sign-In
    private func signInStepContent(w: CGFloat, h: CGFloat) -> some View {
        SignInView(store: store, showsBackground: false) { _ in
            withAnimation(BranchMotion.sharedSpring) {
                currentStep = .profile
            }
        }
        .frame(width: w, height: h)
    }
    
    // MARK: - STEP CONTENT 2: Profile Setup
    private func profileStepContent(w: CGFloat, h: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 72)
            
            // Center Identity Hub
            VStack(spacing: 12) {
                // 96pt Avatar Circle
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(colorScheme == .dark ? 0.22 : 0.08))
                            .frame(width: avatarCircleDiameter, height: avatarCircleDiameter)
                        
                        if avatarType == .photo {
                            #if canImport(UIKit)
                            if let image = localPhotoImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: avatarCircleDiameter, height: avatarCircleDiameter)
                                    .clipShape(Circle())
                            }
                            #endif
                        } else if hasSelectedAvatar {
                            VStack {
                                Spacer()
                                DomeSpriteView(sprite: activeSprite, isBlinking: isSpriteBlinking)
                                    .frame(width: 82, height: 72)
                                    .offset(y: 8)
                            }
                            .frame(width: avatarCircleDiameter, height: avatarCircleDiameter)
                            .clipShape(Circle())
                            .matchedGeometryEffect(id: "avatar_orb_visual", in: flowNamespace)
                        } else {
                            Image(systemName: "plus")
                                .font(.system(size: 26, weight: .ultraLight))
                                .foregroundStyle(Color.gray.opacity(0.85))
                        }
                        
                        Circle()
                            .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                            .frame(width: avatarCircleDiameter, height: avatarCircleDiameter)
                    }
                }
                .buttonStyle(.plain)
                .onChange(of: selectedPhotoItem) { _, newItem in
                    handlePhotoSelected(newItem)
                }
                
                // Name & Nickname Displays (Single perfectly centered unit)
                inlineNameEditorView
                
                // Helper text in empty state: disappears once the user starts interacting
                if focusedField == nil && nickname.isEmpty && fullName.isEmpty {
                    Text("Tap to enter name & nickname")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                }
                
                // Validation feedback
                validationFeedbackCaption
            }
            .position(x: w * 0.50, y: h * 0.32)
            
            Spacer()
            
            // "Sprite Selection" label
            Text("Sprite Selection")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(Color.secondary.opacity(0.8))
                .padding(.bottom, 160)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
    }
    
    private var inlineNameEditorView: some View {
        VStack(spacing: 8) {
            // Nickname row: perfectly centered unit
            ZStack(alignment: .center) {
                // Measurement text defining exact tight width of "@" + (nickname or placeholder)
                HStack(spacing: 0) {
                    Text("@")
                        .font(.system(size: 20, weight: .bold))
                    Text(nickname.isEmpty ? "nickname" : nickname)
                        .font(.system(size: 20, weight: .bold))
                }
                .opacity(0)
                .padding(.trailing, 2)
                .accessibilityHidden(true)
                
                // Centered unit: "@" directly against text, cursor right after "@"
                HStack(spacing: 0) {
                    Text("@")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(nickname.isEmpty ? Color.secondary.opacity(0.65) : Color.primary)
                    
                    TextField("", text: $nickname, prompt: Text("nickname").foregroundStyle(Color.secondary.opacity(0.35)))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .focused($focusedField, equals: .nickname)
                        .submitLabel(.next)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()
                        .onSubmit { focusedField = .fullName }
                        .onChange(of: nickname) { _, val in validateNicknameLive(val) }
                }
            }
            .fixedSize(horizontal: true, vertical: false)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = .nickname
            }
            
            // Full Name row: perfectly centered unit
            ZStack(alignment: .center) {
                Text(fullName.isEmpty ? "Full Name" : fullName)
                    .font(.system(size: 15, weight: .regular))
                    .opacity(0)
                    .padding(.horizontal, 4)
                    .accessibilityHidden(true)
                
                TextField("", text: $fullName, prompt: Text("Full Name").foregroundStyle(Color.secondary.opacity(0.35)))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .focused($focusedField, equals: .fullName)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .onSubmit {
                        focusedField = nil
                    }
            }
            .fixedSize(horizontal: true, vertical: false)
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = .fullName
            }
        }
    }
    
    @ViewBuilder
    private var validationFeedbackCaption: some View {
        switch nicknameStatus {
        case .empty, .available:
            EmptyView()
        case .checking:
            Text("Checking...")
                .font(.caption2)
                .foregroundStyle(.secondary)
        case .taken(let name):
            Text("'@\(name)' is already taken")
                .font(.caption2)
                .foregroundStyle(.red)
        case .invalidFormat(let reason):
            Text(reason)
                .font(.caption2)
                .foregroundStyle(.red)
        }
    }
    
    // MARK: - STEP CONTENT 3: Integrations
    private func integrationsStepContent(w: CGFloat, h: CGFloat, topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer().frame(height: topInset + UsernameBanner.bannerHeight + 36 + 6)
            
            // Search underline field
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    ZStack(alignment: .leading) {
                        if searchText.isEmpty {
                            Text("search...")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color(white: 0.55))
                        }
                        TextField("", text: $searchText)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                            .tint(Color.primary)
                            .frame(height: 26)
                            #if os(iOS)
                            .textInputAutocapitalization(.never)
                            #endif
                            .autocorrectionDisabled()
                    }
                    if !searchText.isEmpty {
                        Button(action: { searchText = ""; currentPage = 0 }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                Rectangle()
                    .fill(colorScheme == .dark ? Color.white.opacity(0.20) : Color.black.opacity(0.18))
                    .frame(height: 1)
            }
            .padding(.horizontal, 26)
            .padding(.top, 4)
            
            // Guidance Copy
            HStack(spacing: 0) {
                Text("Select which ")
                    .font(.subheadline)
                    .foregroundStyle(Color.primary)
                Text("integrations")
                    .font(.subheadline.bold().italic())
                    .foregroundStyle(Color.primary)
                Text(" you'd want to import.")
                    .font(.subheadline)
                    .foregroundStyle(Color.primary)
                Spacer()
            }
            .padding(.horizontal, 26)
            .padding(.top, 10)
            
            // "Supported" label
            Text("Supported")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Color(white: 0.65) : Color(white: 0.45))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 26)
                .padding(.top, 10)
                .padding(.bottom, 6)
            
            // Paged Grid (13 supported items)
            integrationsGridArea
            
            Spacer(minLength: 8)
            
            // "Connected" label
            Text("Connected")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Color(white: 0.65) : Color(white: 0.45))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 26)
                .padding(.bottom, 12)
            
            // Juggling stage space (orbs rendered in juggle loop)
            juggleOrbsOverlay(w: w, h: 165)
                .frame(height: 165)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var integrationsGridArea: some View {
        let items = filteredIntegrations
        let p1 = Array(items.prefix(12))
        let p2 = Array(items.dropFirst(12))
        
        if items.isEmpty {
            VStack {
                Spacer()
                Text("No matches")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(height: 240)
        } else {
            VStack(spacing: 6) {
                TabView(selection: $currentPage) {
                    pageGridView(for: p1).tag(0)
                    if !p2.isEmpty {
                        pageGridView(for: p2).tag(1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 240)
            
            if !p2.isEmpty {
                HStack(spacing: 6) {
                    Circle()
                        .fill(currentPage == 0 ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 5, height: 5)
                    Circle()
                        .fill(currentPage == 1 ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 5, height: 5)
                }
                .padding(.top, 2)
            }
        }
    }
}
    
    private func pageGridView(for items: [Integration]) -> some View {
        let rows = items.chunked(into: 4)
        return VStack(spacing: 14) {
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                let row = rows[rowIndex]
                HStack(spacing: 0) {
                    ForEach(row) { item in
                        if item.id != row.first?.id { Spacer() }
                        orbItemView(for: item)
                    }
                    if row.count < 4 {
                        ForEach(0..<(4 - row.count), id: \.self) { _ in
                            Spacer()
                            Color.clear.frame(width: 62, height: 62)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 26)
    }
    
    private func orbItemView(for item: Integration) -> some View {
        let isConnected = store.connectedIntegrationIds.contains(item.id)
        let isConnecting = connectingIntegrationId == item.id
        
        return IntegrationOrbView(
            integration: item,
            isConnected: isConnected,
            isConnecting: isConnecting,
            connectionProgress: connectionProgress,
            accentColor: activeSprite.color(for: colorScheme),
            onToggle: { handleOrbTap(for: item) }
        )
    }
    
    // MARK: - Juggling Orbs Overlay (Step 3)
    private func juggleOrbsOverlay(w: CGFloat, h: CGFloat) -> some View {
        let count = max(juggleItems.count, 1)
        return ZStack {
            ForEach(0..<juggleItems.count, id: \.self) { index in
                let item = juggleItems[index]
                let (offset, rotation) = calculateOrbPosition(
                    index: index,
                    total: count,
                    width: w,
                    time: juggleTime
                )
                
                orbItemVisual(for: item)
                    .offset(offset)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .frame(width: w, height: h)
    }
    
    // MARK: - STEP CONTENT 4: Syncing & Complete
    private func syncingStepContent(w: CGFloat, h: CGFloat) -> some View {
        let hubCenter = CGPoint(x: w * 0.50, y: h * 0.50)
        let hubDiameter: CGFloat = 136
        let hubRadius: CGFloat = hubDiameter / 2
        
        return ZStack {
            // Status Copy sits ABOVE the hub, centered
            if !statusCopyText.isEmpty {
                Text(statusCopyText)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
                    .position(x: w * 0.50, y: hubCenter.y - hubRadius - 62)
                    .transition(.opacity)
                    .id(statusCopyText)
            }
            
            // Central Hub Ring + Filled Arrow
            hubView(center: hubCenter, diameter: hubDiameter, radius: hubRadius)
            
            // Satellite Orbs Layer (Avatar + Connected Integrations)
            satelliteOrbsLayer(hubCenter: hubCenter, hubRadius: hubRadius, w: w, h: h)
        }
        .frame(width: w, height: h)
    }
    
    private func hubView(center: CGPoint, diameter: CGFloat, radius: CGFloat) -> some View {
        let ringStrokeColor: Color = colorScheme == .dark ? Color.white : Color.black
        let hubArrowColor = Color(red: 0.137, green: 0.122, blue: 0.125)
        
        return ZStack {
            // Background fill
            Circle()
                .fill(activeSprite.gradient)
                .frame(width: diameter * hubFillProgress, height: diameter * hubFillProgress)
            
            // Stroke ring
            Circle()
                .trim(from: 0, to: strokeTrim)
                .stroke(ringStrokeColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: diameter, height: diameter)
                .rotationEffect(.degrees(-90))
            
            // Center Arrow
            Image(systemName: "arrow.right")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(hubArrowColor)
                .scaleEffect(arrowScale)
                .opacity(arrowOpacity)
        }
        .position(center)
        .onTapGesture {
            if currentSyncBeat == .beat4Complete {
                handleContinueTap()
            }
        }
    }
    
    // MARK: - Satellite Orbs Layer (Syncing)
    private func satelliteOrbsLayer(hubCenter: CGPoint, hubRadius: CGFloat, w: CGFloat, h: CGFloat) -> some View {
        let items = syncOrbsList
        return ZStack {
            ForEach(0..<items.count, id: \.self) { index in
                let item = items[index]
                let pos = calculateSatelliteOrbPosition(
                    index: index,
                    total: items.count,
                    hubCenter: hubCenter,
                    hubRadius: hubRadius
                )
                let op = orbsOpacity.indices.contains(index) ? orbsOpacity[index] : 1.0
                let sc = orbsScale.indices.contains(index) ? orbsScale[index] : 1.0
                
                orbItemVisual(for: item)
                    .scaleEffect(sc)
                    .opacity(op)
                    .position(pos)
            }
        }
    }
    
    private func calculateSatelliteOrbPosition(
        index: Int,
        total: Int,
        hubCenter: CGPoint,
        hubRadius: CGFloat
    ) -> CGPoint {
        let baseAngleDeg: Double = {
            switch total {
            case 1: return -90
            case 2: return [-90.0, 90.0][index]
            case 3: return [-90.0, 30.0, 150.0][index]
            case 4: return [-90.0, 0.0, 90.0, 180.0][index]
            default: return -90.0 + Double(index) * (360.0 / Double(total))
            }
        }()
        
        switch currentSyncBeat {
        case .beat0Handoff:
            return CGPoint(x: hubCenter.x, y: hubCenter.y + 180)
            
        case .beat1BigToss:
            let startPos = CGPoint(x: hubCenter.x, y: hubCenter.y + 180)
            let targetDist: CGFloat = 145 + CGFloat(index % 2) * 18
            let targetRad = baseAngleDeg * .pi / 180.0
            let targetPos = CGPoint(
                x: hubCenter.x + cos(targetRad) * targetDist,
                y: hubCenter.y + sin(targetRad) * targetDist
            )
            return CGPoint(
                x: startPos.x + (targetPos.x - startPos.x) * spriteSlideProgress,
                y: startPos.y + (targetPos.y - startPos.y) * spriteSlideProgress
            )
            
        case .beat2Gathering:
            let dist: CGFloat = 142 + CGFloat(index % 2) * 18
            let angleRad = (baseAngleDeg + orbitAngle) * .pi / 180.0
            return CGPoint(
                x: hubCenter.x + cos(angleRad) * dist,
                y: hubCenter.y + sin(angleRad) * dist
            )
            
        case .beat3PullingIn:
            let inwardP = orbsInwardProgress.indices.contains(index) ? orbsInwardProgress[index] : 0
            let startDist: CGFloat = 142 + CGFloat(index % 2) * 18
            let targetDist: CGFloat = 110
            let currentDist = startDist + (targetDist - startDist) * inwardP
            let angleRad = (baseAngleDeg + orbitAngle) * .pi / 180.0
            return CGPoint(
                x: hubCenter.x + cos(angleRad) * currentDist,
                y: hubCenter.y + sin(angleRad) * currentDist
            )
            
        case .beat4Complete:
            let snugDist: CGFloat = hubRadius + 22
            let finalRad = baseAngleDeg * .pi / 180.0
            return CGPoint(
                x: hubCenter.x + cos(finalRad) * snugDist,
                y: hubCenter.y + sin(finalRad) * snugDist
            )
        }
    }
    
    // MARK: - Orb Visual Component
    @ViewBuilder
    private func orbItemVisual(for item: JuggleItem) -> some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? Color(white: 0.22) : Color.white)
                .overlay(
                    Circle()
                        .stroke(
                            colorScheme == .dark
                            ? Color.white.opacity(0.14)
                            : Color.black.opacity(0.07),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.15),
                    radius: 5,
                    x: 0,
                    y: 3
                )
            
            switch item {
            case .avatar:
                if avatarType == .photo {
                    #if canImport(UIKit)
                    if let image = localPhotoImage ?? store.loadedPhotoImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 38, height: 38)
                            .clipShape(Circle())
                    }
                    #endif
                } else {
                    DomeSpriteView(sprite: activeSprite, isBlinking: false)
                        .frame(width: 24, height: 22)
                        .offset(y: 2)
                        .matchedGeometryEffect(id: "avatar_orb_visual", in: flowNamespace)
                }
            case .integration(let integration):
                if let image = resolveLogoImage(for: integration) {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                } else {
                    Text(integration.initial)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(activeSprite.color(for: colorScheme))
                }
            }
        }
        .frame(width: 44, height: 44)
    }
    
    // MARK: - Orb Position in Juggle Loop (Step 3)
    private func calculateOrbPosition(index: Int, total: Int, width: CGFloat, time: Double) -> (CGSize, Double) {
        let baseHandY: CGFloat = -52
        let handX: CGFloat = 68
        
        var fumbleDrop: CGFloat = 0
        var fumbleTilt: Double = 0
        if isFumbling {
            let elapsed = time - fumbleStartTime
            if elapsed < 1.25 {
                let progress = elapsed / 1.25
                fumbleDrop = sin(progress * .pi) * 22
                fumbleTilt = sin(elapsed * 24 + Double(index)) * 16
            }
        }
        
        if total == 1 {
            let period = 2.0
            let u = (time / period).truncatingRemainder(dividingBy: 1.0)
            var x: CGFloat = 0
            var y: CGFloat = baseHandY
            var tilt: Double = 0
            
            if u < 0.10 {
                let prog = u / 0.10
                let dip = sin(prog * .pi / 2) * 10
                x = -handX; y = baseHandY + dip; tilt = -dip * 0.5
            } else if u < 0.24 {
                let prog = (u - 0.10) / 0.14
                let push = (1.0 - cos(prog * .pi / 2)) * 16
                x = -handX + CGFloat(prog * 4); y = (baseHandY + 10) - push; tilt = -prog * 6
            } else if u < 0.50 {
                let prog = (u - 0.24) / 0.26
                x = (-handX + 4) + CGFloat(prog) * ((handX - 4) - (-handX + 4))
                let arc = sin(prog * .pi) * 32
                y = (baseHandY - 6) * CGFloat(1.0 - prog) + baseHandY * CGFloat(prog) - arc
                tilt = sin(prog * .pi) * 12
            } else if u < 0.60 {
                let prog = (u - 0.50) / 0.10
                let dip = sin(prog * .pi / 2) * 10
                x = handX; y = baseHandY + dip; tilt = dip * 0.5
            } else if u < 0.74 {
                let prog = (u - 0.60) / 0.14
                let push = (1.0 - cos(prog * .pi / 2)) * 16
                x = handX - CGFloat(prog * 4); y = (baseHandY + 10) - push; tilt = prog * 6
            } else {
                let prog = (u - 0.74) / 0.26
                x = (handX - 4) - CGFloat(prog) * ((handX - 4) - (-handX + 4))
                let arc = sin(prog * .pi) * 32
                y = (baseHandY - 6) * CGFloat(1.0 - prog) + baseHandY * CGFloat(prog) - arc
                tilt = -sin(prog * .pi) * 12
            }
            return (CGSize(width: x, height: y + fumbleDrop), tilt + fumbleTilt)
        }
        
        let period = 1.6
        let phase = Double(index) * (2 * .pi / Double(total))
        let angle = (time * (2 * .pi / period) + phase).truncatingRemainder(dividingBy: 2 * .pi)
        let arcWidth = min(width * 0.28, 82)
        let x = sin(angle) * arcWidth
        let y = (baseHandY - 14) - cos(angle * 2) * 18 + (cos(angle) > 0 ? 6 : -6)
        let tilt = sin(angle) * 10
        return (CGSize(width: x, height: y + fumbleDrop), tilt + fumbleTilt)
    }
    
    // MARK: - Arm Pose Calculations
    private func calculateArmPoses(totalOrbs: Int) -> (CGFloat, CGFloat) {
        if isFumbling {
            let elapsed = juggleTime - fumbleStartTime
            if elapsed < 1.25 {
                let progress = elapsed / 1.25
                let decay = 1.0 - progress
                let flailL = sin(elapsed * 28) * decay
                let flailR = cos(elapsed * 32 + 1.4) * decay
                return (max(-0.15, min(1.0, 0.35 + flailL * 0.50)), max(-0.15, min(1.0, 0.30 + flailR * 0.50)))
            }
        }
        
        let period = totalOrbs == 1 ? 2.0 : 1.6
        let u = (juggleTime / period).truncatingRemainder(dividingBy: 1.0)
        let leftPose = singleArmCycle(u: u)
        let uRight = (u + 0.50).truncatingRemainder(dividingBy: 1.0)
        let rightPose = singleArmCycle(u: uRight)
        return (leftPose, rightPose)
    }
    
    private func singleArmCycle(u: Double) -> CGFloat {
        if u < 0.10 {
            let prog = u / 0.10
            return CGFloat(1.0 - 1.15 * sin(prog * .pi / 2))
        } else if u < 0.24 {
            let prog = (u - 0.10) / 0.14
            let push = 1.0 - cos(prog * .pi / 2)
            let spring = sin(prog * .pi) * 0.10
            return CGFloat(-0.15 + 1.25 * push + spring)
        } else if u < 0.40 {
            let prog = (u - 0.24) / 0.16
            let settle = prog * (2.0 - prog)
            return CGFloat(1.10 * (1.0 - settle))
        } else if u < 0.85 {
            return 0.0
        } else {
            let prog = (u - 0.85) / 0.15
            return CGFloat(sin(prog * .pi / 2))
        }
    }
    
    // MARK: - Computed Lists
    private var filteredIntegrations: [Integration] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return Integration.allSupported }
        return Integration.allSupported.filter {
            $0.name.lowercased().contains(query) || $0.category.rawValue.lowercased().contains(query)
        }
    }
    
    private var juggleItems: [JuggleItem] {
        let connected = store.connectedIntegrationIds
        let items = Integration.allSupported
            .filter { connected.contains($0.id) }
            .sorted { (a, b) in
                (store.connectedTimestamps[a.id] ?? .distantPast) > (store.connectedTimestamps[b.id] ?? .distantPast)
            }
            .prefix(5)
        
        let avatarOrb = JuggleItem.avatar(store.profile, activeSprite)
        if items.isEmpty {
            return [avatarOrb]
        } else {
            return [avatarOrb] + items.map { .integration($0) }
        }
    }
    
    private var syncOrbsList: [JuggleItem] {
        juggleItems
    }
    
    private var isProfileValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        nicknameStatus == .available &&
        hasSelectedAvatar
    }
    
    private var statusCopyText: String {
        switch currentSyncBeat {
        case .beat0Handoff: return ""
        case .beat1BigToss, .beat2Gathering: return "Gathering your things..."
        case .beat3PullingIn: return "Mixing it all together..."
        case .beat4Complete: return "Yummy! Delicious!"
        }
    }
    
    // MARK: - Action Handlers & State Machine
    private func handleContinueTap() {
        triggerImpactFeedback()
        switch currentStep {
        case .signIn:
            withAnimation(BranchMotion.sharedSpring) {
                currentStep = .profile
            }
        case .profile:
            #if canImport(UIKit)
            store.saveProfile(
                fullName: fullName,
                nickname: nickname,
                avatarType: avatarType,
                spriteColorHex: activeSprite.hex,
                photoImage: localPhotoImage
            )
            #endif
            withAnimation(BranchMotion.sharedSpring) {
                currentStep = .integrations
            }
        case .integrations:
            store.completeIntegrationsStep()
            withAnimation(BranchMotion.sharedSpring) {
                currentStep = .syncing
            }
            startSyncSequence()
        case .syncing, .complete:
            store.completeSyncStep()
        }
    }
    
    private func handleStepChange(from oldStep: OnboardingStep, to newStep: OnboardingStep) {
        if newStep == .syncing {
            startSyncSequence()
        }
    }
    
    private func startSyncSequence() {
        syncPhysicsTimer?.invalidate()
        syncPhysicsTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            Task { @MainActor in
                if currentSyncBeat >= .beat2Gathering && currentSyncBeat < .beat4Complete {
                    orbitAngle += 0.36
                }
            }
        }
        
        syncTask?.cancel()
        syncTask = Task { @MainActor in
            if currentSyncBeat == .beat4Complete || currentStep == .complete {
                currentStep = .complete
                currentSyncBeat = .beat4Complete
                spriteSlideProgress = 1.0
                strokeTrim = 1.0
                hubFillProgress = 1.0
                arrowScale = 1.0
                arrowOpacity = 1.0
                leftArmFlexProgress = 1.0
                for i in 0..<orbsInwardProgress.count { orbsInwardProgress[i] = 1.0 }
                for i in 0..<orbsOpacity.count { orbsOpacity[i] = 1.0 }
                return
            }
            
            // BEAT 0: HAND-OFF (1.0s)
            if currentSyncBeat <= .beat0Handoff {
                currentSyncBeat = .beat0Handoff
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
            }
            
            // BEAT 1: BIG TOSS (0.65s)
            if currentSyncBeat <= .beat1BigToss {
                currentSyncBeat = .beat1BigToss
                withAnimation(BranchMotion.sharedSpring) {
                    spriteSlideProgress = 1.0
                    strokeTrim = 1.0
                }
                try? await Task.sleep(nanoseconds: 650_000_000)
                guard !Task.isCancelled else { return }
            }
            
            // BEAT 2: GATHERING (1.5s)
            if currentSyncBeat <= .beat2Gathering {
                currentSyncBeat = .beat2Gathering
                spriteSlideProgress = 1.0
                strokeTrim = 1.0
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                guard !Task.isCancelled else { return }
            }
            
            // BEAT 3: PULLING IN (2.0s)
            currentSyncBeat = .beat3PullingIn
            for i in 0..<syncOrbsList.count {
                let delay = UInt64(Double(i) * 0.18 * 1_000_000_000)
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: delay)
                    withAnimation(BranchMotion.sharedSpring) {
                        if orbsInwardProgress.indices.contains(i) { orbsInwardProgress[i] = 1.0 }
                        if orbsOpacity.indices.contains(i) { orbsOpacity[i] = 1.0 }
                    }
                }
            }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            guard !Task.isCancelled else { return }
            
            // BEAT 4: COMPLETE (0.85s)
            currentSyncBeat = .beat4Complete
            currentStep = .complete
            
            withAnimation(.easeOut(duration: 0.38)) {
                hubFillProgress = 1.0
            }
            try? await Task.sleep(nanoseconds: 220_000_000)
            
            withAnimation(BranchMotion.quickSpring) {
                arrowScale = 1.0
                arrowOpacity = 1.0
                leftArmFlexProgress = 1.0
            }
            
            triggerDoubleBlink()
            triggerSuccessFeedback()
        }
    }
    
    // MARK: - Helpers
    private func initializeFlow() {
        if let existing = store.profile {
            self.fullName = existing.fullName
            self.nickname = existing.nickname
            self.avatarType = existing.avatarType
            self.activeSprite = CMYKSprite.from(hex: existing.spriteColorHex)
            #if canImport(UIKit)
            self.localPhotoImage = store.loadedPhotoImage
            #endif
            self.nicknameStatus = .available
            self.hasSelectedAvatar = true
        }
    }
    
    private func selectCurrentSpriteForAvatar() {
        avatarType = .sprite
        hasSelectedAvatar = true
        triggerImpactFeedback()
        withAnimation(BranchMotion.quickSpring) {
            spriteTapBounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(BranchMotion.sharedSpring) {
                spriteTapBounce = false
            }
        }
    }
    
    private func handlePhotoSelected(_ item: PhotosPickerItem?) {
        guard let item else { return }
        isPhotoLoading = true
        Task { @MainActor in
            #if canImport(UIKit)
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.localPhotoImage = image
                self.avatarType = .photo
                self.hasSelectedAvatar = true
                self.triggerSelectionFeedback()
            }
            #endif
            self.isPhotoLoading = false
        }
    }
    
    private func validateNicknameLive(_ raw: String) {
        validationTask?.cancel()
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            nicknameStatus = .empty
            return
        }
        let format = DemoStore.validateNicknameFormat(trimmed)
        if case .invalidFormat = format {
            nicknameStatus = format
            return
        }
        nicknameStatus = .checking
        validationTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }
            if DemoStore.takenNicknames.contains(trimmed.lowercased()) {
                self.nicknameStatus = .taken(trimmed)
            } else {
                self.nicknameStatus = .available
            }
        }
    }
    
    private func handleOrbTap(for item: Integration) {
        if store.connectedIntegrationIds.contains(item.id) {
            store.toggleIntegration(item.id)
            triggerSelectionFeedback()
        } else {
            triggerSelectionFeedback()
            connectingIntegrationId = item.id
            connectionProgress = 0
            connectionTask?.cancel()
            connectionTask = Task { @MainActor in
                for step in 1...15 {
                    try? await Task.sleep(nanoseconds: 40_000_000)
                    guard !Task.isCancelled else { return }
                    self.connectionProgress = CGFloat(step) / 15.0
                }
                guard !Task.isCancelled else { return }
                self.store.toggleIntegration(item.id)
                self.connectingIntegrationId = nil
                self.connectionProgress = 0
                self.triggerSuccessFeedback()
            }
        }
    }
    
    private func triggerFumble() {
        guard !isFumbling else { return }
        triggerImpactFeedback()
        isFumbling = true
        fumbleStartTime = juggleTime
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.isFumbling = false
        }
    }
    
    private func triggerDoubleBlink() {
        Task { @MainActor in
            isDoubleBlinking = true
            try? await Task.sleep(nanoseconds: 100_000_000)
            isDoubleBlinking = false
            try? await Task.sleep(nanoseconds: 85_000_000)
            isDoubleBlinking = true
            try? await Task.sleep(nanoseconds: 100_000_000)
            isDoubleBlinking = false
        }
    }
    
    private func startContinuousBlinkLoop() {
        scheduleNextBlink()
    }
    
    private func scheduleNextBlink() {
        blinkTimer?.invalidate()
        let interval = Double.random(in: 2.0...6.0)
        blinkTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            Task { @MainActor in
                isSpriteBlinking = true
                try? await Task.sleep(nanoseconds: 140_000_000)
                isSpriteBlinking = false
                scheduleNextBlink()
            }
        }
    }
    
    private func startJuggleClock() {
        juggleTimer?.invalidate()
        juggleTimer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { _ in
            juggleTime += 0.025
        }
    }
    
    private func resolveLogoImage(for integration: Integration) -> Image? {
        #if canImport(UIKit)
        if let path = Bundle.module.path(forResource: integration.logoAssetName, ofType: "png"),
           let uiImage = UIImage(contentsOfFile: path) {
            return Image(uiImage: uiImage)
        }
        if let uiImage = UIImage(named: integration.logoAssetName, in: .module, with: nil) {
            return Image(uiImage: uiImage)
        }
        return nil
        #else
        return Image(integration.logoAssetName, bundle: .module)
        #endif
    }
    
    private func triggerSelectionFeedback() {
        #if os(iOS)
        let gen = UISelectionFeedbackGenerator()
        gen.selectionChanged()
        #endif
    }
    
    private func triggerImpactFeedback() {
        #if os(iOS)
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.impactOccurred()
        #endif
    }
    
    private func triggerSuccessFeedback() {
        #if os(iOS)
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        #endif
    }
}

// MARK: - Array Chunk Extension
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
