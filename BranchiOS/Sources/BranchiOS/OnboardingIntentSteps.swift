import SwiftUI

#if canImport(UIKit)
import UIKit

// MARK: - Shared bits
private struct IntentLabel: View {
    let text: String
    var alignment: TextAlignment = .leading
    var body: some View {
        Text(text)
            .font(Font.yaya(size: 12))
            .tracking(0.6)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(alignment)
    }
}

private struct IntentTextLink: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Text(title)
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(.primary)
                .underline(true, color: Color.primary.opacity(0.35))
                .frame(minHeight: 44)
                .padding(.horizontal, 8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// Press feedback without opacity flashes: a small spring scale.
private struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Scroll container whose content is at least one viewport tall, so Spacers can open up on tall phones
/// and the content scrolls on small phones or at large Dynamic Type.
private struct IntentScroll<Content: View>: View {
    let viewportHeight: CGFloat
    let content: () -> Content

    var body: some View {
        ScrollView {
            content()
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, minHeight: viewportHeight, alignment: .top)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }
}

// MARK: - Intro
struct OnboardingIntroStep: View {
    let firstName: String?
    let contentTop: CGFloat
    let viewportHeight: CGFloat
    let onTalk: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var headlineSize: CGFloat = 34
    @ScaledMetric(relativeTo: .body) private var spriteSize: CGFloat = 130

    static let body = "Three quick questions help YaYa understand you and your work style. There are no right answers, and you can change any of them later."

    var body: some View {
        IntentScroll(viewportHeight: viewportHeight) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: contentTop)
                IntentLabel(text: "LENGTH: ABOUT 2 MINUTES")
                    .padding(.top, 4)

                OnboardingSlotView(slot: .sprite(.intro), width: spriteSize, height: spriteSize)
                    .padding(.top, 16)

                Text(headline)
                    .font(.system(size: headlineSize, weight: .heavy))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 16)
                    .accessibilityAddTraits(.isHeader)

                Text(Self.body)
                    .font(.system(.body))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)

                IntentTextLink(title: "Or talk it through instead", action: onTalk)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)

                Spacer(minLength: 8)
                OnboardingSlotView(slot: .arrow(.intro), height: 104)
                    .padding(.bottom, 24)
            }
        }
    }

    private var headline: String {
        let greeting = (firstName?.isEmpty == false) ? "Hi \(firstName!)," : "Hi there,"
        return "\(greeting)\nlet's get to know you."
    }
}

// MARK: - Quiz
struct OnboardingQuizStep: View {
    let index: Int
    let selections: [Int?]
    let contentTop: CGFloat
    let rowTop: CGFloat
    let viewportHeight: CGFloat
    var backward: Bool = false
    let onSelect: (Int) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .title) private var questionSize: CGFloat = 30
    @ScaledMetric(relativeTo: .body) private var spriteSize: CGFloat = 90

    var body: some View {
        let question = QuizContent.questions[index]
        let selected = selections.indices.contains(index) ? selections[index] : nil

        ZStack(alignment: .top) {
            IntentScroll(viewportHeight: viewportHeight) {
                ZStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: contentTop)

                    OnboardingSlotView(slot: .sprite(.quiz), width: spriteSize, height: spriteSize)
                        .padding(.top, 4)

                    IntentLabel(text: "QUESTION \(index + 1) OF 3")
                        .padding(.top, 12)

                    Text(question.prompt)
                        .font(.system(size: questionSize, weight: .heavy))
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 6)
                        .accessibilityAddTraits(.isHeader)

                    VStack(spacing: 10) {
                        ForEach(Array(question.answers.enumerated()), id: \.offset) { i, answer in
                            answerCard(i: i, answer: answer, isSelected: selected == i)
                        }
                    }
                    .padding(.top, 18)

                    Text("Remember, there are no wrong answers.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 14)

                    OnboardingSlotView(slot: .arrow(.quiz), height: 96)
                        .padding(.bottom, 24)
                }
                .id(index)
                // Old question clears fast; the new one waits a beat so the texts never overlap.
                .transition(.asymmetric(
                    insertion: AnyTransition.opacity.combined(with: .offset(y: backward ? -24 : 24))
                        .animation(BranchMotion.sharedSpring.delay(0.1)),
                    removal: AnyTransition.opacity.combined(with: .offset(y: backward ? 24 : -24))
                        .animation(.easeOut(duration: 0.12))
                ))
                }
            }

            QuizProgressBar(index: index)
                .padding(.leading, 24 + 44 + 14)
                .padding(.trailing, 24 + 52 + 10)
                .frame(height: 36)
                .padding(.top, rowTop)
        }
    }

    private func answerCard(i: Int, answer: QuizAnswer, isSelected: Bool) -> some View {
        let letter = QuizContent.letters[i]
        return Button {
            onSelect(i)
        } label: {
            HStack(spacing: 14) {
                Text(letter)
                    .font(Font.yaya(size: 12, weight: .bold))
                    .foregroundStyle(isSelected ? Color(.systemBackground) : Color.secondary)
                    .frame(width: 24, height: 24)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(isSelected ? Color.primary : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.primary.opacity(isSelected ? 0 : 0.28), lineWidth: 1)
                    )

                Text(answer.text)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 56, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(colorScheme == .dark ? Color.white.opacity(0.07) : Color.white.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.primary : Color.primary.opacity(0.14), lineWidth: isSelected ? 1.5 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PressScaleStyle())
        .animation(BranchMotion.quickSpring, value: isSelected)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Answer \(letter) of 4, \(answer.text)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// Three black segments that fill with a spring as the questions advance.
struct QuizProgressBar: View {
    let index: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.14))
                    Capsule().fill(Color.primary)
                        .scaleEffect(x: i <= index ? 1 : 0.001, anchor: .leading)
                }
                .frame(height: 4)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: index)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Question \(index + 1) of 3")
    }
}

