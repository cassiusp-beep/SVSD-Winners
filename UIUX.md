# YaYa — UIUX handoff

Updated 18 October 2026. **Current direction: individual first; team integration follows.** This guide specifies the new experience from the latest whiteboard and direct user clarifications. It is a documentation proposal, not a report of implemented features or tested usability.

**Build status · 19 October 2026 (iOS prototype).** The iOS build uses a different onboarding order, approved by the user: Welcome, Sign up, Profile, Intro, Quiz or Talk, Reveal, Integrations, Sync, then the app. The whiteboard A/B/C order below is unchanged as the entry analysis, but the iOS build follows the approved order (DECISIONS.md, Decision 015). Welcome keeps the original full-width buttons (Decision 017). The N04 intent question is officially implemented as an engaging 3-question scored quiz mapping to the user's thinker archetype sprite family (Cloud, Bloom, Prism, Spark), with an audio Talk alternative. Screen details and open decisions for this flow are in DECISIONS.md, not restated here.

## 1. Read the sources correctly

| Source | What it governs |
| --- | --- |
| Latest direct user instructions | Individual-first product direction; establish the individual before team integration; team context may be included during Import work. |
| [Whiteboard, `20261018_123729.jpg`](docs/references/individual-onboarding/2026-10-18%20Onboarding%20Whiteboard.jpg) | A/B/C entry paths; anonymous recording trial; optional intent questions; import work and/or create context; personal profile; refinement, stories, build and explore. |
| [Figma, Prototype · v1](https://www.figma.com/design/N417D7w9RQt7jQSCXBNBr5/SVSD-Winners?node-id=73-711) | **Earlier UIUX precedent only.** Use its observed visual language and applicable interaction patterns. Its product model, frame inventory and navigation do not define the new flow. |
| Earlier product, system and interaction documents | Historical reasoning only where consistent with the latest direction. Do not silently restore the team-first meeting product or creative-exchange marketplace. |

The user explicitly clarified that the Figma reflects previous ideas. Keep three evidence classes distinct: **confirmed** means stated by the user or whiteboard; **observed** describes an inspected Figma screen; **proposed** means a new handoff decision to prototype and validate. All N-series screen IDs below are proposed handoff IDs, not Figma node IDs or implemented routes.

## 2. Product experience

YaYa helps an individual retain and connect their work, thoughts and sources, then develop a clearer account of what they are exploring. A person can start with a short recording or existing work. They receive a personal context they can inspect, correct and build upon; the map supports interpretation rather than evaluating the person's worth or ability.

The first useful result is **recognizing a thread in your own work and being able to change or develop it**. A populated dashboard, a completed quiz or a larger node count is not the outcome.

Keep these constraints throughout:

- **Start with something the person already has:** a thought, recording, artifact or link. Do not require a formal project structure first.
- **Multiple entries, one experience:** trial, guided import and direct import converge on the same personal workspace.
- **The person owns the interpretation:** inferred themes and suggested relationships remain editable and dismissible; every interpretation can lead back to its sources.
- **AI is optional:** manual context, nodes, links and stories remain usable. Automatic transcription or semantic mapping must identify any required AI processing before it occurs.
- **Team material can inform personal context without creating a team workspace.** Importing a shared artifact does not grant new people access to the user's profile.
- **Mobile first:** immediate capture, readable focused views and thumb-accessible actions. Desktop later adds room for the same content and context.

## 3. The three entry paths

These paths transcribe the whiteboard's A/B/C structure. They are entry preferences, not fixed personas or account types.

**A — Try before committing**

`Entry → anonymous recording trial (up to 2 minutes) → sign up → optional intent questions → create new context → personal profile → build / explore`

**B — Guided start with existing work**

`Entry → sign up → optional intent questions → import work → personal profile → build / explore`

**C — Direct start with existing work**

`Entry → sign up → import work → personal profile → build / explore`

Proposed improvements without changing that structure:

- Preserve the trial when moving into signup. The first context can reuse that recording; never make A record the same thought again.
- Intent questions are optional for everyone. Show a visible **Skip for now**, not a hidden shortcut for C.
- Import and create context are complementary. Add a link beside a recording, or record a reflection on an imported artifact, without restarting onboarding.
- If a person has no work ready, **Record a thought** or **Write a note** substitutes for import. There is no minimum artifact count.
- Keep registration to account access. Name, image, interests and richer profile details can be added or corrected afterwards.
- In returning use, offer **Record** immediately in the personal workspace. No quiz, import wizard or dashboard tour repeats.

The anonymous preview should show the value before signup; registration preserves or continues the work. This is a proposed product behavior, not an existing persistence guarantee. Trial storage, expiration and cross-device recovery must be decided and reflected honestly in the interface.

## 4. Screen and interaction handoff

**Proposed design scope: 10 reusable screen families.** N01–N08 cover the three entry paths and first exploration; N09–N10 cover stories and control of data. Variants below are states of those screens, not separate routes. This count is a planning aid, not a count extracted from the old Figma.

| ID / family | What the person sees and does | Leads to / result | Required states and assets |
| --- | --- | --- | --- |
| **N01 Entry** | One concise explanation; primary **Try recording** and clear **Sign up**; returning **Sign in**. | Trial in N02 or account access in N03. | New/returning entry; recognizable recording action; no feature carousel or compulsory profile form. |
| **N02 Capture / create context** | Record, pause, resume and stop; or write a note/add a link. Trial shows the two-minute limit. Signed-in use can attach material to an existing context or leave it unassigned. | Saved context; trial preview, then N03 to continue; signed-in first use proceeds to N06. | Ready, permission request/denied, recording, paused, saving, saved, interrupted/recovery, empty note, optional draft processing/failure. Record controls, timer, audio status, context attachment. |
| **N03 Account access** | Sign up or sign in using supported methods. Keep a visible indication that the trial is being carried forward. | A/B can take N04; C goes directly to N05; existing account resumes its workspace. | Invalid input, pending, success, account exists, canceled or failed signup with recoverable draft. Do not present unsupported SSO as functional. |
| **N04 Intent — optional** | Ask **What brings you here?** with a 3-question scored quiz mapping to your thinker archetype sprite (or audio Talk option). Optional skip available. | Create context (A), import (B), or skip into either. | Unanswered/skipped/edited; 3-question scored quiz or audio Talk; maps to sprite family (Cloud, Bloom, Prism, Spark). |
| **N05 Import work** | Add files, links or recordings; preview selected items. Let the person add team/project context and clarify their contribution where relevant. | N06 once useful material is available; may add N02 reflection first. | Empty, selected, importing, partial success, unsupported/unreadable source, duplicate and canceled. Source preview, scope control, attribution field, retry/remove. |
| **N06 Personal profile / initial context** | Name and optional image; user-stated interests; a few editable threads drawn from selected work, with supporting sources. Primary **Build / explore**, plus **Add context** and **Refine**. | N07 workspace; refinement stays here or opens a detail sheet. | Sparse/manual, proposed interpretation, edited/accepted, no reliable theme, processing, failure. Source-linked theme, edit/dismiss, privacy status. Do not block progress waiting for a complete profile. |
| **N07 Build / explore** | Connected ideas and artifacts; focus one branch at a time. Record/add work stays easy to reach. Select a thread, connect ideas, add a branch or begin a story. | N08 detail, N02 capture, N05 import or N09 story. | Empty/focused/selected, unsaved edit, draft relationships, loading/error; map controls, source-type labels and accessible outline alternative. |
| **N08 Idea / source detail** | Read an idea, its sources and relevant relationships. Edit labels, inspect the original context, remove an incorrect connection, or add a related thought. | Return to the same place in N07; update the map or add to a story. | Source available/missing, unsupported preview, draft versus user-confirmed interpretation, save failure. Evidence panel, linked-source preview, relationship editor, undo. |
| **N09 Story draft** | Choose a thread and relevant evidence; arrange it into an editable account of the work. AI can suggest a draft when enabled; manual composition remains available. | Saved draft; explicit preview before any export or sharing. | Empty/manual/generated draft, edited, missing evidence, export pending/failed. Source selector, ordered story blocks, edit/reorder controls and audience preview. |
| **N10 Preferences / data** | Control processing choices, account access, selected sources and exports. Clearly separate personal storage from any later team access. | Return to the prior screen; permissions change only through explicit action. | AI enabled/disabled, permissions changed, export selection/preparing/ready/failed, destructive confirmation. Preference rows, plain scope copy, downloadable-content selector. |

Use sheets or inline panels for quick edits and small decisions; do not create a full screen for every tag, permission explanation or edit. Reuse the capture composer, source picker and evidence viewer across all paths. System permission dialogs are platform surfaces, not custom screens to imitate.

## 5. Interaction contracts that must survive implementation

### Trial and capture

The person explicitly presses Record; microphones never start on page load. Ask for microphone permission at that moment and give **Write instead** if unavailable. Explain any enabled AI processing before the trial processes audio. Separate **recording**, **saving** and **interpreting** so a pending interpretation does not look like lost audio.

At the trial limit, stop cleanly and show what was retained. Do not interrupt mid-thought with an account wall that discards the recording. A signed-in capture's duration policy is unresolved; the whiteboard's two-minute note applies to the anonymous demo.

A manual session may retain audio or written notes without automatic transcription or mapping. Offer manual nodes and connections rather than making **AI off** a dead end. Do not imply that an AI-powered trial works identically when its processing is disabled.

### Import and team context

One import step accepts personal work, relevant team material or a mixture. Proposed optional prompts are **What is this?**, **Your contribution**, and **Who else contributed?** Ask only when needed; filenames and source metadata can reduce typing but remain editable. Do not infer sole ownership from the importing account.

The whiteboard's “living links if possible” and “connect MCP” are exploratory mechanisms. In product copy use **Connect a source** and name the actual supported service. A pasted link may be a saved reference or a one-time import; it must not imply ongoing synchronization. If refresh is later supported, distinguish last imported content from newer content and ask before replacing meaningful user edits.

Authorized team context may enrich an individual's map during Import work, before that person's first profile is assembled. **Team participation comes after establishing the individual.** Invitations, shared workspaces, teammate permissions and collective interpretation belong to that later integration. Import does not automatically invite, notify, publish, infer team roles or expose the personal profile. Keep origin and attribution attached to shared work; provide a clear scope preview before any later sharing.

### Profile and interpretation

The whiteboard phrase “initial evaluation of you” becomes **Your starting threads** or **A starting picture of your work** in proposed interface copy. Branch describes material the person chose to provide, not their personality, creativity level or professional value.

Separate **You told us**, **From your work** and **Suggested connection** when it helps explain an inference. Each theme has evidence, edit and dismiss actions. Sparse material should produce an honest sparse profile; no fabricated certainty, percentages or completeness pressure. Skipped intent questions must not reduce capability or generate an inferred substitute answer.

The pictured Starting Sprite, Pixel Pusher, Creative Cloud and Technical Triangle are **exploratory identity illustrations**. They are not settled categories, a growth ladder or automatic personality assignments. If retained later, make them user-chosen, optional and changeable; never use them to gate features or rank people.

### Explore and tell a story

The graph carries connections and provenance. Do not fill it with decorative nodes. Selecting an idea should reveal a small, legible neighborhood, with clear access to its source; it should not summon every relationship at once. Show relationship meaning in short labels and differentiate suggested from user-confirmed links using text or line treatment as well as color.

Keep the person's location stable when adding nodes. Provide **Back to thread** and a readable outline/list view. Manual link creation needs a button-based alternative to dragging. Story extraction is an explicit operation over selected material, not automatic publication. Preserve alternatives and uncertainties rather than rewriting all work as a tidy success narrative.

## 6. Minimize effort; retain meaningful decisions

| Interaction level | Examples | Design treatment |
| --- | --- | --- |
| **Micro: operate the interface** | Record/pause/stop; edit a title; open evidence; select a source; return to a branch. | Familiar, immediate, reversible. Keep controls in stable positions and provide clear feedback. |
| **Macro: change meaningful context** | Add work to the personal map; adopt/refine an interpretation; connect previously separate ideas; develop a story. | Show the benefit and resulting context. Avoid unnecessary setup between intention and result. |
| **Deliberate decision** | Enable new processing scope; attribute a contribution; share private work; remove source material irreversibly. | Explain the actual consequence at the point of action. Ask for confirmation where the action changes access or cannot be undone. |

Remove mandatory quiz completion, project naming before capture, duplicated recording after signup, one-confirmation-per-node workflows and forced profile polishing. Keep intentional review around meaning and access. The value moments to test are the first useful connection, correcting a mistaken interpretation, recovering an earlier thought and forming a story from actual evidence.

## 7. Visual language from the previous Figma

**Observed, not measured tokens:** mobile frames around 390 × 844; warm light surfaces; dark pill-shaped primary actions; pale fine borders; serif content headlines contrasted with sans-serif utility labels; restrained pastel organic motifs. Individual screens use generous spacing, concise labels and scannable rows/cards. Exact font families, sizes, color codes, radii and spacing values were not inspected and must not be invented as Figma tokens.

Reusable precedents inspected in the visible design canvas:

- **[U26 You — private profile, node 138:1401](https://www.figma.com/design/N417D7w9RQt7jQSCXBNBr5/SVSD-Winners?node-id=138-1401):** personal header, interests, content counts, privacy language and thread cards support N06's hierarchy. The fixture “Design student” does not define the target audience; old Home/Projects/You navigation is not adopted as a requirement. Nearby U27 Account uses grouped account fields and preference rows; U07d Download data uses selectable categories and one preparation action. These inform N10's controls, not a promise of identical data categories or account capabilities.
- **[U14 Project map, node 73:1050](https://www.figma.com/design/N417D7w9RQt7jQSCXBNBr5/SVSD-Winners?node-id=73-1050):** generous open graph space, rounded text nodes, a dark selected/central node, fine connectors, some dashed draft outlines and restrained pastel emphasis. Nearby U15 Idea details retains the dimmed map behind a rounded sheet with a grab handle, serif heading and source row. Adapt these to N07–N08 for focus and context; keep their old project-specific controls provisional.
- **[U08b Recording paused, node 96:1284](https://www.figma.com/design/N417D7w9RQt7jQSCXBNBr5/SVSD-Winners?node-id=96-1284):** the selected frame is labeled 390 × 844. A visible pause/timer state, a soft central pastel form, large speech excerpt and separated circular controls suggest a calm capture hierarchy. Adjacent Save thoughts uses a single-column form, explicit AI toggle and dark primary action. Reuse clarity of state, not mandatory title/project/tag/save steps that would add effort to the new capture flow.
- **[U05b Source detail — from idea, node 101:1292](https://www.figma.com/design/N417D7w9RQt7jQSCXBNBr5/SVSD-Winners?node-id=101-1292):** audio controls, metadata, timestamped transcript and highlighted cited passage show provenance clearly. Visible **Branch with AI** and **Add ideas manually** illustrate parallel processing choices. Nearby History shows dated events, while Delete source previews affected ideas in a confirmation dialog. Adapt evidence, choice and consequence patterns to N08–N10; do not imply those exact history or restore functions already exist in the new product.

These are static visual observations. Animation, timing, responsive behavior and functioning prototype transitions were not verified. Inspect actual Figma properties before turning the visual direction into measured implementation tokens.

Apply the precedent as a visual direction: a calm light base, a strong typographic hierarchy and one clear primary action. Use actual work and meaningful graph relationships as the main content. The whiteboard's character sketches are optional illustrations, not a replacement for source material. The earlier Night Lab palette and old screen inventory do not override this newer requested UIUX reference.

Any diagram added to this handoff should use a white background, short labels and simple branching. Preserve editable source formats; do not replace semantic relationships with a flattened image alone.

## 8. Component and accessibility checklist

Build a reusable set before multiplying screen variants: primary/secondary/text actions; account fields; recording controls and status; source picker/preview; intent choices; profile theme with evidence; idea node and labeled connection; detail sheet; story block; processing status; reversible feedback/undo; scope and audience preview; destructive confirmation.

Proposed usability defaults, not measurements from Figma:

- Target touch controls at least 44 × 44 CSS pixels with space between destructive and routine actions.
- Never require hover, pinch, drag or a precision connector gesture as the only way to perform an action.
- Support keyboard focus, readable labels and logical reading order. A map needs a structured alternative exposing the same ideas and relationships.
- Use both text and visual state for recording, AI proposals, errors and selection. Do not rely on pastel color to communicate status.
- Keep recording feedback visible without flashing or distracting map movement. Respect reduced motion; transitions should explain where content appeared or moved.
- Preserve text scaling and readable contrast. Confirm actual contrast once measured color tokens are available.
- Desktop may show map and detail side by side; mobile may use a sheet. Preserve the same selected idea, attribution and editing rules across layouts.

## 9. What to prototype and resolve next

Prototype the three entries with the same downstream components. Walk through A with a retained trial, B with a guided import and C with the quiz skipped. In each, demonstrate one editable personal thread and one source-backed connection; do not expand into team administration first.

Check whether a new person understands the result, can correct it and can find the next useful action without being taught graph terminology. Check microphone denial, canceled signup, partial import, AI off and a source that cannot be read. These are proposed evaluation scenarios, not tests already performed.

Still unresolved: anonymous retention/expiration; supported sign-in and import services; living-source refresh behavior; exact visual tokens; how much live mapping to reveal during recording; optional persona treatment; initial story output format; and the eventual team-sharing journey. Do not silently implement assumptions as settled requirements.

This guide supersedes the earlier UIUX product flow for new design work. This handoff records design intent. Creating this guide did not implement or validate application features, modify Figma, deploy the product, or change backend architecture.
