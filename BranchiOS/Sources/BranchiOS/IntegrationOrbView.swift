import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct IntegrationOrbView: View {
    public let integration: Integration
    public let isConnected: Bool
    public let isConnecting: Bool
    public let connectionProgress: CGFloat
    public let accentColor: Color
    public let onToggle: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    public init(
        integration: Integration,
        isConnected: Bool,
        isConnecting: Bool = false,
        connectionProgress: CGFloat = 0,
        accentColor: Color = Color(red: 0.15, green: 0.78, blue: 0.85),
        onToggle: @escaping () -> Void
    ) {
        self.integration = integration
        self.isConnected = isConnected
        self.isConnecting = isConnecting
        self.connectionProgress = connectionProgress
        self.accentColor = accentColor
        self.onToggle = onToggle
    }
    
    private var isDarkMonochromeLogo: Bool {
        let id = integration.id
        return id == "autodesk_fusion" || id == "github" || id == "arena" || id == "cosmos" || id == "savee" || id == "thingiverse"
    }
    
    private var orbFillColor: Color {
        if colorScheme == .dark {
            return isDarkMonochromeLogo ? Color(white: 0.26) : Color(white: 0.22)
        } else {
            return Color.white
        }
    }
    
    public var body: some View {
        Button(action: onToggle) {
            ZStack {
                // Orb circular base
                Circle()
                    .fill(orbFillColor)
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
                        color: isConnected
                        ? Color.black.opacity(colorScheme == .dark ? 0.50 : 0.28)
                        : Color.black.opacity(colorScheme == .dark ? 0.35 : 0.16),
                        radius: isConnected ? 8 : 5,
                        x: 0,
                        y: isConnected ? 5 : 2
                    )
                
                // Connecting progress ring
                if isConnecting {
                    Circle()
                        .trim(from: 0, to: connectionProgress)
                        .stroke(
                            accentColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .padding(2)
                }
                
                // Service Logo Image / Fallback Initial
                logoView
            }
            .frame(width: 62, height: 62)
            .scaleEffect(isConnecting ? 1.05 : 1.0)
            .opacity(isConnected || isConnecting ? 1.0 : (colorScheme == .dark && isDarkMonochromeLogo ? 0.35 : 0.25))
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(integration.name) integration")
        .accessibilityValue(isConnected ? "Connected" : (isConnecting ? "Connecting" : "Not connected"))
        .accessibilityHint(isConnected ? "Double tap to disconnect" : "Double tap to connect")
    }
    
    @ViewBuilder
    private var logoView: some View {
        if let image = resolvedLogoImage {
            if colorScheme == .dark && isDarkMonochromeLogo {
                image
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.white)
                    .frame(width: 32, height: 32)
            } else {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        } else {
            fallbackInitialView
        }
    }
    
    private var resolvedLogoImage: Image? {
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
    
    private var fallbackInitialView: some View {
        Text(integration.initial)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(isConnected ? accentColor : Color.secondary)
    }
}

