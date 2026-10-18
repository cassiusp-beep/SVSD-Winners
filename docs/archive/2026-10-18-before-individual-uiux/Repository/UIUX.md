# Branch: UI/UX and Design Direction

**Historical prototype reference · 18 October 2026:** the document below describes the earlier creative-exchange concept and is preserved for design history. Read [current context](CONTEXT.md) and the [team-first product definition](docs/context/product-definition.md) before new design/build work. Inherited “primary source,” screen and interaction requirements below do not override that direction. The live team experience remains proposed, not implemented or validated by this sync.

**Agent handoff | 16 October 2026 | UI/UX only**

Branch is a creative exchange for student makers sharing unfinished work. Its central interface is a living Project Story: the starting question, experiments, decisions, unexplored paths, and chapters contributed by other people.

Build an interface that makes three things immediately understandable: **how this project grew, where I could contribute, and what will happen if I try.** The visual character should feel like a contemporary creative studio: light, spatial, tactile, and precise, with real work at the center.

## 1. How agents should use this file

This file specifies presentation, screen composition, interaction behavior, visual states, responsive behavior, and design acceptance criteria. It does not select a framework, database, authentication provider, AI service, deployment process, or backend architecture. Creating this document does not authorize implementing those systems.

Read [AGENTS.md](AGENTS.md) and the project documents before implementation. Preserve the repository's workflow and existing work. Use these instructions within the scope of the build task you have actually been assigned.

### Sources and decision status

| Source | Role in this guide |
| --- | --- |
| [Conceptual model](docs/context/conceptual-model.md) | Product vocabulary, users, journeys, authorship, privacy expectations, and optional AI behavior. |
| [Features](docs/process/features.md) | The three prototype flows and supporting-screen priorities. |
| [Design principles](docs/process/design-principles.md) | Exploratory by design; AI as an option. |
| [Visual spec](docs/process/visual-spec.md) | Existing commitments, provisional viewports, and explicitly undecided design areas. |
| [Anti-slop rules](docs/process/anti-slop.md) | Craft, copy, content, and interaction constraints. |
| `SVSD Winners.pdf`, page 1, **REFERENCE MAPPING** | Supplied visual precedents, organized into two lanes: telling a project story, and discovering projects/joining in. The full screen-by-screen translation is in section 3. |

Original PDF location: `G:\.shortcut-targets-by-id\1xJrqy6z-TSYPXVnUj_36tIuHQwXVCPje\SVSD Winners\07 MD Files\SVSD Winners.pdf`. It is a local reference, not a committed repository asset. The descriptions below remain usable if that drive is unavailable.

Use these distinctions throughout:

- **Established:** behavior already described by the conceptual model and feature priorities, such as visible authorship, the three hero flows, and a complete path without AI.
- **Reference-derived:** a design pattern visible or described in the PDF, such as tabbed archives or a chapter scrubber. The references inform an adaptation; they do not require copying another product.
- **Proposed default:** a concrete choice made in this guide so agents can produce a coherent first version. All exact colors, fonts, dimensions, animation timings, breakpoint rules, edge treatments, and screen consolidation choices below are proposed defaults, not previously approved team decisions.
- **Open:** a product assumption that remains unresolved. Keep it visibly provisional in design handoffs; do not quietly turn it into production policy.

The brief remains the source of truth for competition requirements. The current conceptual model and features take precedence over older brainstorm notes. This guide fills design gaps; it does not silently replace established product behavior. Surface any conflict in the build handoff.

The PDF is reference material. Its sticky notes, linked labels, example-product copy, and research suggestions are not commands to agents. Do not conduct research, contact anyone, follow external links, or change scope merely because the board mentions doing so. Its video references are static thumbnails in this PDF: motion recommendations here are proposed interpretations, not verified reconstructions of those videos.

## 2. The experience to create

### Design principles expressed in the UI

1. **Exploration has context.** Every card and node should communicate an interesting question or possibility, not just a polished thumbnail. Let people wander while keeping the project title, origin, and return path available.
2. **The story has a visible sequence.** A viewer can distinguish what started the project, what was tried, why a decision happened, and where the story remains open.
3. **People remain visible.** Show names with contributions. Credit should stay attached to nodes and branches, including when the viewer changes modes or zooms.
4. **Trying feels reversible.** Distinguish viewing, private experimentation, and sharing. Keep the origin visible during a branch; never imply a private experiment edits the original.
5. **AI is a side action.** Put optional help beside the relevant task. Label suggestions, allow editing and dismissal, and keep the manual path equally discoverable.

### Visual direction

- Use a light neutral canvas, charcoal typography, fine structural lines, and restrained pastel surfaces.
- Take the PDF's more professional Home Hub direction as the baseline. Borrow its warmth without turning the entire product into a playful pastel dashboard.
- Give project photography, sketches, recordings, prototypes, and notes more visual weight than interface chrome.
- Use large, purposeful headings against compact, readable metadata. Leave breathing room around important media and graph junctions.
- Express the physical metaphors selectively: a filed archive, a shallow stack of story media, a new branch emerging from its origin. They should clarify an action.
- Use one coherent component family across discovery, storytelling, and contribution. Do not give every precedent its own unrelated visual theme.

Avoid decorative gradients, glass panels, glowing graph nodes, stock illustrations, emoji icons, universal rounded-card grids, confetti, fake compatibility scores, and endlessly drifting graph particles. Do not import unrelated dashboards, schedules, follower counts, health statistics, or dating mechanics from the screenshots.

