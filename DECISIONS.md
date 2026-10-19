# Decisions

Significant product and design choices, newest first. Each entry is also raw material for the "how we got here" part of the submission video.

## October 19, 2026: Takeaways isometric grid, in progress (Decision 019)

**Status:** In progress, not finished. Built in `IsometricContributionGrid.swift`: the flat and isometric grid, blurred artifact images inside slabs, "Artifact · time" callouts, and the FLAT/ISOMETRIC toggle with tilt → extrude → callout fade. Not built yet: the arrival sequence (step c), tap → moment sheet in Insights (step d), and the team receipt with the Solo/Group toggle (step e). The Takeaways light sweep is removed. The sweep constants remain in `ContributionGrid.swift` only because `ProfileHistoryGridView` still uses them.

**Decided:**
1. **2D projection, not a 3D engine.** One projection maps (column, lane) to screen points: rotate by 45° × t, then scale Y by 1 − 0.42 × t. Animating t from 0 (flat) to 1 (isometric) gives the tilt. Every block is a rounded `Path` with that transform applied.
2. **Rejected first isometric look.** The step (a) render had hard, darker side faces, one block per 2s slice and a sprite on every lane. The user rejected it ("I don't like this at all") and pointed to a reference frame.
3. **Moments, not slices.** Consecutive 2s slices of one agent merge into one long slab. Each empty run becomes one wide outlined tile. Aim for 3 to 6 large pieces per lane.
4. **Frosted slabs in agent colour.** Short, blurred, translucent slabs with a soft glow, tinted with each agent's gradient (Maya purple, Theo orange, Alex blue, Sam green). No hard side faces. All slabs share one low height; intensity shows as glow and opacity.
5. **Artifact callouts.** A slab whose moment contains a `KnowledgeEntry` with media shows that image, blurred, inside the slab, tinted with the agent's colour. Each such slab gets one outlined callout on a stem: "Artifact name · 0:07–0:11". The image is still at rest; tapping opens the moment sheet, where silent playback would live.
6. **No sprites on the grid.** Agents are identified by colour, and by name on tap. This drops the hop pass and the sprite-tap highlight.
7. **Arrival.** Rows fade in, then the tilt, then slabs rise column by column (about 1 s), then callouts fade in, then the grid settles. No other motion (one-moment rule, Decision 018).
8. **Tap.** Tapping a block opens `MomentDetailSheet` in Insights (planned, not yet in code). Dismissing leaves the user in Insights filtered to that moment.
9. **Team receipt (planned, not started).** Group view names real teammates by name and colour, not sprites. Tapping a name highlights that person's blocks and dims the rest. The Solo/Group toggle sits on the Session screen before a session; Group opens the receipt after stop. The NEXT STEP card is left out. The teammate frame sets the layout; our palette, naming and button rules take precedence.

**Why:** The user rejected the sprite-on-block look, and the reference frame showed what the grid should feel like. Artifact callouts make the grid show the work, which is the project-is-the-story principle. Removing sprites and the sweep follows the no-decoration rule.

**Alternatives considered:**
- Hard isometric side faces (step a): rejected by the user.
- Sprite hop pass and sprite-tap highlight: dropped once sprites left the grid.
- A "strongest 3 to 4 moments" tag rule: replaced by artifact callouts.
- A 3D engine: not used; the plan chose 2D math only.
- Haptics on the toggle and on sprite taps: rejected by the user.

**Defaults (per spec):** Solo Takeaways defaults to ISOMETRIC, remembered per app session and ISOMETRIC on launch. The Team receipt strip defaults to FLAT. These are two different screens. The agent highlight by long press is to be confirmed at step (d).

**Familiar or new:** new for this project. A tilting 2D grid with slabs and artifact callouts has no precedent in our earlier work.

## October 19, 2026: Global iOS rules for onboarding, safe areas and motion (Decision 018)

