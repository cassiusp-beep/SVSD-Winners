# SVSD Winners: Branch

Team Fester's entry for the Silicon Valley School of Design competition. The brief asks for a product on the theme of storytelling, built for a specific group of people. Submissions are due Monday, October 19, 2026 at 11:59 PM Pacific.

## What we're building

**Branch** is a creative exchange for student makers who want to share unfinished work and discover what it could become in someone else's hands.

A creator publishes a living **Project Story**: the question that started it, the experiments tried, the decisions made, and the paths not yet explored, all as connected nodes. Others can follow how the project grew, find where they fit, and add a new chapter, and every contributor stays credited. The node graph itself is the story of how a project changes over time.

The prototype focuses on three flows:

1. **Follow Its Story.** Open a project and watch how it grew.
2. **Find Your Place.** See where your skills fit, try a branch privately, then keep it or undo it.
3. **Open Invite loop.** A stuck creator asks for help, an explorer answers, and the contributor is credited.

There are two design principles: **exploratory by design** and **AI as an option**. AI is never required, and every journey works without it.

The full details are in the [conceptual model](docs/context/conceptual-model.md).

## Using AI assistants on this project

All project instructions live in [AGENTS.md](AGENTS.md). Edit that file, not CLAUDE.md, so every tool stays in sync.

- **Claude Code** loads CLAUDE.md automatically, and CLAUDE.md imports AGENTS.md. The agent roles in `.claude/agents/` are available as subagents.
- **Codex**, ChatGPT's coding agent, reads AGENTS.md automatically.
- **ChatGPT through its GitHub connector** should be told to read AGENTS.md first.
- **Any other assistant** can read AGENTS.md and the docs, since they are plain Markdown.

To use an agent role in a tool without subagents, ask it to "act as the product-designer," for example. The role list in AGENTS.md says where each role's instructions are. Each agent file starts with a short settings block between `---` lines. That block is for Claude Code, and other tools can skip it.

## What's where

| Path | What it holds |
|---|---|
| `AGENTS.md` | Project overview, deadline, team, workflow and agent roles |
| `docs/context/conceptual-model.md` | Branch's users, core concepts, user journeys, edge cases and open questions |
| `docs/context/brief.md` | The official SVSD brief, judging criteria and dates |
| `docs/context/judging.md` | Our research on what the judges reward |
| `docs/context/concept.md` | Notes from the first brainstorm |
| `docs/process/features.md` | The three prototype flows, supporting screens and demo data |
| `docs/process/design-principles.md` | The design principles every decision traces back to |
| `docs/process/visual-spec.md` | Visual and interaction rules. Undecided sections are marked. |
| `docs/process/anti-slop.md` | How to avoid work that looks generic or AI-made |
| `docs/process/demo-script.md` | The structure of the submission video |
| `docs/process/references.md` | Precedents and inspiration |
| `.claude/agents/` | Instructions for each agent role |
