import SwiftUI
import PhotosUI

#if canImport(UIKit)
import UIKit
#endif

// Note: CMYKSprite and DomeSpriteView are canonically provided in SpriteView.swift


// MARK: - Redesigned ProfileSetupView
public struct ProfileSetupView: View {
    @Bindable var store: DemoStore = DemoStore.shared
    public var isEditing: Bool = false
    public var onSaveCompleted: (() -> Void)? = nil
    
    // Core Identity State
    @State private var fullName: String = ""
    @State private var nickname: String = ""
    @State private var avatarType: AvatarType = .sprite
    @State private var activeSprite: CMYKSprite = .cyan
    
    // Photo Picker State
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    #if canImport(UIKit)
    @State private var localPhotoImage: UIImage? = nil
    #endif
    @State private var isPhotoLoading: Bool = false
    @State private var photoErrorMessage: String? = nil
    
    @State private var hasSelectedAvatar: Bool = false
    
    // Inline Name Editing Toggle
    @State private var isEditingNamesInline: Bool = false
    private enum FocusField: Hashable {
        case fullName, nickname
    }
    @FocusState private var focusedField: FocusField?
    
    // Live Nickname Validation
    @State private var nicknameStatus: DemoStore.NicknameStatus = .empty
    @State private var validationTask: Task<Void, Never>? = nil
    
    // Blinking Interaction
    @State private var isSpriteBlinking: Bool = false
    @State private var blinkTimer: Timer? = nil
    
    // Gesture & Motion
    @State private var spriteDragOffset: CGFloat = 0
    @State private var spriteTapBounce: Bool = false
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    
    private let avatarCircleDiameter: CGFloat = 96
    