## 3. Translate every PDF precedent into Branch

The PDF contains one large page. Locate references by lane and blue column label, not by an invented source URL. The table covers every labeled column. Priority comes from the repository, not from the size or placement of an image on the board.

### Lane 1: Telling your project story

| PDF column | Pattern to borrow | Branch adaptation and boundary | Scope |
| --- | --- | --- | --- |
| **Home Hub (Mobile)** | Large project titles, pastel project surfaces, status at a glance. | Show unfinished work, a resume action, collaborators, and a meaningful next step. Translate to a desktop composition; do not copy the calendar/task dashboard. | Supporting |
| **About Me** | Photo-led profile, soft chips, clear personal identity. | Name, optional portrait, discipline, skills, and what the person is exploring. Skills support collaboration, not ranking. Preserve a usable layout without a portrait. | Later; identity reused now |
| **Archive of Previous Works** | Indexed drawers and layered file tabs. | File past work behind labeled tabs; reveal details when selected. Archive context is optional and must not dominate a new maker's profile. | Later |
| **Calibration** | Tap-to-select interest and skill chips. | Separate what someone can offer from what they want to explore. Selection is explicit and reversible. Avoid a compatibility score or forced personality quiz. | Later |
| **Modes of Storytelling** | Distinct mode cards and colorful editorial hierarchy. | Free Form, Quick Design Sessions, Assisted, and AI Draft are understandable choices. Label the last two as optional AI; manual creation remains prominent. | Later |
| **Project Story & Add Nodes** | Stacked media, tagged layers, chronological spatial arrangement. | Use real artifacts as readable story nodes. Keep title, author, and sequence legible in the flat view. Isometric depth is optional presentation polish, not the only usable editor. | Story display now; authoring later |
| **Connect Nodes** | Visible paths, connected circles, route-like links, text beside nodes. | Give relationships readable labels and stable paths. A selected connection shows its source and destination. Color may reinforce meaning but cannot carry meaning alone. | Relationships now; editing later |
| **Living Map** | A map combining media thumbnails, interests, and collaborations. | Reuse graph grammar to show a person's projects and credited chapters. Keep contribution and origin visible. Do not copy the decorative 3D objects in the example. | Supporting |
| **Review & Share** | A deliberate privacy moment before publication. | Summarize what is being shared, who can see it, and who is credited. Audience wording must match actual supported behavior; the screenshot's privacy statement is not Branch policy. | Later; reuse review pattern for branch sharing |

### Lane 2: Discovering projects and joining in

| PDF column | Pattern to borrow | Branch adaptation and boundary | Scope |
| --- | --- | --- | --- |
| **Explore** | Thematic rows, strong media, rich metadata, bold editorial typography. | Group work by meaningful themes or openings. Show the starting question, maker, and invitation alongside the media. Do not copy entertainment ratings, neon branding, or a recommendation algorithm. | Supporting |
| **About Me/Pecha Kuchas** | Immersive story slides, banner/avatar/bio, transitions between artifacts. | Create a short project introduction with manual next/previous controls, position, author, and a link to the full story. Do not merge every profile and story into a new screen type. | Later |
| **Tinder Style** | A visible stack of cards and direct swipe interaction. | One project or Open Invite at a time; Interested, Pass, and Undo also work as buttons. Opening a card reveals context before any request is sent. | Supporting; Open Invite discovery now |
| **Wander the Graph** | A network of people/projects, small colored markers, author reveal. | Let people preview then open a project, with stable positions and search/filter context. Use hover and keyboard focus on desktop, tap on touch. Avoid densely packed dot clusters. | Supporting, medium-high fidelity |
| **Shuffle** | Radial carousel and a new random project on each spin. | Reuse the project preview, offer Shuffle Again and Open Project, and retain a route back. A simple transition can replace 3D rotation. Random selection is still a product assumption. | Later |
| **Open a Project** | Large hero media followed by the project's content. | Open a clear project introduction that leads directly into its story and available contribution points. Keep maker and project status visible. | Hero entry |
| **Follow Its Story** | Chapter cards, a route-like timeline, and a tick-mark scrubber. | Synchronize selected chapter, graph position, artifact, author, and date/sequence. Provide manual controls and a complete-story overview. | Hero 1 |
| **Find Your Place** | Visible relationships between creator, project, and contributor. | Show a relevant opening and explain what the user could bring to it. Offer the four established contribution choices; let people choose without AI. | Hero 2 |
| **Suggest Where I Fit** | Orbiting people and radial relationships around a center. | Highlight a few possible connections to the currently selected project. Use a static or gently revealed arrangement; never imply an objective match score. Suggestions are optional AI, editable, and dismissible. | Optional within Hero 2 |
| **Start a New Branch** | Media lineage visibly splitting while retaining its origin. | Keep a persistent origin connection, isolate the private draft, then visibly attach a kept chapter with attribution. | Hero 2 |

The board also raises a concern about too many unique screens. The proposed response is the shared-screen model below; the annotation does not authorize a separate user study. Several referenced patterns support multiple steps within the same screen.

## 4. Screen model and navigation

Use five primary surfaces. Treat step names as modes, panels, or states when that preserves context. Keep the model's vocabulary in design notes even when the visible label is shorter.

