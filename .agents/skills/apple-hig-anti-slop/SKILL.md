---
name: apple-hig-anti-slop
description: Strict craft and anti-slop rules for Apple platforms (iOS, iPadOS, macOS). How to eliminate generic AI patterns, fake box shadows, tacky glowing rings, and web-like bloat in favor of native materials, typography traits, and spatial ergonomics.
---

# Apple HIG Anti-Slop Guide for Native Prototypes

This guide translates SVSD's core anti-slop mandates (`docs/process/anti-slop.md`) into native Apple HIG (Human Interface Guidelines) standards.

---

## What Makes iOS Prototypes Look Like "AI Slop"

1. **Web CSS Ports:** Attempting to render generic web cards with thick artificial box shadows (`.shadow(radius: 20)`), glowing neon outlines, or ungrounded card borders.
2. **Circular Bubble Clutter:** Overusing generic circles with text that truncate words and force awkward radial clipping.
3. **Floating Isolated Modals:** Presenting full-screen alert dialogs or disconnected modals instead of native sheets (`.sheet(isPresented:)`), toolbars, or docked HUD bars.
4. **Static Linear Transitions:** Using `.linear` or `.easeIn` animations instead of fluid, interruptible Apple spring physics (`.spring(response:dampingFraction:)`).
5. **Ignoring Safe Area Ergonomics:** Letting text collide with the Dynamic Island, home indicator, or screen corners.

---

## What To Do Instead (High-Craft Native Alternatives)

| AI Slop Pattern | High-Craft Apple Alternative |
|---|---|
| Deep diffuse drop-shadows | Multi-layered subtle hairline border: `overlay(RoundedRectangle().stroke(Color.black.opacity(0.08), lineWidth: 1))` with a micro-shadow (`radius: 3, y: 1`). |
| Circular bubble bloat | TouchDesigner-style modular rectangular cards with distinct operator badges (`HUB`, `COMP`, `SRC`, `CONS`). |
| Tacky glowing outer rings | Small amber dot pins (16–20pt) that cleanly spring open into parameter cards on tap or hover. |
| Hard web fonts or system defaults | SF Pro with curated design traits: `.fontDesign(.monospaced)` for parameters, `.fontDesign(.serif)` for quotes/dialogue, `.fontDesign(.rounded)` for personas. |
| Web modal popups | Floating docked pills, dynamic HUD bars with `.background(.ultraThinMaterial)` or `.background(StudioTheme.cardSurface)`. |
| Jump cuts between states | Smooth fluid spring interpolation on spatial transforms (`panOffset`, `zoomScale`, `scaleEffect`). |

---

## Spatial Canvas Ergonomics

1. **Gestures Must Be Simultaneous:**
   Always use `SimultaneousGesture` or combined pan/pinch so the user can fluidly explore the canvas without gesture locking.
2. **Dynamic Clamping:**
   Clamp zoom scale between `0.45` and `2.5` to prevent infinite drift into empty space.
3. **Re-Center Safety Anchor:**
   Always provide a subtle floating `"Reset View"` capsule button docked above the bottom toolbar to recover focus instantly.
4. **Haptics Must Mirror Action Weight:**
   Use `.light` for hovers and selection, `.medium` for card expansion, and `.heavy` or `.notification(.success)` for merging/publishing.
