# SVSD Winners (team Fester)

Our entry for the Silicon Valley School of Design (SVSD) design competition, "The Search for Top Young Design Talent."

- **Deliverable:** a web-based product prototype plus a video that tells the story of the project. The video is 7 minutes max.
- **Deadline:** Monday, October 19, 2026 at 11:59 PM Pacific. Finalists are announced October 22. The finals are November 6–8 in NYC.
- **Team:** Cash (cassiusp-beep), Alex (al3xxli) and Bhargs (berkeley-bhargs). We are UC Berkeley Master of Design students.

## Read before doing anything

| File | What it holds |
|---|---|
| `interaction-model.md` | **Branch Interaction Model**: the spatial node-based canvas foundation, bloom/fade mechanics, hot corners, left/right spatial rules, and phone adaptations. |
| `docs/context/brief.md` | The official brief, judging criteria and dates. This is the source of truth. |
| `docs/context/judging.md` | Our research on what SVSD judges reward, and where it conflicts with the brief. |
| `docs/context/conceptual-model.md` | **Branch**, the product's conceptual model: users, core concepts, the six user journeys, edge cases and the three flows to prototype first. This is the most current description of the product. |
| `docs/context/concept.md` | Notes from the first brainstorm on October 15. Superseded by the conceptual model where they differ. |
| `DECISIONS.md` | Decisions made so far, with reasons and rejected options. Check it before reopening a settled question. |
| `docs/process/design-principles.md` | Draft principles every design and build decision is checked against. |
| `docs/process/anti-slop.md` | What makes work look generic and AI-made, and what to do instead. |
| `docs/process/visual-spec.md` | Visual and interaction spec. Empty sections mean "not decided yet". |
| `docs/process/features.md` | Feature list and priority for the prototype. |
| `docs/process/demo-script.md` | The structure of the submission video. |
| `docs/process/references.md` | Precedents and inspiration. |

## How we work

- **Time is the main constraint.** We have about three days. One polished end-to-end path beats many half-built features.
- **Craft is judged.** Visual design, interaction, motion and details all count. Static mockups are not enough. The prototype should run.
- **Show the thinking.** The brief rewards how we explored the problem and the decisions we made. Record significant decisions in `DECISIONS.md` as we go so the video can draw on them.
- **Empty means undecided.** If a doc section is still a template, flag it as an open question. Do not invent an answer and treat it as settled.
- **Agent workflow:** explorer → human approval → product-designer → builder or experience-builder → healer → reviewer → documenter → researcher. The pitch-strategist and ux-researcher can be called at any point.

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