| Surface | Includes | Persistent orientation |
| --- | --- | --- |
| **Home Hub** | Resume Draft, New Story, Explore, recent activity, Nothing Here Yet. | App navigation and a clear next action. |
| **Explore** | Wander the Graph and Tinder Style first; later Pecha Kuchas, Shuffle, Follow a Person. | Current mode, filters, project preview, return to Home Hub. |
| **Project Story** | Project introduction, Follow Its Story, node detail, Find Your Place, and creator's I'm Stuck entry. | Project title, creator, story position, return to Explore/Home. |
| **Private Branch** | Origin context, Try It Privately, draft content, Keep or Undo, Adds a Chapter. | Private status, source project, and explicit exit/review controls. |
| **My Map / activity** | Living Map; Notifications opens as a reusable panel or focused view. | Person identity, credited projects, and Home Hub. |

Desktop navigation: use a compact 64px top bar with Branch, Home, Explore, My Map, Notifications, and the current identity or guest state. Avoid a permanent second sidebar. Local story controls belong inside the story surface.

Mobile navigation: use four labeled destinations, Home, Explore, My Map, and Activity, with a 56px minimum navigation region plus the device safe area. Account/help can live in the profile menu. Keep primary page actions clear of bottom navigation.

Make the active destination obvious with weight and an underline or filled treatment. Use text labels with icons where meaning could be unclear. Back preserves the previous discovery mode, filters, selected project, and position; Home Hub is always independently reachable.

Guest browsing must not start with an authentication wall. A contribution sign-up interruption is a provisional behavior from the conceptual model; if included in the prototype, preserve the selected project/opening and return to that context afterward.

## 5. Proposed design tokens

Use shared tokens rather than one-off values. These are buildable starting values selected from the references' visual direction, not sampled measurements or finalized brand assets.

### Color

| Token | Value | Use |
| --- | --- | --- |
| `canvas` | `#F3F3F0` | Main application and graph background. |
| `surface` | `#FFFFFF` | Media framing, menus, panels, raised content. |
| `surface-subtle` | `#EAECE7` | Recessed regions and quiet secondary grouping. |
| `ink` | `#202420` | Headings, body, primary actions, important links. |
| `ink-muted` | `#60665F` | Secondary metadata on light neutral surfaces. |
| `border` | `#D2D6CF` | Quiet dividers and decorative boundaries. |
| `control-border` | `#767D73` | Outlines needed to identify controls. |
| `question-tint` | `#F4E7A3` | Starting questions and editorial highlights. |
| `experiment-tint` | `#D8E8F0` | Experiment tags and small selected surfaces. |
| `decision-tint` | `#DCE8D5` | Decision tags. |
| `branch-tint` | `#E4DDF0` | Branch context and lineage labels. |
| `ai-tint` | `#F4DDE5` | Optional AI labels and suggestion container. |
| `positive-ink` | `#315D3B` | Confirmed success text/icons. |
| `attention-ink` | `#7A4D0B` | Open-path and pending-action labels. |
| `error-ink` | `#A12D32` | Errors and destructive-action text. |
| `focus` | `#2454C6` | Keyboard focus outline. |

Use `ink` on pastel tints; use white on the charcoal primary button. Pastels are supporting surfaces, not low-contrast text. The faint `border` token is not sufficient for an essential control outline. Check contrast for actual combinations, including hover, selected, disabled, and image-overlay states.

Reserve rose treatment for optional AI so it does not become confused with a human contribution type. The PDF's blue step labels and magenta title are board navigation conventions, not required application colors. A private state uses a lock icon and explicit text; never rely on color to communicate privacy.

### Typography

- **Display:** Space Grotesk, medium weight, for page titles and selected editorial project headings.
- **Interface and reading:** IBM Plex Sans, regular/medium/semibold, for controls, body copy, graph labels, and metadata.
- **Fallback:** a readable system sans-serif stack if either font is unavailable. Preserve layout and hierarchy while the intended fonts load. Do not add a third family for decoration.
- Use existing approved local font assets if the repository already establishes a different family; record the substitution in the design handoff. Do not silently introduce network font dependencies.

| Role | Desktop | Mobile | Line height |
| --- | --- | --- | --- |
| Editorial page title | 48px / 500 | 32px / 500 | 1.08 |
| Project title | 32px / 500 | 28px / 500 | 1.15 |
| Section heading | 24px / 500 | 22px / 500 | 1.25 |
| Card/node title | 18px / 500 | 18px / 500 | 1.3 |
| Body | 16px / 400 | 16px / 400 | 1.5 |
| Control label | 14px / 500 | 14px / 500 | 1.35 |
| Metadata | 12-13px / 400 | 13px / 400 | 1.4 |

Keep paragraph width around 55-70 characters. Do not uppercase entire sentences or shrink important content to fit. Use tabular numerals for story position and dates. Small labels must remain readable at normal zoom.

### Spacing, shape, and elevation

- Spacing scale: **4, 8, 12, 16, 24, 32, 48, 64px**.
- Desktop content padding: 32px; mobile: 16px. Standard content max-width: 1280px. Graph workspaces can use the available width.
- Standard gaps: 24px between content groups, 16px within a card/panel, 8px between a label and its related control.
- Corners: 6px for media, 10px for buttons/inputs, 14px for cards and panels, full rounding for small tags and avatars. Avoid using pill shapes for every element.
- Borders: 1px for surfaces; 2px for selected/focused structure when needed. Selection also gets a label or other non-color cue.
- Use a very light shadow only for floating layers: approximately `0 8px 24px rgba(32,36,32,0.10)`. Base cards can rely on spacing and borders.
- Icons: one consistent outlined family, approximately 1.5-2px strokes at 20px. Use simple shapes and clear labels; no emoji substitutes.
- Touch controls: target at least 44 by 44px. Small visible nodes may have larger invisible hit regions, provided those regions do not overlap.