**Decided:**
1. **Onboarding wash.** The Welcome wash (warm off-white with lavender and sage glows, dimmed in dark mode) runs behind every onboarding step from Welcome through Sync. It is never part of a step transition. It fades out when onboarding ends. The main tabs stay plain white or black.
2. **Safe areas.** Only background layers ignore the safe area. Root cause: `.ignoresSafeArea` on the whole onboarding `GeometryReader` made the top inset read as 0. The shared `ScreenHeader` sits 12 pt below the top safe area.
3. **@nickname banner.** Shown only on Profile, Integrations and Sync, 8 pt below the safe area. Hidden on Intro, Quiz, Talk and Reveal.
4. **Family accent.** The selected tab uses the user's family colour. Light: Cloud `#7E5FA6`, Bloom `#C9652F`, Prism `#2F7FA3`, Spark `#5E8A56`. Dark: Cloud `#A083BC`, Bloom `#E39A57`, Prism `#4598BB`, Spark `#8AAE83`. Guests use Cloud. All are at least 3:1.
5. **One-moment rule.** Each screen gets one arrival moment of motion. After it settles, only ambient motion remains (blinking, marquee rows). Never two attention-grabbing animations at once.
6. **Haptics.** The older rule "every interactive state change triggers a haptic" is replaced. Haptics fire at the moments the user approved: quiz answer selection, Reveal sprite tap and success, and capture success. The Takeaways screen has none. Other haptics still in the code (for example the scripted live-meeting entry and the Integrations and Syncing feedback) are not yet reviewed against this rule.
7. **Fonts.** Berkeley Mono files are not bundled; SF Mono is the accepted fallback. `UIAppFonts` was removed from `Info.plist` after missing fonts caused a blank screen.
8. **Testing.** Test on iPhone 17 and iPhone 17 Pro Max only (no iPhone SE). Agents never use the user's simulator.
9. **Review.** Three reviewer rounds. Round 3 passed all four areas.

**Why:** The existing rules did not describe the wash, the safe-area bug, the approved exceptions or the one-moment rule. The one-moment rule came from the Takeaways brief.

**Alternatives considered:**
- Keep "every state change triggers a haptic": rejected by the user, because it adds noise to the moments that should be quiet.
- Ignore the safe area on the whole onboarding screen: caused the header bug above.
- Use a bundled Berkeley Mono: not done. The SF Mono fallback was accepted.

**Familiar or new:** the one-moment rule is new for this project. The safe-area and font decisions are ordinary iOS practice.

## October 19, 2026: Welcome keeps the original full-width buttons (Decision 017)

**Decided:** The round-arrow Welcome with text links was rejected. The original full-width "Try YaYa without an account" (black) and "Sign up" (outlined) buttons and the "Already have an account? Sign in" line are restored. Welcome is an approved exception to the rule against full-width bottom buttons. The new wordmark and both cloud eyes stay visible.

**Why:** The user judged the arrow version against the original and chose the original. The override is recorded here so later reviewers do not restore the arrow.

**Alternatives considered:** The round-arrow Welcome with text links (rejected by the user).

**Familiar or new:** familiar. This is the original design.

## October 19, 2026: YaYa wordmark, icon mark, app icon and launch splash (Decision 016)

**Decided:**
1. **Wordmark.** The bold sans letterforms from `docs/references/brand/yaya-wordmark-black.svg`, with gradient eyes (`#A083BC` to `#4598BB` and `#E39A57` to `#8AAE83`), embedded as a SwiftUI `Shape`. Not Berkeley Mono. No font file is needed.
2. **Icon mark.** A black rounded square with two white eyes, matching `yaya-icon-rounded.svg`. It is used on Welcome (as the wordmark) and on the launch splash.
3. **App icon.** A full-bleed 1024 black square, with dark and tinted variants, generated by `BranchiOS/scripts/render-app-icon.swift`.
4. **Launch.** The static system launch screen hands off to `LaunchSplashView`, which draws the same mark, blinks once and fades to Welcome or the app.
5. **Shared blink.** A `BlinkClock` drives the blinks for the sprites and both logos.
6. **Xcode app wrapper.** `BranchiOS/YaYa.xcodeproj` carries the icon and launch screen to the home screen. A Swift package executable cannot.

**Why:** The user wanted the brand to match the SVG proportions. The SVGs are now the checked-in source. A system launch screen cannot animate, so a SwiftUI takeover keeps it pixel-identical.

