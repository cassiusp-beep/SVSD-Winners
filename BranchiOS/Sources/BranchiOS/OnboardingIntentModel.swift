import SwiftUI

// MARK: - Quiz Content
/// One place for every quiz question, answer and family mapping.
public struct QuizAnswer: Sendable, Equatable {
    public let text: String
    public let family: ThinkingFamily
}

public struct QuizQuestion: Sendable, Equatable {
    public let prompt: String
    public let answers: [QuizAnswer]
}

public enum QuizContent {
    public static let questions: [QuizQuestion] = [
        QuizQuestion(
            prompt: "When a new idea shows up, what do you do first?",
            answers: [
                QuizAnswer(text: "Map how it connects to what I already know", family: .cloud),
                QuizAnswer(text: "Build a rough version to see if it works", family: .spark),
                QuizAnswer(text: "Sketch where it could go, even the weird parts", family: .prism),
                QuizAnswer(text: "Watch how people deal with it today", family: .bloom)
            ]
        ),
        QuizQuestion(
            prompt: "When a crit gets tough, what helps you most?",
            answers: [
                QuizAnswer(text: "Laying out the logic step by step", family: .cloud),
                QuizAnswer(text: "Making a quick fix and trying again", family: .spark),
                QuizAnswer(text: "Turning the problem around to see it differently", family: .prism),
                QuizAnswer(text: "Listening to how everyone else sees it", family: .bloom)
            ]
        ),
        QuizQuestion(
            prompt: "Your favorite moment in a project is when...",
            answers: [
                QuizAnswer(text: "The whole system finally clicks", family: .cloud),
                QuizAnswer(text: "The first prototype actually works", family: .spark),
                QuizAnswer(text: "A strange idea turns out to be right", family: .prism),
                QuizAnswer(text: "You notice something everyone missed", family: .bloom)
            ]
        )
    ]

    public static let letters = ["A", "B", "C", "D"]

    /// Most chosen family. A tie goes to the family picked on Question 1.
    public static func result(for selections: [Int?]) -> ThinkingFamily {
        let picked: [ThinkingFamily?] = selections.enumerated().map { qIndex, sel in
            guard let sel, questions.indices.contains(qIndex), questions[qIndex].answers.indices.contains(sel) else { return nil }
            return questions[qIndex].answers[sel].family
        }
        var counts: [ThinkingFamily: Int] = [:]
        for f in picked.compactMap({ $0 }) { counts[f, default: 0] += 1 }
        let best = counts.values.max() ?? 0
        guard best > 0 else { return .cloud }
        if let first = picked.first ?? nil, counts[first] == best { return first }
        return ThinkingFamily.allCases.first { counts[$0] == best } ?? .cloud
    }

    public static func families(for selections: [Int?]) -> [ThinkingFamily] {
        selections.enumerated().compactMap { qIndex, sel in
            guard let sel, questions.indices.contains(qIndex), questions[qIndex].answers.indices.contains(sel) else { return nil }
            return questions[qIndex].answers[sel].family
        }
    }
}

// MARK: - Talk It Through (simulated)
public enum TalkScript {
    /// Ready state only; speaking and writing read plain "TALK IT THROUGH".
    public static let readyLabel = "TALK IT THROUGH · 2 MIN"
    public static let label = "TALK IT THROUGH"
    public static let readyClock = "2:00"
    public static let prompt = "Tell me about something you're making, and how it started."
    public static let micNote = "The mic only turns on when you start."
    /// Seconds between transcript lines (script time; `-talkFast` runs script time at 8x).
    public static let lineInterval: Double = 4
    /// First line appears after this many seconds.
    public static let firstLineAt: Double = 2
    /// The simulated talk ends when the script does: last line + a short pause.
    public static var totalSeconds: Double {
        firstLineAt + lineInterval * Double(lines.count - 1) + 4.0
    }
    public static let lines: [String] = [
        "...honestly, I start by building something rough.",
        "I'd rather prototype it than talk about it for an hour.",
        "Once I can hold it, I can tell what's working.",
        "Then I bring it to people and see what they do with it."
    ]
    /// The family a spoken take-through resolves to (the script is a Spark / builder).
    public static let family: ThinkingFamily = .spark

    public static var speed: Double {
        CommandLine.arguments.contains("-talkFast") ? 8 : 1
    }

    static let keywords: [(ThinkingFamily, [String])] = [
        (.cloud, ["map", "system", "connect"]),
        (.spark, ["build", "prototype", "test"]),
        (.prism, ["sketch", "weird", "imagine"]),
        (.bloom, ["watch", "notice", "people"])
    ]

    /// Highest keyword count wins; no matches (or a tie at the top) falls back to Cloud first.
    public static func family(forWritten text: String) -> ThinkingFamily {
        let lower = text.lowercased()
        var best: (ThinkingFamily, Int) = (.cloud, 0)
        for (family, words) in keywords {
            let tokens = lower.split { !$0.isLetter }.map(String.init)
            // Word-start match, so "test" does not fire on "latest" but "connect" still matches "connected".
            let count = words.reduce(0) { acc, word in acc + tokens.filter { $0.hasPrefix(word) }.count }
            if count > best.1 { best = (family, count) }
        }
        return best.0
    }

    public static func clock(_ seconds: Double) -> String {
        let total = max(0, Int(seconds.rounded(.down)))
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

// MARK: - Family copy
public extension ThinkingFamily {
    static let revealDescription = "Your shape comes from how you work, and it's how collaborators spot your ideas."

    var revealTitle: String { "You're a \(rawValue)" }
}

// MARK: - Radar seeded from the intent answers
public extension ThinkingRadarCalculator {
    /// Share of each family among the saved answers, strongest scaled to 0.9, floor 0.25.
    static func values(fromIntent families: [ThinkingFamily]) -> ThinkingRadarValues {
        guard !families.isEmpty else {
            return ThinkingRadarValues(systematic: 0.90, tinkering: 0.55, creative: 0.45, observant: 0.60)
        }
        func share(_ f: ThinkingFamily) -> Double {
            Double(families.filter { $0 == f }.count) / Double(families.count)
        }
        let strongest = ThinkingFamily.allCases.map(share).max() ?? 1
        let scale = strongest > 0 ? 0.9 / strongest : 1
        func v(_ f: ThinkingFamily) -> Double { max(0.25, share(f) * scale) }
        return ThinkingRadarValues(systematic: v(.cloud), tinkering: v(.spark), creative: v(.prism), observant: v(.bloom))
    }
}

// MARK: - Layout slots (the persistent sprite and arrow follow these)
enum OnboardingSlot: Hashable {
    case sprite(OnboardingStep)
    case arrow(OnboardingStep)
}

struct OnboardingSlotsKey: PreferenceKey {
    static let defaultValue: [OnboardingSlot: CGRect] = [:]
    static func reduce(value: inout [OnboardingSlot: CGRect], nextValue: () -> [OnboardingSlot: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

/// An empty, sized placeholder that reports its frame in the onboarding space.
struct OnboardingSlotView: View {
    let slot: OnboardingSlot
    var width: CGFloat? = nil
    var height: CGFloat

    var body: some View {
        Color.clear
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: OnboardingSlotsKey.self,
                        value: [slot: geo.frame(in: .named("OnboardingFlowSpace"))]
                    )
                }
            )
            .accessibilityHidden(true)
    }
}