## 6. Screen-by-screen build instructions

### 6.1 Home Hub

**Purpose:** get a returning maker back to work and give an explorer a useful entry point.

Compose the desktop page as a large current-work region plus a narrower activity region, approximately 8/4 columns. The first content row should contain a clear heading, the most relevant draft/project, and Resume Draft or Explore. Place New Story as a visible secondary action when an active draft is present.

Project summaries include a real thumbnail, title, a one-sentence question, textual status, last meaningful activity, and contributor identity. Distinguish a large resumable project from smaller recent projects through scale; avoid an equal-size grid of interchangeable cards. Use the PDF's soft project surfaces sparingly.

On mobile, stack the current project, activity, and discovery content. Keep the resume action in the first viewport. Do not recreate the precedent's scheduling timeline unless an independently approved feature needs it.

**States:** returning with a draft; projects without a draft; first visit/empty; loading; activity unavailable. Empty copy can begin with the established “What are you exploring?” and offer Explore. “Start with one sketch” remains proposed copy. Do not show an empty analytics dashboard.

### 6.2 Explore and Wander the Graph

**Purpose:** make unfinished work and its possibilities discoverable across disciplines.

Use an Explore heading, a concise mode switch, and optional relevant filters above the content. Start with Wander the Graph and the swipe feed. The conceptual model includes five discovery modes, but unbuilt modes do not need dead buttons in the prototype.

For the graph, display connected people and projects, with restrained color and clear differences between person markers and project/media nodes. A person marker uses an avatar or initials; a project preview uses a thumbnail and title. Never show placeholder headshots implying real identities.

- Hover/focus previews title, maker, starting question, and an open possibility. Click/tap selects; an explicit Open Project action enters the story.
- Keep the preview in a consistent side panel on desktop. On mobile, use a bottom sheet that can be dismissed without losing the graph location.
- Stabilize positions after layout. Selection and preview must not cause the network to rearrange beneath the pointer.
- Provide Fit Map, zoom controls, a visible return to the last selected project, and an equivalent list view.
- Make thematic browse rows use the same project content and preview component. Use one lead item and smaller supporting items where appropriate; do not fill the screen with uniform widgets.
- A no-results state shows the active filters and Clear Filters. An empty feed suggests another available exploration path.

### 6.3 Open a Project and Project Story

**Purpose:** establish what the project is, who made it, and why its unfinished state is interesting.

The opening view contains project title, creator, status, a short starting question, and substantial hero media. Use actual work rather than a marketing illustration. Display collaborators without hiding credit behind a count alone.

The two principal actions are **Follow Its Story** and **Find Your Place**. Keep Save for Later as a quiet action. For the creator, expose **I'm Stuck** near the project/open-path area, not as a global warning banner.

Enter Follow Its Story within this same project surface. The detailed desktop composition is:

- Project context/header above the workspace, approximately 72-96px tall as content requires.
- Graph taking the remaining main area; preserve at least about 600px of usable graph width before switching to an overlay panel.
- A node/chapter detail panel around 360px wide, containing artifact, title, author, description, and relationships.
- A timeline/control strip around 72-88px tall below the graph, plus readable chapter labels.

Let the graph remain visible when details open. Avoid stacking multiple persistent sidebars. Selected-node details and Find Your Place should reuse the context-panel region.

### 6.4 Follow Its Story — Hero 1

**Purpose:** make the project's development understandable as a sequence and as a branching structure.

Start on an orienting overview with the starting question and the first chapter clearly identified. Provide Begin/Play, Previous, Next, a scrubber, and Show Full Story. Do not require autoplay; manual navigation is the default. A numbered chapter sequence is required even when dates are missing.

Selecting a chapter must synchronize five things: the current graph node, the active route/edge, the detail panel, the timeline position, and the visible author. Older experiments remain available. Unrevealed material can be hidden in guided mode but must return in the full-story overview.

The sequence should expose a real turning point: an experiment, why it did or did not work, and what changed next. A graph of attractive images without this causal information fails the storytelling requirement.

Use timeline ticks for chapters, with an active label and visible position such as “3 of 7.” Scrubbing previews the destination chapter; releasing selects it. Keyboard users can select chapters without dragging. Timeline motion must not invent continuous dates between discrete events.

**States:** overview; current chapter; media loading/failure; playing/paused; final chapter; full story; reduced motion. The final chapter points to a real open path and Find Your Place. It must not become a dead end.

### 6.5 Find Your Place — Hero 2 entry

**Purpose:** connect the viewer's interests or skills with a specific unfinished possibility.

Keep the selected project or open node visible and open the contribution panel. Lead with a concrete opening, for example, an interaction to test or an abandoned experiment to revisit. If skills are unknown, allow the viewer to choose interests here; browsing should not depend on completing onboarding.

Show the four established choices as clear action rows or compact selectable options, each with a short explanation:

| Action | UI outcome |
| --- | --- |
| **Save for Later** | Confirm saved state and allow reversal. Persistence/account behavior is provisional; do not promise more than the prototype supports. |
| **Contribute a Skill** | Open a short contribution/request composer tied to this opening. Review before sending; do not create a public contribution on selection alone. |
| **Revive an Experiment** | Select a paused/abandoned experiment and carry its context into a private attempt. Preserve its history. |
| **Start a New Branch** | Enter a private draft with a visible origin and a prompt for the new direction. |

