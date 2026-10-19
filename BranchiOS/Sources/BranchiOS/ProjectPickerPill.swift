import SwiftUI

// MARK: - "Recording to" Project Picker
/// Top-left control on the Session screen. Tappable while ready; locked (static, no chevron) while live.
public struct ProjectPickerPill: View {
    @Bindable var store: DemoStore
    public let isLocked: Bool
    
    public init(store: DemoStore, isLocked: Bool) {
        self.store = store
        self.isLocked = isLocked
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("RECORDING TO")
                .font(Font.yaya(size: 12, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            
            if isLocked {
                pill(showsChevron: false)
                    .allowsHitTesting(false)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Recording to \(store.activeProject.name)")
            } else {
                Menu {
                    Picker("Recording to", selection: $store.activeProjectID) {
                        ForEach(DemoProject.all) { project in
                            Text(project.name).tag(project.id)
                        }
                    }
                    .pickerStyle(.inline)
                } label: {
                    pill(showsChevron: true)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: store.activeProjectID)
                .accessibilityLabel("Recording to \(store.activeProject.name)")
                .accessibilityHint("Choose a project")
            }
        }
    }
    
    private func pill(showsChevron: Bool) -> some View {
        HStack(spacing: 8) {
            Text(store.activeProject.name)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            if showsChevron {
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(minHeight: 44)
        .background(Capsule().fill(Color(.systemBackground)))
        .overlay(Capsule().stroke(Color.primary.opacity(0.15), lineWidth: 1))
        .contentShape(Capsule())
    }
}