// MARK: - Talk it through
enum TalkPhase: Equatable {
    case ready, speaking, writing
}

struct OnboardingTalkStep: View {
    let phase: TalkPhase
    let elapsed: Double
    let shownLines: Int
    @Binding var text: String
    let contentTop: CGFloat
    let viewportHeight: CGFloat
    let onRecordTap: () -> Void
    let onWriteInstead: () -> Void
    let onTalkInstead: () -> Void

    @FocusState private var fieldFocused: Bool
    @ScaledMetric(relativeTo: .title) private var promptSize: CGFloat = 30
    @ScaledMetric(relativeTo: .body) private var spriteBase: CGFloat = 1

    private var remaining: Double { max(0, TalkScript.totalSeconds - elapsed) }

    var body: some View {
        IntentScroll(viewportHeight: viewportHeight) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: contentTop)
                IntentLabel(text: phase == .ready ? TalkScript.readyLabel : TalkScript.label)
                    .padding(.top, 4)

                ZStack(alignment: .topLeading) {
                    // Two Text views keyed by phase: font never interpolates, so words never re-wrap mid-spring.
                    if phase == .ready {
                        Text(TalkScript.prompt)
                            .font(.system(size: promptSize, weight: .heavy))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.easeOut(duration: 0.18).delay(0.12)),
                                removal: .opacity.animation(.easeOut(duration: 0.08))))
                    } else {
                        Text(TalkScript.prompt)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityAddTraits(.isHeader)
                            .transition(.asymmetric(
                                insertion: .opacity.animation(.easeOut(duration: 0.18).delay(0.12)),
                                removal: .opacity.animation(.easeOut(duration: 0.08))))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.top, 8)

                if phase == .writing {
                    writingBody
                } else {
                    voiceBody
                }
            }
            .animation(BranchMotion.sharedSpring, value: phase)
        }
    }

    // MARK: Ready + speaking
    private var voiceBody: some View {
        VStack(spacing: 0) {
            OnboardingSlotView(slot: .sprite(.talk), height: (phase == .ready ? 210 : 248) * max(spriteBase, 1))
                .padding(.top, phase == .ready ? 8 : 4)

            if phase == .ready {
                Text(TalkScript.micNote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                    .transition(.opacity)
            } else {
                Spacer(minLength: 0)   // centre the transcript in the free height (Pro Max)
                transcript
                    .padding(.top, 14)
                    .transition(.opacity)
            }

            Spacer(minLength: 16)

            if phase == .speaking {
                progress
                    .padding(.bottom, 18)
                    .transition(.opacity)
            }

            RecordButton(
                symbol: phase == .speaking ? "stop.fill" : "mic.fill",
                accessibilityLabel: phase == .speaking ? "Stop and see your shape" : "Start talking"
            ) {
                onRecordTap()
            }
            .frame(maxWidth: .infinity)

            Group {
                if phase == .ready {
                    Text(TalkScript.readyClock)
                        .accessibilityLabel("2 minutes")
                } else {
                    Text(TalkScript.clock(elapsed))
                        .accessibilityLabel("\(TalkScript.clock(elapsed)) elapsed")
                }
            }
            .font(Font.yaya(size: 15))
            .monospacedDigit()
            .foregroundStyle(.secondary)
            .padding(.top, 10)

            IntentTextLink(title: "Write instead", action: onWriteInstead)
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
                .padding(.bottom, 28)
        }
    }

    private var transcript: some View {
        let lines = Array(TalkScript.lines.prefix(shownLines))
        let visible = Array(lines.suffix(2))
        let newestIndex = visible.count - 1
        return VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(visible.enumerated()), id: \.element) { i, line in
                Text(line)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(i == newestIndex ? Color.primary : Color.secondary.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.asymmetric(
                        // Fast-out / delayed-in: the old line clears before the new one arrives, never both at once.
                        insertion: AnyTransition.opacity.combined(with: .offset(y: 10)).animation(BranchMotion.quickSpring.delay(0.12)),
                        removal: AnyTransition.opacity.animation(.easeOut(duration: 0.1))
                    ))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
        .animation(BranchMotion.sharedSpring, value: shownLines)
        .accessibilityHidden(true)
    }

    private var progress: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.primary.opacity(0.14))
                Capsule().fill(Color.primary)
                    .frame(width: max(4, geo.size.width * min(1, elapsed / TalkScript.totalSeconds)))
            }
        }
        .frame(height: 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(TalkScript.clock(elapsed)) elapsed, \(TalkScript.clock(remaining)) left")
    }

    // MARK: Writing
    private var writingBody: some View {
        VStack(spacing: 0) {
            OnboardingSlotView(slot: .sprite(.talk), height: 84)
                .padding(.top, 8)

            TextField("Type what you'd say...", text: $text, axis: .vertical)
                .font(.system(size: 17))
                .lineLimit(4...8)
                .focused($fieldFocused)
                .padding(16)
                .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.top, 8)
                .accessibilityLabel("Write your answer")

            OnboardingSlotView(slot: .arrow(.talk), height: 88)
                .padding(.top, 8)

            IntentTextLink(title: "Talk instead", action: onTalkInstead)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
        }
        .onAppear { fieldFocused = !CommandLine.arguments.contains("-onboardingTalkWrite") }
    }
}