Represent the “domain of possibility” through specific connections between an opening and a skill or interest. Give a reason in plain language; avoid percentages, rankings, or claims about the person's potential.

Place **Suggest Where I Fit · Optional AI** below the manual choices or beside the relevant context. If implemented, show a few labeled suggestions that can be edited, dismissed, or turned into a chosen action. Do not auto-send a request, create a branch, or rearrange the project when a suggestion appears.

### 6.6 Try It Privately, Keep or Undo, Adds a Chapter — Hero 2 completion

**Purpose:** let someone try a direction without threatening the original, then understand the effect of keeping it.

Show a persistent **Private draft** label with a lock icon, the new working title, and **Branched from [project / node]** as a navigable origin. Place “The original is never touched” near the first draft action. Make origin content visually distinct from editable draft content without making the original unreadable.

The draft can contain a short intention and an artifact/note using existing story components. Do not build an unrelated full creative editor for this flow. For a prototype, local/sample interactions must be identified honestly in the handoff.

The review state shows the proposed chapter, its source connection, the contributor, existing attribution, and its intended visibility. The conceptual model says keeping leads to Adds a Chapter but does not fully define approval/visibility policy. The proposed demo interaction is an explicit review followed by **Keep and add chapter**, with the audience stated before confirmation. A generic Save control must not unexpectedly share work.

- **Try again:** return to editing without discarding the current attempt.
- **Discard private draft:** return to Home Hub with a way to recover the draft while recovery is actually available. Confirm discard if no real recovery is supported.
- **Keep and add chapter:** after success, reveal the chapter's connection to its origin, show author credit, and offer View in Story, My Map, and Home Hub.
- **Failure:** keep the draft visible, explain the failed operation, and offer retry without pretending the chapter was added.

Keeping a chapter and accepting an Open Invite request are different events. Do not conflate them or imply that a request automatically edits the creator's original work. Any undo after sharing must match supported behavior; otherwise stop at a clear review boundary and flag the unresolved reversal policy.

### 6.7 Open Invite loop — Hero 3

**Purpose:** turn a specific stuck point into an understandable invitation and a credited collaboration.

1. **I'm Stuck / Ask for Help:** open a panel linked to the current node. Show the project context and ask “Where could someone contribute?” Include the obstacle, what has already been tried, and the kind of help wanted. Keep the form short and editable.
2. **Review and post:** preview the invite as it will appear in discovery, including creator, source node, desired help, and audience. The final action is clearly Post Open Invite. Cancel returns to the original story position.
3. **Open Invite Posted:** mark the open path and provide View Invite and Home Hub. Do not silently navigate away before the result is understandable.
4. **Explorer discovers it:** show the invite in the swipe feed with a real artifact and the need above the fold. Interested opens details and a response composer; it does not automatically send a request.
5. **Explorer responds:** let the person state what they could contribute, review, and explicitly submit. Show a pending state and retain context if submission fails.
6. **Review a Request:** the creator's Notifications view opens the linked invite, applicant identity, offered skill, and response together. Offer clearly separated Accept and Decline actions.
7. **Accept / Contributor Credited:** visibly associate the person with the project and label their role/contribution accurately. Acceptance is not proof that an artifact has already been delivered. Existing authors stay credited.
8. **Decline / Explorer Can Still Branch:** use respectful copy, preserve the original context, and offer a separate Start a New Branch route. Do not style decline as a permanent ban or delete the explorer's private work.

The conceptual model's “Not permission to use it, help to iterate” is a tone cue for collaboration. Do not turn it into an unsupported rights or licensing claim.

### 6.8 Tinder Style / swipe feed

Use one primary card with at most one or two offset cards behind it. The primary card shows media, project title, maker, starting question or invite, and a short opportunity line. Give the human question more weight than popularity metrics.

Place **Pass**, **Interested**, and **Undo** in a consistent control area. Right swipe means interested; left means pass. Labels appear as the gesture develops, and an incomplete swipe returns the card to its starting position. Undo restores the last card and its position. Buttons and keyboard controls provide the same actions without swiping.

Use a conservative gesture threshold around one quarter of the card width as a starting point, then adjust through actual testing. Vertical movement scrolls card content; it should not accidentally dismiss the card. Desktop cards remain centered with enough width to read comfortably, rather than becoming a giant stretched phone mockup.

After the final available card, show a clear end state, Undo if available, and Wander the Graph. Do not fabricate endless recommendations.

### 6.9 Living Map, Notifications, and reusable profile context

**Living Map:** show interests, owned projects, and contributed chapters with the same graph language. A newly kept chapter appears with its origin and credit. Offer an equivalent readable list and a direct way to open the corresponding Project Story. Distinguish authorship from participation through labels, not status rankings.

**Notifications:** use compact rows with an actor, action, project, time when known, and unread state. Opening a notification lands on the relevant request or chapter. Design empty, loading, failed, unread, and resolved states. A simulated prototype event must not be presented as a real message from a real person.

**Profile context:** name, optional image, skills, current exploration, and work samples. Keep the identity component consistent in cards, graph details, invites, and credit lists. Do not require an archive or integrations to look like a legitimate contributor.

### 6.10 Later interfaces: preserve the direction, defer the build

These patterns are specified so future agents stay consistent. They do not expand the current three-flow priority.

