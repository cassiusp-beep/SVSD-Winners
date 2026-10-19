# Visual and interaction spec

**Historical prototype reference · 18 October 2026:** the document below describes the earlier creative-exchange concept and is preserved for design history. Read [current context](../../CONTEXT.md) and the [team-first product definition](../../docs/context/product-definition.md) before new design/build work. Inherited “primary source,” screen and interaction requirements below do not override that direction. The live team experience remains proposed, not implemented or validated by this sync.

## Current iOS app rules · 19 October 2026

The native iOS prototype (`BranchiOS/`) follows these rules. Full text: [.agents/rules/swiftui-ios.md](../../.agents/rules/swiftui-ios.md). Decisions: [DECISIONS.md](../../DECISIONS.md), Decisions 014 to 019.

- **Background.** Main tabs are plain white or black. The Welcome wash (warm off-white with lavender and sage glows, dimmed in dark mode) runs behind every onboarding step from Welcome through Sync, and fades out when onboarding ends.
- **Safe area.** Only background layers ignore it. Controls stay inside it. The shared header sits 12 pt below the top inset.
- **Accent.** The selected tab uses the user's family colour, at least 3:1 in both modes.
- **One moment.** Each screen gets one arrival motion, then only ambient motion.
- **Logo.** The SVG wordmark and mark in `docs/references/brand/` are the source of truth.
- **Takeaways.** Grid with no sprites. Agent colour, frosted slabs, and artifact callouts.

The "Night Lab" palette and sections below describe the earlier web prototype unless a section says otherwise.

Source for product decisions: `docs/context/conceptual-model.md`. An empty section means it has not been decided yet. Agents should propose an option, label it provisional and flag it for the team rather than treat a guess as the spec.

## Platform and viewports

- **Medium:** web, running in a desktop browser. This is decided.
- **Primary viewport:** provisional, 1440×900. The video demo will most likely be recorded on desktop.
- **Secondary viewport:** provisional, 390×844. It must not break on a phone. The **Tinder Style** feed is the screen most likely to be used on a phone.

## Tech stack

_Not decided._ Candidates: React or Next.js, a graph library such as d3-force or React Flow, and Framer Motion for motion. Choose for speed of building and quality of motion.

## Rules from the conceptual model

These are decided, because the board commits to them. Every screen must follow them.

- **AI is always optional and always marked.** Anything AI-generated is visibly labeled as AI, can be edited, and can be dismissed. No flow requires it. On the board, AI steps are pink. Whether pink carries into the UI is not decided, but AI must have one consistent visual marker.
- **Human authorship is visible.** Every node shows who made it. Every branch and chapter credits everyone involved.
- **Nothing is a dead end.** Every screen has a clear way back to **Home Hub**. Every risky action has undo. **Try It Privately** never touches the original.
- **No gatekeeping.** Nothing waits on a creator's approval. A creator learns about a branch through a quiet notification. It has no Accept or Decline, no red badge counts, and no urgency.
- **No account needed to look.** Guests can browse everything in Explore. Sign-up appears only when someone tries to join (still an assumption to validate).
- **Errors say nothing was lost.** Failure messages say what happened, confirm the work is safe, and offer a one-tap retry.

## The node graph

The conceptual model now defines what the graph is.

- **Node:** one piece of a project's story, such as a sketch, recording, prototype, file or note. It has media, connections and an author. A node can be added, connected, organized or undone.
- **Edge:** a connection between story pieces. What edges look like, and whether they have types such as "led to" or "branched from," is _not decided_.
- **Story structure:** a **Project Story** contains a starting question, experiments, decisions and paths not yet explored. These may need distinct node styles so the story reads at a glance. _Not decided._
- **Branch:** a new direction that stays linked to its origin and credits everyone involved. It grows as a linked offshoot **beside** the original story, never inside it. It must be visibly someone else's work, by color, position or treatment. Exactly how is _not decided_.
- **Chapter:** what a contribution or branch adds. It visibly connects to the original graph at the node it branched from, while staying outside the creator's own story.
- **The creator's story:** only the creator changes it. A reader should always be able to tell the original story apart from the branches around it.
- **Dead ends and open paths:** a dead end can be revived with **Revive an Experiment**. A path not yet explored is an open invite. Both need a distinct look. _Not decided._
- **Growth over time:** **Follow Its Story** must show the order the project grew in. This carries the storytelling theme, so it is the most important motion in the product. _Not decided._

## Key screens and their states

From the board's Key States row. Items marked "?" on the board are still assumptions.

| State | What the user sees |
|---|---|
| First visit | Opens with "What are you exploring?" |
| Empty map | **Nothing Here Yet** on Home Hub, leading to Explore. Draft copy: "start with one sketch" (?) |
| In progress | Drafts autosave and stay private (?) |
| Error | "Upload failed, nothing lost, retry" (?) |
| Success | "Someone branched your work," as a quiet notification with no action required |

## Type

_Not decided._

## Color: "Night Lab"

**Status:** DECIDED by the team (Oct 17, 2026). This section overrides any earlier color guidance in visual-spec.md.
**Idea:** Branch is a lab at night. The canvas is deep ink, and the work is what glows. Light means life: a node is lit because someone made it, a connection lights up because dialogue is moving through it, a gap glows because it's waiting for help. Nothing glows for decoration.

### The rule
Every color on the canvas means something. If a color can't be explained by the table below, remove it.

### Base (the dark lab)

