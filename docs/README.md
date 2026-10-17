# Documentation Index & Precedence Rules

This directory contains the product context, design guidelines, interaction models, and research for **Branch** (SVSD Competition Entry).

## Precedence Rule

When files conflict, the higher one in this list wins. Always flag the conflict to the human team before proceeding:

1. **`docs/context/whiteboard-transcript.md`** — Primary source of truth from Cassius's walkthrough (`IMG_0837.MOV`). Single infinite canvas, profile at center, bulbing radial options, drag-in project genesis, gooey morph on drag, and hot corners.
2. **`interaction-model.md`** — The spatial node-based canvas foundation, bloom/fade mechanics, hot corners, left/right spatial rules, and phone adaptations.
3. **`docs/process/visual-spec.md`** — Visual and interaction specifications, viewports (1440px / 390px), tokens, and component requirements.
4. **`docs/process/references.md` and `docs/references/images/`** — Precedents, visual benchmarks, and reference imagery catalog. References inform the look; they don't override the transcript, the interaction model, or the spec.
5. **`docs/process/anti-slop.md`** — Anti-slop constraints: eliminates generic AI output, cards-in-a-grid, default gradients, and filler copy.
6. **`UIUX.md`** — Detailed screen-by-screen reference mapping, token scales, and cross-screen craft criteria.
7. **Everything else** — Supporting notes, brainstorms, and templates below.

---

## Directory Inventory

### `docs/context/` (Product Foundation & Competition)
- **`docs/context/whiteboard-transcript.md`**: Primary source of truth from the recorded whiteboard walkthrough; defines infinite canvas, bulbing hub, and hot corners.
- **`docs/context/brief.md`**: Official SVSD design competition brief, challenge constraints ("storytelling"), judging criteria, and dates.
- **`docs/context/judging.md`**: Research on SVSD founder and judges, scoring criteria (Product Thinking, Depth of Thinking, Craft), and lessons from past winner.
- **`docs/context/conceptual-model.md`**: The complete conceptual model of Branch: users, core concepts, journeys, edge cases, and the 3 hero prototypes.
- **`docs/context/concept.md`**: Notes from the initial October 15 brainstorm on living node graphs and cross-disciplinary maker collaboration.

### `docs/process/` (Design, Engineering & Delivery)
- **`docs/process/visual-spec.md`**: Visual and interaction specifications, viewport standards, and design commitments.
- **`docs/process/references.md`**: Precedents, inspiration, and reference imagery catalog.
- **`docs/process/anti-slop.md`**: Craft rules forbidding generic AI patterns, card grids, default gradients, and stock illustrations.
- **`docs/process/design-principles.md`**: The foundational principles: Exploratory by design, AI as an option, and the Project is the story.
- **`docs/process/features.md`**: Feature prioritization for Prototypes 1 (Story), 2 (Branch), and 3 (Open Invite loop).
- **`docs/process/demo-script.md`**: 7-minute submission video structure, timeline breakdown, and key turning points.
- **`docs/process/submission-checklist.md`**: Deliverables, limits, deadline (Oct 19, 11:59 PM PT), judging criteria alignment, and team questions (owned by `pitch-strategist`).
- **`docs/process/research-plan.md`**: Lightweight template for rapid 15-minute hallway user research and testing.

### `docs/references/images/` (Visual & Motion Reference Assets)
- **`docs/references/images/`**: 32 reference assets (PNG mockups, UI kit sheets, SVG diagrams, and MP4 motion studies) from the Miro "Reference Mapping" frame, illustrating project story layers, gooey metaball node merging, glowing paths, chapter cards, and radial carousels.

### Workspace Root Documents
- **`AGENTS.md`**: Team instructions, master document list, precedence mandates, and agent roles.
- **`CLAUDE.md`**: Agent orchestrator entrypoint importing `@AGENTS.md`.
- **`DECISIONS.md`**: Chronological record of settled architectural and design decisions with rejected options.
- **`LESSONS.md`**: Retrospective learnings from builds, evaluation lenses, and craft anti-patterns.
- **`README.md`**: Repository overview, product description, and team information.
- **`UIUX.md`**: Detailed screen-by-screen reference mapping, token scales, and cross-screen craft criteria.
- **`interaction-model.md`**: Spatial canvas foundation, bloom/fade mechanics, hot corners, and mobile rules.
- **`whiteboard-transcript.md`**: Workspace root copy of Cassius's whiteboard walkthrough (`IMG_0837.MOV`).

### `.claude/agents/` (Subagent Instructions)
- **`builder.md`**: Implements approved logic, data models, and features.
- **`documenter.md`**: Maintains documentation, decision trails, and turning point logs.
- **`experience-builder.md`**: High-craft front-end specialist for UI, motion, and canvas graph.
- **`explorer.md`**: Investigates project state, maps 3 divergent paths, and runs pre-mortems.
- **`healer.md`**: Self-healing agent running checks, root cause reproduction, and guards.
- **`pitch-strategist.md`**: Owns competition storytelling, video script, and judging alignment.
- **`product-designer.md`**: Designs flows, states, and static mockups for human approval.
- **`researcher.md`**: Outward-facing lessons, external research, and multi-lens critique.
- **`reviewer.md`**: Independent critic reviewing bugs, design issues, and anti-slop rules.
- **`ux-researcher.md`**: Fast hallway testing, user research plans, and collaborator dynamics.
