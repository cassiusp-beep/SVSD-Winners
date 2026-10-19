# Decisions

Significant product and design choices, newest first. Each entry is also raw material for the "how we got here" part of the submission video.

## October 18, 2026: Shared Navigation Arrow & Elevated Sprite Juggle (Decision 012)

**Decided:**
1. **Shared NextArrowButton Navigation Pattern:**
   - Standardized the 56pt circular arrow button (`NextArrowButton`) across `ProfileSetupView` and `IntegrationsView` as the primary way forward.
   - Replaced the swipe-up gesture and prompt on `IntegrationsView` with the centered `NextArrowButton` positioned in the open space between the page dots and the "Connected" label.
   - Kept top-right `ContinueButton` as the consistent plain-text fallback across all onboarding screens.
   - On `IntegrationsView`, continuing with zero integrations is valid, so `NextArrowButton` is always enabled.
2. **Elevated Juggle & Extended Sprite Arms:**
   - Elevated the juggling trajectory so orb arc peaks reach at least 1.5 orb diameters ($>63\text{pt}$) above the dome apex, completely eliminating sprite body overlap.
   - Lowered the sprite body slightly (`offset(y: domeHeight * 0.48)`) so more is cut off by the bottom screen edge rather than shrinking the sprite.
   - Extended `SpriteArmShape` so the raised arm's hand tip reaches the high catch point ($Y \approx -50\text{pt}$), while the lowered arm relaxes near the top of the dome.
   - Maintained clean breathing space below the "Connected" label so orbs never collide with typography.


## October 18, 2026: Swift iOS Prototyping Workflow & Markdown-First Pivot (Decision 011)

**Decided:**
1. **Completely Scrapped First Idea:** The original creative-exchange concept (gooey canvas, hot corners, and public collaborative branching) is completely scrapped. The product is pivoting to an individual-first onboarding and storytelling experience based on the October 18 whiteboard sketch (`2026-10-18 Onboarding Whiteboard.jpg`).
2. **Native Swift iOS Workflow:** Formalized a native SwiftUI iOS prototyping architecture using `.agents/skills/` and `.agents/rules/`:
   - `swiftui-prototype-craft`: TouchDesigner modular card hierarchy, springing amber gap pins, simultaneous pan/pinch gestures, and `@Observable` state stores.
   - `swiftui-camera-ready-demo`: Simulator status bar overrides (`9:41`, full battery/signal), touch visualizers, 60fps MP4 recording, and 1-tap demo scrubbers.
   - `apple-hig-anti-slop`: Native materials, SF Pro design traits (`.monospaced`, `.rounded`), native spring physics, and eliminating web/AI slop.
   - Dedicated `ios-builder` agent role for Apple platform execution.
3. **Markdown-First Discipline:** Prioritize complete markdown documentation, journey mapping, and skill alignment before building any code, ensuring all `.md` files maintain cross-referencing and precedence integrity.

**Why:** The team needed a foolproof, camera-ready native iOS workflow for the upcoming competition demo while keeping the workspace clean and unencumbered as the new onboarding sketch develops.

## October 18, 2026, later clarification: Individual first; newest onboarding whiteboard governs

**Decided:** Establish Branch for individuals before team integration. Follow the latest onboarding whiteboard: A, anonymous two-minute recording trial → sign up → quiz → create context → profile → build/explore; B, sign up → quiz → import work → profile → build/explore; C, sign up → import work → profile → build/explore. Team context can enter through Import work; that does not grant team access or join a workspace. The new UIUX.md records screen/state details and labels proposed defaults and open decisions.

**Why:** The user explicitly clarified audience and precedence. The Figma board represents older ideas and is a UI/UX reference, not the current flow specification. The earlier team-first product statement remains available as strategy history, with its audience and entry flow superseded.

**Alternatives considered:** Keeping team onboarding as the default would contradict the clarification. Rebuilding the old profile/discovery flow from Figma would override the new whiteboard. Keeping both old and new source UIUX guides active would leave agents uncertain. Preserve exact old documents in dated archives and maintain one current UIUX.md per workspace.

**Scope and preservation:** UI/UX documentation and source-photo copies only. Existing application, CLAUDE/roles and source AGENTS are preserved. No app implementation, Figma edits, commit, push or deployment. Pre-edit copies are under `docs/archive/2026-10-18-before-individual-uiux/Repository/` and source `07 MD Files/Archive/2026-10-18 Individual UIUX/{Repository,Source}/`.

**Familiar or new:** an explicit change to the first-use flow and audience sequence; existing research remains background, not validation of the new experience.

## October 18, 2026: Team-first collective emergence and portable agent context

**Decided:** Sync the source workspace's current product direction into this repository. Branch now proposes a live shared semantic map for multidisciplinary concept-development teams, prioritizing creative discovery before commitment. Keep possible tensions, complementary contributions and alternatives visible; participants decide what is accepted or acted on. Preserve the five positioning answers and repeated-session value loop in `docs/context/product-definition.md`, with `CONTEXT.md` as the short agent entry.