// MARK: - Reveal
struct OnboardingRevealStep: View {
    let family: ThinkingFamily
    let contentTop: CGFloat
    let viewportHeight: CGFloat

    @ScaledMetric(relativeTo: .largeTitle) private var titleSize: CGFloat = 34

    var body: some View {
        IntentScroll(viewportHeight: viewportHeight) {
            VStack(spacing: 0) {
                Spacer().frame(height: contentTop)
                IntentLabel(text: "YOUR SHAPE", alignment: .center)
                    .padding(.top, 4)

                OnboardingSlotView(slot: .sprite(.reveal), height: 180)
                    .padding(.top, 12)

                Text("Tap to try another shape")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)

                Text(family.revealTitle)
                    .font(.system(size: titleSize, weight: .heavy))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 18)
                    .contentTransition(.opacity)
                    .accessibilityAddTraits(.isHeader)

                Text(ThinkingFamily.revealDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)

                // Old line clears fast, new line waits a beat; both pinned to the same top edge.
                ZStack(alignment: .top) {
                    Text(family.oneLineDescription)
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .id(family)
                        .transition(.asymmetric(
                            insertion: AnyTransition.opacity.animation(BranchMotion.quickSpring.delay(0.1)),
                            removal: AnyTransition.opacity.animation(.easeOut(duration: 0.1))
                        ))
                }
                .padding(.top, 14)

                Spacer(minLength: 8)
                OnboardingSlotView(slot: .arrow(.reveal), height: 104)
                    .padding(.bottom, 24)
            }
            .animation(BranchMotion.sharedSpring, value: family)
        }
    }
}
#endif
