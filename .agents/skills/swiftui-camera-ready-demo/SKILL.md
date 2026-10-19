---
name: swiftui-camera-ready-demo
description: Best practices and commands for capturing camera-ready iOS simulator demos, clean status bar overrides, high-framerate video recordings, touch visualizers, and zero-fail demo scrubber state machines.
---

# SwiftUI Camera-Ready Demo Skill

Use this skill when preparing, testing, or recording SwiftUI prototype demonstrations for video pitches, stakeholder walkthroughs, and jury presentations.

---

## 1. Clean Simulator Status Bar Override

Before capturing screenshots or recording demo videos, execute this command so the status bar displays clean Apple presentation defaults (9:41 AM, full battery, full signal, no carrier clutter):

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl status_bar booted override \
  --time "9:41" \
  --dataNetwork "wifi" \
  --wifiMode "active" \
  --wifiBars 3 \
  --cellularMode "active" \
  --cellularBars 4 \
  --batteryState "charged" \
  --batteryLevel 100
```

To clear the override when finished:
```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl status_bar booted clear
```

---

## 2. Touch Indicator Visualization

When recording demos on macOS without a physical hand, enable touch circles so the viewer can follow taps and drags clearly:

```bash
# Enable touch circle highlights in Simulator
defaults write com.apple.iphonesimulator ShowSingleTouches 1
```

To disable:
```bash
defaults write com.apple.iphonesimulator ShowSingleTouches 0
```

---

## 3. High-Framerate Video Recording

Record 60fps MP4/HEVC video directly from the booted simulator:

```bash
# Start recording
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl io booted recordVideo --codec=h264 ./demo_capture.mp4

# Stop recording: press Ctrl+C in terminal
```

---

## 4. Zero-Fail Demo Scrubber State Machine

Never rely on live manual dragging of 20 different parameters during a video pitch. Build a **1-tap Demo Scrubber** at the bottom of the canvas:

```swift
public struct DemoPreset {
    public let id: Int
    public let label: String
    public let summary: String
    public let applyState: (inout AppState) -> Void
}
```

### Scripted Beat Conventions
1. **Beat 1: The Hook / Seed State** — Clean initial view showing the protagonist's core dilemma.
2. **Beat 2: Tension / Gap Emergence** — The problem space blooms into focus (amber gap pin appears).
3. **Beat 3: Interactive Resolution / Branch** — The system suggests or collaborator branches a new path.
4. **Beat 4: Synthesis / Convergence** — The unified outcome is revealed.

### Camera Animation Rule
Always animate camera shifts (`panOffset`, `zoomScale`) using `Animation.spring(response: 0.45, dampingFraction: 0.82)`. This provides cinema-grade gliding without sudden jumps.

---

## 5. Haptic Feedback Timing

For real devices and camera demonstrations:
- Light tap on node select: `UIImpactFeedbackGenerator(style: .light)`
- Medium tap on node expansion: `UIImpactFeedbackGenerator(style: .medium)`
- Success on branch/merge action: `UINotificationFeedbackGenerator().notificationOccurred(.success)`
- Always prepare the generator beforehand (`generator.prepare()`) to avoid latency.
