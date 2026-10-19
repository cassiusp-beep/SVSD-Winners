import SwiftUI
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit

// MARK: - Capture Cluster (Camera · Record · Paste)
/// The primary Session control: take a photo, start or stop a session, paste a link or image.
/// Photos and links join the active project (and the live session when one is running).
public struct CaptureCluster: View {
    public let isLive: Bool
    public let elapsedSeconds: Double
    public let onRecordTap: () -> Void
    public let onCapture: (DemoStore.CaptureContent, String) -> Void
    public let onEmptyPaste: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingCamera: Bool = false
    @State private var clipboardHasContent: Bool = false

    public static let width: CGFloat = 48 + 16 + 64 + 16 + 48

    public init(
        isLive: Bool,
        elapsedSeconds: Double,
        onRecordTap: @escaping () -> Void,
        onCapture: @escaping (DemoStore.CaptureContent, String) -> Void,
        onEmptyPaste: @escaping () -> Void
    ) {
        self.isLive = isLive
        self.elapsedSeconds = elapsedSeconds
        self.onRecordTap = onRecordTap
        self.onCapture = onCapture
        self.onEmptyPaste = onEmptyPaste
    }

    public var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 16) {
                cameraButton
                recordButton
                pasteControl
            }

            Text(isLive ? Self.format(elapsedSeconds) : "Start session")
                .font(Font.yaya(size: 13, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .allowsHitTesting(false)
                .accessibilityHidden(!isLive)
                .accessibilityLabel("Elapsed time \(Self.format(elapsedSeconds))")
        }
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker { image in
                isShowingCamera = false
                if let image {
                    onCapture(.image(image), "CAMERA")
                }
            }
            .ignoresSafeArea()
        }
        .onAppear { refreshClipboard() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refreshClipboard() }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIPasteboard.changedNotification)) { _ in
            refreshClipboard()
        }
    }

    static func format(_ seconds: Double) -> String {
        let total = max(0, Int(seconds))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    // MARK: Camera
    private var cameraButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            isShowingCamera = true
        } label: {
            Image(systemName: "camera.fill")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 48, height: 48)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: Circle())
        .accessibilityLabel("Take a photo")
    }

    // MARK: Record
    private var recordButton: some View {
        RecordButton(
            symbol: isLive ? "stop.fill" : "play.fill",
            symbolOffset: isLive ? 0 : 2,
            accessibilityLabel: isLive ? "Stop session" : "Start session",
            action: onRecordTap
        )
    }

    // MARK: Paste
    @ViewBuilder
    private var pasteControl: some View {
        if clipboardHasContent {
            PasteButton(supportedContentTypes: [.image, .url, .plainText]) { providers in
                handlePaste(providers)
            }
            .labelStyle(.iconOnly)
            .buttonBorderShape(.circle)
            .tint(Color(.systemGray5))
            .foregroundStyle(.primary)
            .frame(width: 48, height: 48)
            .accessibilityLabel("Paste a link or image")
        } else {
            // Look-alike for an empty clipboard: the system PasteButton greys itself out silently,
            // so this explains what to do instead. It never reads the pasteboard, so no paste prompt.
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onEmptyPaste()
            } label: {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 48, height: 48)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: Circle())
            .accessibilityLabel("Paste a link or image")
            .accessibilityHint("Clipboard is empty. Copy a link or image first.")
        }
    }

    private func refreshClipboard() {
        let board = UIPasteboard.general
        clipboardHasContent = board.hasImages || board.hasURLs || board.hasStrings
    }

    private func handlePaste(_ providers: [NSItemProvider]) {
        guard let provider = providers.first else {
            onEmptyPaste()
            return
        }
        Task { @MainActor in
            if let content = await Self.content(from: provider) {
                onCapture(content, "PASTED")
            } else {
                onEmptyPaste()
            }
        }
    }

    @MainActor
    private static func content(from provider: NSItemProvider) async -> DemoStore.CaptureContent? {
        if provider.canLoadObject(ofClass: UIImage.self) {
            let image: UIImage? = await withCheckedContinuation { continuation in
                _ = provider.loadObject(ofClass: UIImage.self) { object, _ in
                    continuation.resume(returning: object as? UIImage)
                }
            }
            if let image { return .image(image) }
        }
        if provider.canLoadObject(ofClass: URL.self) {
            let url: URL? = await withCheckedContinuation { continuation in
                _ = provider.loadObject(ofClass: URL.self) { object, _ in
                    continuation.resume(returning: object)
                }
            }
            if let url, url.scheme?.hasPrefix("http") == true { return .link(url) }
        }
        if provider.canLoadObject(ofClass: String.self) {
            let string: String? = await withCheckedContinuation { continuation in
                _ = provider.loadObject(ofClass: String.self) { object, _ in
                    continuation.resume(returning: object)
                }
            }
            if let string, let url = Self.url(fromText: string) { return .link(url) }
        }
        return nil
    }

    /// Accepts a URL copied as plain text (Notes, Messages). Bare domains get https://.
    static func url(fromText text: String) -> URL? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains(" "), !trimmed.contains("\n") else { return nil }
        if let url = URL(string: trimmed), let scheme = url.scheme?.lowercased(),
           scheme == "http" || scheme == "https", url.host() != nil {
            return url
        }
        if trimmed.contains("."), let url = URL(string: "https://\(trimmed)"), let host = url.host(),
           host.contains("."), !host.hasPrefix("."), !host.hasSuffix(".") {
            return url
        }
        return nil
    }
}

// MARK: - Camera Picker
/// UIImagePickerController wrapper: camera on device, photo library on Simulator.
struct CameraPicker: UIViewControllerRepresentable {
    let onFinish: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onFinish: (UIImage?) -> Void

        init(onFinish: @escaping (UIImage?) -> Void) {
            self.onFinish = onFinish
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            onFinish(info[.originalImage] as? UIImage)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onFinish(nil)
        }
    }
}

// MARK: - Capture Toast
public struct CaptureToastItem: Identifiable, Equatable {
    public let id = UUID()
    public let message: String
    public let thumbnail: UIImage?
    public let isLink: Bool
    public let isHint: Bool
    public var entryID: String? = nil

    public static func == (lhs: CaptureToastItem, rhs: CaptureToastItem) -> Bool { lhs.id == rhs.id }
}

public struct CaptureToast: View {
    public let item: CaptureToastItem

    public var body: some View {
        HStack(spacing: 10) {
            if let thumbnail = item.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            } else {
                Image(systemName: item.isLink ? "link" : "doc.on.clipboard")
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 28, height: 28)
            }

            Text(item.message)
                .font(.system(size: 15, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(.primary)
        .padding(.leading, 10)
        .padding(.trailing, 16)
        .padding(.vertical, 8)
        .glassEffect(.regular, in: Capsule())
        .overlay(Capsule().stroke(Color.primary.opacity(0.12), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.message)
        .accessibilityAddTraits(item.isHint ? [] : .isButton)
    }
}
#endif
