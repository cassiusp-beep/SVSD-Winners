import SwiftUI
import Observation

/// Shared random-interval blink used by the YaYa logos (and available to sprites).
/// Waits 2.5 to 5.5 s between blinks; each blink holds closed for 120 ms.
@MainActor
@Observable
public final class BlinkClock {
    public private(set) var isBlinking: Bool = false
    @ObservationIgnored private var task: Task<Void, Never>?

    public static let intervalRange: ClosedRange<Double> = 2.5...5.5
    public static let closedDuration: Double = 0.12

    public init() {}

    public func start() {
        guard task == nil else { return }
        task = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                let wait = Double.random(in: BlinkClock.intervalRange)
                try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
                guard !Task.isCancelled, let self else { return }
                await self.blinkOnce()
            }
        }
    }

    public func stop() {
        task?.cancel()
        task = nil
        isBlinking = false
    }

    /// One blink: eyes close to ~10% height and open again.
    public func blinkOnce() async {
        withAnimation(.easeInOut(duration: 0.1)) { isBlinking = true }
        try? await Task.sleep(nanoseconds: UInt64(BlinkClock.closedDuration * 1_000_000_000))
        withAnimation(.easeInOut(duration: 0.12)) { isBlinking = false }
    }
}
