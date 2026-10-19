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
    case intro
    case quiz
    case talk
    case reveal
    case integrations
    case syncing
    case complete
}

// MARK: - Arrow Slot Preference Key
public struct ArrowSlotFrameKey: PreferenceKey {
    public static let defaultValue: CGRect? = nil
    public static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
        value = nextValue() ?? value
    }
}

// MARK: - Shared Arrow Slot View
public struct ArrowSlotView: View {
    public var minHeight: CGFloat
    
    public init(minHeight: CGFloat = 104) {
        self.minHeight = minHeight
    }
    
    public var body: some View {
        Color.clear
            .frame(minHeight: minHeight, maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ArrowSlotFrameKey.self,
                        value: geo.frame(in: .named("OnboardingFlowSpace"))
                    )
                }
            )
    }
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
    
    // MARK: - Intent State (Intro / Quiz / Talk / Reveal)
    @State private var quizIndex: Int = 0
    @State private var quizSelections: [Int?] = [nil, nil, nil]
    @State private var quizAdvanceTask: Task<Void, Never>? = nil
    @State private var talkPhase: TalkPhase = .ready
    @State private var talkText: String = ""
    @State private var talkElapsed: Double = 0
    @State private var talkShownLines: Int = 0
    @State private var talkTask: Task<Void, Never>? = nil
    @State private var talkFrozen: Bool = false
    @State private var revealedFamily: ThinkingFamily = .cloud
    @State private var cameFromTalk: Bool = false
    @State private var navigatingBack: Bool = false
    @State private var slots: [OnboardingSlot: CGRect] = [:]
    @State private var autoplayTask: Task<Void, Never>? = nil
    
    private enum FocusField: Hashable {
        case fullName, nickname
    }
    @FocusState private var focusedField: FocusField?
    @State private var editingField: FocusField? = nil
    @State private var keyboardHeight: CGFloat = 0
    @State private var arrowSlotFrame: CGRect? = nil
    /// Real safe-area insets (see `body`). Defaults match a Dynamic Island iPhone until measured.
    @State private var safeInsets: EdgeInsets = EdgeInsets(top: 59, leading: 0, bottom: 34, trailing: 0)
    
    private var isTyping: Bool {
        currentStep == .profile && (focusedField != nil || editingField != nil)
    }
    
    private var effectiveKeyboardHeight: CGFloat {
        if keyboardHeight > 0 { return keyboardHeight }
        if isTyping {
            return UIScreen.main.bounds.height < 700 ? 260 : 336
        }
        return 0
    }
    
    private func profileHubCenterY(h: CGFloat, topInset: CGFloat) -> CGFloat {
        if isTyping {
            let topBarBottom = topInset + UsernameBanner.bannerHeight + 36
            let effectiveKeyboardTop = h - effectiveKeyboardHeight
            // Required clearance below name block: 96pt (for arrow 48pt + 24pt above + 24pt below)
            // Identity block extends ~80pt below its center
            let maxHubCenterY = effectiveKeyboardTop - 96 - 80
            let minHubCenterY = topBarBottom + 12 + 80
            let idealHubCenterY = topBarBottom + (h < 700 ? 8 : 16) + 80
            return max(minHubCenterY, min(idealHubCenterY, maxHubCenterY))
        } else {
            return h * 0.32
        }
    }
    
    /// How far the Profile sprite is raised so the eyes of every family clear the home-indicator area.
    /// The "Sprite Selection" label and the arrow slot rise by the same amount.
    private func profileSpriteLift(w: CGFloat, h: CGFloat) -> CGFloat {
        let spriteH = min(w * 0.72, 300) * 0.88
        let maxEyeFrac = BranchSprite.allCases.map { sp -> CGFloat in
            let e = SpriteMorphSampler.eyes(for: sp); return (e.left.y + e.ry) / 100
        }.max() ?? 0.65
        let baseCenter = h - spriteH * 0.08
        let eyeBottom = baseCenter - spriteH / 2 + maxEyeFrac * spriteH
        return max(0, eyeBottom - (h - safeInsets.bottom - 8))
    }
    
    private func profileArrowCenterY(w: CGFloat, h: CGFloat, topInset: CGFloat) -> CGFloat {
        let hubY = profileHubCenterY(h: h, topInset: topInset)
        let nameBottomY = hubY + 80 // bottom of full name text
        
        if isTyping {
            let effectiveKeyboardTop = h - effectiveKeyboardHeight
            // Centered between bottom of name block and top of keyboard
            return (nameBottomY + effectiveKeyboardTop) / 2
        } else {
            let spriteLabelTop = h - 174 - profileSpriteLift(w: w, h: h) // "Sprite Selection" label top (padding bottom 160 + font size 11 + margin)
            // Centered in empty space between bottom of full name and "Sprite Selection"
            return (nameBottomY + spriteLabelTop) / 2
        }
    }

    
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
    /// False while the sprite is travelling into the bottom stage (Integrations / Sync): body and arms stay
    /// hidden, then fade in together once the destination has settled. Keeps arms attached and keeps the
    /// body from sweeping across the arrow.
    @State private var spriteLanded: Bool = false
    @State private var landingTask: Task<Void, Never>? = nil
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
        if let existing = store.profile {
            // Seed from the stored profile so the first frame already has the nickname (banner, hub, sprite).
            self._fullName = State(initialValue: existing.fullName)
            self._nickname = State(initialValue: existing.nickname)
            self._avatarType = State(initialValue: existing.avatarType)
            self._activeSprite = State(initialValue: CMYKSprite.from(hex: existing.spriteColorHex))
            self._nicknameStatus = State(initialValue: .available)
            self._hasSelectedAvatar = State(initialValue: true)
        }
        if CommandLine.arguments.contains("-onboardingProfileKeyboardEmpty") || CommandLine.arguments.contains("-onboardingProfileKeyboardMidTyping") || CommandLine.arguments.contains("-profileMidTyping") {
            self._editingField = State(initialValue: .nickname)
        }
        
        // Screenshot / demo launch states for the intent steps
        let args = CommandLine.arguments
        if resolvedStep == .quiz {
            let index = args.contains("-quizQ3") ? 2 : (args.contains("-quizQ2") ? 1 : 0)
            var selections: [Int?] = [nil, nil, nil]
            for i in 0..<index { selections[i] = 0 }
            if args.contains("-quizSelected") { selections[index] = 1 }
            self._quizIndex = State(initialValue: index)
            self._quizSelections = State(initialValue: selections)
        }
        if resolvedStep == .talk {
            if args.contains("-onboardingTalkSpeaking") {
                self._talkPhase = State(initialValue: .speaking)
                self._talkElapsed = State(initialValue: 9)
                self._talkShownLines = State(initialValue: 2)
                self._talkFrozen = State(initialValue: true)
            } else if args.contains("-onboardingTalkWrite") {
                self._talkPhase = State(initialValue: .writing)
            }
        }
        if resolvedStep == .reveal {
            let family = ThinkingFamily.allCases.first { args.contains("-reveal\($0.rawValue)") } ?? .cloud
            self._revealedFamily = State(initialValue: family)
        }
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack {
            // Real safe-area insets, read by a reader that RESPECTS the safe area. (The canvas below is full-bleed so
            // its proxy reads 0, and reading UIWindow insets inside body freezes SwiftUI updates.)
            GeometryReader { probe in
                Color.clear
                    .onChange(of: probe.safeAreaInsets, initial: true) { _, insets in
                        if safeInsets != insets { safeInsets = insets }
                    }
            }
            .allowsHitTesting(false)
            flowCanvas
        }
    }
    
    private var flowCanvas: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            // The flow's canvas is full-bleed (backgrounds + the sprites' bottom crop), but every piece of
            // content is laid out from the REAL safe-area top. The proxy reads 0 under a full-bleed reader,
            // so take the max with the window's inset. +8pt = banner top offset below the safe-area edge.
            let topInset = safeInsets.top + 8
            
            ZStack(alignment: .top) {
                // 1. PERSISTENT BACKGROUND LAYER
                persistentBackgroundLayer
                    .ignoresSafeArea(.keyboard)
                
                // 2. PERSISTENT TOP USERNAME BANNER & CONTINUE BUTTON (Structured vertically)
                VStack(spacing: 0) {
                    Spacer().frame(height: topInset)
                    persistentBannerView
                        .frame(height: bannerHeightNow)
                        .clipped()
                    persistentTopContinueRow
                        .frame(height: 36)
                }
                .animation(BranchMotion.sharedSpring, value: bannerHeightNow)
                .zIndex(20)
                .ignoresSafeArea(.keyboard)
                
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
                        profileStepContent(w: w, h: h, topInset: topInset)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .offset(y: 20)),
                                removal: .opacity.combined(with: .offset(y: -20))
                            ))
                            .zIndex(2)
                    }
                    
                    if currentStep == .intro {
                        OnboardingIntroStep(
                            firstName: firstName,
                            contentTop: intentContentTop(topInset: topInset),
                            viewportHeight: h,
                            onTalk: { openTalk() }
                        )
                        .frame(width: w, height: h)
                        .transition(stepTransition)
                        .zIndex(2.2)
                    }
                    
                    if currentStep == .quiz {
                        OnboardingQuizStep(
                            index: quizIndex,
                            selections: quizSelections,
                            contentTop: intentContentTop(topInset: topInset),
                            rowTop: topInset + bannerHeightNow,
                            viewportHeight: h,
                            backward: navigatingBack,
                            onSelect: { selectQuizAnswer($0) }
                        )
                        .frame(width: w, height: h)
                        .transition(stepTransition)
                        .zIndex(2.4)
                    }
                    
                    if currentStep == .talk {
                        OnboardingTalkStep(
                            phase: talkPhase,
                            elapsed: talkElapsed,
                            shownLines: talkShownLines,
                            text: $talkText,
                            contentTop: intentContentTop(topInset: topInset),
                            viewportHeight: h,
                            onRecordTap: { toggleTalk() },
                            onWriteInstead: { enterWriting() },
                            onTalkInstead: { leaveWriting() }
                        )
                        .frame(width: w, height: h)
                        .transition(stepTransition)
                        .zIndex(2.6)
                    }
                    
                    if currentStep == .reveal {
                        OnboardingRevealStep(
                            family: revealedFamily,
                            contentTop: intentContentTop(topInset: topInset),
                            viewportHeight: h
                        )
                        .frame(width: w, height: h)
                        .transition(stepTransition)
                        .zIndex(2.8)
                    }
                    
                    if currentStep == .integrations {
                        integrationsStepContent(w: w, h: h, topInset: topInset)
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
                if showsPersistentArrow {
                    persistentNextArrowButton(w: w, h: h, topInset: topInset)
                        .zIndex(15)
                }
                
                // 6. PERSISTENT SPRITE INSTANCE (Single instance for the entire flow)
                persistentSpriteLayer(w: w, h: h, topInset: topInset)
                    .zIndex(12)
                    .ignoresSafeArea(.keyboard)
            }
            .frame(width: w, height: h)
            .coordinateSpace(name: "OnboardingFlowSpace")
            .onPreferenceChange(OnboardingSlotsKey.self) { newSlots in
                applySlots(newSlots)
            }
            .onPreferenceChange(ArrowSlotFrameKey.self) { newFrame in
                if let newFrame = newFrame {
                    // Hop off the layout pass: state written from a preference callback mid-layout can be dropped.
                    DispatchQueue.main.async {
                        withAnimation(BranchMotion.sharedSpring) {
                            self.arrowSlotFrame = newFrame
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
        // Full-bleed canvas only so absolute coordinates match the screen; content respects `topInset`.
        // Backgrounds (wash) ignore the safe area individually.
        .ignoresSafeArea()
        .onAppear {
            initializeFlow()
            spriteLanded = Self.isStageStep(currentStep)
            startContinuousBlinkLoop()
            startJuggleClock()
            if currentStep == .syncing || currentStep == .complete {
                startSyncSequence()
            }
            if currentStep == .talk && talkPhase == .speaking && !talkFrozen {
                startTalkClock()
            }
            if currentStep == .reveal {
                celebrateReveal()
            }
            startAutoplayIfRequested()
            if CommandLine.arguments.contains("-onboardingProfileKeyboardEmpty") {
                self.nickname = ""
                self.fullName = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(BranchMotion.sharedSpring) {
                        editingField = .nickname
                        focusedField = .nickname
                    }
                }
            } else if CommandLine.arguments.contains("-onboardingProfileKeyboardMidTyping") || CommandLine.arguments.contains("-profileMidTyping") {
                if nickname.isEmpty {
                    self.nickname = "cassius"
                    self.fullName = "Cassius"
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(BranchMotion.sharedSpring) {
                        editingField = .nickname
                        focusedField = .nickname
                    }
                }
            }
        }
        .onDisappear {
            blinkTimer?.invalidate()
            juggleTimer?.invalidate()
            syncPhysicsTimer?.invalidate()
            syncTask?.cancel()
            connectionTask?.cancel()
            talkTask?.cancel()
            quizAdvanceTask?.cancel()
            autoplayTask?.cancel()
        }
        .onChange(of: focusedField) { _, newFocus in
            if newFocus != editingField {
                withAnimation(BranchMotion.sharedSpring) {
                    editingField = newFocus
                }
            }
        }
        .onChange(of: currentStep) { oldStep, newStep in
            handleStepChange(from: oldStep, to: newStep)
            updateSpriteLanding(to: newStep)
        }
        .onChange(of: store.session) { _, newSession in
            if newSession != nil && currentStep == .signIn {
                withAnimation(BranchMotion.sharedSpring) {
                    currentStep = .profile
                }
            }
        }
        #if canImport(UIKit)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let screenH = UIScreen.main.bounds.height
                let newH = frame.minY >= screenH ? 0 : frame.height
                withAnimation(BranchMotion.sharedSpring) {
                    keyboardHeight = newH
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(BranchMotion.sharedSpring) {
                keyboardHeight = 0
            }
        }
        #endif
    }
    
    // MARK: - 1. Persistent Background Layer
    private var persistentBackgroundLayer: some View {
        // The wash lives behind every onboarding step and is never part of a step transition,
        // so it never reloads. It leaves with the whole flow when AppRootView fades onboarding out.
        WelcomeSoftWashBackground()
            .ignoresSafeArea()
    }
    
    // MARK: - 2. Persistent Username Banner
    private var persistentBannerView: some View {
        let displayNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let shouldShowBanner = bannerVisible
        
        return UsernameBanner(nickname: displayNickname)
            .opacity(shouldShowBanner ? 1.0 : 0.0)
            .allowsHitTesting(shouldShowBanner)
            .animation(BranchMotion.sharedSpring, value: shouldShowBanner)
    }
    
    // MARK: - 3. Persistent Top Continue Button Row
    private var persistentTopContinueRow: some View {
        let title: String? = {
            switch currentStep {
            case .signIn, .talk:
                return nil
            case .intro, .quiz:
                return "Skip"
            case .profile, .reveal, .integrations, .complete:
                return "Continue"
            case .syncing:
                return currentSyncBeat == .beat4Complete ? "Continue" : nil
            }
        }()
        let isVisible = title != nil
        
        let isEnabled: Bool = {
            switch currentStep {
            case .signIn, .talk:
                return false
            case .profile:
                return isProfileValid
            case .intro, .quiz, .reveal, .integrations, .syncing, .complete:
                return true
            }
        }()
        
        let showsBack = currentStep == .quiz || currentStep == .talk || currentStep == .reveal
        
        return HStack {
            backButton
                .opacity(showsBack ? 1.0 : 0.0)
                .allowsHitTesting(showsBack)
                .animation(BranchMotion.sharedSpring, value: showsBack)
            Spacer()
            ContinueButton(
                title: title ?? "Continue",
                isEnabled: isEnabled,
                disabledHint: "Enter name and nickname to continue"
            ) {
                handleTopRightTap()
            }
            // Label swaps without overlap ("Skip" never ghosts into "Continue").
            .id(title ?? "Continue")
            .transition(.identity)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(BranchMotion.sharedSpring, value: isVisible)
            .animation(BranchMotion.quickSpring, value: isEnabled)
            .allowsHitTesting(isVisible)
        }
        .padding(.horizontal, 24)
        .frame(height: 36)
    }
    
    private var backButton: some View {
        Button {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            goBack()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.primary)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
        .accessibilityLabel("Back")
    }
    
    // MARK: - 5. Persistent Next Arrow Button
    private var persistentNextArrowButton: some View {
        persistentNextArrowButton(w: 393, h: 852, topInset: 59)
    }
    
    private func persistentNextArrowButton(w: CGFloat, h: CGFloat, topInset: CGFloat) -> some View {
        let isEnabled: Bool = {
            switch currentStep {
            case .profile:
                return isProfileValid
            case .integrations, .syncing, .complete, .intro, .reveal:
                return true
            case .quiz:
                return quizSelections.indices.contains(quizIndex) && quizSelections[quizIndex] != nil
            case .talk:
                return !talkText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            case .signIn:
                return false
            }
        }()
        
        let intentSlot: CGRect? = isIntentStep ? slots[.arrow(currentStep)] : nil
        let arrowX: CGFloat = intentSlot?.midX ?? arrowSlotFrame?.midX ?? (w * 0.50)
        let arrowY: CGFloat = {
            if let slot = intentSlot {
                return slot.midY
            }
            if !isIntentStep, let slot = arrowSlotFrame {
                return slot.midY
            }
            switch currentStep {
            case .intro, .quiz, .talk, .reveal:
                return h * 0.80
            case .profile:
                return profileArrowCenterY(w: w, h: h, topInset: topInset)
            case .integrations:
                return h * 0.65
            case .syncing, .complete:
                return h * 0.50
            case .signIn:
                return h * 1.2
            }
        }()
        let arrowLabel: String = {
            switch currentStep {
            case .intro: return "Start the questions"
            case .quiz: return quizIndex < 2 ? "Next question" : "See your shape"
            case .talk: return "Done writing"
            default: return "Continue to next step"
            }
        }()
        return NextArrowButton(
            isEnabled: isEnabled,
            accessibilityLabel: arrowLabel
        ) {
            handleContinueTap()
        }
        .position(x: arrowX, y: arrowY)
        .animation(BranchMotion.sharedSpring, value: arrowSlotFrame)
        .animation(BranchMotion.sharedSpring, value: currentStep)
        .animation(BranchMotion.sharedSpring, value: isTyping)
        .animation(BranchMotion.quickSpring, value: isEnabled)
    }
    
    // MARK: - 6. Persistent Sprite Layer
    /// Integrations / Sync sprite placement: full dome and both eyes visible, eyes end at least
    /// max(20% of the sprite height, home-indicator inset + 6pt) above the screen edge; only the lower body is cropped.
    private func stageSpriteGeometry(h: CGFloat, topInset: CGFloat) -> (side: CGFloat, centerY: CGFloat, crop: CGFloat, headTop: CGFloat) {
        let eye = SpriteMorphSampler.eyes(for: activeSprite)
        let eyeFrac = (eye.left.y + eye.ry) / 100
        let bottomInset = safeInsets.bottom
        func visible(_ side: CGFloat) -> CGFloat { eyeFrac * side + max(0.2 * side, bottomInset + 6) }
        // Space left under the Integrations content (top block + arrow slot + "Connected" label) for
        // juggle band (~104) + 8 gap above the label + 16 gap above the head: the sprite takes whatever fits.
        let available = h - (topInset + 430) - 88 - 22 - 136 - 8
        var side: CGFloat = 140
        while side < 250 && visible(side + 2) <= available { side += 2 }
        let vis = min(visible(side), side)
        return (side, h - vis + side / 2, vis / side, h - vis)
    }
    
    private func persistentSpriteLayer(w: CGFloat, h: CGFloat, topInset: CGFloat) -> some View {
        let stage = stageSpriteGeometry(h: h, topInset: topInset)
        // Sprite geometry computation per step
        let intentSlot: CGRect? = isIntentStep ? slots[.sprite(currentStep)] : nil
        let intentSide: CGFloat = intentSlot.map { min($0.width, $0.height) } ?? 0
        let spriteW: CGFloat = isIntentStep ? intentSide : ((currentStep == .profile) ? min(w * 0.72, 300) : max(220, stage.side * 1.6))
        let spriteH: CGFloat = isIntentStep ? intentSide : ((currentStep == .profile) ? spriteW * 0.88 : stage.side)
        
        let spriteX: CGFloat = {
            switch currentStep {
            case .intro, .quiz, .talk, .reveal:
                return intentSlot?.midX ?? w * 0.50
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
                let shiftedX = min(w * 0.72, w - stage.side / 2 - 12)
                return centeredX + (shiftedX - centeredX) * spriteSlideProgress
            }
        }()
        
        let spriteY: CGFloat = {
            switch currentStep {
            case .intro, .quiz, .talk, .reveal:
                return intentSlot?.midY ?? (h + 220)
            case .signIn:
                return h + 220
            case .profile:
                // Eyes of every family stay above the home-indicator area; only the lower body is cropped.
                return h - spriteH * 0.08 - profileSpriteLift(w: w, h: h)
            case .integrations:
                return stage.centerY
            case .syncing, .complete:
                if currentSyncBeat == .beat0Handoff {
                    return stage.centerY
                }
                let startY = stage.centerY + spriteH * 0.34
                let endY = stage.centerY
                return startY + (endY - startY) * spriteSlideProgress
            }
        }()
        
        let spriteOpacity: Double = {
            if currentStep == .signIn { return 0.0 }
            if currentStep == .profile && isTyping { return 0.0 }
            if isIntentStep && intentSlot == nil { return 0.0 }
            if Self.isStageStep(currentStep) && !spriteLanded { return 0.0 }
            return 1.0
        }()
        let showsArms: Bool = (currentStep == .integrations)
        let stageHidden = Self.isStageStep(currentStep) && !spriteLanded
        
        // Arm poses
        let (armL, armR) = calculateArmPoses(totalOrbs: juggleItems.count)
        
        return ZStack(alignment: .bottom) {
            if currentStep == .syncing || currentStep == .complete {
                if currentSyncBeat == .beat1BigToss {
                    // Big toss: both arms push high
                    SpriteArmShape(pose: 1.0, isLeft: true, sprite: activeSprite, crop: stage.crop)
                        .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(stage.side * 0.085, 9), lineCap: .round, lineJoin: .round))
                        .frame(width: min(spriteW, spriteH), height: min(spriteW, spriteH))
                    
                    SpriteArmShape(pose: 1.0, isLeft: false, sprite: activeSprite, crop: stage.crop)
                        .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(stage.side * 0.085, 9), lineCap: .round, lineJoin: .round))
                        .frame(width: min(spriteW, spriteH), height: min(spriteW, spriteH))
                } else if currentSyncBeat >= .beat2Gathering {
                    // Beats 2-4: left arm resting -> bicep flex
                    SpriteFlexArmShape(flexProgress: leftArmFlexProgress, sprite: activeSprite, crop: stage.crop)
                        .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(stage.side * 0.085, 9), lineCap: .round, lineJoin: .round))
                        .frame(width: min(spriteW, spriteH), height: min(spriteW, spriteH))
                }
            } else if showsArms {
                // Juggling arms in Step 3 (Integrations) & Beat 0
                SpriteArmShape(pose: armL, isLeft: true, sprite: activeSprite, crop: stage.crop)
                    .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(stage.side * 0.085, 9), lineCap: .round, lineJoin: .round))
                    .frame(width: min(spriteW, spriteH), height: min(spriteW, spriteH))
                
                SpriteArmShape(pose: armR, isLeft: false, sprite: activeSprite, crop: stage.crop)
                    .stroke(activeSprite.gradient, style: StrokeStyle(lineWidth: max(stage.side * 0.085, 9), lineCap: .round, lineJoin: .round))
                    .frame(width: min(spriteW, spriteH), height: min(spriteW, spriteH))
            }
            
            // Central morphing sprite (single instance for the entire flow)
            MorphingSpriteView(
                family: spriteFamily,
                isBlinking: isSpriteBlinking || isDoubleBlinking,
                eyeStyle: isListening ? .listening : .open,
                breathing: isListening
            )
            .frame(width: spriteW, height: spriteH)
            .scaleEffect(spriteTapBounce ? 0.94 : 1.0, anchor: .bottom)
            .contentShape(Rectangle())
            .onTapGesture {
                if currentStep == .profile {
                    selectCurrentSpriteForAvatar()
                } else if currentStep == .integrations {
                    triggerFumble()
                } else if currentStep == .reveal {
                    cycleRevealedFamily()
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
        .allowsHitTesting((currentStep == .profile && !isTyping) || currentStep == .integrations || currentStep == .reveal)
        .animation(BranchMotion.sharedSpring, value: currentStep)
        .animation(BranchMotion.sharedSpring, value: isTyping)
        .animation(BranchMotion.sharedSpring, value: spriteSlideProgress)
        .animation(BranchMotion.quickSpring, value: spriteTapBounce)
        // Outermost on purpose: the sprite vanishes at once when it has to travel into the stage (it never sweeps
        // over the arrow, and arms never show detached), then fades in at the destination.
        .transaction { t in
            if stageHidden { t.animation = nil; t.disablesAnimations = true }
        }
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
    private func profileStepContent(w: CGFloat, h: CGFloat, topInset: CGFloat) -> some View {
        let hubY = profileHubCenterY(h: h, topInset: topInset)
        
        return ZStack(alignment: .top) {
            // Center Identity Hub (avatar + @nickname + Full Name)
            VStack(spacing: 12) {
                // 96pt Avatar Circle
                avatarPickerView
                
                // Name & Nickname Displays (Single perfectly centered unit)
                inlineNameEditorView
                
                // Validation feedback
                validationFeedbackCaption
            }
            .frame(width: w)
            .position(x: w * 0.50, y: hubY)
            .animation(BranchMotion.sharedSpring, value: isTyping)
            
            // Profile Step Arrow Slot: between full name and "Sprite Selection"
            let nameBottomY = hubY + 80
            let slotBottomY = isTyping ? (h - effectiveKeyboardHeight) : (h - 174 - profileSpriteLift(w: w, h: h))
            let slotHeight = max(slotBottomY - nameBottomY, 104)
            let slotCenterY = (nameBottomY + slotBottomY) / 2
            
            Color.clear
                .frame(width: w, height: slotHeight)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ArrowSlotFrameKey.self,
                            value: geo.frame(in: .named("OnboardingFlowSpace"))
                        )
                    }
                )
                .position(x: w * 0.50, y: slotCenterY)
            
            // Bottom "Sprite Selection" label
            VStack(spacing: 0) {
                Spacer(minLength: 24)
                Text("Sprite Selection")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.secondary.opacity(0.8))
                    .padding(.bottom, 160 + profileSpriteLift(w: w, h: h))
            }
            .frame(width: w, height: h)
            .opacity(isTyping ? 0.0 : 1.0)
            .animation(BranchMotion.sharedSpring, value: isTyping)
            .allowsHitTesting(!isTyping)
        }
        .frame(width: w, height: h)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(BranchMotion.sharedSpring) {
                editingField = nil
            }
            focusedField = nil
        }
    }
    
    private var avatarPickerView: some View {
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
                        Spacer(minLength: 0)
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
    }
    
    // MARK: - Text Measurement Helpers
    private func measureTextWidth(_ text: String, fontSize: CGFloat, weight: Font.Weight) -> CGFloat {
        #if canImport(UIKit)
        let uiWeight: UIFont.Weight = {
            switch weight {
            case .bold: return .bold
            case .semibold: return .semibold
            case .medium: return .medium
            case .regular: return .regular
            case .light: return .light
            case .ultraLight: return .ultraLight
            case .heavy: return .heavy
            case .black: return .black
            default: return .regular
            }
        }()
        let font = UIFont.systemFont(ofSize: fontSize, weight: uiWeight)
        let size = (text as NSString).size(withAttributes: [.font: font])
        return ceil(size.width)
        #else
        return CGFloat(text.count) * (fontSize * 0.6)
        #endif
    }
    
    private var nicknameDisplayOrEditView: some View {
        let isEditing = (editingField == .nickname)
        
        return Group {
            if !isEditing {
                // Resting: Single plain Text view, centered. No TextField.
                Group {
                    if nickname.isEmpty {
                        (Text("@").foregroundStyle(Color.secondary.opacity(0.65))
                         + Text("nickname").foregroundStyle(Color.secondary.opacity(0.35)))
                    } else {
                        Text("@\(nickname)")
                            .foregroundStyle(Color.primary)
                    }
                }
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(BranchMotion.sharedSpring) {
                        editingField = .nickname
                    }
                    focusedField = .nickname
                }
            } else {
                // Editing: "@" prefix + TextField sized to typed text only.
                let textWidth = measureTextWidth(nickname, fontSize: 20, weight: .bold)
                let fieldWidth = max(textWidth + 2, 8)
                
                HStack(spacing: 0) {
                    Text("@")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(nickname.isEmpty ? Color.secondary.opacity(0.65) : Color.primary)
                    
                    TextField("", text: $nickname)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .focused($focusedField, equals: .nickname)
                        .submitLabel(.next)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()
                        .frame(width: fieldWidth, alignment: .leading)
                        .onSubmit {
                            withAnimation(BranchMotion.sharedSpring) {
                                editingField = .fullName
                            }
                            focusedField = .fullName
                        }
                        .onChange(of: nickname) { _, val in validateNicknameLive(val) }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = .nickname
                }
            }
        }
    }
    
    private var fullNameDisplayOrEditView: some View {
        let isEditing = (editingField == .fullName)
        
        return Group {
            if !isEditing {
                // Resting: Single plain Text view, centered. No TextField.
                Group {
                    if fullName.isEmpty {
                        Text("Full Name")
                            .foregroundStyle(Color.secondary.opacity(0.35))
                    } else {
                        Text(fullName)
                            .foregroundStyle(Color.secondary)
                    }
                }
                .font(.system(size: 15, weight: .regular))
                .multilineTextAlignment(.center)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(BranchMotion.sharedSpring) {
                        editingField = .fullName
                    }
                    focusedField = .fullName
                }
            } else {
                // Editing: TextField sized to typed text only.
                let textWidth = measureTextWidth(fullName, fontSize: 15, weight: .regular)
                let fieldWidth = max(textWidth + 2, 8)
                
                TextField("", text: $fullName)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .focused($focusedField, equals: .fullName)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
                    .frame(width: fieldWidth, alignment: .center)
                    .onSubmit {
                        withAnimation(BranchMotion.sharedSpring) {
                            editingField = nil
                        }
                        focusedField = nil
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .fullName
                    }
            }
        }
    }
    
    private var inlineNameEditorView: some View {
        VStack(spacing: 8) {
            nicknameDisplayOrEditView
            fullNameDisplayOrEditView
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
            Spacer().frame(height: topInset + UsernameBanner.bannerHeight + 36 + 4)
            
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
            .padding(.top, 6)
            
            // "Supported" label
            Text("Supported")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Color(white: 0.65) : Color(white: 0.45))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 26)
                .padding(.top, 6)
                .padding(.bottom, 4)
            
            // Paged Grid (13 supported items)
            integrationsGridArea(h: h)
            
            // Arrow Slot: Between page dots and "Connected"
            // Has minimum height of arrow size (56) + 24pt above + 24pt below = 104pt
            ArrowSlotView(minHeight: 88)
            
            // "Connected" label
            Text("Connected")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Color(white: 0.65) : Color(white: 0.45))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 26)
            
            // Fixed reserve under the label: juggle band + gaps + the visible sprite. The arrow slot absorbs the slack.
            Color.clear.frame(height: h - stageSpriteGeometry(h: h, topInset: topInset).headTop + 136)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .top) {
            // Juggling stage: orbs bottom out 24pt above the head; stage height 140 (orbs span about -121...-11 from its centre).
            let headTop = stageSpriteGeometry(h: h, topInset: topInset).headTop
            juggleOrbsOverlay(w: w, h: 140)
                .frame(width: w, height: 140)
                .position(x: w / 2, y: headTop - 24 + 11 - 0)
                .allowsHitTesting(false)
        }
    }
    
    @ViewBuilder
    private func integrationsGridArea(h: CGFloat) -> some View {
        let items = filteredIntegrations
        let p1 = Array(items.prefix(12))
        let p2 = Array(items.dropFirst(12))
        let gridH: CGFloat = 214
        
        if items.isEmpty {
            VStack {
                Spacer()
                Text("No matches")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(height: gridH)
        } else {
            VStack(spacing: 6) {
                TabView(selection: $currentPage) {
                    pageGridView(for: p1).tag(0)
                    if !p2.isEmpty {
                        pageGridView(for: p2).tag(1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: gridH + 26)   // +26 room for the orb shadow inside the paged clip
                .padding(.bottom, -26)       // net layout height unchanged
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(currentPage == 0 ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 5, height: 5)
                    Circle()
                        .fill(currentPage == 1 ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 5, height: 5)
                }
                .opacity(p2.isEmpty ? 0.0 : 1.0)
                .frame(height: 10)
                .padding(.top, 2)
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
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.bottom, 26)
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
                    // Rotate in place, then offset: the other order swings the orb around the stage centre.
                    .rotationEffect(.degrees(rotation))
                    .offset(offset)
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
                    // Upper area: >=48pt above the highest orb (orbit radius up to 160 + orb radius 31)
                    .position(x: w * 0.50, y: hubCenter.y - 160 - 31 - 48 - 12)
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
                .fill(Color.white)
                .overlay(Circle().stroke(Color.black.opacity(0.06), lineWidth: 1))
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
                    IntegrationLogoBadge(
                        image: image,
                        isOpaqueTile: IntegrationLogoBadge.isOpaqueTile(named: integration.logoAssetName),
                        diameter: 30
                    )
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
        
        // Cascade: every orb owns a lane at least 52pt wide (orbs are 44pt), so no two orbs can overlap at
        // any count; a hop travels across the lanes like a wave while each orb sways a few points.
        let period = 1.6
        let spacing = min(54, (width - 72) / CGFloat(max(total - 1, 1)))
        let laneX = (CGFloat(index) - CGFloat(total - 1) / 2) * spacing
        let angle = (time * (2 * .pi / period)) - Double(index) * (2 * .pi / Double(total))
        let hop = (1 - cos(angle)) / 2            // 0...1
        let x = laneX + CGFloat(sin(angle)) * 3
        let y = (baseHandY + 4) - CGFloat(hop) * 34
        let tilt = sin(angle) * 9
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
        
        // The "Connected" area is never empty: with nothing connected the sprite juggles the single avatar orb.
        let avatarOrb = JuggleItem.avatar(store.profile, activeSprite)
        return [avatarOrb] + items.map { .integration($0) }
    }
    
    private var syncOrbsList: [JuggleItem] {
        return juggleItems
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
                currentStep = .intro
            }
        case .intro:
            startQuiz()
        case .quiz:
            advanceQuiz()
        case .talk:
            finishWriting()
        case .reveal:
            finishReveal()
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
        if oldStep == .talk && newStep != .talk {
            talkTask?.cancel()
        }
        if oldStep == .quiz && newStep != .quiz {
            quizAdvanceTask?.cancel()
        }
        if newStep == .reveal {
            celebrateReveal()
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
    
    // MARK: - Intent Steps (Intro / Quiz / Talk / Reveal)
    private var isIntentStep: Bool {
        switch currentStep {
        case .intro, .quiz, .talk, .reveal: return true
        default: return false
        }
    }
    
    private var showsPersistentArrow: Bool {
        switch currentStep {
        case .profile, .integrations, .intro, .quiz, .reveal: return true
        case .talk: return talkPhase == .writing
        default: return false
        }
    }
    
    private var firstName: String? {
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.split(whereSeparator: { $0.isWhitespace }).first else { return nil }
        return String(first)
    }
    
    private var bannerVisible: Bool {
        let displayNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        // Banner shows only on Profile, Integrations and Sync; hidden on signIn and the intent steps (no reserved height there).
        let showsOnStep: Bool = { switch currentStep { case .profile, .integrations, .syncing, .complete: return true; default: return false } }()
        return showsOnStep && !displayNickname.isEmpty && !store.isGuest
    }
    
    private var bannerHeightNow: CGFloat {
        bannerVisible ? UsernameBanner.bannerHeight : 0
    }
    
    private func intentContentTop(topInset: CGFloat) -> CGFloat {
        topInset + bannerHeightNow + 36 + 8
    }
    
    private var stepTransition: AnyTransition {
        // Outgoing content clears fast; incoming waits a beat, so two screens of full-weight text never overlap.
        .asymmetric(
            insertion: AnyTransition.opacity.combined(with: .offset(y: navigatingBack ? -24 : 24))
                .animation(BranchMotion.sharedSpring.delay(0.1)),
            removal: AnyTransition.opacity.combined(with: .offset(y: navigatingBack ? 24 : -24))
                .animation(.easeOut(duration: 0.12))
        )
    }
    
    /// The family the persistent sprite wears. `nil` means shapeless (cycling).
    private var spriteFamily: BranchSprite? {
        switch currentStep {
        case .intro, .talk:
            return nil
        case .quiz:
            guard quizSelections.indices.contains(quizIndex),
                  let sel = quizSelections[quizIndex] else { return nil }
            return QuizContent.questions[quizIndex].answers[sel].family.sprite
        case .reveal:
            return revealedFamily.sprite
        default:
            return activeSprite
        }
    }
    
    private var isListening: Bool {
        currentStep == .talk && (talkPhase == .speaking || talkPhase == .writing)
    }
    
    /// Stores the reported slot frames. A change in which slots exist (new step or phase) or in a slot's
    /// size springs; a pure position change (scrolling) follows the content without lag.
    private func applySlots(_ newSlots: [OnboardingSlot: CGRect]) {
        let sameKeys = Set(newSlots.keys) == Set(slots.keys)
        let sizeChanged = newSlots.contains { key, frame in
            guard let old = slots[key] else { return false }
            return abs(old.width - frame.width) > 0.5 || abs(old.height - frame.height) > 0.5
        }
        if sameKeys && !sizeChanged {
            var t = Transaction()
            t.disablesAnimations = true
            withTransaction(t) { slots = newSlots }
        } else {
            withAnimation(BranchMotion.sharedSpring) { slots = newSlots }
        }
    }
    
    private func handleTopRightTap() {
        switch currentStep {
        case .intro, .quiz:
            skipIntent()
        default:
            handleContinueTap()
        }
    }
    
    private func skipIntent() {
        quizAdvanceTask?.cancel()
        withAnimation(BranchMotion.sharedSpring) {
            currentStep = .integrations
        }
    }
    
    /// Backward moves use the mirrored transition: the flag is set one tick ahead so the departing view picks it up.
    private func navigate(to step: OnboardingStep, backward: Bool) {
        navigatingBack = backward
        DispatchQueue.main.async {
            withAnimation(BranchMotion.sharedSpring) {
                currentStep = step
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                navigatingBack = false
            }
        }
    }
    
    private func goBack() {
        switch currentStep {
        case .quiz:
            quizAdvanceTask?.cancel()
            if quizIndex > 0 {
                navigatingBack = true
                DispatchQueue.main.async {
                    withAnimation(BranchMotion.sharedSpring) { quizIndex -= 1 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { navigatingBack = false }
                }
            } else {
                navigate(to: .intro, backward: true)
            }
        case .talk:
            talkTask?.cancel()
            navigate(to: .intro, backward: true)
        case .reveal:
            if cameFromTalk {
                resetTalk()
                navigate(to: .talk, backward: true)
            } else {
                quizIndex = 2
                navigate(to: .quiz, backward: true)
            }
        default:
            break
        }
    }
    
    // MARK: Quiz
    private func startQuiz() {
        quizIndex = 0
        cameFromTalk = false
        withAnimation(BranchMotion.sharedSpring) {
            currentStep = .quiz
        }
    }
    
    private func selectQuizAnswer(_ answer: Int) {
        guard quizSelections.indices.contains(quizIndex) else { return }
        triggerSelectionFeedback()
        withAnimation(BranchMotion.quickSpring) {
            quizSelections[quizIndex] = answer
        }
        quizAdvanceTask?.cancel()
        guard !reduceMotion else { return }
        let questionAtTap = quizIndex
        quizAdvanceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 600_000_000)
            guard !Task.isCancelled, currentStep == .quiz, quizIndex == questionAtTap else { return }
            advanceQuiz()
        }
    }
    
    private func advanceQuiz() {
        quizAdvanceTask?.cancel()
        guard quizSelections.indices.contains(quizIndex), quizSelections[quizIndex] != nil else { return }
        if quizIndex < QuizContent.questions.count - 1 {
            navigatingBack = false
            withAnimation(BranchMotion.sharedSpring) { quizIndex += 1 }
        } else {
            cameFromTalk = false
            revealedFamily = QuizContent.result(for: quizSelections)
            store.saveIntent(answers: QuizContent.families(for: quizSelections), revealed: revealedFamily)
            withAnimation(BranchMotion.sharedSpring) { currentStep = .reveal }
        }
    }
    
    // MARK: Talk it through (simulated; no microphone is used)
    private func openTalk() {
        resetTalk()
        withAnimation(BranchMotion.sharedSpring) { currentStep = .talk }
    }
    
    private func resetTalk() {
        talkTask?.cancel()
        talkPhase = .ready
        talkElapsed = 0
        talkShownLines = 0
        talkFrozen = false
    }
    
    private func toggleTalk() {
        switch talkPhase {
        case .ready:
            talkElapsed = 0
            talkShownLines = 0
            withAnimation(BranchMotion.sharedSpring) { talkPhase = .speaking }
            startTalkClock()
        case .speaking:
            finishTalk(family: TalkScript.family)
        case .writing:
            break
        }
    }
    
    private func startTalkClock() {
        talkTask?.cancel()
        talkTask = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 100_000_000)
                guard !Task.isCancelled, talkPhase == .speaking else { return }
                talkElapsed += 0.1 * TalkScript.speed
                let due = talkElapsed >= 2 ? min(TalkScript.lines.count, Int((talkElapsed - 2) / TalkScript.lineInterval) + 1) : 0
                if due > talkShownLines {
                    talkShownLines = due
                    announceTalkLine(TalkScript.lines[due - 1])
                }
                if talkElapsed >= TalkScript.totalSeconds {
                    // The script has ended (last line + a short pause): move on by itself.
                    finishTalk(family: TalkScript.family)
                    return
                }
            }
        }
    }
    
    private func announceTalkLine(_ line: String) {
        var text = AttributedString(line)
        text.accessibilitySpeechAnnouncementPriority = .low
        AccessibilityNotification.Announcement(text).post()
    }
    
    private func enterWriting() {
        talkTask?.cancel()
        withAnimation(BranchMotion.sharedSpring) { talkPhase = .writing }
    }
    
    private func leaveWriting() {
        resetTalk()
    }
    
    private func finishWriting() {
        guard !talkText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        finishTalk(family: TalkScript.family(forWritten: talkText))
    }
    
    private func finishTalk(family: ThinkingFamily) {
        talkTask?.cancel()
        cameFromTalk = true
        revealedFamily = family
        store.saveIntent(answers: [family], revealed: family)
        withAnimation(BranchMotion.sharedSpring) { currentStep = .reveal }
    }
    
    // MARK: Reveal
    private func celebrateReveal() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 650_000_000)
            guard currentStep == .reveal else { return }
            triggerSuccessFeedback()
            triggerDoubleBlink()
        }
    }
    
    private func cycleRevealedFamily() {
        let all = ThinkingFamily.allCases
        let next = all[((all.firstIndex(of: revealedFamily) ?? 0) + 1) % all.count]
        triggerSelectionFeedback()
        withAnimation(BranchMotion.quickSpring) { revealedFamily = next }
    }
    
    private func finishReveal() {
        activeSprite = revealedFamily.sprite
        // The Profile sprite is written only when the user commits on Reveal, not on every cycle.
        store.saveIntent(answers: store.quizAnswers, revealed: revealedFamily, updatesProfile: true)
        withAnimation(BranchMotion.sharedSpring) { currentStep = .integrations }
    }
    
    // MARK: Scripted autoplay (-autoplayOnboarding quiz|talk|skip)
    private func startAutoplayIfRequested() {
        let args = CommandLine.arguments
        guard let flag = args.firstIndex(of: "-autoplayOnboarding"), args.indices.contains(flag + 1) else { return }
        let mode = args[flag + 1]
        guard ["quiz", "talk", "skip"].contains(mode), autoplayTask == nil else { return }
        
        func pause(_ seconds: Double) async {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        }
        
        autoplayTask = Task { @MainActor in
            if currentStep == .signIn {
                await pause(1.6)
                guard !Task.isCancelled else { return }
                store.signIn(provider: .apple)
                await pause(1.4)
            }
            if currentStep == .profile {
                fullName = "Cash Palacio"
                nickname = "cashp"
                nicknameStatus = .available
                withAnimation(BranchMotion.sharedSpring) {
                    activeSprite = .prism
                    hasSelectedAvatar = true
                }
                await pause(1.6)
                guard !Task.isCancelled else { return }
                handleContinueTap()
            }
            await pause(2.8)
            guard !Task.isCancelled, currentStep == .intro else { return }
            
            switch mode {
            case "skip":
                skipIntent()
            case "talk":
                openTalk()
                await pause(1.6)
                toggleTalk()
                while currentStep == .talk && !Task.isCancelled { await pause(0.3) }
            default:
                startQuiz()
                for (q, pick) in [0, 0, 1].enumerated() {
                    await pause(1.3)
                    guard !Task.isCancelled, currentStep == .quiz, quizIndex == q else { return }
                    selectQuizAnswer(pick)
                    await pause(1.0)
                    // Reduce Motion disables the tap auto-advance; the script advances explicitly.
                    if reduceMotion, currentStep == .quiz, quizIndex == q { advanceQuiz() }
                }
            }
            
            if mode != "skip" {
                await pause(2.0)
                guard !Task.isCancelled, currentStep == .reveal else { return }
                cycleRevealedFamily()
                await pause(1.4)
                cycleRevealedFamily()
                await pause(1.4)
                cycleRevealedFamily()
                await pause(1.4)
                cycleRevealedFamily()
                await pause(1.6)
                finishReveal()
            }
            
            await pause(1.8)
            guard !Task.isCancelled, currentStep == .integrations else { return }
            for id in ["github", "pinterest", "printables"] where Integration.allSupported.contains(where: { $0.id == id }) {
                if let item = Integration.allSupported.first(where: { $0.id == id }) {
                    handleOrbTap(for: item)
                }
                await pause(1.2)
            }
            await pause(0.8)
            handleContinueTap()
            while currentSyncBeat != .beat4Complete && !Task.isCancelled { await pause(0.3) }
            await pause(1.5)
            handleContinueTap()
        }
    }
    
    // MARK: - Helpers
    private static func isStageStep(_ step: OnboardingStep) -> Bool {
        step == .integrations || step == .syncing || step == .complete
    }
    
    private func updateSpriteLanding(to step: OnboardingStep) {
        landingTask?.cancel()
        guard Self.isStageStep(step) else {
            var t = Transaction(); t.disablesAnimations = true
            withTransaction(t) { spriteLanded = false }
            return
        }
        guard !spriteLanded else { return }
        landingTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 480_000_000)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.30)) { spriteLanded = true }
        }
    }
    
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
