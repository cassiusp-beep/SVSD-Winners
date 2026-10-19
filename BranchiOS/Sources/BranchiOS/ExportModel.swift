import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Scope and format

/// What an export covers. `.session` is the session that just ended (Takeaways); `.project` is one project (Insights).
public enum ExportScope: Equatable, Sendable {
    case session
    case project(String)
}

public enum ExportFormat: String, CaseIterable, Identifiable, Sendable {
    case map, video, package
    
    public var id: String { rawValue }
    
    var title: String {
        switch self {
        case .map: return "Interactive map"
        case .video: return "Video replay"
        case .package: return "Agent package"
        }
    }
    var detail: String {
        switch self {
        case .map: return "People explore your threads and open the sources behind them."
        case .video: return "A short, step-by-step video of how your work grew."
        case .package: return "Your insights, timeline and sources, ready to hand to an AI tool."
        }
    }
    /// Mono line on the Choose card.
    var formatLine: String {
        switch self {
        case .map: return "HTML + PDF"
        case .video: return "MP4 · ABOUT 40 SEC"
        case .package: return ".ZIP · MARKDOWN + FILES"
        }
    }
    /// Mono label above the Preview headline, and the suffix of the export button.
    var previewLabel: String {
        switch self {
        case .map: return "HTML + PDF"
        case .video: return "MP4"
        case .package: return ".ZIP"
        }
    }
}

public struct ExportSelection: Equatable, Sendable {
    public var threads = true
    public var sources = true
    public var quotes = true
    public var sprite = false
    public var isEmpty: Bool { !(threads || sources || quotes || sprite) }
}

// MARK: - Snapshot of the scoped data

public struct ExportSnapshot {
    public let name: String
    public let entries: [KnowledgeEntry]
    public let family: BranchSprite
    public let radarCurrent: ThinkingRadarValues
    public let radarHeading: ThinkingRadarValues
    
    public var threadCount: Int { entries.count }
    public var sourceEntries: [KnowledgeEntry] { entries.filter { $0.media != nil } }
    public var sourceCount: Int { sourceEntries.count }
}

@MainActor
public extension DemoStore {
    func exportSnapshot(for scope: ExportScope) -> ExportSnapshot {
        let name: String
        let entries: [KnowledgeEntry]
        switch scope {
        case .project(let id):
            name = DemoProject.name(for: id)
            entries = knowledgeEntries.filter { $0.projectID == id }
        case .session:
            if !lastFinishedSessionEntryIDs.isEmpty {
                let ids = Set(lastFinishedSessionEntryIDs)
                entries = knowledgeEntries.filter { ids.contains($0.id) }
                name = "\(activeProject.name) session"
            } else {
                // No live session this launch: the latest seeded session plus captures filed to it.
                let latest = KnowledgeEntry.seededSessions.first
                let captures = knowledgeEntries.filter {
                    $0.id.hasPrefix("capture_") && ($0.sessionID ?? latest?.id) == latest?.id && $0.projectID == activeProjectID
                }
                entries = KnowledgeEntry.session3Entries + captures
                name = latest?.title ?? "Session"
            }
        }
        return ExportSnapshot(
            name: name,
            entries: entries,
            family: accentFamily,
            radarCurrent: ThinkingRadarCalculator.computeCurrentProcess(sessions: completedSessionActions, quiz: quizAnswers),
            radarHeading: ThinkingRadarCalculator.computeWhereHeading(sessions: completedSessionActions)
        )
    }
}

// MARK: - Mini map selection (3 to 5 real, connected entries)

struct ExportMiniMap {
    let main: KnowledgeEntry
    let artifact: KnowledgeEntry?
    let colored: KnowledgeEntry?
    let extras: [KnowledgeEntry]
    let edges: [(String, String)]
    
    var all: [KnowledgeEntry] { [main] + [artifact, colored].compactMap { $0 } + extras }
    
