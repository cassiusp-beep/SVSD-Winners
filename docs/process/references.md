# References

## Current product evidence · 18 October 2026

Read [collective-emergence source notes](../references/collective-emergence/source-notes.md), the [supplied Ben Shaw presentation](../references/collective-emergence/Collective%20Emergence%20-%20Ben%20Shaw%202009.pdf) and [product direction notes](../references/collective-emergence/Product%20Direction%20Notes.png) alongside the [current product definition](../context/product-definition.md). These inform hypotheses, not validated product outcomes. The visual and interaction references preserved below relate to earlier prototype explorations; use their status in [the documentation index](../README.md).

## Past SVSD work

- **Figma Mobile Live Comments**, the competition winner: https://www.rachelchen.tech/projects/figma. Study how three principles drive every decision.
- **Tomo, an OpenAI hardware concept**: https://christinaraganit.xyz/hardware-openai
- **Amy La's portfolio**, a reel-first case study format: https://blog.opendoorscareers.com/p/junior-portfolio-showcase-amy-la
- **Bruce Cao**, a grid of micro-interactions: https://www.bruce-cao.com/
- **Gily Yu**, high-polish experimental interfaces: https://gilyyu.com/

## Interaction precedents from the brainstorm

- **Obsidian graph view.** Notes as a connected node graph.
- **Alex's portfolio site.** Scrolling through skills, where hovering branches out into related projects. Ask Alex for the link.
- **Zotero.** Research cataloguing. It's an example of what stops short, since it doesn't show the journey behind a highlight.
- **Tinder and Hinge.** Quick swipe matching, which the team is considering for charrettes.
- **GitHub, Hackster and Figma.** Places where different disciplines keep their work. They're possible integrations.

## Brand and icon sources (`docs/references/brand/`) · 19 October 2026

Checked-in source for the YaYa logo. Do not redraw them.

- **`yaya-wordmark-black.svg`** and **`yaya-wordmark-white.svg`**: the "YaYa" wordmark in bold sans letterforms with gradient eyes (viewBox 694×286, baseline y 216). The black version is for light mode; the white version is for dark. The app embeds the glyph path as a SwiftUI `Shape`.
- **`yaya-icon-rounded.svg`**: the icon mark, a black rounded square with two white eyes. Proportions are the reference for `YaYaMark`.
- **`yaya-icon-appstore-1024.svg`**: the 1024 app icon source. iOS applies its own mask, so the asset is not rounded.

## Takeaways reference frames (teammate, not in repository)

The Takeaways redesign (Decision 019) follows a teammate's reference frame: the layout for "Takeaways" slabs and tags, and the receipt layout for the team view. The frames are screenshots that the user supplied by path during the session, and they are not checked into `docs/references/images/`. Our palette, naming and button rules take precedence over them.

## Visual Reference Images (`docs/references/images/`)

### `branch_landing_mockup.jpg`
- **Filename:** `docs/references/images/branch_landing_mockup.jpg`
- **DRAFT: What to take from it:**
  - **Color:** Saturated whiteboard marker emerald green (`#0D8F5B`) for structural conduits and verified paths; vermillion red (`#E23D28`) for core content/turning points; electric amber glow (`#FF9F0A`) for unanswered gaps; warm off-white drafting bed (`#FAF9F5`).
  - **Node style:** Circular maker focal hub at center with organic, bulging option sub-nodes that squish into one another; rounded capsule nodes for gaps; tactile cards with real media for projects.
  - **Motion:** Spring-driven bulbing bloom on user tap; magnetic proximity morph on drag; gentle pulsing signals along live connection conduits.
  - **Layout:** Centralized focal network framing four hot corners (Profile, Help, Save, Story) with zero modal overlays.
  - **Mood:** Tactile, alive, studio-authentic, high-craft, anti-slop.

### `audit_desktop_1440.png`
- **Filename:** `docs/references/images/audit_desktop_1440.png`
- **DRAFT: What to take from it:**
  - **Color:** Negative example of overly muted gray palette (`#F3F3F0`) that must be replaced by saturated markers.
  - **Node style:** Negative example of generic SaaS rectangular cards that must be replaced by organic living nodes.
  - **Motion:** Negative example of static uncentered canvas camera.
  - **Layout:** What to avoid: off-center empty void with nodes pushed to the edge; contrast with desired centered hub.
  - **Mood:** Sterile and AI-generic (anti-pattern).

### `audit_mobile_390.png`
- **Filename:** `docs/references/images/audit_mobile_390.png`
- **DRAFT: What to take from it:**
  - **Color:** Negative example of washed-out mobile viewport.
  - **Node style:** Demonstrates the need for auto-fit bounds on mobile.
  - **Motion:** Demands responsive touch pan/pinch gestures on 390px.
  - **Layout:** Negative example showing fixed scrubber and buttons obscuring 40% of the screen; must be refactored into compact thumb-reach controls.
  - **Mood:** Cluttered and broken; serves as baseline for mobile parity refactor.

### `night_lab_desktop_1440.png`
- **Filename:** `docs/references/images/night_lab_desktop_1440.png`
- **DRAFT: What to take from it:**
  - **Color:** Night Lab canonical palette: `--canvas` deep ink (`#0B0E1A`), faint dot grid `--grid` (`#232B47`), `--maker-1` ion cyan (`#4FD8F0`) ring and radial glow for Elena, `--gap` amber (`#FFB547`) breathing glow for unanswered questions, `--maker-3` acid lime (`#B8F35A`) for Marcus's branched chapter, `--dialogue` pure white pulse.
  - **Node style:** Central profile hub with bulbing radial option nodes; capsule and rounded card nodes for projects and sources; glowing breathing gap node.
  - **Motion:** 3s slow breathing glow on the gap node; live animated text dialogue snippets moving along bezier links with white dialogue pulse.
  - **Layout:** User at center of single infinite canvas, framed by 4 quiet hot corners (Profile, Help with amber gap dot, Save with "Saved just now", Story with Follow Story).
  - **Mood:** Immersive, authentic studio lab at night, anti-slop, high craft.

### `night_lab_mobile_390.png`
- **Filename:** `docs/references/images/night_lab_mobile_390.png`
- **DRAFT: What to take from it:**
  - **Color:** Night Lab palette adapted to 390x844: reduced glow radii to maintain legibility, contrast preserved against deep ink background.
  - **Node style:** Profile hub centered with bulbing radial options; dialogue snippet becomes compact badge with maker-color left edge.
  - **Motion:** Focused vertical flow; breathing glow preserved on open gap.
  - **Layout:** Hot corners hug screen perimeter cleanly without overlapping the central work; one-thumb reach for bottom Story and Save controls.
  - **Mood:** Intimate, focused mobile companion to the living canvas.
