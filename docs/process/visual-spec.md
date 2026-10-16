# Visual and interaction spec

**Status: mostly undecided.** An empty section means it has not been decided yet. Agents should propose an option, label it provisional and flag it for the team rather than treat a guess as the spec.

## Platform and viewports

- **Medium:** web, running in a desktop browser. This is decided.
- **Primary viewport:** provisional, 1440×900. The video demo will most likely be recorded on desktop.
- **Secondary viewport:** provisional, 390×844. It must not break on a phone, since off-time phone browsing came up in the brainstorm.

## Tech stack

_Not decided._ Candidates: React or Next.js, a force-directed graph library such as d3-force or React Flow, and Framer Motion for motion. Choose for speed of building and quality of motion.

## Type

_Not decided._

## Color

_Not decided._ Cash's working files use a gray background. That's a starting point, not a decision.

## Spacing and layout

_Not decided._

## The node graph

_Not decided._ Questions to answer: what a node is (a person, a project, a skill or a contribution), what an edge means, how the graph grows over time, and how the "jellyfish" latch-on interaction looks and moves.

## Motion

_Not decided._ Default to 150–300ms for UI feedback. Graph transitions can run longer if they explain change over time. Honor `prefers-reduced-motion`.

## Voice and tone

_Not decided._ Start from the anti-slop copy rules.
