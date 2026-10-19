# Swift iOS & SwiftUI Prototyping Rules

1. **Target Viewport & Parity:**
   - Design for iPhone 17 (393x852) / iPhone 17 Pro.
   - Respect Safe Area insets (`.ignoresSafeArea()` only on infinite background canvas; keep controls and HUD within safe bounds).

2. **Visual Tokens (Light Studio Drafting Palette):**
   - Canvas: Warm off-white `#FAF9F5` (or system background adapted for tactile trace paper).
   - Architectural Grid: Faint millimeter dots `#DDD9D0`.
   - Typography: San Francisco (`.font(.system(..., design: .rounded))` or `.monospaced()`).
   - Saturated Marker Palette:
     - Emerald Green: `Color(red: 13/255, green: 143/255, blue: 91/255)`
     - Vermillion/Terracotta: `Color(red: 226/255, green: 61/255, blue: 40/255)`
     - Electric Amber: `Color(red: 255/255, green: 159/255, blue: 10/255)`
     - Cobalt Blue: `Color(red: 29/255, green: 106/255, blue: 229/255)`

3. **Motion & Feedback:**
   - All interactive state changes must trigger haptics via `UIImpactFeedbackGenerator`.
   - Tap-to-expand gap nodes must spring cleanly without obscuring sibling nodes.
   - Fluid drag and magnification gestures on the canvas must not conflict with card touch targets.

4. **Demo Readiness:**
   - Provide a persistent preset bar for rapid resetting during screen recordings.
   - Ensure all assets are packaged locally so previews and demo runs never fail due to network drops.
