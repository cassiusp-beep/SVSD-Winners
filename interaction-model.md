# Branch: Interaction Model

Source: Preserved from team interaction model specifications and prompt directives.

## 1. Core Concept: Canvas & Person Node Centered
Branch is not a set of traditional pages. It is a **spatial canvas focused around one person node (Home Hub)**. Everything the user opens appears as a node that blooms out of something already on screen, connected by a visible link, and fades back when done unless pinned.

## 2. Spatial Rule: Left = Me, Right = The World
- **Left of the person node:** Personal and system things. These include Settings & Profile, Notifications, and the Network.
- **Right of the person node:** Work and discovery. These include your projects and Living Map, New Story, Resume Draft, Explore, other people's projects, and open invites.
- New nodes always appear on their designated side and link back to the originating node. Layout remains legible with multiple nodes open.

## 3. Opening Nodes from the Person Node
- **Left-click your person node:** Expands your Living Map to the right (projects, branches, and collaborations).
- **Right-click / Long-press your person node:** Radial or compact menu:
  - Settings & Profile (blooms left)
  - Notifications (blooms left)
  - Network (blooms left)
  - New Story (blooms right)
  - Resume Draft (blooms right)
  - Log Out (returns to signed-out / guest landing state)

## 4. Transient Nodes Fade Unless Pinned
- Opened nodes are transient by default. Clicking back on the person node, or on empty canvas space, causes unpinned nodes to fold/fade back into their parent.
- Every transient node has a **Pin** toggle. Pinned nodes stay fixed on the canvas until unpinned.

## 5. Network Node: Ring or List
- Network opens to the left of the person node.
- **Default view: Ring** around the network node.
  - Pinned favorites sit on innermost positions.
  - Remaining slots fill with frequent collaborators.
- An inline toggle flips between **Ring** and **List** view.
- Users can pin/unpin favorites from either view.
- **Clicking a collaborator:** Opens their person node beside yours; their projects and shared chapters bloom to their right while your node stays anchored.

## 6. Projects are Node Graphs (Left-to-Right)
- Opening a project displays its Project Story as an interactive graph:
  - **Starting Question** on the far left.
  - **Sources, Experiments, Decisions** branch to the right.
  - **Dead ends / paused experiments** are visually muted/dimmed.
  - **Open paths / Gaps / Open Invites** are highlighted in a distinct color.
- **Core Journeys within the Project Graph:**
  - **Follow Its Story (Hero 1):** Step through the starting question, sources, experiments, decisions, and unexplored paths in sequence.
  - **Find Your Place (Hero 2):** Drop onto a project or branch, explore the domain of possibility, then **Try It Privately** (private draft branch where the original is untouched). Keep, revise, or discard. Keeping adds an **Adds a Chapter** node credited on the graph.
  - **Open Invite Loop (Hero 3):** Stuck creator uses **Ask for Help** / Help hot corner; **Open Invite Posted** appears on their graph and in discovery feeds. An explorer responds; notification arrives in the creator's Notifications. Creator reviews; branch connects beside the original with contributor credit.

## 7. Hot Corners
Hot corners anchor persistent navigation and rapid actions on the canvas:
- **Profile (Top-Left):** Quick focus to person node / identity.
- **Help (Top-Right):** Help resources, stuck triggers, and entry into the Open Invite loop.
- **Save (Bottom-Left):** Saved projects, bookmarks, private branch drafts.
- **Story (Bottom-Right):** Story scrubber / guided narrative progression controls for the active project.

## 8. Explore and Feeds
- Explore opens as a node to the right of the person node.
- Feeds (Tinder Style / Swipe feed, Pecha Kuchas) open as focused card stacks. Swiping right / clicking Interested manifests the project node onto the canvas.
- Wander the Graph, Shuffle, and Follow a Person also launch from Explore.

## 9. Guests & Authentication
- Guests land centered on the **Explore node** (or guest profile) with discovery opening to the right.
- Browsing requires no account. Joining a project or saving private drafts prompts a quick non-destructive sign-up/mock login.

## 10. Optional AI as Ghost Nodes & Connection Explanations
- AI suggestions appear strictly as **ghost nodes or dashed pink links** (labeled "AI").
- **Connection Relevance Layer:** An optional AI layer on in-between node edges that explains the semantic relevance and narrative causality between connection A and B (e.g. why an experiment led to a decision or why two interdisciplinary approaches link). Labeled "AI", dismissible, and rendered in the rose AI tint.
- Click a ghost to adopt/keep, drag to edit, or ignore to let it fade.
- Fully opt-in, behind a single feature flag, and every user journey is 100% complete without AI.

## 11. Proximity & Micro-interactions
- **Morph-on-proximity:** As nodes or dragged files approach candidate drop targets (e.g., dropping onto an experiment node or gap), target nodes morph/expand to reveal drop affordances.
- **Live dialogue:** Animated connection pulses and snippet preview overlays on links.
- **Desktop Drag & Drop:** Drag files (images, PDFs, 3D thumbnails) directly onto the canvas or nodes to seed new experiments or branch drafts.

## 12. Phone & Responsive Equivalent
- **Mobile First-Class Parity (390px):**
  - Left items (personal/settings) slide up via bottom sheet drawer.
  - Right items (projects/discovery) stack vertically or accordion below/beside the active focal node.
  - Right-click radial menu maps to long-press or tap trigger.
  - Canvas supports two-finger pinch-to-zoom and pan gestures, plus explicit zoom buttons.
  - Story scrubber switches to responsive touch chapter bar or step list.
