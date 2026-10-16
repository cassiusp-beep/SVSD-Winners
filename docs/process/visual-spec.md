# Visual and interaction spec

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

## Color

_Not decided._ Cash's working files use a gray background. That's a starting point, not a decision. The board uses blue for steps and pink for optional AI. Those are diagram conventions and don't have to become UI colors.

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