**Alternatives considered:**
- Berkeley Mono wordmark (the plan's first version): replaced by the SVG letterforms.
- Old logos (four-colour mark, "YAYA." gradient pill, "YA²"): not found anywhere in the repository, so there was nothing to remove.
- Package executable only, with no app wrapper: rejected, because the icon would not reach the home screen.

**Familiar or new:** familiar for the icon and launch screen. The blinking eyes are our own motif.

## October 19, 2026: Onboarding order, intent quiz and simulated talk (Decision 015)

**Decided:**
1. **Order.** Welcome, Sign up, Profile, Intro, Quiz or Talk, Reveal, Integrations, Sync, then the app. The `OnboardingStep` enum matches this.
2. **Profile first.** Profile's Continue goes to Intro. Intro greets with the first word of the Profile name ("Hi Cash,"), or "Hi there," if the name is empty. There is no provider name and no `firstName` field.
3. **Quiz to family.** Three questions, four answers each. The family with the most votes wins; a tie goes to the Q1 answer. The result sets the sprite family and seeds the Profile radar. Auto-advance after 0.6 s; Reduce Motion turns it off.
4. **Talk is simulated.** A scripted talk (`TalkScript`) with no audio capture and no speech recognition. It ends when the script ends and goes to Reveal. "Write instead" takes typed text, matched by keyword on word boundaries.
5. **Reveal.** The sprite settles into the revealed family. Tapping the sprite cycles families. The arrow or top-right Continue goes to Integrations. Reveal overrides the Profile sprite unless the user chose a photo; the family is still saved.
6. **Skip.** Skip on Intro and Quiz goes to Integrations and keeps the Profile sprite.
7. **Morphing sprite.** Shape changes use a point-sampled morph with a spring. The crossfade is the fallback behind the `-spriteCrossfade` launch argument. Intro cycles through Cloud, Spark, Prism and Bloom every 2.5 s.

**Why:** The user wanted a short "get to know you" pass that sets the first shape. Putting name and avatar first means the quiz result lands on a known person. Talk gives a second path without building speech recognition.

**Alternatives considered:**
- Whiteboard order (sign up, quiz, create context, profile): the approved order differs. UIUX.md still shows the whiteboard order (see the status note there).
- Provider first name, or a `-providerFirstName` argument: dropped.
- Full mockup approval before build (AGENTS.md Option A): waived by the user (Option B). The frames plus the plan were the approved design.
- Crossfade only: kept as the fallback, not the default.
- Real speech recognition: not built.

**Open:** UIUX.md section N04 says the intent question is "not a scored quiz." The approved quiz produces a family result, which is a scored mapping. The team should decide whether to keep it.

**Familiar or new:** new. A quiz that maps to a shape, plus a simulated talk, is not a pattern we have used before.

## October 19, 2026: YaYa name, native tab bar, project picker and capture cluster (Decision 014)

**Decided:**
1. **Name.** The app is called YaYa. Every "Ya Ya" in `BranchiOS/Sources` is renamed. Where it meant the project, it became "Making YaYa". Internal IDs such as `"yaya"` and launch arguments are unchanged. The docs still use "Branch" as the workspace name; whether the docs rename is not decided.
2. **Native tab bar.** Four system tabs in a `TabView`: YaYa, Projects, Insights, Profile. The custom glass bar is removed, so Reduce Transparency and Increase Contrast work through the system. The Profile tab icon is the user's sprite, rendered once.
3. **"Recording to" picker.** A top-left pill showing the active project: Making YaYa (default) or Critical design P3. It is a `Menu` with an inline picker. It is locked during a session.
4. **Capture cluster.** Camera, Record and Paste in one row. The label under it reads "Start session" or the elapsed time. Record starts and stops the session.
5. **Paste.** The system `PasteButton` is kept, although it renders as a grey circle. The user chose this to avoid a paste prompt that a custom button would trigger.

**Why:** The user wanted photos and links to join a session as it happens. The system tab bar removes custom chrome and follows the iOS accessibility settings.

**Alternatives considered:**
- Custom glass tab bar: replaced by the system `TabView`.
- Custom glass paste button: rejected, because it would trigger the paste prompt.
- The frame's names, warm background and yellow play button: ignored under the global rules (plain white or black, primary-coloured record button).

**Not recorded as answered:** the plan's extra additions (URLs copied as plain text, tapping the toast to open Insights, the picker selection haptic). Some are in the code, but the user's yes or no is not in the plan. Confirm them.

**Familiar or new:** the tab bar and paste button are familiar platform patterns. The capture cluster and project picker are new for this product.

## October 19, 2026: Live Map Actor-Discourse Network & Cognitive Emergence (Decision 013)

**Decided:**
1. **Ben Shaw Cognitive Emergence Architecture:**
   - Grounded the Live Map tab in Ben Shaw's "A Cognitive Account of Collective Emergence in Design" (slides 46, 49, 52–56).
   - Positioned the four team agents at perimeter quadrants (Maya, Theo, Sam, Alex) with the user anchor at the center ("You"), visualizing real-time discourse evolution and idea genesis.
   - Implemented discourse links with distinct visual and semantic weights: solid directional links for `buildsOn`, subtle curved links for `transforms`, bold contrasting links for `challenges`, and converging multi-actor links for `combines`.
   - Highlighted emergent combination ideas (e.g. `s3_08` "Stories from dialogue") with iridescent dual-gradient bloom rings (`◎`) and two-line merging iconography.
2. **Pinned Throughline Card & Interactive Filtering:**
   - Designed a frosted glass Throughline Card beneath the header showing `◎ YOUR THROUGHLINE` in Berkeley Mono plus the user's latest emergent insight, answering the designer's primary orientation question in one glance.
   - Added filter chips (`+ 5`, `− 2`, `? 1`, `// 2`, `◎ 1`) that isolate specific move types and dim the remainder of the graph to 10% opacity.
   - Actor isolation mode: Tapping any actor (User or Agent) isolates their discourse trajectory and dims other actors and unlinked ideas.
3. **Friction Resolution Sheet (M4 Pattern):**
   - Implemented the friction resolution sheet directly modeled on teammate frame M4 layout with strictly four non-AI actions: "Keep mine" (primary bold filled), "Use Ya Ya's", "Keep both", and "Not now". Strictly eliminated generic chatbot prompts like "Talk it through".
   - Resolving friction dynamically updates node appearance (red counterpoint stroke turns into resolved state with checkmark) and immediately updates live takeaways.
4. **Shared KnowledgeEntry Data Model:**
   - Unified `LiveMapView` and `KnowledgeView` around the shared `KnowledgeEntry` model, with live resolution state synced across tabs via `DemoStore`.
5. **Anti-Slop Craft Standards:**
   - Plain white/black backgrounds (zero dot grids, zero web-like colored washes), black/white ink, Berkeley Mono for small labels, original sprite proportions, 44pt touch targets, and full clearance for the floating liquid glass tab bar.

**Why:** Creative emergence in interdisciplinary teams happens through conversational moves and synthesis, not retroactive meeting notes. The Live Map makes this cognitive phenomenon legible, interactive, and actionable for human designers.


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


## October 18, 2026: SyncingView Orbital Choreography, Dynamic Hub Navigation, and Sprite Flex Arm

**Decided:**
1. **Orbital Choreography & Hand-Off:** Built `SyncingView` bridging `IntegrationsView` and `HomeView` with zero-jump visual continuity:
   - Beat 0 (Hand-off): Sprite and connected orbs continue juggling in rhythm while the avatar orb joins the apex of the loop.
   - Beat 1 & 2 (Big Toss & Gathering): Single large heave launches orbs upward; central 136pt circular hub draws in with trim (0→1); sprite slides down and to the right into the lower corner with left arm resting low; integration orbs loosely orbit clockwise at 25% opacity with gentle floating bobbing. Copy: "Gathering your things...".
   - Beat 3 (Pulling In / Almost There): Orbs drift inward staggered by 0.2s, transition 25% → 100% opacity with soft spring physics and lifted drop shadows. Copy: "Mixing it all together...".
   - Beat 4 (Complete): Orbit stops; orbs settle snug against the hub with 0.95 squash/rebound; hub fills from center outward with user's sprite color; bold high-contrast `arrow.right` scales in at center; sprite left arm curls up into a 90° bicep flex with a springy bounce and executes a happy double blink; copy reads "Yummy! Delicious!".
2. **Dynamic Hub as Primary Forward Action:** In Beat 4 ("Complete"), the entire filled hub becomes the primary interactive button (scales to 0.96 on press with medium haptic, VoiceOver labeled "Continue, button") to advance to `HomeView`. The shared text `Continue` button at top-right fades in simultaneously as a persistent fallback.
3. **Animatable `SpriteFlexArmShape`:** Created animatable custom Shape transitioning `flexProgress` from 0.0 (resting outward hanging curve) to 1.0 (90° vertical forearm bicep flex).
4. **Resilience & Accessibility:** Full VoiceOver live region announcements for each beat transition, instant state jumps when Reduce Motion is enabled, mid-sync relaunch recovery from Beat 1, and zero-integration handling skipping Beat 3 drift directly into hub fill.
