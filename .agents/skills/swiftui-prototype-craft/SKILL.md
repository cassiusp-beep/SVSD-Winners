---
name: swiftui-prototype-craft
description: >-
  Expert guidance for building high-craft, camera-ready SwiftUI iOS prototypes and interactive spatial canvases.
  Use when creating or modifying SwiftUI views, canvas gesture engines, spring motion, haptics, and demo presets.
---

# SwiftUI Prototype Craft & Camera-Ready iOS Workflow

This skill guides the construction of camera-ready SwiftUI prototypes for product demos, pitch videos, and interactive user testing.

## Core Tenets for Camera-Ready Demos

1. **Camera-Ready Polish Over Full Backend:**
   - In demo prototypes, not every button needs an end-to-end backend.
   - The primary demo flow must be 100% stable, flicker-free, with zero dropped frames or unexpected layout shifts.
   - Seed realistic, domain-authentic data (real maker quotes, engineering specs, high-resolution imagery).

2. **Touch & Motion Physics:**
   - Use fluid spring animations: `.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0)`.
   - Add tactile haptics on selection, expansion, and drag events via `UIImpactFeedbackGenerator(style: .medium)`.
   - Never use instant snaps or raw linear transitions.

3. **Spatial Canvas Architecture in SwiftUI:**
   - Use a coordinate space container (`GeometryReader` + drag gesture + magnification gesture).
   - Keep scale bounded: `.scaleEffect(zoomLevel)` with clamp between `0.4` and `2.0`.
   - Position nodes using explicit `CGPoint` canvas coordinates translated by viewport offset.
   - Render edges using custom SwiftUI `Path` with smooth cubic/quad bezier curves.

4. **TouchDesigner Modular Card Hierarchy:**
   - Solid container cards with hairline borders (`Color.secondary.opacity(0.2)`), subtle elevation shadows (`radius: 8, y: 3`), and distinct header bars.
   - Clean color coding:
     - Saturated Emerald (`#0D8F5B`) for active project containers and validated paths.
     - Terracotta/Vermillion (`#E23D28`) for collaborator lineage branches.
     - Electric Amber (`#FF9F0A` / `#D97706`) for unanswered questions/gaps.
   - Gap pins start as quiet 20pt dot badges and smoothly spring open into parameter cards upon tap.

5. **Demo Script Scrubber & Presets:**
   - Include a floating presentation controller (or chapter scrubber) to easily advance between story beats during video recording:
     - Beat 1: Initial team meeting & live capture waveform
     - Beat 2: Emerging tension & semantic mapping
     - Beat 3: Open question / gap expansion
     - Beat 4: Contributor branch integration
     - Beat 5: Evolving project memory & resume view

## Project & Build Commands

- **Build for iOS Simulator:**
  ```bash
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project BranchiOS.xcodeproj -scheme BranchiOS -destination 'platform=iOS Simulator,name=iPhone 17' build
  ```
- **Launch on Booted Simulator:**
  ```bash
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl install booted <path_to_app>
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl launch booted <bundle_identifier>
  ```
