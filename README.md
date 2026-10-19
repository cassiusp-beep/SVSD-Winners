# SVSD Winners: Branch

Team Fester's entry for the Silicon Valley School of Design (SVSD) design competition: **"The Search for Top Young Design Talent."**

- **Deliverable:** Web-based product prototype + 7-minute submission video.
- **Deadline:** Monday, October 19, 2026 at 11:59 PM Pacific. Finalists announced October 22. Finals in NYC on November 6–8.
- **Team:** Cash ([cassiusp-beep](https://github.com/cassiusp-beep)), Alex ([al3xxli](https://github.com/al3xxli)), and Bhargs ([berkeley-bhargs](https://github.com/berkeley-bhargs)) — UC Berkeley Master of Design students.
- **Live Prototype:** [https://svsd-branch.vercel.app](https://svsd-branch.vercel.app)

---

## Active Pivot & Direction (18 October 2026)

> [!IMPORTANT]
> **Major Pivot:** We are **completely scrapping the first idea** (the collaborative creative-exchange canvas with gooey morphs and team branching). 
>
> We are pivoting to an **individual-first onboarding and storytelling experience**, directly based on the new October 18 whiteboard sketch ([`2026-10-18 Onboarding Whiteboard.jpg`](file:///Users/cassiuspalacio/Documents/SVSD/docs/references/individual-onboarding/2026-10-18%20Onboarding%20Whiteboard.jpg)):
> - **Individual Value First:** Users come to document their own work and gain clarity on their narrative ("Who r you??", "What u want.", "Where they can fit").
> - **Flexible Entry Pathways:** Anonymous 2-minute test recording, quiz narrative alignment, live link/MCP imports, or new context creation.
> - **Story Extraction & Personas:** Dynamic story extraction into evolving personal avatars (*Starting Sprite*, *Pixel Pusher*, *Creative Cloud*, *Technical Triangle*).
> - **Swift iOS Workflow:** Native SwiftUI iOS development workflow defined in [`.agents/skills/swiftui-prototype-craft/SKILL.md`](file://.agents/skills/swiftui-prototype-craft/SKILL.md) and [`.agents/rules/swiftui-ios.md`](file://.agents/rules/swiftui-ios.md) for camera-ready demo execution.

## What We're Building

**Branch establishes value for individuals first:** capture or import thinking, build personal context, then explore how ideas connect. Team integration follows after the individual product is established; team context may be supplied during Import work without joining or sharing with a team.

The latest [UIUX.md](UIUX.md) translates the new onboarding whiteboard into screens and interactions. Older Figma work is UI/UX precedent only. Start with [CONTEXT.md](CONTEXT.md); the [earlier product definition](docs/context/product-definition.md) preserves team-first strategy and is superseded for audience/entry flow. The new experience is a proposal, not something this documentation update implements or validates.

## Scrapped Prototype and Design History (Archived)

The application and mechanics described below belong to the scrapped earlier creative-exchange concept. They remain preserved in `docs/archive/` purely as design history:

**Branch** is a creative exchange for student makers who want to share unfinished work and discover what it could become in someone else's hands.

Instead of static portfolios or isolated card feeds, you land as a node at the center of an **infinite, living canvas**. Projects and collaborators surface and pulse around you. Connections are animated and carry real dialogue: comment snippets, contributions, and shared sources. 

### Core Mechanics & Spatial Rules
1. **Bulbing Radial Options:** Nodes bloom and bulge into each other organically using gooey metaball aesthetics.
2. **Drag-in Project Genesis:** Starting a project is spatial — nearby nodes morph toward whatever you are holding.
3. **Hot Corners:** When a project begins, your profile slides to the top-left, framed by four hot corners:
   - **Top-Left (Profile):** Returns to user hub.
   - **Bottom-Left (Help / Gaps):** Reveals unfilled project needs and open invites with an amber breathing pulse.
   - **Top-Right (Save / Fork):** Instant quiet state sync ("Saved just now").
   - **Bottom-Right (Story):** Scans chapter history, lineage, and timeline scrubber.
4. **Dialogue on Links:** Conversation, references, and critique ride directly on the bezier connectors, never buried in separate chat tabs.
5. **Night Lab Palette:** Deep navy canvas (`#0B0E1A`), glowing amber gaps (`#FFB547`), cyan maker identity (`#4FD8F0`), and saturated maker branches.

The prototype demonstrates three core journeys:
1. **Follow Its Story:** Open a project and watch how it grew across chronological chapters.
2. **Find Your Place:** See where your skills fit, branch a project privately, then keep or publish it.
3. **Open Invite Loop:** A stuck creator flags a need; an explorer branches the project credited beside the original without blocking approval gates.

---

## Quick Start & Local Development

### Prerequisites
- Node.js (v18+)
- npm

### Installation & Running
```bash
# Install dependencies
npm install

# Start local development server (http://localhost:5173)
npm run dev

# Run automated visual reviews (captures 1440x900 and 390x844 viewports via Playwright)
npm run shots

# Production build and preview
npm run build
npm run preview
```

### Production Deployment
Deployed to Vercel production:
```bash
VERCEL_NO_UPDATE_NOTIFIER=1 npx --yes vercel --yes --name svsd-branch --prod
```

---

## Documentation & Precedence

Start at [CONTEXT.md](CONTEXT.md), then [UIUX.md](UIUX.md). [docs/README.md](docs/README.md) defines precedence: latest direct user instructions govern the current direction; the official brief governs competition requirements; AGENTS.md retains the workflow. Earlier whiteboard transcripts, interaction and visual documents are historical prototype references. The current UIUX.md follows the newest onboarding whiteboard; Figma informs UI/UX only. The [archived individual-first system and maps](docs/archive/2026-10-17-individual-first/SYSTEM_DESIGN.md) are also historical, not the latest individual onboarding blueprint.

This repository contains a selective source-workspace snapshot dated 18 October 2026. It is not automatic synchronization, a new implementation, or a deployment.

---

## Repository Structure

| Path | What it holds |
|---|---|
| [CONTEXT.md](CONTEXT.md) | Current individual-first agent entry and source-sync provenance |
| [Product definition](docs/context/product-definition.md) | Earlier team-first strategy; audience/entry superseded by UIUX.md |
| [Collective-emergence references](docs/references/collective-emergence/) | Supplied PDF, direction image and evidence notes |
| [Individual-first archive](docs/archive/2026-10-17-individual-first/) | Historical system design and five editable Draw.io maps |
| [`AGENTS.md`](AGENTS.md) | Team rules, Required Agent Pipeline, and agent role definitions |
| [`CLAUDE.md`](CLAUDE.md) | Agent orchestrator entrypoint importing `@AGENTS.md` |
| [`DECISIONS.md`](DECISIONS.md) | Chronological record of settled architectural decisions and rejected alternatives |
| [`LESSONS.md`](LESSONS.md) | Retrospective learnings from builds and multi-lens critiques |
| [`interaction-model.md`](interaction-model.md) | Spatial canvas rules, bloom/fade mechanics, hot corners, and mobile adaptations |
| [`whiteboard-transcript.md`](whiteboard-transcript.md) | Workspace root copy of Cassius's whiteboard walkthrough |
| [`UIUX.md`](UIUX.md) | Current individual-first screens, states, interactions and UI/UX references |
| [`docs/README.md`](docs/README.md) | Documentation index, directory inventory, and precedence rules |
| [`docs/context/whiteboard-transcript.md`](docs/context/whiteboard-transcript.md) | Historical source for the earlier living-canvas prototype |
| [`docs/context/brief.md`](docs/context/brief.md) | Official SVSD brief, judging criteria, challenge theme, and dates |
| [`docs/context/judging.md`](docs/context/judging.md) | Research on judges, scoring criteria (Product Thinking, Depth of Thinking, Craft) |
| [`docs/context/conceptual-model.md`](docs/context/conceptual-model.md) | Historical creative-exchange model: users, journeys and edge cases |
| [`docs/context/concept.md`](docs/context/concept.md) | Initial October 15 brainstorm notes on cross-disciplinary collaboration |
| [`docs/process/visual-spec.md`](docs/process/visual-spec.md) | Visual and interaction spec, including canonical "Color: Night Lab" palette |
| [`docs/process/references.md`](docs/process/references.md) | Precedents, inspiration catalog, and board notes |
| [`docs/references/images/`](docs/references/images/) | 32 visual and motion reference assets (Miro mapping) |
| [`docs/process/anti-slop.md`](docs/process/anti-slop.md) | Anti-slop rules forbidding generic cards, stock illustrations, and filler copy |
| [`docs/process/design-principles.md`](docs/process/design-principles.md) | Principles: Exploratory by design, AI as an option, Project is the story |
| [`docs/process/features.md`](docs/process/features.md) | Prioritization of the three hero prototype flows |
| [`docs/process/demo-script.md`](docs/process/demo-script.md) | 7-minute submission video structure, timeline breakdown, and turning points |
| [`docs/process/submission-checklist.md`](docs/process/submission-checklist.md) | Deliverable tracking, deadline countdown, and criteria mapping |
| [`docs/process/research-plan.md`](docs/process/research-plan.md) | Rapid hallway user testing guide and script template |
| [`.claude/agents/`](.claude/agents/) | Instructions and Required Reading for all 10 specialized agent roles |

---

## Agent Pipeline & Multi-Agent Collaboration

All automated operations strictly adhere to the mandatory 10-step pipeline in [`AGENTS.md`](AGENTS.md):

`explorer` → `researcher` → `ux-researcher` → `product-designer` (human gate: mockup approval) → `builder` → `experience-builder` → `healer` → `reviewer` (visual inspection mandate at 1440px and 390px) → `documenter` → `pitch-strategist`.
