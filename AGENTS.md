# SVSD Winners (team Fester)

Our entry for the Silicon Valley School of Design (SVSD) design competition, "The Search for Top Young Design Talent."

- **Deliverable:** a web-based product prototype plus a video that tells the story of the project. The video is 7 minutes max.
- **Deadline:** Monday, October 19, 2026 at 11:59 PM Pacific. Finalists are announced October 22. The finals are November 6–8 in NYC.
- **Team:** Cash (cassiusp-beep), Alex (al3xxli) and Bhargs (berkeley-bhargs). We are UC Berkeley Master of Design students.

## Read before doing anything

Every agent reads `docs/README.md` first and follows its precedence rule.

| File | What it holds |
|---|---|
| `docs/context/whiteboard-transcript.md` | **Whiteboard Transcript: Branch Interaction Walkthrough**: Primary source of truth from Cassius's walkthrough (`IMG_0837.MOV`). Single infinite canvas, profile at center, bulbing radial options, drag-in project genesis, gooey morph on drag, and hot corners. |
| `whiteboard-transcript.md` | Workspace root copy of Cassius's whiteboard walkthrough. Matches `docs/context/whiteboard-transcript.md`. |
| `interaction-model.md` | **Branch Interaction Model**: the spatial node-based canvas foundation, bloom/fade mechanics, hot corners, left/right spatial rules, and phone adaptations. |
| `docs/context/brief.md` | The official brief, judging criteria and dates. This is the source of truth. |
| `docs/context/judging.md` | Our research on what SVSD judges reward, and where it conflicts with the brief. |
| `docs/context/conceptual-model.md` | **Branch**, the product's conceptual model: users, core concepts, the six user journeys, edge cases and the three flows to prototype first. This is the most current description of the product. |
| `docs/context/concept.md` | Notes from the first brainstorm on October 15. Superseded by the conceptual model where they differ. |
| `DECISIONS.md` | Decisions made so far, with reasons and rejected options. Check it before reopening a settled question. |
| `LESSONS.md` | Lessons learned from previous builds, retro lenses, and craft constraints. |
| `docs/process/design-principles.md` | Draft principles every design and build decision is checked against. |
| `docs/process/anti-slop.md` | What makes work look generic and AI-made, and what to do instead. |
| `docs/process/visual-spec.md` | Visual and interaction spec, including canonical "Color: Night Lab" palette. |
| `docs/process/features.md` | Feature list and priority for the prototype. |
| `docs/process/demo-script.md` | The structure of the submission video. |
| `docs/process/references.md` | Precedents, inspiration, and reference imagery catalog. |
| `docs/references/images/` | Visual and motion reference assets (32 files from Miro reference mapping). |
| `docs/process/submission-checklist.md` | Competition deliverables, deadline, criteria mapping, and team questions (owned by `pitch-strategist`). |
| `docs/process/research-plan.md` | Lightweight hallway testing and research guide template. |
| `docs/README.md` | Documentation index and precedence rules. |
| `UIUX.md` | Screen-by-screen specification, visual tokens, and interface contracts. |
| `CLAUDE.md` | Agent orchestrator entrypoint importing `@AGENTS.md`. |
| `README.md` | Repository overview, product description, and team information. |

## How we work

- **Time is the main constraint.** We have about three days. One polished end-to-end path beats many half-built features.
- **Craft is judged.** Visual design, interaction, motion and details all count. Static mockups are not enough. The prototype should run.
- **Show the thinking.** The brief rewards how we explored the problem and the decisions we made. Record significant decisions in `DECISIONS.md` as we go so the video can draw on them.
- **Empty means undecided.** If a doc section is still a template, flag it as an open question. Do not invent an answer and treat it as settled.
- **Autonomous operation & human gate:** Work autonomously, with one exception: product-designer's mockup must be approved by a human before builder or experience-builder implement it.
- **Visual review mandate:** reviewer and product-designer must run `npm run shots` and look at the images before giving any verdict. Code-only review does not count.
- **Subagent delegation:** When delegating to a subagent, the orchestrator passes the file paths it needs and the outputs of previous steps. Never assume a subagent knows the context. When delegating, the orchestrator passes the paths of the references relevant to the slice.
- **Deploy command:** To deploy to Vercel: `VERCEL_NO_UPDATE_NOTIFIER=1 npx --yes vercel --yes --name svsd-branch --prod`. Live production URL: https://svsd-branch.vercel.app

## Required agent pipeline (mandatory for every slice)

The main session is the orchestrator only. It delegates every step to the named agent in `.claude/agents` and never does an agent's job itself. When delegating to a subagent, the orchestrator passes the file paths it needs and the outputs of previous steps. Never assume a subagent knows the context. When delegating, the orchestrator passes the paths of the references relevant to the slice.

1. **explorer**: map current code relevant to the slice
2. **researcher**: extract requirements from `docs/context/*`, `docs/process/*`, `docs/process/references.md`, reference images in `docs/references/images/`, and `docs/context/whiteboard-transcript.md`, with citations
3. **ux-researcher**: map the slice to `conceptual-model.md` journeys; write experience-test beats
4. **product-designer**: design against `docs/process/visual-spec.md`, `docs/process/anti-slop.md`, `docs/process/references.md`, and reference images in `docs/references/images/` (open every image; name which references it draws from); deliver one static mockup and wait for team approval
5. **builder**: data model, state, logic
6. **experience-builder**: canvas, interactions, motion, using motion and interaction references in `docs/process/references.md` and `docs/references/images/` (especially morphing nodes) as the target behavior
7. **healer**: fix all errors and broken paths
8. **reviewer**: independent pass/fail vs docs + compare screenshots against reference images in `docs/references/images/` + experience test at 1440px and 390px
   - FAIL → return to the owning agent (visual: product-designer, interaction: experience-builder, bug: healer), then re-run reviewer
9. **documenter**: update docs, `DECISIONS.md`, and turning points
10. **pitch-strategist**: align slice with judging criteria and update `demo-script.md`

## Agent roles

This file is read by any AI coding assistant, including ChatGPT, Codex and Claude Code. Each role below has full instructions in `.claude/agents/<name>.md`. The block at the top of each file between `---` lines is settings for Claude Code and can be ignored by other tools. When asked to act as a role, read its file and follow the instructions below that block.

| Role | Use it to |
|---|---|
| explorer | Map the current state and propose several different approaches before anything is built. It never changes files. |
| pitch-strategist | Sharpen the audience, the storytelling angle and the principles, and write the video script. |
| ux-researcher | Plan and synthesize quick research with real people. |
| product-designer | Design flows, screens, states and motion specs before building. |
| builder | Implement an approved plan. |
| experience-builder | Implement UI, motion and the node graph to a high craft bar. |
| healer | Run checks, fix bugs at the root, and add guards. |
| reviewer | Critique finished work against the brief, the principles and the anti-slop rules. |
| documenter | Keep docs and `DECISIONS.md` current. |
| researcher | Look outward for lessons and record them in `LESSONS.md`. |

Without a subagent feature, run these roles one at a time in the workflow order above, and stop for human approval after the explorer.