| Interface | Design instructions |
| --- | --- |
| About Me / Calibration | One focused prompt at a time; labeled skill/interest chips; selected state includes a checkmark; custom entry and skip where appropriate. Return to the work quickly. |
| Archive of Previous Works | Accessible tab/list structure using the folder metaphor. Selected tab reveals media and context. Keyboard navigation and a flat list work without 3D perspective. |
| Modes of Storytelling | Four differentiated choices within one chooser. Describe what each starts with. Mark Assisted and AI Draft as optional AI, without making them larger than manual choices. |
| Add Nodes | Media, note, title, author, and type in a compact composer. Show progress at the affected node, retry on failure, and keep entered context. |
| Connect Nodes | Select source then destination, or drag a visible connection handle. A non-drag method is required. Preview the relationship and provide cancel/undo. Label suggested AI links until accepted. |
| Review & Share | Preview audience, content, credit, and action outcome. Retain the draft when sharing fails. Do not offer unsupported audience options. |
| Pecha Kuchas | Immersive media slides with author, progress, next/previous, pause if playing, and Open Full Story. No mandatory timed reading. |
| Shuffle | Reuse project preview and provide Shuffle Again. Keep spatial motion brief and optional. Selection semantics remain provisional. |
| Follow a Person | Reuse profile identity and a reversible follow control. What following changes in the feed remains open. |
| Account/settings/help | Compact forms with persistent labels, focused errors, preserved context, and an exit back to the task. Do not invent a full account system in a design-only assignment. |

## 7. Graph grammar and controls

The Project Story graph and the wider discovery graph share styling but represent different things. A Project Story node is a story artifact/event. A discovery node can represent a person or a project. Do not confuse a person's avatar with an experiment node.

### Project Story nodes

| Meaning | Proposed treatment | Required information |
| --- | --- | --- |
| Starting question | Question label, question tint, strong typographic text. | Question, author, sequence/date if known. |
| Experiment | Media thumbnail or document/audio preview, experiment tag. | Title, artifact, what was tried, author. |
| Decision | Compact text-led node, decision tint and label. | Decision and reason; links to relevant experiments. |
| Open path / Open Invite | Dashed boundary, visible opening or plus, explicit Open path/Invite label. | What remains unresolved, who is asking, relevant action. |
| Abandoned experiment | Muted surface with Paused/Abandoned label; retain readable contrast. | Original context and Revive an Experiment action. |
| New branch/chapter | Branch tint on tag, solid origin connector, contributor identity. | New direction, origin, credit, state. |
| Optional AI suggestion | Rose container with AI suggestion label; distinct from accepted content. | Suggestion, selected-material context, edit/accept/dismiss controls. |

At a comfortable default zoom, use compact media nodes around 160-200px wide and an expanded selected view around 260-320px where space permits. Avoid showing a full paragraph in every node. A far zoom may simplify to markers; the selected-node panel and list retain access to titles and authors. Do not shrink essential text into illegibility.

Use mostly horizontal chronology in the desktop story graph, with branches offset into adjacent lanes. Leave approximately 80-120px between major story steps and enough vertical space for labels. These are starting layout targets, not reasons to clip real content.

### Connections and lineage

- Use clear 1.5-2px ink connections with directional cues where sequence matters.
- Keep the main story path visually continuous. Give the selected path a slightly heavier line; keep inactive paths readable.
- Use short relationship labels such as “led to,” “informed,” “branched from,” or “revived from” when they explain actual supplied content. These labels are a proposed UI vocabulary, not an established ontology.
- Distinguish suggested/open relationships with a dashed treatment plus text. An accepted chapter has a solid origin connection.
- Route lines around labels and media when possible. Avoid decorative loops and unnecessary crossings.
- Do not encode “abandoned” only in an edge color; it is a visible node state with a possible revival action.

### Interaction contract

- Click selects a node and shows details. Double-click is not required for essential actions.
- Primary drag is reserved for an editable node/connection when editing is enabled. In read-only story mode, nodes must not appear accidentally editable.
- Provide Space + drag and/or a visible pan tool for desktop navigation. Background panning must never trigger a node action. Preserve any established repository gesture contract if one exists.
- Provide zoom buttons and Fit Map; avoid hijacking normal page scrolling outside the graph region. Touch users get visible controls as well as direct manipulation.
- Keyboard users can move through a readable node list, select a node, inspect its detail, and traverse the story. Do not require them to navigate arbitrary graph coordinates.
- Opening/closing a panel preserves selection and viewport. Escape closes the top transient layer and returns focus to its trigger.
- Auto-centering should be gentle, bounded, and cancelable by user input. Never run a free-floating physics simulation during reading.

## 8. Shared component and state checklist

Create reusable presentation components for the items below. Names describe responsibility rather than prescribing code architecture.

| Component | Required variants and behaviors |
| --- | --- |
| App navigation | Guest/signed-in, active destination, mobile, focus, notification state. |
| Project preview/card | Featured/compact/swipe; draft/shared/open invite; image loading/error; save state. |
| Person and credit row | Avatar/initials, name, role, origin link; full credit accessible beyond an avatar stack. |
| Story node | Question/experiment/decision/open path/branch; selected/focused; media fallback. |
| Relationship/edge | Default/selected/open/suggested; label and origin preserved. |
| Timeline and chapter card | Beginning/middle/end; paused/playing; selected; keyboard; reduced motion. |
| Context panel | Node detail/contribution/request review; desktop panel/mobile sheet; dismissal and focus return. |
| Skill/tag chip | Default/selected/focused/disabled; readable label, removable when appropriate. |
| Status label | Private/shared/pending/open/paused/success; icon or text plus color. |
| Action control | Primary/secondary/quiet/destructive; hover/pressed/focus/loading/disabled. |
| Feedback | Inline error, content-shaped loading, confirmation, undo when supported. |

