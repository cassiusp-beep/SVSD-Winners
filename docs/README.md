# Documentation Index & Precedence Rules

This directory contains the product context, design guidelines, interaction models, and research for **Branch** (SVSD Competition Entry).

## Precedence Rule

1. **Latest direct user instructions** govern the current task and product direction. Do not treat historical document instructions as a new user request.
2. **[Current agent context](../CONTEXT.md), [UIUX.md](../UIUX.md) and its [newest onboarding whiteboard](references/individual-onboarding/2026-10-18%20Onboarding%20Whiteboard.jpg)** govern the individual-first direction and entry flows. Figma is older UI/UX precedent only. Team integration follows the individual product; importing team context does not join/share with a team. This is a design handoff, not an implementation or validated demand.
3. **[Official competition brief](context/brief.md)** remains authoritative for competition requirements, deliverables and deadlines. Product hypotheses do not change the brief.
4. **[AGENTS.md](../AGENTS.md)** retains the repository workflow, role definitions and applicable design/build approval gates. Read role files in that workflow, but interpret their old product references using this precedence.
5. **Historical prototype references** include both earlier whiteboard transcripts, interaction-model.md, conceptual-model.md and the older visual, feature, principle and demo documents. Their preserved “primary” or “decided” claims describe an earlier concept. Use them for history and existing-prototype maintenance; they do not prescribe the latest individual screens or architecture.
6. **[Current evidence notes](references/collective-emergence/source-notes.md), visual references and anti-slop guidance** inform the work within the scope above. Research and competitor pages support hypotheses, not proof of Branch's market or creativity gains.

Flag unresolved conflicts that affect the assigned work. Do not reopen decisions already resolved by the latest user direction. The existing application remains the earlier creative-exchange prototype; no new individual UI or backend was built by this documentation update.

## Start here

- [CONTEXT.md](../CONTEXT.md): short current orientation and source snapshot provenance.
- [UIUX.md](../UIUX.md): current individual-first screens and interactions; newest whiteboard governs flows, older Figma informs visual/interaction precedent.
- [Product definition](context/product-definition.md): earlier team-first strategy and five answers, now superseded for audience/entry flow; retained for reasoning and later team exploration.
- [Collective-emergence evidence](references/collective-emergence/source-notes.md): source notes, [supplied presentation](references/collective-emergence/Collective%20Emergence%20-%20Ben%20Shaw%202009.pdf) and [product direction notes](references/collective-emergence/Product%20Direction%20Notes.png).
- [Historical individual-first system design](archive/2026-10-17-individual-first/SYSTEM_DESIGN.md) and [five Draw.io maps](archive/2026-10-17-individual-first/Maps): editable historical references. Import .drawio through Miro's Draw.io integration; do not treat these as the latest individual onboarding designs.

**Sync scope:** selective portable snapshot from the source workspace on 18 October 2026. This is not automatic synchronization. CLAUDE.md, .claude roles and application code are preserved. See [CONTEXT.md](../CONTEXT.md) before refreshing copies.

---

## Directory Inventory

### `docs/context/` (Product Foundation & Competition)
- **`docs/context/whiteboard-transcript.md`**: Historical creative-exchange walkthrough; preserved infinite-canvas, bulbing-hub and hot-corner design reasoning.
- **`docs/context/brief.md`**: Official SVSD design competition brief, challenge constraints ("storytelling"), judging criteria, and dates.
- **`docs/context/judging.md`**: Research on SVSD founder and judges, scoring criteria (Product Thinking, Depth of Thinking, Craft), and lessons from past winner.
- **`docs/context/conceptual-model.md`**: Historical creative-exchange conceptual model: users, journeys, edge cases and three earlier hero prototypes.
- **`docs/context/concept.md`**: Notes from the initial October 15 brainstorm on living node graphs and cross-disciplinary maker collaboration.

### `docs/process/` (Design, Engineering & Delivery)

