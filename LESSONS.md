# Lessons learned

## October 16, 2026: Do not build a generic interpretation of the product

The first implementation pass was technically functional but visually and conceptually sloppy. It translated the written brief into a familiar “AI prototype” pattern instead of discovering and expressing Branch's specific point of view. It moved too quickly from exploration to code, used invented visual language and generic artifact treatments, and treated the graph as a decorative interface rather than the product's central storytelling medium.

What to do differently:

- Do not scaffold or code from a text-only handoff when the intended visual bar has not been concretely resolved.
- Use the supplied visual references and existing UI/UX direction as a design constraint, not as a loose mood board.
- Establish the graph, media treatment, typography, spacing, and key interaction as a small, reviewable visual slice before building the rest.
- Prototype one decisive screen and get human feedback before expanding into multiple flows.
- Prefer real, specific project artifacts and compositions over abstract CSS “artifact” placeholders.
- Treat “polished” as a product and visual design requirement, not merely a passing build.
- Preserve the distinction between implementation completeness and design quality; a passing build is not evidence of a good prototype.

## October 17, 2026: Spatial Canvas Over Modal Architecture

**Lessons learned**
- Modals, drawers, and fixed dashboards destroy the feeling of a single infinite canvas. Every time a modal covers the graph, spatial continuity is broken and the app feels like conventional SaaS.
- A spatial canvas requires nodes that behave like living physical entities on a drafting bed: circular hubs that bulb with spring physics, vectors with persistent dialogue snippets, and gaps that visibly glow.
- When working with React Flow or canvas engines, the camera's initial coordinate anchor is crucial: landing the user at `(0, 0)` with their personal hub centered creates instant presence.

**Lenses applied**
- *Collaborator / Maker Lens:* Makers join through visible, radiating gaps and unblocked paths, not form dialogs.
- *Storytelling Lens:* The canvas coordinate plane is the narrative timeline; moving left-to-right is moving forward through time.
- *Craft Lens:* Saturated marker colors (whiteboard emerald green and vermillion red) give the tool an authentic studio feel distinct from muted AI-generated palettes.

**Worth exploring next**
- SVG metaball filter bridges that physically stretch toward dragged items.
- Dual-track branching where offshoot lanes visually mirror musical scores.

**Sources**
- [`whiteboard-transcript.md`](whiteboard-transcript.md): Primary walkthrough by Cassius Palacio establishing infinite canvas, bulbing options, and drag-in genesis.