**Why:** The source workspace had advanced beyond the repository's student-maker exchange. Agents need one clear current entry without mistaking earlier screen contracts for the new product. This is a documentation change, not a validated market claim or implementation.

**Alternatives considered:** Retaining the old whiteboard as current product authority would obscure the pivot. Replacing all agent files or deleting old designs would lose workflow and design history. Instead, preserve CLAUDE.md and role files, retain prior document bodies with status banners, and import the individual-first system/maps under a dated historical archive.

**Preservation and scope:** Exact pre-edit repository/source documents are backed up in the source workspace's `Archive/2026-10-18 Repository Context Sync`, separated into `Repository/` and `Source/` paths. This is a selective portable snapshot, not automatic synchronization. Application source, tests and existing assets are unchanged; no commit, push or deployment is part of the sync. The shared live screen inventory, permissions experience and architecture need a later explicit design task.

**Familiar or new:** the team-first live-mapping direction is a new product hypothesis for Branch; a documentation snapshot with explicit precedence preserves the existing workflow.

## October 17, 2026: TouchDesigner Modular Operator Hierarchy & Studio Drafting Bed (Decision 010)

**Decided:**
1. **TouchDesigner Operator Block Hierarchy:** Replaced tacky concentric glowing rings and round nodes with a clean, structured hierarchy of modular operator blocks:
   - **Maker Hub:** Grounded rectangular studio operator block with Elena's avatar, MDes discipline pill, and clean parameter bar (`Projects`, `Network`, `Needs`, `Skills`).
   - **Project COMP:** Solid container block with saturated emerald header (`#0D8F5B`), live textile photography, thesis context, and visible in/out docking ports.
   - **Asset SOP:** Compact rounded pill capsule (`[SOURCE · STEP 2] Tactile Aesthetics`).
   - **Open Gap:** Small amber dot pin (`?`) in resting state that smoothly blooms into an actionable parameter card on hover/focus.
   - **Lineage Branch:** Solid terracotta block (`#E23D28`) with Marcus Chen's avatar and contribution summary.
2. **Warm Studio Drafting Bed (`#FAF9F5`):** Complete elimination of dark mode in favor of warm architectural trace paper with a subtle millimeter dot grid (`#DDD9D0`), hairline card borders (`1px solid #E2E0D8`), and dark studio typography (`#14171F`).
3. **Directional Left-to-Right Bus Flow:** Left is personal/network peers (`Amina Diallo`, `Lucas Zhao`), center is the maker hub, and right is the project story, validation sources, gaps, and collaborator branches.

**Why:**
- Concentric glowing circles and dark neon voids read as AI bloatware/slop and lacked authentic tool identity.
- Modular TouchDesigner-inspired blocks bring professional creative-coding rigor, clarity, and delight to cross-disciplinary collaboration.

**Alternatives considered:**
- Architectural trace paper with rigid 90-degree orthogonal elbow routing: Rejected for now to prevent wire overlap on dense graphs.


**Decided:**
1. **Abolished Dark Mode in Favor of the Studio Whiteboard Drafting Bed:** Replaced the generic dark blue/space canvas with a tactile warm off-white drafting bed (`#FAF9F5`), subtle architectural dot grid (`#E5E0D5`), and saturated physical whiteboard marker conduits (Emerald Green `#0D8F5B`, Vermillion Red `#E23D28`, Electric Amber Glow `#FF9F0A`).
2. **Replaced Text-Box Cards with Rich Physical Artifacts:** In accordance with `anti-slop.md`, eliminated empty rectangular text cards. Replaced them with tactile white cards carrying high-resolution macro photography of Elena's woven jacquard textiles, Challis & Edwards loom pitch concept sketches, Marcus Chen's hardware/DSP prototype photography, and peer project imagery.
3. **Blooming Petal Membrane Hub:** Transformed Elena's central hub from detached satellite icons into a continuous blooming organic cell with five rounded circular petals (`Projects`, `Connections`, `Skills`, `Interests`, `Needs & Gaps`) that physically cluster around the maker.
4. **Authentic Speech Bubble Dialogue Margins:** Converted tooltip-like edge badges into genuine margin notes and speech bubbles with maker quotes, timestamps, and pointer tails anchored to the conduit pulses.

**Why:**
- The dark mode was diagnosed by visual critique as reading like generic AI slop (the common dark cyber/crypto dashboard look), which obscured the authentic physical studio spirit of UC Berkeley MDes.
- `branch_landing_mockup.jpg` and Miro reference image 15 proved that Branch's true visual soul is a warm, tactile drafting whiteboard with physical media and rich marker ink.

**Alternatives considered:**
- Keeping dark mode with image thumbnails: Rejected because the dark void still looked like a developer IDE rather than a vibrant design studio charrette.



