# Decisions

Significant product and design choices, newest first. Each entry is also raw material for the "how we got here" part of the submission video.

## October 17, 2026: Living Canvas Reset — Option B Shell Refactor & Zero-Modal Architecture (Decision 008)

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

**Still open:** how a branch looks different from the original story in the graph, and whether Report or Block is needed for the prototype.
