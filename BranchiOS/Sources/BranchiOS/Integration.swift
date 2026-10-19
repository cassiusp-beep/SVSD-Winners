import Foundation

public enum IntegrationCategory: String, CaseIterable, Sendable, Codable {
    case referential = "Referential"
    case design = "Design"
    case models = "Models"
    case code = "Code"
    case docsAndResearch = "Docs and research"
    case ideation = "Ideation"
    case showcase = "Showcase"
}

public struct Integration: Identifiable, Sendable, Codable, Equatable, Hashable {
    public let id: String
    public let name: String
    public let logoAssetName: String
    public let initial: String
    public let category: IntegrationCategory
    
    public init(
        id: String,
        name: String,
        logoAssetName: String,
        initial: String,
        category: IntegrationCategory
    ) {
        self.id = id
        self.name = name
        self.logoAssetName = logoAssetName
        self.initial = initial
        self.category = category
    }
}

public extension Integration {
    static let allSupported: [Integration] = [
        // Row 1 (Frame 2): Autodesk Fusion (angled shape), Behance, Figma, GitHub
        Integration(id: "autodesk_fusion", name: "Autodesk Fusion", logoAssetName: "logo_autodesk_fusion", initial: "AF", category: .models),
        Integration(id: "behance", name: "Behance", logoAssetName: "logo_behance", initial: "B", category: .showcase),
        Integration(id: "figma", name: "Figma", logoAssetName: "logo_figma", initial: "F", category: .design),
        Integration(id: "github", name: "GitHub", logoAssetName: "logo_github", initial: "G", category: .code),
        
        // Row 2 (Frame 2): Google Drive, Miro, Pinterest, Printables
        Integration(id: "google_drive", name: "Google Drive", logoAssetName: "logo_google_drive", initial: "GD", category: .docsAndResearch),
        Integration(id: "miro", name: "Miro", logoAssetName: "logo_miro", initial: "M", category: .ideation),
        Integration(id: "pinterest", name: "Pinterest", logoAssetName: "logo_pinterest", initial: "P", category: .referential),
        Integration(id: "printables", name: "Printables", logoAssetName: "logo_printables", initial: "P", category: .models),
        
        // Row 3 (Frame 2): Thingiverse (T), Are.na (**), Cosmos (dots), Onshape (cube)
        Integration(id: "thingiverse", name: "Thingiverse", logoAssetName: "logo_thingiverse", initial: "T", category: .models),
        Integration(id: "arena", name: "Are.na", logoAssetName: "logo_arena", initial: "A", category: .referential),
        Integration(id: "cosmos", name: "Cosmos", logoAssetName: "logo_cosmos", initial: "C", category: .referential),
        Integration(id: "onshape", name: "Onshape", logoAssetName: "logo_onshape", initial: "O", category: .models),
        
        // Page 2: Savee (S)
        Integration(id: "savee", name: "Savee", logoAssetName: "logo_savee", initial: "S", category: .referential)
    ]
}