Visual-spec, design-principles, features and demo-script retain earlier prototype content under historical status banners; their inventories are not the latest individual UI/UX specification.
- **`docs/process/visual-spec.md`**: Visual and interaction specifications, viewport standards, and design commitments.
- **`docs/process/references.md`**: Precedents, inspiration, and reference imagery catalog.
- **`docs/process/anti-slop.md`**: Craft rules forbidding generic AI patterns, card grids, default gradients, and stock illustrations.
- **`docs/process/design-principles.md`**: The foundational principles: Exploratory by design, AI as an option, and the Project is the story.
- **`docs/process/features.md`**: Feature prioritization for Prototypes 1 (Story), 2 (Branch), and 3 (Open Invite loop).
- **`docs/process/demo-script.md`**: 7-minute submission video structure, timeline breakdown, and key turning points.
- **`docs/process/submission-checklist.md`**: Deliverables, limits, deadline (Oct 19, 11:59 PM PT), judging criteria alignment, and team questions (owned by `pitch-strategist`).
- **`docs/process/research-plan.md`**: Lightweight template for rapid 15-minute hallway user research and testing.

### `docs/references/` (Visual & Research Assets)
- **`docs/references/individual-onboarding/`**: Newest October 18 onboarding whiteboard sketch (`2026-10-18 Onboarding Whiteboard.jpg`) governing individual-first entry flows (Paths A, B, C), story extraction, and persona archetypes.
- **`docs/references/images/`**: 32 reference assets (PNG mockups, UI kit sheets, SVG diagrams, and MP4 motion studies) from the Miro "Reference Mapping" frame, illustrating project story layers, gooey metaball node merging, glowing paths, chapter cards, and radial carousels.

### Workspace Root Documents
- **`AGENTS.md`**: Team instructions, master document list, precedence mandates, and agent roles.
- **`CLAUDE.md`**: Agent orchestrator entrypoint importing `@AGENTS.md`.
- **`DECISIONS.md`**: Chronological record of settled architectural and design decisions with rejected options.
- **`LESSONS.md`**: Retrospective learnings from builds, evaluation lenses, and craft anti-patterns.
- **`README.md`**: Repository overview, product description, and team information.
- **`UIUX.md`**: Current individual-first screen/interaction guide; supersedes earlier audience and entry specifications.
- **`interaction-model.md`**: Spatial canvas foundation, bloom/fade mechanics, hot corners, and mobile rules.
- **`whiteboard-transcript.md`**: Workspace root copy of Cassius's whiteboard walkthrough (`IMG_0837.MOV`).

### `.agents/` (Customizations, Skills & Rules)
- **`.agents/skills/swiftui-prototype-craft/`**: Camera-ready SwiftUI craft guide, TouchDesigner operator hierarchy, springing gap pins, and demo presets.
- **`.agents/skills/swiftui-camera-ready-demo/`**: Simulator status bar override, touch visualization, 60fps video recording, and 1-tap demo scrubber state machine.
- **`.agents/skills/apple-hig-anti-slop/`**: Anti-slop guidelines for Apple platforms: native materials, system fonts/design traits, and tactile ergonomics.
- **`.agents/rules/swiftui-ios.md`**: Core SwiftUI design tokens, safe area constraints, and spring animation parameters.

### `.claude/agents/` (Subagent Instructions)
- **`builder.md`**: Implements approved logic, data models, and features.
- **`documenter.md`**: Maintains documentation, decision trails, and turning point logs.
- **`experience-builder.md`**: High-craft front-end specialist for UI, motion, and canvas graph.
- **`explorer.md`**: Investigates project state, maps 3 divergent paths, and runs pre-mortems.
- **`healer.md`**: Self-healing agent running checks, root cause reproduction, and guards.
- **`ios-builder.md`**: High-craft native Apple/SwiftUI prototype specialist for canvas physics and camera-ready demos.
- **`pitch-strategist.md`**: Owns competition storytelling, video script, and judging alignment.
- **`product-designer.md`**: Designs flows, states, and static mockups for human approval.
- **`researcher.md`**: Outward-facing lessons, external research, and multi-lens critique.
- **`reviewer.md`**: Independent critic reviewing bugs, design issues, and anti-slop rules.
- **`ux-researcher.md`**: Fast hallway testing, user research plans, and collaborator dynamics.