    public init(
        store: DemoStore = DemoStore.shared,
        isEditing: Bool = false,
        onSaveCompleted: (() -> Void)? = nil
    ) {
        self.store = store
        self.isEditing = isEditing
        self.onSaveCompleted = onSaveCompleted
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            // STRICT RULE: Plain background, white in light, black in dark
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
            // Main Content Stack (Large intentional negative space)
            VStack(spacing: 0) {
                // Top Marquee Banner sits below status bar
                UsernameBanner(nickname: nickname.trimmingCharacters(in: .whitespacesAndNewlines))
                    .opacity(nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 1)
                    .animation(.easeInOut(duration: 0.25), value: nickname.isEmpty)
                
                // Top Navigation Bar (ContinueButton placed strictly BELOW the banner)
                topNavigationBar
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                
                Spacer(minLength: 16)
                
                // CENTER: Avatar Circle & Name Identity Hub
                centerIdentityHub
                
                Spacer(minLength: 16)
                
                // PROFILE SETUP: Circular Arrow Button
                // Centered horizontally, vertically centered in empty space between name block and "Sprite Selection"
                circularArrowButton
                
                Spacer(minLength: 16)
                
                // "Sprite Selection" label
                Text("Sprite Selection")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.secondary.opacity(0.8))
                    .padding(.bottom, 12)
                
                // BOTTOM: Large Swipeable Dome Sprite flush with bottom edge
                bottomDomeSpriteArea
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
            if !fullName.isEmpty || !nickname.isEmpty {
                isEditingNamesInline = false
            }
        }
        .onAppear {
            setupInitialState()
            startBlinkLoop()
        }
        .onDisappear {
            blinkTimer?.invalidate()
        }
    }
    
    // MARK: - Top Navigation Bar
    private var topNavigationBar: some View {
        HStack {
            if isEditing {
                Button("Cancel") {
                    dismiss()
                }
                .font(.system(.body, design: .default, weight: .regular))
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            ContinueButton(
                title: isEditing ? "Done" : "Continue",
                isEnabled: isContinueEnabled,
                disabledHint: "Enter your name and nickname to continue"
            ) {
                saveAndProceed()
            }
        }
    }
    
    // MARK: - Circular Arrow Button (Primary Navigation)
    private var circularArrowButton: some View {
        Button(action: {
            if isContinueEnabled {
                #if os(iOS)
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                #endif
                saveAndProceed()
            }
        }) {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ? Color(white: 0.22) : Color.white)
                    .overlay(
                        Circle()
                            .stroke(
                                colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.07),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: isContinueEnabled
                            ? Color.black.opacity(colorScheme == .dark ? 0.35 : 0.15)
                            : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.primary)
            }
            .frame(width: 56, height: 56)
            .opacity(isContinueEnabled ? 1.0 : 0.25)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isContinueEnabled)
        }
        .disabled(!isContinueEnabled)
        .accessibilityLabel("Continue to Integrations")
        .accessibilityHint(isContinueEnabled ? "" : "Enter your name and nickname to continue")
    }
    
    // MARK: - Center Identity Hub
    private var centerIdentityHub: some View {
        VStack(spacing: 12) {
            // 96pt Avatar Circle
            avatarCircleView
            
            // Name & Nickname Displays / Minimal Inline Input
            if isEditingNamesInline {
                inlineNameEditorView
            } else if fullName.isEmpty && nickname.isEmpty {
                // Frame 1 Empty State: "Name?" placeholder
                Text("Name?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.primary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            isEditingNamesInline = true
                            focusedField = .nickname
                        }
                    }
                    .accessibilityHint("Tap to enter your name and nickname")
            } else {
                formattedNameLabelsView
            }
            
            // Understated Validation Feedback
            validationFeedbackCaption
        }
    }
    
    // MARK: - Avatar Circle
    private var avatarCircleView: some View {
        PhotosPicker(
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                // Background & Thin hairline gray ring
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
                    } else {
                        emptyPlusIcon
                    }
                    #endif
                } else if isSpriteChosen {
                    // Frame 4: Selected Sprite rising from bottom, clipped to circle
                    VStack {
                        Spacer()
                        DomeSpriteView(sprite: activeSprite, isBlinking: isSpriteBlinking)
                            .frame(width: 82, height: 72)
                            .offset(y: 8)
                    }
                    .frame(width: avatarCircleDiameter, height: avatarCircleDiameter)
                    .clipShape(Circle())
                } else {
                    // Frame 1 Empty State: Gray circle with thin '+'
                    emptyPlusIcon
                }
                
                if isPhotoLoading {
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: avatarCircleDiameter, height: avatarCircleDiameter)
                        .overlay(
                            ProgressView()
                                .tint(.white)
                        )
                }
                
                // Thin gray perimeter ring
                Circle()
                    .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                    .frame(width: avatarCircleDiameter, height: avatarCircleDiameter)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(avatarType == .photo ? "Profile photo" : "\(activeSprite.rawValue) sprite avatar")
        .accessibilityHint("Double tap to choose photo or tap bottom sprite to choose sprite")
        .onChange(of: selectedPhotoItem) { _, newItem in
            handlePhotoSelected(newItem)
        }
    }
    
    private var emptyPlusIcon: some View {
        Image(systemName: "plus")
            .font(.system(size: 26, weight: .ultraLight))
            .foregroundStyle(Color.gray.opacity(0.85))
    }
    
    private var isSpriteChosen: Bool {
        hasSelectedAvatar && avatarType == .sprite
    }
    
    // MARK: - Name Display & Minimal Inline Editing
    private var formattedNameLabelsView: some View {
        VStack(spacing: 4) {
            Text("@\(nickname.isEmpty ? "nickname" : nickname)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(fullName.isEmpty ? "Your Name" : fullName)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                isEditingNamesInline = true
                focusedField = .nickname
            }
        }
        .accessibilityHint("Double tap to edit name and nickname")
    }
    
    private var inlineNameEditorView: some View {
        VStack(spacing: 8) {
            HStack(spacing: 2) {
                Text("@")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.secondary)
                
                TextField("nickname", text: $nickname)
                    .font(.system(size: 20, weight: .bold))
                    .focused($focusedField, equals: .nickname)
                    .submitLabel(.next)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
                    .autocorrectionDisabled()
                    .onSubmit {
                        focusedField = .fullName
                    }
                    .onChange(of: nickname) { _, newValue in
                        validateNicknameLive(newValue)
                    }
            }
            .frame(maxWidth: 220)
            .multilineTextAlignment(.center)
            
            TextField("Full Name", text: $fullName)
                .font(.system(size: 15, weight: .regular))
                .focused($focusedField, equals: .fullName)
                .submitLabel(.done)
                .autocorrectionDisabled()
                .multilineTextAlignment(.center)
                .onSubmit {
                    focusedField = nil
                    if !nickname.isEmpty && !fullName.isEmpty {
                        isEditingNamesInline = false
                    }
                }
                .frame(maxWidth: 220)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var validationFeedbackCaption: some View {
        switch nicknameStatus {
        case .empty:
            if fullName.isEmpty && nickname.isEmpty {
                Text("Tap to enter name & nickname")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
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
        case .available:
            EmptyView()
        }
    }
    
    // MARK: - Bottom Large Dome Sprite Area
    private var bottomDomeSpriteArea: some View {
        let allSprites = CMYKSprite.allCases
        let currentIndex = allSprites.firstIndex(of: activeSprite) ?? 0
        
        return GeometryReader { geo in
            let domeWidth = min(geo.size.width * 0.72, 300)
            let domeHeight = domeWidth * 0.88
            
            ZStack(alignment: .bottom) {
                // Large Dome cut off by the bottom screen edge
                DomeSpriteView(sprite: activeSprite, isBlinking: isSpriteBlinking)
                    .frame(width: domeWidth, height: domeHeight)
                    .offset(y: domeHeight * 0.22) // Cut off bottom so only dome & eyes show
                    .offset(x: spriteDragOffset)
                    .scaleEffect(spriteTapBounce ? 0.94 : 1.0, anchor: UnitPoint.bottom)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectCurrentSpriteForAvatar()
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                spriteDragOffset = value.translation.width * 0.4
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 40
                                withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                                    if value.translation.width < -threshold {
                                        // Swipe Left -> Next Sprite
                                        let nextIndex = (currentIndex + 1) % allSprites.count
                                        activeSprite = allSprites[nextIndex]
                                        triggerSelectionFeedback()
                                    } else if value.translation.width > threshold {
                                        // Swipe Right -> Prev Sprite
                                        let prevIndex = (currentIndex - 1 + allSprites.count) % allSprites.count
                                        activeSprite = allSprites[prevIndex]
                                        triggerSelectionFeedback()
                                    }
                                    spriteDragOffset = 0
                                }
                            }
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(height: 180)
    }
    
    // MARK: - Actions & Logic
    private func selectCurrentSpriteForAvatar() {
        avatarType = .sprite
        hasSelectedAvatar = true
        triggerImpactFeedback()
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            spriteTapBounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                spriteTapBounce = false
            }
        }
    }
    
    private func handlePhotoSelected(_ item: PhotosPickerItem?) {
        guard let item else { return }
        isPhotoLoading = true
        photoErrorMessage = nil
        
        Task { @MainActor in
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    #if canImport(UIKit)
                    if let image = UIImage(data: data) {
                        self.localPhotoImage = image
                        self.avatarType = .photo
                        self.hasSelectedAvatar = true
                        self.isPhotoLoading = false
                        self.triggerSelectionFeedback()
                        return
                    }
                    #endif
                }
                self.photoErrorMessage = "Could not load photo."
            } catch {
                self.photoErrorMessage = error.localizedDescription
            }
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
        
        let formatResult = DemoStore.validateNicknameFormat(trimmed)
        if case .invalidFormat = formatResult {
            nicknameStatus = formatResult
            return
        }
        
        if isEditing, let cur = store.profile?.nickname, cur.lowercased() == trimmed.lowercased() {
            nicknameStatus = .available
            return
        }
        
        nicknameStatus = .checking
        validationTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            
            if DemoStore.takenNicknames.contains(trimmed.lowercased()) {
                self.nicknameStatus = .taken(trimmed)
            } else {
                self.nicknameStatus = .available
            }
        }
    }
    
    private var isContinueEnabled: Bool {
        let isNameFilled = !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isNickValid = nicknameStatus == .available
        let isAvatarReady = hasSelectedAvatar
        
        return isNameFilled && isNickValid && isAvatarReady
    }
    
    private func setupInitialState() {
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
            self.isEditingNamesInline = false
        } else {
            self.hasSelectedAvatar = false
            self.isEditingNamesInline = false
        }
    }
    
    private func startBlinkLoop() {
        guard !reduceMotion else { return }
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 3.8, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.12)) {
                    isSpriteBlinking = true
                }
                try? await Task.sleep(nanoseconds: 140_000_000)
                withAnimation(.easeInOut(duration: 0.12)) {
                    isSpriteBlinking = false
                }
            }
        }
    }
    
    private func saveAndProceed() {
        #if canImport(UIKit)
        store.saveProfile(
            fullName: fullName,
            nickname: nickname,
            avatarType: avatarType,
            spriteColorHex: activeSprite.hex,
            photoImage: localPhotoImage
        )
        #endif
        
        triggerSuccessFeedback()
        
        if isEditing {
            dismiss()
        } else {
            onSaveCompleted?()
        }
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

// MARK: - Previews
#Preview("ProfileSetup - Light") {
    ProfileSetupView(store: DemoStore(), isEditing: false)
        .preferredColorScheme(.light)
}

#Preview("ProfileSetup - Dark") {
    ProfileSetupView(store: DemoStore(), isEditing: false)
        .preferredColorScheme(.dark)
}

#Preview("ProfileSetup - Accessibility 3") {
    ProfileSetupView(store: DemoStore(), isEditing: false)
        .environment(\.dynamicTypeSize, .accessibility3)
}
