# SVSD Winners

Team Fester's entry for the Silicon Valley School of Design competition. It's a web-based product prototype on the theme of storytelling, due Monday, October 19, 2026 at 11:59 PM Pacific.

Start with [AGENTS.md](AGENTS.md). It explains the project, the deadline and the agent roles, and points to everything in `docs/`. It works with any AI assistant, including ChatGPT, Codex and Claude Code.

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
| `docs/context/` | The brief, judging research and the current concept |
| `docs/process/` | Design principles, anti-slop rules, visual spec, features, video plan and references |
| `.claude/agents/` | Instructions for each agent role |