Never make a card with nested actions behave as one undifferentiated click target. Opening a project, saving it, and opening a person must have distinct targets and predictable focus order.

### Common recovery states

| Situation | What to show | Recovery |
| --- | --- | --- |
| Initial loading | Skeletons matching the actual panel/card and a brief contextual label. | Keep navigation usable; no indefinite spinner alone. |
| Upload fails | Error at the artifact plus retained text/selection. | Retry or choose another file. Claim “nothing lost” only when that is true. |
| Publish/keep fails | Draft still visible; clear failed action. | Retry without duplicate submission or losing work. |
| Missing media | Stable preview frame with file type/title. | Read available context and retry/open the file if supported. |
| No results | Active filters and a clear explanation. | Clear Filters or another discovery mode. |
| Unsaved draft exit | Explain what will be retained or discarded. | Continue editing, keep privately if supported, or explicit discard. |
| No notifications | Calm empty state. | Explore or return Home. |
| Request pending/declined | Accurate status and project context. | Return later or take the separate branch path. |

Do not use transient toasts as the only evidence of a major change. Added chapters, posted invites, saved states, and accepted requests remain visible in their relevant surfaces.

## 9. Motion direction

Motion should explain origin, progression, selection, and consequence. The values below are proposed timings for the first prototype. Adjust after observing the actual interaction; do not claim they were measured from the reference videos.

| Event | Timing target | Behavior |
| --- | --- | --- |
| Button/chip feedback | 120-160ms | Color/border or very small positional feedback; no bouncing controls. |
| Panel/sheet opening | 200-240ms | Enter from the region it belongs to; keep context visible. |
| Story chapter selection | 220-320ms | Update emphasis and detail; pan only when the selected node would be obscured. |
| Guided graph growth | 450-650ms per deliberate step | Reveal the connection, then the artifact, then its label/author as one readable sequence. |
| New chapter joins | 600-800ms total | Show origin, extend the branch, settle the new chapter and credit. |
| Swipe completion | 180-240ms | Finish in the chosen direction; bring the next card forward. |
| Hover preview | 100-150ms delay, short fade | Avoid flicker when crossing nearby nodes; show on focus without requiring hover. |

Use a consistent decelerating ease for entering panels and settling cards. Timeline dragging tracks the input directly rather than lagging behind an easing animation. Cancel playback/auto-pan when the viewer manually selects or navigates.

Honor reduced motion: remove orbiting, perspective shifts, graph travel, and large slide transitions. Use immediate selection or a short opacity change; preserve the same sequence, labels, credit, and controls. Audio/video is user-initiated, with pause and accessible text alternatives.

## 10. Responsive and accessible behavior

**Primary review viewport:** 1440 x 900, inherited as provisional from the visual spec. **Secondary:** 390 x 844. Also check a 1024px-wide viewport, a 320px-wide narrow layout, and enlarged text/zoom so the layout does not only work at the demo size.

| Width | Proposed layout |
| --- | --- |
| 1200px and above | Desktop navigation; graph with side detail panel; generous 32px page padding. |
| 768-1199px | Reduced padding; details become an overlay when needed to preserve graph readability; fewer simultaneous columns. |
| Below 768px | Single-column content, bottom navigation, full-width cards, sheet/full-screen details; timeline becomes horizontally navigable or a vertical chapter list. |

On a phone, default Project Story reading to a chapter list with a clear Map toggle. The graph stays available, but it is not a tiny desktop canvas squeezed behind three panels. Preserve the same selected chapter across list/map changes. Close sheets before opening another; avoid overlapping action bars.

Implementation acceptance targets:

- All actions work with keyboard, pointer, and touch where applicable; dragging, swiping, hovering, and graph panning have alternatives.
- Use semantic controls, persistent input labels, meaningful names for icon-only controls, logical heading order, and a visible focus indicator.
- Aim for at least 4.5:1 contrast for normal text and 3:1 for large text and essential interface boundaries. Verify actual rendered combinations; this guide is not a compliance certification.
- Do not convey status solely through pastel color, line style, position, or animation. Include readable labels.
- Provide meaningful alternative text for informative images and text/transcripts for relevant audio/video. Describe the work, not a file identifier.
- Announce important state changes accessibly without repeatedly announcing every animation frame.
- Dialogs/sheets manage focus, have a visible close action, and return focus to the initiating control. Sticky regions cannot obscure focused controls.
- At text enlargement, let titles wrap and panels scroll; do not truncate the question, invitation, or primary action. Permit horizontal scrolling inside a graph/timeline only, not accidental whole-page overflow.

## 11. Copy and content rules

Keep established step names in the design specification so agents can trace them to the conceptual model. Prefer direct, human wording in the interface. Show what the action does and what happens next.

