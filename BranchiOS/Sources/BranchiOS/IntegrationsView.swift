import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct IntegrationsView: View {
    @Bindable var store: DemoStore
    
    // Search & Filter State
    @State private var searchText: String = ""
    @State private var currentPage: Int = 0
    
    // Connection Ring Animation Task
    @State private var connectingIntegrationId: String? = nil
    @State private var connectionProgress: CGFloat = 0
    @State private var connectionTask: Task<Void, Never>? = nil
    
    // Sprite State (Natural subtle blink)
    @State private var isSpriteBlinking: Bool = false
    @State private var blinkTimer: Timer? = nil
    
    // Swipe Up Detection
    @State private var swipeUpOffset: CGFloat = 0
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(store: DemoStore = DemoStore.shared) {
        self.store = store
    }
    
    // Resolved Active Sprite
    private var activeSprite: CMYKSprite {
        if let hex = store.profile?.spriteColorHex {
            return CMYKSprite.from(hex: hex)
        }
        return .cyan
    }
    
    // Accent Color for user's sprite
    private var accentColor: Color {
        activeSprite.color(for: colorScheme)
    }
    
    // Progress Ring Color (matches prompt rule)
    private var progressRingColor: Color {
        if store.profile?.avatarType == .photo {
            return colorScheme == .dark ? Color.white : Color.black
        }
        if activeSprite == .key {
            return colorScheme == .dark ? Color(white: 0.78) : Color(white: 0.22)
        }
        return activeSprite.color(for: colorScheme)
    }
    
    // Supported Integrations in Canonical Order
    private var allIntegrations: [Integration] {
        Integration.allSupported
    }
    
    // Filtered integrations based on search text
    private var filteredIntegrations: [Integration] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return allIntegrations }
        return allIntegrations.filter {
            $0.name.lowercased().contains(query) ||
            $0.category.rawValue.lowercased().contains(query)
        }
    }
    
    // Slices for Paged Grid (12 per page)
    private var page1Items: [Integration] {
        Array(filteredIntegrations.prefix(12))
    }
    
    private var page2Items: [Integration] {
        Array(filteredIntegrations.dropFirst(12))
    }
    
    // Most Recently Connected Integrations (for juggling)
    private var recentlyConnectedForJuggle: [Integration] {
        let connectedSet = store.connectedIntegrationIds
        return allIntegrations
            .filter { connectedSet.contains($0.id) }
            .sorted { (a, b) -> Bool in
                let dateA = store.connectedTimestamps[a.id] ?? .distantPast
                let dateB = store.connectedTimestamps[b.id] ?? .distantPast
                return dateA > dateB
            }
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack(alignment: .top) {
            // Plain background: white in light mode, black in dark mode
            (colorScheme == .dark ? Color.black : Color.white)
                .ignoresSafeArea()
            
            // Main Top-Down Composition (strictly ordered from Figma frames)
            VStack(spacing: 0) {
                // Top Marquee Banner (same size, position, speed, and color on every screen)
                UsernameBanner(nickname: store.profile?.nickname ?? "branch")
                
                // Top Row: Shared ContinueButton below banner, right-aligned to content margin
                HStack {
                    Spacer()
                    ContinueButton(
                        title: "Continue",
                        isEnabled: true
                    ) {
                        advanceToNextStep()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                
                // Search Field: Plain text with single thin gray underline spanning content width
                searchUnderlineField
                    .padding(.horizontal, 26)
                    .padding(.top, 4)
                
                // Guidance Copy: Small body text, subheadline size, regular weight, only "integrations" bold italic
                guidanceCopyView
                    .padding(.horizontal, 26)
                    .padding(.top, 10)
                
                // "Supported" label in small semibold gray, left-aligned on same margin
                Text("Supported")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? Color(white: 0.65) : Color(white: 0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 26)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                
                // Integrations Paged Grid Area (4 columns, tall enough for 3 rows + shadows without clipping)
                gridContentSection
                
                // Balanced vertical spacing between top and bottom halves
                Spacer(minLength: 8)
                
                // "Swipe up to complete this part." (centered, bold, on its own with space around it, NO chevron)
                swipeUpPromptView
                    .padding(.bottom, 4)
                
                // "Connected" label in small semibold gray, left-aligned on same margin as "Supported"
                Text("Connected")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? Color(white: 0.65) : Color(white: 0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 26)
                    .padding(.bottom, 4)
                
                // Bottom Sprite + Juggling Stage (open space between "Connected" and sprite)
                bottomSpriteJuggleStage
                    .frame(height: 154)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            startBlinkLoop()
        }
        .onDisappear {
            blinkTimer?.invalidate()
            connectionTask?.cancel()
        }
    }
    
    // MARK: - Search Underline Field
    private var searchUnderlineField: some View {
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
                
                // Clear search "✕" button
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        currentPage = 0
                        triggerSelectionFeedback()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            
            // Single thin gray underline spanning content width
            Rectangle()
                .fill(colorScheme == .dark ? Color.white.opacity(0.20) : Color.black.opacity(0.18))
                .frame(height: 1)
        }
    }
    
    // MARK: - Guidance Copy
    private var guidanceCopyView: some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel("Select which integrations you'd want to import.")
    }
    
    // MARK: - Grid Content Section
    @ViewBuilder
    private var gridContentSection: some View {
        if filteredIntegrations.isEmpty {
            VStack {
                Spacer()
                Text("No matches")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
            .frame(height: 240)
            .frame(maxWidth: .infinity)
        } else if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // When actively searching, show matched items directly
            pageGridView(for: filteredIntegrations)
                .frame(height: 240)
        } else {
            // Paged horizontal presentation (12 on Page 1, 1 on Page 2)
            VStack(spacing: 6) {
                TabView(selection: $currentPage) {
                    pageGridView(for: page1Items)
                        .tag(0)
                    
                    if !page2Items.isEmpty {
                        pageGridView(for: page2Items)
                            .tag(1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 240)
                
                // Minimal page indicator dots (shown only when > 1 page)
                if !page2Items.isEmpty {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(currentPage == 0 ? Color.primary : Color.secondary.opacity(0.3))
                            .frame(width: 5, height: 5)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    currentPage = 0
                                }
                            }
                        
                        Circle()
                            .fill(currentPage == 1 ? Color.primary : Color.secondary.opacity(0.3))
                            .frame(width: 5, height: 5)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    currentPage = 1
                                }
                            }
                    }
                    .padding(.top, 2)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Page \(currentPage + 1) of 2")
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
                        if item.id != row.first?.id {
                            Spacer()
                        }
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
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Orb Item Component
    private func orbItemView(for item: Integration) -> some View {
        let isConnected = store.connectedIntegrationIds.contains(item.id)
        let isConnecting = connectingIntegrationId == item.id
        
        return IntegrationOrbView(
            integration: item,
            isConnected: isConnected,
            isConnecting: isConnecting,
            connectionProgress: connectionProgress,
            accentColor: progressRingColor,
            onToggle: {
                handleOrbTap(for: item)
            }
        )
    }
    
    // MARK: - Orb Tap & 1.0s Connection Simulation
    private func handleOrbTap(for item: Integration) {
        if store.connectedIntegrationIds.contains(item.id) {
            // Already connected: toggle off with light haptic
            store.toggleIntegration(item.id)
            triggerSelectionFeedback()
        } else {
            // Start 1.0s connection simulation
            triggerSelectionFeedback()
            connectingIntegrationId = item.id
            connectionProgress = 0
            
            connectionTask?.cancel()
            connectionTask = Task { @MainActor in
                let totalSteps = 20
                for step in 1...totalSteps {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                    guard !Task.isCancelled else { return }
                    self.connectionProgress = CGFloat(step) / CGFloat(totalSteps)
                }
                guard !Task.isCancelled else { return }
                self.store.toggleIntegration(item.id)
                self.connectingIntegrationId = nil
                self.connectionProgress = 0
                self.triggerSuccessFeedback()
            }
        }
    }
    
    // MARK: - Swipe Up Prompt
    private var swipeUpPromptView: some View {
        Text("Swipe up to complete this part.")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Color.primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            .contentShape(Rectangle())
            // Approved Addition: Tap fallback to advance
            .onTapGesture {
                advanceToNextStep()
            }
            // Vertical Drag / Swipe Up Gesture Recognizer
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height < 0 {
                            swipeUpOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height < -40 {
                            advanceToNextStep()
                        }
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            swipeUpOffset = 0
                        }
                    }
            )
    }
    
    // MARK: - Bottom Sprite + Juggling Stage
    private var bottomSpriteJuggleStage: some View {
        JuggleView(
            connectedIntegrations: recentlyConnectedForJuggle,
            userProfile: store.profile,
            activeSprite: activeSprite,
            accentColor: accentColor,
            isBlinking: isSpriteBlinking
        )
    }
    
    // MARK: - Navigation Action
    private func advanceToNextStep() {
        store.completeIntegrationsStep()
        triggerSuccessFeedback()
    }
    
    // MARK: - Animation Loops
    private func startBlinkLoop() {
        guard !reduceMotion else { return }
        blinkTimer?.invalidate()
        blinkTimer = Timer.scheduledTimer(withTimeInterval: 4.2, repeats: true) { _ in
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
    
    // MARK: - Haptic Feedback Helpers
    private func triggerSelectionFeedback() {
        #if canImport(UIKit)
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        #endif
    }
    
    private func triggerSuccessFeedback() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
    }
}

// MARK: - Previews
#Preview("IntegrationsView - Light Zero Connected") {
    let store = DemoStore()
    store.session = UserSession(providerName: "Apple")
    store.profile = UserProfile(fullName: "Cassius", nickname: "Cash", avatarType: .sprite, spriteColorHex: "#26C6DA")
    return IntegrationsView(store: store)
}

#Preview("IntegrationsView - Dark 5 Connected") {
    let store = DemoStore()
    store.session = UserSession(providerName: "Apple")
    store.profile = UserProfile(fullName: "Cassius", nickname: "Cash", avatarType: .sprite, spriteColorHex: "#E91E63")
    store.toggleIntegration("pinterest")
    store.toggleIntegration("arena")
    store.toggleIntegration("figma")
    store.toggleIntegration("github")
    store.toggleIntegration("miro")
    return IntegrationsView(store: store)
        .preferredColorScheme(.dark)
}

// MARK: - Array Chunk Helper
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
