# Decisions

Significant product and design choices, newest first. Each entry is also raw material for the "how we got here" part of the submission video.

## October 17, 2026: Spatial Canvas Architecture, Hot Corners, and AI Connection Explanations

**Decided:**
1. **Canvas Foundation:** React Flow (`@xyflow/react`) with custom React/CSS nodes and SVG edges. Solves coordinate transformation, infinite pan/zoom, and desktop file drop cleanly while letting custom card components render rich media, turning points, and story scrubbers.
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