| Moment | Suggested wording |
| --- | --- |
| First visit | “What are you exploring?” |
| Ask for Help | “Where could someone contribute?” |
| Private branch | “Private draft” and “The original is never touched.” |
| Unexplored path | “This could go somewhere else.” followed by the actual opportunity. |
| AI entry | “Suggest Where I Fit” with “Optional AI.” |
| AI result | “AI suggestion” with Edit and Dismiss. |
| Kept chapter | “[Name] added a chapter” with a link to the chapter. |
| Branch notification | “Someone branched your work” with actual actor/project context when available. |
| Failed upload | “Upload failed. Your note is still here. Try again.” only if the note was retained. |

These are examples, not claims about implemented persistence, audience controls, exports, or data practices. Do not display “Saved,” “Private,” “Exported,” or “Shared” unless the underlying prototype state supports that meaning. Label demo limitations in the prototype handoff, and keep interface feedback accurate within the demonstrated scope.

Use authentic, supplied project material. Do not insert stock work, invented testimonials, fake collaborator activity, or generic lorem ipsum. If real project content is not available, use clearly identified sample content and record that fact; do not present it as research evidence.

For the hero story, prepare a content fixture with a starting question, multiple experiments, one decision with a reason, one abandoned direction, an open invitation, and a new contributor's chapter. Credit three disciplines where actual or explicitly fictional sample content supports it. Do not assign names or roles to real teammates without evidence.

## 12. Build order for design agents

Follow the repository's approval workflow for implementation. This sequence is a UI/UX work breakdown, not permission to broaden the build or choose an infrastructure stack.

1. **Inspect and preserve.** Read current project instructions and UI assets. Identify established styles, controls, and user changes. Keep a short list of conflicts with this proposed direction.
2. **Establish the visual foundation.** Apply shared type, color, spacing, media treatment, identity, buttons, tags, panels, and graph tokens. Use the supplied project story to judge the result.
3. **Build Hero 1 first.** Make Open a Project -> Follow Its Story complete, including chronology, authors, a turning point, manual controls, and an open end.
4. **Extend that surface for Hero 2.** Add Find Your Place, a private branch, explicit review, keep/try again/discard, and a visible credited chapter. Reuse graph and context components.
5. **Complete Hero 3.** Add the creator's invite panel, swipe-card discovery, explorer response, request review, acceptance/decline, and accurate credit states.
6. **Add only the supporting surfaces needed.** Home Hub, Wander the Graph, Notifications, Living Map, and guest entry. Keep later screens in section 6.10 deferred unless specifically requested.
7. **Review real interactions.** Check desktop/mobile, keyboard, reduced motion, error/recovery states, and authored content. Judge the rendered UI and the actual sequence, not only a component inventory or screenshots.

Keep design decisions reviewable: for each material departure, note the screen, the precedent being adapted, the reason, and whether it is a reversible visual default or an unresolved product behavior. Update other project records only when the assigned implementation/documentation scope calls for it.

## 13. Acceptance criteria and handoff

Do not describe a flow as complete merely because its primary screen exists. The UI/UX handoff should demonstrate the following with screenshots and a short interaction recording or walkthrough of the actual prototype when built:

### Hero 1

- [ ] A viewer can identify the starting question, sequence, turning point, author, and unresolved possibility.
- [ ] Previous/Next, chapter selection, and the timeline update the same story state.
- [ ] The full graph remains understandable and available outside guided playback.
- [ ] Media failure and reduced motion preserve comprehension.

### Hero 2

- [ ] All four Find Your Place choices are visible and understandable.
- [ ] A complete manual path exists without AI.
- [ ] A private draft is unmistakably separate from its source.
- [ ] Review explains visibility, credit, and the effect of keeping a chapter.
- [ ] Keep, try again, discard, and failure have distinct, accurate outcomes.
- [ ] A kept chapter visibly links to the origin and credits the contributor.

### Hero 3

- [ ] A creator's specific stuck point becomes an understandable Open Invite.
- [ ] An explorer can inspect it before responding; swiping does not silently send a request.
- [ ] The creator can review, accept, or decline with clear feedback.
- [ ] Acceptance makes credit visible without inventing completed work.
- [ ] Decline still leaves the independent branch path available.

### Cross-screen craft

- [ ] The same project, person, node, and status look consistent across surfaces.
- [ ] The references are recognizable through layout and interaction principles, without unrelated features or copied branding.
- [ ] Every surface has a clear Home Hub path; returning preserves useful local context.
- [ ] Empty/loading/error/selected/focus/success states are designed, not left to browser defaults.
- [ ] Keyboard and touch alternatives exist for graph, scrubber, swipe, and connection interactions.
- [ ] Mobile and enlarged-text layouts keep primary actions and authorship readable.
- [ ] Claims about saved work, privacy, sharing, requests, and AI match actual behavior.
- [ ] Remaining product assumptions and prototype limitations are listed honestly.

### Open decisions to carry forward

The design defaults above can support a first implementation within an authorized build task. These questions remain open and must not be disguised as settled requirements:

- Final brand typography, palette, wordmark, and whether the team wants the proposed restrained pastel direction.
- Exact guest sign-up trigger and whether Save for Later persists for guests.
- Audience, approval, and reversal rules when a private branch becomes a shared chapter.
- Autosave/persistence guarantees and what “nothing lost” can truthfully promise.
- Whether creators can discuss a request before accepting it.
- Whether optional AI is demonstrated, and the actual capabilities/data practices behind it.
- Exact behavior of Shuffle, Follow a Person, Pecha Kucha saving, integrations, and export.

Do not block a reversible layout/style draft on all of these questions. Keep uncertainty explicit, and resolve the dependent behavior before making user-facing promises.