    init?(entries: [KnowledgeEntry]) {
        guard let main = entries.first(where: { $0.isEmergent })
                ?? entries.first(where: { $0.isCombination })
                ?? entries.max(by: { $0.links.count < $1.links.count }) else { return nil }
        self.main = main
        var used: Set<String> = [main.id]
        func connected(_ e: KnowledgeEntry) -> Bool {
            main.links.contains { $0.targetEntryID == e.id } || e.links.contains { $0.targetEntryID == main.id }
        }
        let pool = entries.filter { $0.id != main.id }
        let ranked = pool.filter(connected) + pool.filter { !connected($0) }
        
        artifact = ranked.first(where: { $0.media != nil })
        if let a = artifact { used.insert(a.id) }
        colored = ranked.first(where: { !used.contains($0.id) && $0.actor.sprite != nil })
            ?? ranked.first(where: { !used.contains($0.id) })
        if let c = colored { used.insert(c.id) }
        let more = ranked.filter { !used.contains($0.id) }.prefix(2)
        extras = Array(more)
        
        let ids = Set(([main] + [artifact, colored].compactMap { $0 } + extras).map(\.id))
        var e: [(String, String)] = []
        for entry in [artifact, colored].compactMap({ $0 }) + extras { e.append((main.id, entry.id)) }
        for entry in entries where ids.contains(entry.id) {
            for l in entry.links where ids.contains(l.targetEntryID) && l.targetEntryID != main.id && entry.id != main.id {
                e.append((entry.id, l.targetEntryID))
            }
        }
        edges = e
    }
}

// MARK: - Document built from the selection

struct ExportSection {
    enum Kind { case threads, sources, quotes, sprite }
    let kind: Kind
    let heading: String
    let lines: [String]
}

struct ExportDocument {
    let name: String
    let dateText: String
    let sections: [ExportSection]
    
    @MainActor
    init(snapshot: ExportSnapshot, selection: ExportSelection, date: Date = Date()) {
        name = snapshot.name
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        dateText = f.string(from: date)
        var s: [ExportSection] = []
        if selection.threads {
            s.append(ExportSection(kind: .threads, heading: "Threads (\(snapshot.threadCount))", lines: snapshot.entries.map {
                "\($0.shortLabel) (\($0.actor.displayName), \($0.dateDisplay))"
            }))
        }
        if selection.sources {
            s.append(ExportSection(kind: .sources, heading: "Sources and links (\(snapshot.sourceCount))", lines: snapshot.sourceEntries.compactMap { e in
                guard let m = e.media else { return nil }
                var line = "\(m.title) (\(m.source), \(m.dateString))"
                if let url = m.linkURL { line += " " + url.absoluteString }
                else if let snip = m.previewSnippet, !snip.isEmpty { line += ": \(snip)" }
                return line
            }))
        }
        if selection.quotes {
            s.append(ExportSection(kind: .quotes, heading: "Quotes", lines: snapshot.entries.map {
                "\u{201C}\($0.text)\u{201D} \u{2014} \($0.actor.displayName)"
            }))
        }
        if selection.sprite {
            func pct(_ v: Double) -> String { "\(Int((v * 100).rounded()))%" }
            let c = snapshot.radarCurrent, h = snapshot.radarHeading
            s.append(ExportSection(kind: .sprite, heading: "Your sprite and direction", lines: [
                "Sprite family: \(snapshot.family.rawValue)",
                "How you think now: systematic \(pct(c.systematic)), tinkering \(pct(c.tinkering)), creative \(pct(c.creative)), observant \(pct(c.observant))",
                "Where you are heading: systematic \(pct(h.systematic)), tinkering \(pct(h.tinkering)), creative \(pct(h.creative)), observant \(pct(h.observant))"
            ]))
        }
        sections = s
    }
    
    func html() -> String {
        func esc(_ t: String) -> String {
            t.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;").replacingOccurrences(of: "\"", with: "&quot;")
        }
        var out = """
        <!doctype html>
        <html lang="en"><head><meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>\(esc(name))</title>
        <style>body{font:16px/1.5 -apple-system,Helvetica,Arial,sans-serif;max-width:680px;margin:40px auto;padding:0 20px;color:#111}
        h1{font-size:30px;margin-bottom:4px}h2{font-size:18px;margin-top:32px}p.meta{color:#666;margin-top:0}li{margin:6px 0}</style>
        </head><body>
        <h1>\(esc(name))</h1>
        <p class="meta">Exported from YaYa on \(esc(dateText))</p>
        
        """
        for sec in sections {
            out += "<h2>\(esc(sec.heading))</h2>\n<ul>\n"
            for l in sec.lines { out += "<li>\(esc(l))</li>\n" }
            out += "</ul>\n"
        }
        out += "</body></html>\n"
        return out
    }
    
    func markdown(kinds: Set<ExportSection.Kind>, title: String) -> String {
        var out = "# \(title)\n\nExported from YaYa on \(dateText)\n"
        for sec in sections where kinds.contains(sec.kind) {
            out += "\n## \(sec.heading)\n\n"
            for l in sec.lines { out += "- \(l)\n" }
        }
        return out
    }
    
    var hasInsightsContent: Bool { sections.contains { $0.kind != .sources } }
    var hasSourcesContent: Bool { sections.contains { $0.kind == .sources } }
}