| Token | Hex | Use |
|---|---|---|
| `--canvas` | `#0B0E1A` | Infinite canvas background. Deep ink, slightly blue, never pure black. |
| `--grid` | `#232B47` | Faint dot grid on the canvas, for orientation while panning. Low contrast on purpose. |
| `--node` | `#151B30` | Node body fill. |
| `--node-raised` | `#1E2640` | Hovered or selected node body, menus, sheets. |
| `--text` | `#EEF1FA` | Primary text. |
| `--text-2` | `#A3ACC7` | Secondary text: metadata, timestamps, captions. |
| `--muted` | `#7A84A8` | Placeholder and disabled text, inactive links. |

### Makers (authorship)
Each maker owns one color. It shows on their profile node's ring, on every node and chapter they made, and on the tail of their dialogue along connections. This is how authorship stays visible everywhere.

| Token | Hex | Name |
|---|---|---|
| `--maker-1` | `#4FD8F0` | Ion cyan |
| `--maker-2` | `#FF7A6B` | Coral |
| `--maker-3` | `#B8F35A` | Acid lime |
| `--maker-4` | `#A98BFF` | Violet |
| `--maker-5` | `#FF6FCF` | Magenta |

- The current user is always `--maker-1` (ion cyan) on their own screen, so "you" is instantly findable.
- More than 5 makers: reuse colors, but never for two makers in the same project.
- Never use a maker color for UI chrome (buttons, menus). Maker colors mean people.

### Meaning states

| Token | Hex | Meaning | How it shows |
|---|---|---|---|
| `--gap` | `#FFB547` | A gap: an open question or a spot that needs help. | Amber outline plus a slow breathing glow (about 3 s cycle). The only thing on the canvas that breathes. |
| `--dialogue` | `#FFFFFF` | Live dialogue moving between nodes. | A small bright pulse travels along the connection, trailing the sender's maker color. Comment snippet fades in beside the link. |
| `--ai` | `#C3C7DD` | Anything AI-suggested. | Pale silver, dotted outline, always labeled "AI". Deliberately the least colorful thing on the canvas, because AI is optional and secondary. |
| `--error` | `#FF5468` | Something failed (save, upload). | Always paired with an icon and text, never color alone. |

### Node states

| State | Look |
|---|---|
| Resting | `--node` fill, 1.5px ring in the maker's color at 60% opacity. |
| Active / hovered | `--node-raised` fill, ring at 100%, soft outer glow in the maker color (blur 16px, 35% opacity). |
| Private branch (Find Your Place, not yet kept) | Dashed ring in the maker's color, node at 70% opacity. Reads as "draft." |
| Kept chapter / credited contribution | Solid ring at 100%, small filled dot in the contributor's color, contributor name visible. |
| Gap | `--gap` ring and breathing glow (see above). |
| AI suggestion (ghost node) | `--ai` dotted ring, 60% opacity, "AI" label, until the user places it. Once placed it takes the user's maker color. |
| Morph target (something dragged near) | Node stretches toward the dragged item and its glow brightens to 60%. Reduced motion: brighter ring only. |

### Connections

| Type | Look |
|---|---|
| Idle link | 1.5px line in `--muted` at 50% opacity. |
| Link between one maker's nodes | 1.5px line in that maker's color at 40% opacity. |
| Link with recent activity | Same line at 80%, plus the `--dialogue` pulse. |
| Branch split | Line forks; each fork takes the color of the maker who made that branch. |

### Profile node
- Larger than other nodes. Filled with a radial gradient of the user's maker color (center 35% opacity to edge 0%) over `--node`, with a full-opacity ring.
- Radial option nodes use `--node-raised` with a `--text` icon. They pick up the user's color only on hover.

### Hot corners
- At rest: `--text-2` icon on `--node-raised`, 80% opacity. Quiet.
- On approach: full opacity, label appears in `--text`.
- Help corner: when a gap exists anywhere in the open project, its icon carries a small `--gap` dot. That's the link between "stuck" and "ask."
- Save corner: status text in `--text-2` ("Saved just now"). On failure it switches to `--error` with an icon.

### Phone
Same palette. On small screens, glows are reduced (blur 8px) to keep the canvas legible, and dialogue snippets become badges in `--node-raised` with a maker-color edge.

### Accessibility (checked)
Contrast ratios against `--canvas` / `--node`:
- `--text` 17.0 / 15.1
- `--text-2` 8.5 / 7.5
- `--muted` 5.2 / 4.6
- `--maker-1` 11.4 / 10.1
- `--maker-2` 7.6 / 6.7
- `--maker-3` 14.7 / 13.0
- `--maker-4` 7.2 / 6.4
- `--maker-5` 7.7 / 6.8
- `--gap` 10.9 / 9.7
- `--ai` 11.5 / 10.2
- `--error` 6.2 / 5.5

All pass WCAG AA for text (4.5:1). `--grid` is intentionally low contrast and must never carry information.
- Color is never the only signal: gaps also have an icon and label, AI has a label, private branches are dashed, errors have text.
- `prefers-reduced-motion`: breathing glow, dialogue pulse, and morph are replaced by static brighter rings.

### Banned
- Pure black (`#000`) or pure gray backgrounds.
- Purple-to-blue "AI" gradients, or any gradient that doesn't come from a maker color.
- Glow on anything that isn't a maker's work, a gap, or live dialogue.
- More than one breathing element type on screen (only gaps breathe).
- Maker colors used for buttons or chrome.

## Spacing and layout

_Not decided._

## Motion

_Not decided._ Defaults until it is decided:

- 150–300ms for UI feedback.
- Graph growth, branching and a chapter joining the graph can run longer, because they explain change over time. These are the hero animations for the video.
- Honor `prefers-reduced-motion`.

## Voice and tone

_Mostly not decided._ Start from the anti-slop copy rules. Board copy to keep, because it already has a voice:

- "What are you exploring?"
- "Where could someone contribute?"
- "Not permission to use it, help to iterate."
- "Nothing is a dead end."
- "The original is never touched."
- "Retry, nothing lost."