**Decided:**
1. **Option B Shell Refactor over Scratch Rewrite:** Kept the React Flow (`@xyflow/react`) coordinate and gesture substrate, but completely dismantled and gutted the legacy modal popover shell. Implemented the true vision from Cassius's whiteboard walkthrough (`IMG_0837.MOV`): a single, unified, infinite living canvas.
2. **Circular Bulbing Profile Hub (`PersonHubNode`):** Replaced rectangular user cards with Elena Rostova's central organic circular avatar hub (`110px` diameter) with a glowing cyan ambient ring and 4 bulbing radial satellite action buttons: Genesis (`+`), Explore (`compass`), Share/Export (`arrow`), and Branch network.
3. **Zero Modals Mandate:** Abolished all modal dialogs. Every interaction—inspecting open gaps, exploring branches, reviewing validation sources, seeking help—unfolds directly in the spatial graph or through the 4 non-intrusive Hot Corners (`HotCornersHUD`).
4. **Living Dialogue on Edges (`DialogueEdge`):** Dialogue snippets and creator quotes (e.g. Elena's *"Need DSP to map voice pitch into LRA pulses"* and Marcus's *"AudioWorklet splits speech syllables at <8ms"*) are anchored directly to the bezier connectors with traveling dash pulses, showing who talked to whom and why a branch sprouted without navigating away.
5. **Night Lab Saturated Marker Palette:** Standardized all UI tokens strictly to the 16 Night Lab tokens (`--nl-space-void`, `--nl-surface-card`, `--nl-accent-cyan`, `--nl-accent-amber`, `--nl-accent-lime`, `--nl-accent-coral`, `--nl-accent-violet`). Abandoned muted grays in favor of vibrant high-contrast markers on deep space navy.
6. **Genesis Project Creation via Drag-and-Drop:** Dropping external files or project ideas onto the canvas (or onto the central `+` hub) triggers instant project genesis into the graph with organic morph animations.

**Why:**
- Section-by-section audit of Whiteboard Transcript (3.1 to 3.11) revealed the old modal popovers completely destroyed the core spatial metaphor of Branch.
- Option B saved 12–16 engineering hours compared to a from-scratch rewrite while delivering 100% fidelity to the whiteboard walkthrough and visual spec.
- Saturated markers and glowing gap nodes directly address the SVSD judging criteria ("Craft," "Visual Design," and "Unapologetically original").

**Alternatives considered:**
- **Option A (From-scratch rewrite with raw SVG / HTML Canvas):** Estimated at 18–24 hours, risking the Oct 19 deadline with severe regressions in panning, zooming, and gestures. Rejected.
- **Keeping bottom drawer sheets for details:** Rejected as half-hearted. All details and dialogue belong directly on the canvas nodes and connecting edges.



**Decided:**
1. **Canvas Foundation & Dragging Architecture:** React Flow (`@xyflow/react`) with custom React/CSS nodes and SVG edges. Solves coordinate transformation, infinite pan/zoom, and desktop file drop cleanly while letting custom card components render rich media, turning points, and story scrubbers. To support fluid node rearrangement without overriding spatial persistence, positions are updated via `onNodesChange` and cached in a spatial ref map (`draggedPositions`), while interior interactive controls (buttons, chips, stars) use the `.nodrag` boundary class so dragging and tapping never collide.
2. **Hot Corners Navigation:** Replaced traditional top/side navigation bars with four persistent Hot Corners: Profile (Top-Left), Help & I'm Stuck (Top-Right), Save & Drafts (Bottom-Left), and Story Scrubber (Bottom-Right).
3. **AI Connection Relevance Layer:** Added an opt-in semantic explanation badge on in-between node edges explaining *why* step A connects to step B (e.g. why the thermal dead end led to LRAs). Rendered in the rose AI tint (`#F4DDE5`) and completely dismissible.
4. **Mobile First-Class Parity (390px):** Mobile preserves canvas zoom while personal nodes and project drawer slide up in an adaptive bottom sheet rather than flattening the entire graph into a list.

**Why:**
- Speed to deadline (under 3 days to Oct 19).
- Directly answers the SVSD storytelling theme: the graph itself is the spatial narrative.
- Non-negotiable AI rule preserved: 100% of user flows work without AI.

## October 16, 2026: No requests. Branches grow beside the original.

**Decided:** creators never approve or decline anything. When someone branches their work, the creator gets a quiet notification. Branches appear as linked offshoots beside the original project, credited to whoever made them. The creator's own story only changes when the creator adds to it.

**Replaces:** the board's request flow, where Review a Request led to Accept or Decline.

**Why:**
- Approval contradicted our own line, "not permission to use it, help to iterate."
- Branches never touch the original, so there was nothing to protect by approving them.
- Quiet notifications suit student makers sharing unfinished work. A request queue turns creators into gatekeepers.
- It shrinks Prototype 3, which leaves more time for polish before the deadline.

**Alternatives considered:**
- **Branches join the original story directly.** Rejected because anyone could change someone else's story. It would need moderation before it felt safe.
- **The creator can pull a branch into the story after the notification.** Rejected because it brings approval back in a lighter form.

**Familiar or new:** new. Forking on GitHub works similarly, but we chose this to match "help, not permission," not by default.

**Still open:** how a branch looks different from the original story in the graph, and whether Report or Block is needed for the prototype.