// MARK: - File writer

#if canImport(UIKit)
enum ExportFileWriter {
    static var root: URL { FileManager.default.temporaryDirectory.appendingPathComponent("YaYaExport", isDirectory: true) }
    
    static func cleanUp() { try? FileManager.default.removeItem(at: root) }
    
    static func baseName(_ name: String, date: Date = Date()) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        let cleaned = name.split(whereSeparator: { $0.isWhitespace }).joined(separator: "-")
            .filter { $0.isLetter || $0.isNumber || $0 == "-" }
        return "YaYa-\(cleaned)-\(f.string(from: date))"
    }
    
    private static func makeFolder() throws -> URL {
        let dir = root.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }
    
    /// Interactive map: one .html and a one-page .pdf with the same list.
    static func writeMap(_ doc: ExportDocument) throws -> [URL] {
        let dir = try makeFolder()
        let base = baseName(doc.name)
        let htmlURL = dir.appendingPathComponent("\(base).html")
        try doc.html().write(to: htmlURL, atomically: true, encoding: .utf8)
        let pdfURL = dir.appendingPathComponent("\(base).pdf")
        try pdfData(doc).write(to: pdfURL, options: .atomic)
        return [htmlURL, pdfURL]
    }
    
    /// Agent package: a .zip with insights.md and sources.md, zipped with NSFileCoordinator.
    static func writePackage(_ doc: ExportDocument) throws -> [URL] {
        let dir = try makeFolder()
        let base = baseName(doc.name)
        let folder = dir.appendingPathComponent(base, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        if doc.hasInsightsContent {
            try doc.markdown(kinds: [.threads, .quotes, .sprite], title: "\(doc.name): insights")
                .write(to: folder.appendingPathComponent("insights.md"), atomically: true, encoding: .utf8)
        }
        if doc.hasSourcesContent {
            try doc.markdown(kinds: [.sources], title: "\(doc.name): sources")
                .write(to: folder.appendingPathComponent("sources.md"), atomically: true, encoding: .utf8)
        }
        let dest = dir.appendingPathComponent("\(base).zip")
        var coordinatorError: NSError?
        var copyError: Error?
        NSFileCoordinator().coordinate(readingItemAt: folder, options: .forUploading, error: &coordinatorError) { zipURL in
            do { try FileManager.default.copyItem(at: zipURL, to: dest) } catch { copyError = error }
        }
        if let e = coordinatorError ?? copyError { throw e }
        try? FileManager.default.removeItem(at: folder)
        return [dest]
    }
    
    static func pdfData(_ doc: ExportDocument) -> Data {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let inset = CGRect(x: 48, y: 52, width: 516, height: 688)
        func attributed(scale: CGFloat) -> NSAttributedString {
            let out = NSMutableAttributedString()
            let title = NSMutableParagraphStyle(); title.paragraphSpacing = 4
            let head = NSMutableParagraphStyle(); head.paragraphSpacingBefore = 12 * scale; head.paragraphSpacing = 4
            let body = NSMutableParagraphStyle(); body.paragraphSpacing = 3 * scale
            out.append(NSAttributedString(string: doc.name + "\n", attributes: [.font: UIFont.systemFont(ofSize: 24 * scale, weight: .heavy), .paragraphStyle: title]))
            out.append(NSAttributedString(string: "Exported from YaYa on \(doc.dateText)\n", attributes: [.font: UIFont.systemFont(ofSize: 10 * scale), .foregroundColor: UIColor.darkGray]))
            for sec in doc.sections {
                out.append(NSAttributedString(string: sec.heading + "\n", attributes: [.font: UIFont.systemFont(ofSize: 13 * scale, weight: .bold), .paragraphStyle: head]))
                for l in sec.lines {
                    out.append(NSAttributedString(string: "\u{2022} " + l + "\n", attributes: [.font: UIFont.systemFont(ofSize: 10 * scale), .paragraphStyle: body]))
                }
            }
            return out
        }
        // Shrink until everything fits on the single page.
        var scale: CGFloat = 1
        var text = attributed(scale: scale)
        while scale > 0.35, text.boundingRect(with: CGSize(width: inset.width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil).height > inset.height {
            scale -= 0.05
            text = attributed(scale: scale)
        }
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        return renderer.pdfData { ctx in
            ctx.beginPage()
            text.draw(with: inset, options: [.usesLineFragmentOrigin], context: nil)
        }
    }
}
#endif
