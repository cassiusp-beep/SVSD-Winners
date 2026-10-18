# Branch — comprehensive system design

**Historical reference:** this is the preserved 17 October individual-first design, with its later status notice. Inherited requirements, screen counts and “current” labels below apply only to that earlier proposal. Begin at [current agent context](../../../CONTEXT.md) for the live team direction. Do not use this archive as its build blueprint.

**Direction update · 18 October 2026:** the user has pivoted to a live shared semantic map for collective idea development. Read [Product Definition.md](../../context/product-definition.md) for current positioning, the target-audience hypothesis, counter-positioning and the autopilot/intentional-friction rules. Live AI proposals may appear within an authorized session, but meaning, agreement and wider access require participant control.

**Status of the specification below:** retained from the individual-first design of 17 October. It has not been rewritten for the live team product. Its 17-screen inventory and post-capture AI sequence are historical design proposals, not the committed team-app architecture. The source, revision, accessibility and portability principles remain useful. The latest user instruction and the dated product definition take precedence.

Start with the [UIUX interaction handoff](Maps/05%20Interaction%20Breakdown.drawio). It is one editable file with two pages: **01 Screen flow** shows the continuous core journey using screen/control sketches; **02 Screen and asset checklist** specifies what to design for every current screen. The two pages replace the overcrowded all-in-one interaction map. They do not add screens or change product scope.

## Contents

- [Product boundaries](#product-boundaries)
- [Screens and journeys](#screens-and-journeys)
- [UIUX production handoff](#uiux-production-handoff)
- [Interaction design](#interaction-design)
- [Data and backend](#data-and-backend)
- [Privacy, implementation and validation](#privacy-implementation-and-validation)
- [Detailed interaction contracts](#detailed-interaction-contracts)
- [Diagram handoff](#diagram-handoff)

## Product boundaries

### Product and audience

**Branch is a visual memory for designers and creative professionals. It turns captured conversations, voice notes and documents into an editable map of ideas, helping people recover their thinking, understand how it changed and reuse it in new work.**

Begin with an individual designer, architect, engineer or other creative professional working across projects. Being a student is not the audience definition. An individual must receive complete value before inviting anyone.

The core job is: “I remember considering something useful. Help me recover the idea, its context and why I moved away from it.” The product should help when resuming work, reconsidering a decision or beginning related work.

The eventual corporate use case is maintaining shared project understanding across conversations, documents and people. Shared context for agents is a later use of that record. Neither is required for the first individual product.

### Decisions to preserve

1. **Individual first.** No public profile, collaborator invitation or forced project filing before first value.
2. **Record first.** Opening the app lands on Recorder U08 ready. One deliberate tap begins capture; only a necessary system microphone prompt may intervene. No dashboard browsing, menu, scrolling, onboarding tour, sign-in, title, project or AI setup precedes the first recording. Import remains an available secondary path. Record once, set the phone down and stop after the session.
3. **Nonlinear ideas, chronological history.** An idea can be unfiled or belong to multiple projects. Its changes remain traceable over time.
4. **Optional AI.** Manual mapping, source access, text search and export work with AI disabled. Automatic transcription, semantic extraction and semantic suggestions require enabled AI.
5. **Human authority over meaning.** AI proposes changes. It does not silently publish accepted nodes, fabricate a decision or resolve disagreement into consensus.
6. **Inspectable evidence.** Nodes and relationships can open their supporting material. An inferred link is visibly different from an accepted relationship.
7. **Selective sharing later.** Share a project and authorized supporting material, not an entire private library.
8. **Open-source direction.** Preserve data portability and a plausible community-supported path. Optional hosting or team services are a sustainability hypothesis. Data sales and unconsented model training are not the business model.

“World model” here means a maintained representation of project ideas, constraints, decisions and relationships. Do not promise a predictive world simulator. The consumer-facing explanation is simply “your ideas and how they connect.”

Native/web delivery, storage, sync, authentication, models and hosting remain undecided. The Vercel/local-video decisions apply to Shot Canvas, a separate app. Start with individuals; desktop, shared corporate context and read-only agent integrations come later.

## Screens and journeys

**Inventory: 17 full screens + 3 sheets/dialogs + 1 reusable recovery state.** U21–U24 are four later sharing views. States and editor modes are not extra screens. OS microphone prompts, file pickers and native sharing are platform surfaces.

### Opening screen and navigation

**Open Branch → see Record immediately → tap once to record.** Use the ready state of U08; do not invent another home or dashboard screen. Keep the primary Record control above the fold. Library and Import are secondary ready-state actions. Updates remains reachable when returning to proposals.

Do not require an Add menu, dashboard scrolling, onboarding tour, sign-in, project selection, title or AI settings before the first recording. The system microphone prompt appears only when needed, after the person taps Record. Opening the app itself must never start recording automatically.

Library holds earlier sources and projects. Updates holds pending proposals. A focused map opens after acceptance or from Library. A first session needs no named project. On phones, source, idea, review and editing views are full-screen; short choices use sheets/dialogs. Back restores the previous map/selection. Desktop can later use side panels.

### Connected journeys

#### The six-moment screen sequence


1. **U08 ready — Open Branch.** A large Record control is the obvious first action.
2. **U08 active — Record.** Tap Record, grant microphone permission if needed, then set the phone down. Show elapsed time, Pause/Resume and Stop. No tagging or live map maintenance is required.
3. **U04 — Source saved.** Stop finalizes and saves the audio. Show success only after persistence; no extra Save tap. A default title is enough; rename/file later. Build idea map and Keep audio only are the next choices.
4. **U05 — Processing → ready.** Use permitted AI only. Keep the original accessible, show actual progress and allow leaving. Review ideas becomes available when a draft is ready.
5. **U11 — Draft review.** Inspect supporting evidence, edit or dismiss proposals, then Accept selected. Do not force a visit to Updates first.
6. **U14 — Focused session map.** Show accepted ideas immediately, even without a named project. Tap an idea to open U15 and its U16 source/history links; Record remains available for the next thought.

There are six visual moments but only five unique screens: ready and active share U08. On first AI use, **U04 → U07 choice → U05** is a conditional step after capture. With an existing permitted preference, proceed directly. AI-off path: **U04 → U05 saved source → U10 manual node → U14 map**; keeping audio without creating any node is also valid.

If microphone permission is denied, U09 explains retry/settings or import/write. A save failure retains recoverable capture and never displays “saved.” Returning to an active/interrupted recording restores its status, not a second fresh capture. Test interruption and lock-screen behavior on the actual chosen platform before making claims.

Import remains secondary: U08 → U03, or U01 Library → U02 Add material → U03 → validated save → U04. Support supported text/transcripts first; retaining an attachment does not imply automatic interpretation of every format.

#### Review suggestions or create a node manually

With permitted AI: Source detail **U05** → **Review ideas** → Draft review **U11** → accept selected changes → Project map **U14**. Updates **U06** is the alternative entry when returning later.

With AI off: Source detail **U05** → Node editor **U10** → save → Project map **U14**.

Draft review presents a small proposed map with source evidence beside it. View evidence can open the existing U16 viewer at the cited passage/time; Back restores the same U11 selection and review position. The primary actions are **Accept selected**, **Edit** and **Dismiss**. Keep unreviewed proposals separate from saved ideas. Editing opens the same node editor used by manual work. In draft mode, Save draft returns to U11 for explicit acceptance; it does not save the proposal as an accepted idea. Dismissal keeps the original source. A successful transcription is not approval of the meaning inferred from it.

#### Return to an idea

Recorder **U08 ready** → Library **U01** → Search results **U12** → Idea details **U15**, or Library **U01** → Project map **U14** → select an idea → Idea details **U15**.

Idea details exposes Source viewer **U16**, History **U19** and Edit **U10**. Preserve the project and query context when entering or leaving a detail view. A source link should open the relevant passage or real audio timestamp, not merely the top of a long transcript.

#### Reuse earlier thinking

Project map **U14** → Related ideas **U13** → Idea details **U15**, or Project map **U14** → Reuse idea **U18** → save into the selected project.

Related ideas explains the suggested connection with a reason and source evidence. The semantic suggestion path requires enabled AI. Dismissal creates no saved relationship; ordinary text search remains available without AI.

Reuse asks for an existing or new project, then distinguishes **Link this idea** from **Create a derivative**. Linking preserves the same identity across projects. A derivative gets its own identity and an explicit relationship to the original. Neither action removes the original context.

#### Export selected context

Project map **U14** → project menu → Export preview **U25** → confirm the selected scope → save or use the native share sheet. Preview the included ideas, relationships, source references and unresolved uncertainty. Export remains available with AI disabled. Close returns to the same project view.

#### Share later

Project map **U14** → Share preview **U21** → Invite/access **U22** → Shared map **U23** → Comments/changes **U24**.

Preview the exact project, nodes, links and supporting material that will become visible. Shared changes have attribution and use the same review rules. A comment does not automatically become a decision. Collaboration is not required for the first individual loop.

### Screen and panel contract

IDs match the [editable user journey](Maps/01%20User%20Journey%20-%20UI%20Screens.drawio). They identify interactions, not required URL routes.

| ID | Screen or panel | Entry and main action | Result or return |
|---|---|---|---|
| U01 | Library | Secondary navigation from Recorder; search, import or open a project | U02, U12 or U14; settings opens U07 |
| U02 | Add material | Library → Add | U03 for import/write; U08 for recording |
| U03 | Import / write | Select a file, paste or type | Continue to U04; cancel returns without saving |
| U04 | Source saved | Stop finalizes/saves; title and project are optional | Build map using permitted scope, first AI choice U07, or keep source U05 |
| U05 | Source detail | Original + processing/ready status | Direct Review U11; later Updates U06; manual U10; recovery U09 |
| U06 | Updates | Open a proposed change set | Review in U11; saved work remains separate |
| U07 | AI settings | Ordinary settings, or first AI use after U04 | Choose scope before processing; return to invoking context or U05 |
| U08 | Recorder | Default app entry; ready → tap Record → active | Stop saves to U04; ready-state Library/Import are secondary |
| U09 | Recovery | Failed input or processing | Retry returns to source status; paste/write fallback returns to U03 |
| U10 | Node editor | Source detail, draft edit, + Node or idea edit | Manual edit saves to U14; draft edit returns to U11 for acceptance; cancel returns to its entry |
| U11 | Draft review | Source detail → Review ideas, or Updates later | Accept selected → U14; edit → U10; dismiss keeps source |
| U12 | Search results | Library search | Open the selected idea in U15 with its context |
| U13 | Related ideas | Map → Related | Inspect in U15 or dismiss without adding a link |
| U14 | Project map | Library, accepted review or saved edit | Select a node, add, filter, reuse or open related ideas |
| U15 | Idea details | Select a map node or search result | Source U16, history U19 or edit U10; Close restores the view |
| U16 | Source viewer | Idea details → Source, or Draft review → View evidence | Inspect the evidence; source menu may open U20 |
| U17 | Filters | Map → Filter | Apply or clear view filters without changing records |
| U18 | Reuse idea | Map → Reuse | Link or derive into a chosen project; cancel preserves the original |
| U19 | History | Idea details → History | Compare versions; restore creates a new revision |
| U20 | Delete source? | Source menu → Delete | Confirm affected references or cancel; retained ideas show missing evidence |
| U25 | Export preview | Project menu → Export | Confirm permitted scope; save or use native share sheet |
| U21 | Share preview · later | Map → Share | Preview the exact scope, then continue to U22 |
| U22 | Invite / access · later | Share preview | Confirm people and roles, then open U23 |
| U23 | Shared map · later | Confirmed project access | Same map model with attribution and U24 discussion |
| U24 | Comments / changes · later | Shared map | Discuss or propose changes; proposals use U11 review |


### UIUX production handoff

The UIUX team should be able to answer four questions for any interaction: **Which screen am I drawing? Which control does the person use? What visible feedback or state change is needed? Where does that action go?** Backend work belongs in the backend map. A box named “apply change” or “process source” is not a sufficient UI design task.

Use the two pages of `05 Interaction Breakdown.drawio` together:

1. **01 Screen flow:** follow U08 Recorder → U04 Source saved → U05 Source detail → U11 Draft review → U14 Idea map. Record/active/paused are states inside U08. The source remains usable with AI off. Branches show first-use AI choice U07, manual editor U10, source evidence U16 and reuse U18. Editing and return destinations are written next to the control, not drawn as page-spanning arrows. Keeping a recording is already a completed goal.
2. **02 Screen and asset checklist:** create the 17 current full-screen layout families, three overlays and one shared recovery pattern. Each card has **Draw**, **States**, **Actions** and **Assets**. Secondary navigation, search, history, settings, import and export are defined here. Follow the U-number to reuse an existing layout, not to invent a duplicate screen.

The screen sketches are proposed low-fidelity layouts, not final visual styling, approved pixel dimensions or real source material. U/I/C numbers and destination notes belong to the design handoff; do not put implementation identifiers into consumer-facing UI. All text, containers, controls and arrows are native editable Draw.io objects. The gallery deliberately has no connector network; its Actions field gives exact destinations.

**Design output:** one named layout family per full-screen ID, reusable sheet/dialog components for U02/U17/U20, and the listed variants. A single layout may require several wireframes to demonstrate its states; 17 is not the number of all eventual frames. Apply U09 recovery inside the screen where the failure occurs. OS permission prompts, file pickers and native sharing are platform surfaces. Later collaboration U21–U24 and unresolved account/sync flows are not part of this first-release count.

**Prototype order:** prove capture U08 → U04 first, including save failure. Then source/manual creation U05 → U10 → U14, followed by optional AI choice, progress, review and evidence U07/U05/U11/U16. Add finding/reuse U01/U12/U15/U18 to test recurring value. Include the real choice between linking an idea and creating a derivative. Keep sign-in, naming and project filing out of first capture.

#### Shared assets to design once

These are component families and state variants to create, not claims that production image/icon files already exist. Reuse them across screen layouts. Include readable labels, visible focus, keyboard behavior, non-color status cues and touch-friendly controls. Playback and live microphone capture must look and behave distinctly.

- **C01 · Navigation:** Header · Back · Library entry; Focus / scroll restoration.
- **C02 · Recording:** Record / Pause / Resume / Stop; Timer · level indicator · mic status.
- **C03 · Source & evidence:** Audio player · transcript / excerpt; Attachment · citation · missing source.
- **C04 · Idea cards:** Title · type · status · selection; Empty / accepted / disputed variants.
- **C05 · Connections:** Labeled edge · proposed / accepted; Connect form · focused map / list.
- **C06 · Review:** Proposal · checkbox · selection count; Accept · dismiss · reversible Undo.
- **C07 · Forms & choices:** Field · picker · radio choice; Validation · draft / saved edit modes.
- **C08 · Find & filter:** Search · result · filter chip; No results · active filter / clear.
- **C09 · Status & recovery:** Saving · saved · processing · retry; Interrupted · failed · stale change.
- **C10 · Sheets & menus:** Action sheet · impact confirmation; Export scope · cancel / confirm.

#### Screen production cards

The exact action destinations are in the screen contract above and in the checklist page. This list adds the tangible design work and variants. “Draw” includes actual controls and content elements rather than backend status names alone.

**U08 · Recorder · Screen**

- Draw: Record button; timer; audio level; Pause / Resume / Stop; mic status.
- Variants: Ready · active · paused; Interrupted · permission denied.
- Reuse: C01 Navigation, C02 Recording, C09 Status & recovery.

**U04 · Source saved · Screen**

- Draw: Saved confirmation; audio preview; Build idea map; Keep audio only.
- Variants: Saving → saved; failed save; Optional rename / project later.
- Reuse: C03 Source & evidence, C07 Forms & choices, C09 Status & recovery.

**U05 · Source detail · Screen**

- Draw: Original source / playback; job status; Review ideas; Add idea manually.
- Variants: Saved only · processing · ready; Failed / cancelled; source retained.
- Reuse: C03 Source & evidence, C07 Forms & choices, C09 Status & recovery.

**U11 · Draft review · Screen**

- Draw: Proposals + links; select checkboxes; Evidence; Edit; Dismiss; Accept count.
- Variants: None / some selected; empty; Partial acceptance · stale change.
- Reuse: C03 Source & evidence, C04 Idea cards, C05 Connections, C06 Review, C09 Status & recovery.

**U14 · Idea map · Screen**

- Draw: Nodes + labeled links; map / list; Add; select; fit; filter; Reuse.
- Variants: Empty / populated; focused / filtered; Missing evidence; saved changes.
- Reuse: C01 Navigation, C04 Idea cards, C05 Connections, C08 Find & filter, C10 Sheets & menus.

**U18 · Reuse idea · Screen**

- Draw: Selected idea; destination picker; Link this idea / Create a derivative.
- Variants: Destination unset / selected; New project inline; saving / failed.
- Reuse: C04 Idea cards, C07 Forms & choices, C09 Status & recovery.

**U10 · Idea editor · Screen**

- Draw: Title / meaning; type; evidence; Relationship source / target / type.
- Variants: New idea · draft edit · accepted edit; Unsaved · validation · save conflict.
- Reuse: C03 Source & evidence, C04 Idea cards, C05 Connections, C07 Forms & choices, C09 Status & recovery.

**U16 · Source viewer · Screen**

- Draw: Audio player / text; cited excerpt; Real timestamp; source action menu.
- Variants: Available / loading / missing; Playback; highlighted evidence.
- Reuse: C01 Navigation, C03 Source & evidence, C09 Status & recovery, C10 Sheets & menus.

**U01 · Library · Screen**

- Draw: Sources / project list; search; Add; pending updates; AI settings.
- Variants: Empty / populated; saved material; Preserved scroll and search context.
- Reuse: C01 Navigation, C03 Source & evidence, C08 Find & filter.

**U12 · Search results · Screen**

- Draw: Search field; result + source context; Matched snippet; result selection.
- Variants: Query / results / no results; Loading; query retained on Back.
- Reuse: C01 Navigation, C04 Idea cards, C08 Find & filter, C09 Status & recovery.

**U06 · Updates · Screen**

- Draw: Pending change sets; source + date; Ready / processing badges.
- Variants: No updates · processing · ready; Failed; saved ideas kept separate.
- Reuse: C03 Source & evidence, C06 Review, C09 Status & recovery.

**U13 · Related ideas · Screen · optional AI**

- Draw: Suggestion cards; reason + evidence; Inspect / dismiss; source context.
- Variants: AI off · loading · suggestions; None / failed; no silent links.
- Reuse: C03 Source & evidence, C04 Idea cards, C08 Find & filter, C09 Status & recovery.

**U03 · Import / write · Screen**

- Draw: File / paste / write input; preview; Supported-format hint; Save.
- Variants: Empty / filled; unsupported / failed; Keep entered material on failure.
- Reuse: C03 Source & evidence, C07 Forms & choices, C09 Status & recovery.

**U07 · AI settings · Screen**

- Draw: Processing scope; what is sent; Enable / keep off; current preference.
- Variants: First-use choice after capture; Enabled / disabled; existing job status.
- Reuse: C07 Forms & choices, C09 Status & recovery.

**U15 · Idea details · Screen**

- Draw: Idea title / type / meaning; evidence; Source; History; Edit; Back.
- Variants: Accepted / tentative / disputed; Missing evidence; updated revision.
- Reuse: C01 Navigation, C03 Source & evidence, C04 Idea cards, C09 Status & recovery.

**U19 · History · Screen**

- Draw: Version list; author / time; compare; Restore target + effect preview.
- Variants: Current / selected revision; Restoring / restored / conflict.
- Reuse: C03 Source & evidence, C07 Forms & choices, C09 Status & recovery.

**U25 · Export preview · Screen**

- Draw: Included ideas / links / references; Scope selection; missing-asset notice.
- Variants: Ready / preparing / failed; Cancelled; permitted content only.
- Reuse: C07 Forms & choices, C09 Status & recovery, C10 Sheets & menus.

**U02 · Add material · Bottom sheet**

- Draw: Record / Import / Write options; Dismiss / close.
- Variants: Open / closed; caller retained; Never required before first Record.
- Reuse: C10 Sheets & menus.

**U17 · Filters · Bottom sheet**

- Draw: Filter choices; active chip / count; Apply; Clear; Cancel.
- Variants: No filter / active / no matches; Visible scope only; records unchanged.
- Reuse: C08 Find & filter, C10 Sheets & menus.

**U20 · Delete source? · Dialog**

- Draw: Affected references; impact summary; Delete / Cancel.
- Variants: Confirming / deleting / failed; Retained ideas show missing evidence.
- Reuse: C03 Source & evidence, C09 Status & recovery, C10 Sheets & menus.

**U09 · Shared recovery pattern:** show what failed, what is retained and the available Retry/fallback action inside the invoking screen. Cover denied microphone permission, interrupted recording, failed persistence, failed processing and stale edits. Never acknowledge a save before it succeeds, and do not make retry create duplicates.

#### Interaction reductions and value

The two-tap capture target applies after app open and microphone permission: Record + Stop. Automatic persistence, a neutral title and an unfiled source remove organization work. First-use AI choice happens after saving. Opening evidence at the actual passage, preserving navigation state, reusing one editor and accepting an explicit selection reduce repeated work. Review, processing consent, source deletion and reuse identity choices remain intentional.

Macro goals are capture, understand, recover and reuse. The flow page groups the core sequence by goal; the checklist supplies the recover/search screens. Microinteractions are controls and their state/feedback loops inside those screens: record/pause/resume/stop, select/deselect, edit, dismiss/undo, play/seek, filter/clear and confirm/cancel. A macro is not one tap, and a microinteraction is not necessarily a new screen.

The value checkpoints remain: dependable retention at U04, inspectable accepted meaning at U14, and useful retrieval/reuse through U12/U15/U18. Test those outcomes and correction effort with users; a cleaner diagram is not product validation.

### Map interaction and visual grammar

Nodes represent **Idea, Question, Constraint, Finding or Decision**. The default card needs a concise title, recognizable type and any meaningful status. Supporting paragraphs, attachments and evidence belong in its detail panel.

Connections express a relationship, such as supports, challenges, depends on or replaces. A suggested relationship is visibly different from an accepted one. Review state and meaning state are separate: an accepted record can still describe a tentative or disputed idea.

Proposed controls are pan, zoom, select, focus and a clear fit/return action. Make a node selectable by keyboard and provide a straightforward list/search route when spatial navigation is difficult. Creating a connection must have a clear source, destination and relationship type. Repositioning, zooming and filtering change the view, not the meaning or saved history.

Keep a stable local layout while a person reads or edits. Add accepted changes without unexpectedly rearranging the entire canvas. Avoid opening the whole library as a dense network. Showing provenance should help answer “Where did this come from?” and “What changed?”, without requiring database vocabulary.

### Sheets, dialogs and shared state — 4

- **U02 Add material:** bottom sheet; import/write or record.
- **U17 Filters:** bottom sheet; changes the visible map, not saved meaning.
- **U20 Delete source?:** confirmation dialog; previews affected references.
- **U09 Recovery:** reusable error/retry state in the relevant capture or source screen, not a standalone navigation destination.

### Later collaboration — 4 views

U21 Share preview → U22 Invite/access → U23 Shared map → U24 Comments/changes. U23 reuses the map layout with role and attribution states; U24 can be a discussion panel. These are four later views to consider, not four required first-release full-screen layouts.

### Wireframe variants, not extra screens

Include empty/populated Library; recording idle/active/paused/interrupted and permission denial; source saving/processing/ready/failed; AI enabled/disabled; draft/manual editor modes; review conflict and partial acceptance; search empty/results; missing evidence; failed saves and stale revisions; export ready/failure. U09 supplies the shared recovery pattern rather than replacing the context where an error happened.

Creation of a project can be an inline choice in save/reuse, not another setup screen. OS microphone permissions, file selection and the native share sheet are platform UI. Authentication, account recovery and sync settings are conditional on later technical choices and are not included in this count; revisit the inventory when those choices are made.

## Interaction design

### The design objective

**Make a fleeting thought safe with almost no interruption. Make it useful again without making the person organize everything.**

Branch opens on U08 Recorder ready. One deliberate tap starts recording; Stop saves automatically. Library, project filing, titles and AI choices come afterward. Keeping only a recording is a valid completed task. Never require a map to justify capturing something.

The supplied interaction framework informs the diagrams' structure: **screen/state → user action → system response → next state/outcome**. Its older profile/community examples do not define the current Branch product.

### Macro and micro mean different things

**Macrointeraction:** a complete user goal, often spanning several screens and many small interactions. Branch has four core macros: **capture a thought → make sense of it → recover the thinking → use it again**. These can happen across different days; capture does not force the remaining steps in one session. Control and recovery support all four.

**Microinteraction:** a focused control loop with a trigger, rule/state change, feedback and any repeated/reversible states. It may involve more than one tap. For example: tap Pause → audio capture pauses → timer/status and Resume label update → Resume continues the same session. “Record,” “select a proposal,” “dismiss,” “seek audio” and “clear a filter” are microinteractions.

Automatic persistence or transcription is system work, not another user interaction. Waiting, reading, choosing words and correcting AI output still consume effort even when there are no taps. Navigation alone is not the value delivered.

The flow page continues between screen layouts. Arrow labels show actions; short branches show first-use AI choice, manual editing, evidence and reuse. An explicit button destination such as “Save draft → U11” identifies the return without a long crossing arrow. The checklist page is an inventory, not another journey or a grid of new steps. Detailed I identifiers remain in editable object metadata and the catalog below. For example, U18 reuse requires destination selection, link/derivative selection and confirmation. It must not be counted as one tap. Repeated U labels describe states/entry contexts of the same screen, not extra wireframes.

### Where Branch must create value

- **V1 — A thought is safely retained.** U08 → U04. Immediate, dependable value. Show “saved” only after persistence. A default title and an unfiled session are sufficient.
- **V2 — The person can see and trust their reasoning.** U05 → U11 → U14, or manual U10 → U14. The differentiated payoff is accurate, editable ideas and meaningful source-linked relationships. A large graph or a successful transcript alone does not prove value.
- **V3 — Earlier thinking helps with current work.** U01/U12/U14 → U15/U16 → U18 → U14. Recover the reason behind an idea and reuse it while preserving its origin. This is the strongest recurring-value hypothesis to validate.

Prioritize reliable capture first, then a small useful map with evidence, then successful retrieval/reuse. Decorative node animation, streaks and mandatory organization do not strengthen this loop by themselves.

### Remove, defer, automate, preserve

**Remove from the opening path:** dashboard browsing, an Add menu before Record, scrolling, onboarding tours, sign-in, profile creation, project selection, naming and AI setup. Remove a second Save after Stop. Remove a required Updates visit between a ready source and review. Do not require graph dragging to create, inspect or reuse meaning.

**Defer until useful:** rename and file after saving; choose a reuse destination at reuse time; configure AI after capture and before first processing; sign-in only when a feature actually needs an account, without losing existing material. These are timing rules, not a chosen authentication/storage architecture.

**Automate safe work:** finalizing/persisting after Stop, neutral default titles, permitted indexing, job-status updates, carrying the current source into an editor, restoring navigation state and a stable initial layout. Automatic indexing must obey the allowed processing scope; ordinary text search does not require AI.

**Preserve intentional choices:** starting a microphone, granting required OS permission, allowing AI processing, accepting meaning, distinguishing a linked idea from a derivative, reviewing export/sharing scope and confirming source deletion impact. Never make permission dialogs disappear through auto-recording or silent consent. Never automatically accept a decision inferred by AI.

**Proposed efficiency choices to test:** explicit selection of a small group of proposals with a clear selection count; evidence opened at its cited time/passage; accessible Undo for reversible dismissal; simple controls to connect ideas without dragging. These reduce repetitive work while keeping the outcome visible. Batch acceptance must name the included nodes/relationships and must not silently include unrelated changes.

### Effort budget, counted honestly

- **Retain audio:** after the app is open and microphone permission is already granted, **Record + Stop = two deliberate taps**. Talking and elapsed recording time are not counted as taps. First-use OS permission adds interaction; recovery adds effort.
- **Create an AI-assisted map:** the current flow has five named primary actions: Record, Stop, Build idea map, Review ideas, Accept selected. Proposal selection, evidence inspection, corrections and first-use consent add actions and time. This is **not** a promise of five taps end to end.
- **No AI:** the same two-tap capture is complete value. Creating manual nodes requires entering meaning and saving; do not disguise that effort as automatic.
- **Retrieve/reuse:** count query entry, result inspection, evidence review, destination and link/derivative choices. A successful answer matters more than a low tap count.

An **optional, unvalidated later optimization** is “prepare drafts after each recording” for people who explicitly enable it. It could remove the repeated Build idea map action within permitted scope; it must retain a clear status/cancel control and explicit acceptance. It is not the current default and does not authorize always-on listening or automatic publication.

### Interaction contracts for builders

Use the diagram's I01–I28 identifiers in design reviews. Before implementing a control, specify: **entry state → trigger → rule → visible feedback → next state → cancel/undo/retry → evidence of success**. Include keyboard/accessibility behavior and persistence boundaries. Do not add a screen just because a new state is needed.

The detailed catalog covers every U screen. These are the critical contracts:

- **Capture I01–I06:** U08 ready/active/paused share one screen. Record is visible immediately. Resume active/interrupted sessions truthfully. Stop persists before U04 success. Preserve recoverable audio when saving fails. AI choice follows capture. Library/Import/Updates remain secondary.
- **Review I07–I13:** direct U05 → U11; U06 is for later return. Drafts remain separate from saved ideas. View evidence may open the existing U16 viewer, returning to the same review selection. Draft edits save back to U11; manual/accepted edits save to U14. Accept only explicit selection. Dismissal keeps the original. Empty review offers source/manual/leave options.
- **Recover I14–I18:** query/project context survives navigation. Selecting an idea opens its existing identity. Source links open the actual excerpt/time; history opens attributable versions. Back returns to the invoking screen and position, including U16 → U11 when entered from review. Semantic related ideas are optional AI; ordinary search remains usable without it.
- **Reuse I19–I20:** carry the selected idea into U18. Choose destination and Link this idea versus Create a derivative. Link preserves identity; a derivative creates a new identity with provenance. Cancel leaves the original unchanged. Return to the destination map after a successful save.
- **Support I21–I28:** preserve input on failed import, show processing scope before enabling it, retry without duplicate work, and treat pan/zoom/filter as view changes. Restore creates a new revision. Delete previews affected evidence; after deletion return from the dead source view with truthful missing-evidence status. Export previews scope before native save/share. Collaboration remains later and is not required for individual value.

The interaction handoff emphasizes the UIUX production task: identify the screen, draw its visible controls, design the required variants and connect each action to its named destination. The full user journey remains the broader navigation reference. Screen IDs and the sitemap inventory are unchanged. A state change, asset family or reused screen reference is not an additional screen.

Reuse these small controls across those journeys:

- **Select/deselect:** update a visible selection count and the exact acceptance scope. Disable Accept when nothing is selected. Filtering must not hide what will be accepted.
- **Play/pause/seek evidence:** update playback state and the real timestamp; preserve the current idea/review context. Distinguish playback from microphone recording.
- **Edit an existing idea:** U15 Edit opens U10 in accepted-edit mode; saving makes a revision. Draft-edit mode remains separate. Optional rename/file controls after capture must never gate retention.
- **Connect ideas:** choose source, destination and relationship, preview, then save or cancel. Provide a button/form alternative to dragging. Moving a node, zooming or filtering never creates a semantic link.

### Feedback, accessibility and recovery

Use visible, accessible recording state and elapsed time; do not require continuous monitoring of the screen. Prevent accidental duplicate starts/submissions while a request is pending. Do not display fake progress or “ready” on failure. Leaving a processing screen must not discard saved work.

Support labeled controls, visible keyboard focus, non-color status cues, reduced motion and list/search alternatives to fine spatial manipulation. Make pause, stop, evidence inspection and acceptance reachable without hover or precise dragging. Test actual phone interruption, permission and lock-screen behavior before making claims about it.

Preserve query, scroll, selection and map focus on return. Avoid unexpected canvas relayout during reading. Failed edits remain recoverable; stale edits require conflict resolution. Source deletion must flag retained ideas with missing evidence. Do not promise Undo for destructive actions unless restoration is actually supported. Turning AI off is not the same as deleting existing data.

### Validate value before optimizing counts

Test with individual creative professionals, including returning sessions with their own prior material. Record whether they can begin capture unaided; whether Stop really retains playable material; whether they understand what was saved and what AI will process; and whether they can recover a known idea with its evidence later.

Measure interruption time, required decisions, review/correction effort, evidence-finding success and successful reuse in a real task. Compare proposed batch review with individual review without hiding mistakes. Check capture/manual mapping/search/export with AI disabled. Record failures and uncertainty alongside successes.

Two taps is a design contract for a defined capture path, not a measured usability result. Other speed, retention or willingness-to-speak assumptions remain unvalidated. A person who rarely thinks aloud may prefer importing existing transcripts or writing; test that behavior instead of requiring a new habit without a demonstrated reward.

## Data and backend

### Proposed data model

Use stable identifiers and explicit revisions. These are logical entities; database technology is undecided.

- **Workspace:** owner or members, private default, processing preferences and access policy.
- **Source:** original asset or text, source type, owner, scope, version, content hash, import/capture time, processing state and retention choice. Keep original material separate from generated interpretation.
- **Source segment:** source ID and version, quoted/text range or actual audio timestamp range, optional parsing/transcription uncertainty. Anchors must resolve to real content.
- **Idea node:** ID, title, body, type, meaning state, evidence references, project associations, author and revision. Initial types: Idea, Question, Constraint, Finding, Decision.
- **Relationship:** ID, source and target node IDs, a typed verb such as supports/challenges/depends on/replaces, evidence and review state. A relationship can be wrong even when both nodes are valid.
- **Project:** a named scope with node associations and view state. A project is not a destructive folder that owns every idea exclusively.
- **Change set:** proposed creates/edits/links, affected IDs, evidence, base revisions and draft/accepted/dismissed state. Support partial acceptance.
- **Revision:** actor, timestamp, previous/current content, reason and evidence. Restore writes a new revision instead of erasing history.
- **Processing job:** source/version, allowed scope, stage, status, retry count, error and idempotency key.
- **Later sharing entities:** project role grants, comments, invitations and review policy.

Keep review state separate from meaning state. “Accepted” means the user accepted the record; it does not make a tentative idea a confirmed decision. Current, disputed and superseded meanings remain distinct. Exact field names and state enums are implementation choices to settle before writing migrations.

### Backend contract

The backend map is a logical decomposition, not a mandate for separate microservices. E01–E03 identify source-ready, access-denied and conflict-returned outcomes. They are result states, not additional services. The draft-to-command connection represents a new request after human approval, not automatic publication.

1. Validate requests and access at the boundary. Validate input integrity and supported format; give source uploads stable identities and make retries idempotent.
2. Preserve source content and version before processing. Track queued, running, ready, failed and cancelled work. Recheck permission before a job executes.
3. Normalize supported text without requiring a model. Route allowed audio through optional transcription. With AI off, retain audio and metadata without claiming an automatic transcript.
4. Optional semantic generation uses only allowed source segments and permitted existing context. Produce a change set with source anchors, not direct graph writes.
5. Validate shape, references and evidence coverage. Unsupported reasoning and conflicts remain visible for review. Automated checks do not establish truth.
6. Manual edits and approved proposals enter the same command handler. Check expected revisions, source scope and permission again at commit. Reject stale conflicts for review rather than silently overwriting another edit.
7. Commit accepted graph changes and revision history consistently. Update derived search structures; the index is never the authority for access or current state.
8. Scoped retrieval builds focused map responses, source/history references and related candidates. Filter before ranking/model context and again before returning results. A read or suggestion does not silently create a relationship.
9. A selected export rechecks scope and includes date, source references and unresolved uncertainty. A future agent connector is read-only and uses this access contract.
10. Deletion cancels dependent jobs, removes source-derived retrieval content and invalidates stale proposals/citations according to retention policy. A retry must not resurrect deleted content. Keep only policy-permitted audit metadata.

No model provider, database, identity provider, API framework or deployment architecture has been selected for Branch. The earlier Vercel requirement applied to Shot Canvas. A web build may be sensible, but do not present Vercel or local-only storage as an already-decided Branch requirement.

### Backend process definitions

#### B01 · Request entry

The backend boundary accepts operations from any authorized client. Capture happens on the device; this boundary receives saved content or upload chunks. API framework and hosting provider are not selected.

- submits operation → B02

#### B02 · Access enforcement

Enforce access on writes, reads, model context, derived snippets and exports. A UI filter alone is not an access control. Scope must be rechecked when a queued job actually executes.

- authorizes ingest → B03
- reads policy → B07
- authorizes query → B11
- authorizes write → B16
- Deny unauthorized request → E02
- Authorize project access management → B23
- Authorize a scoped read-only agent request → B22

#### B03 · Source ingestion

Use resumable upload where required. Validation errors return a specific status; save only verified chunks or an explicitly incomplete source. Idempotency prevents retries creating duplicate sources.

- persists source → B04

#### B04 · Source store

Preserve original source material and its version separately from model-generated claims. Audio timestamps exist only when grounded in audio. Storage may be local, hosted or mixed; this map does not choose that deployment.

- enqueues work → B05

#### B05 · Job orchestration

Jobs are retryable with bounded attempts and idempotent outputs. Cancellation, changed permissions or deletion prevents later work from using revoked material. Status updates can be polled or streamed; transport is undecided.

- fails after retries → B06
- dispatches with scope → B08

#### B06 · Failure handling

A failed parser, transcription job or model operation must not silently create an empty successful map. Report actionable error state to the client. Retry reuses source and job identifiers.


#### B07 · Policy records

Permissions and source lineage constrain derived content. A node with mixed-scope evidence cannot become more visible than its supporting material without an explicit authorized redaction step.

- constrains AI use → B08

#### B08 · AI processing gate

Gate each optional transcription, extraction and semantic retrieval operation. Saving a source is not automatic permission to send it to a cloud model. Provider and training terms remain a product implementation requirement.

- text / metadata → B09
- audio + AI enabled → B10

#### B09 · Source normalization

Non-AI parsing can extract text from supported formats. With AI off, an audio-only source remains an accessible recording with metadata; there is no invented automatic transcript.

- AI enabled: extract meaning → B13
- indexes source text → B12
- AI off: return the preserved source → E01

#### B10 · Transcription

Optional AI operation for allowed audio. Its output is a source-derived transcript with locations, not an authoritative decision record. The original recording remains separately referenced.

- supplies transcript → B09

#### B11 · Scoped retrieval

Apply permission filters before ranking, before assembling model context and before returning output. Resolve current revisions and visibility; do not leak inaccessible labels, counts or snippets.

- searches index → B12
- loads allowed records → B17
- supplies permitted context → B13
- builds focused view → B19
- finds related ideas → B20

#### B12 · Search index

An index is a derived retrieval structure, not the authority for permissions or current graph state. Update it on accepted edits and source changes; invalidate on deletion or revoked scope.


#### B13 · Semantic proposal

Optional model step. Proposed types: Idea, Question, Constraint, Finding and Decision. Inferred connections remain suggestions. New sources produce change sets against existing records rather than replacing the entire graph.

- checks proposed claims → B14

#### B14 · Evidence checks

Check that cited segments exist and assertions are supported. A source mentioning a possible decision must not become a confirmed decision automatically. Low support remains visible for human review; automated checks do not establish truth.

- stores draft only → B15

#### B15 · Pending change store

Separate model proposals from accepted graph content. Draft IDs allow partial acceptance, editing or dismissal. Model outputs cannot directly write the canonical graph.

- After user review, accepting selected changes creates a new authorized command → B16

#### B16 · Authorized commands

A manual edit and an accepted AI suggestion use the same write contract. Require action permission, actor identity, current expected revision and explicit selected changes; rejection is a state change, not source deletion.

- validates command → B17a
- authorized source delete → B25

#### B17a · Apply a change

Recheck scope at commit, validate node and edge references, enforce version checks and write graph changes with their revision record. Concurrent edits are not silently overwritten; conflict returns to review.

- commits reviewed change → B17
- loads selected draft → B15
- Return stale-edit conflict → E03

#### B17 · Saved idea graph

Canonical accepted state. One idea may belong to several projects. A derivative receives a new identity and a relationship to the original. Graph persistence need not imply a specific graph-database product.

- records revision → B18
- updates retrieval index → B12

#### B18 · Version / provenance log

Store the accepted revision and provenance together with the corresponding graph change. Preserve disputed and superseded states rather than presenting them as current consensus.


#### B19 · Focused map response

Build a bounded view of authorized current records. Position and filter data can be view state; changing the view must not mutate the stored graph. No inaccessible source labels or hidden edges should be revealed.

- serializes selected context → B21

#### B20 · Cross-project matches

Text matches can work without AI. Semantic suggestions are optional and use the same processing gate. User selection creates an explicit link or derivative through the command path, not through this read service.


#### B21 · Selected context export

Export only chosen authorized context. Exclude unreviewed inference unless clearly included as such; identify disputed or superseded content. Portable exports leave the access-control boundary and cannot be remotely recalled.


#### B22 · Agent connector · later

Future optional access to selected project context. Every request is checked under the current access policy. This connector does not grant model tools permission to modify the map or act on behalf of the user.

- requests allowed context → B21

#### B23 · Project roles · later

Future sharing services create scoped role grants and enforce source-derived visibility. Corporate rollout may additionally need administration and retention management; these do not gate individual value.

- scopes shared actions → B24

#### B24 · Shared changes · later

Shared commands pass the same access, revision and evidence rules as private commands. Comments are not automatically decisions. Shared proposals feed the pending-change and review contract.

- uses the same write rules → B17a

#### B25 · Deletion / retention

Remove or invalidate source-derived data according to the selected retention policy, including transcripts, semantic indexes, pending proposals and cached outputs. Preserve only policy-allowed tombstones/history. A deletion should not be undone by an in-flight retry.

- retains allowed audit → B18
- invalidates affected records → B17

#### E01 · Source ready

Original material is available without semantic generation. Supported text remains searchable. Audio without permitted transcription remains an audio source with metadata.


#### E02 · Access denied

The request ends without reading, writing or exposing unauthorized content.


#### E03 · Conflict returned

A stale expected revision returns a conflict without overwriting accepted records. The user reviews the conflict before submitting a new authorized command.

## Privacy, implementation and validation

### Privacy and portability requirements

Saving a file does not imply permission for cloud AI processing. Make processing scope understandable and persistent where the user chooses it. Permissions must cover source excerpts, graph labels, derived summaries, suggestions, indexes and exports—not only the canvas objects.

No sale of user content and no training on it without separate informed consent are intended requirements. Verify the actual implementation and provider terms before publishing guarantees. Do not imply that all processing is on-device unless it really is.

Use a portable export that includes nodes, relationships, project associations, evidence references and revisions where allowed. Explain missing or external assets. Exported copies are outside Branch’s revocation boundary.

### First implementation slice

1. Recorder ready/active states, real phone microphone handling, Stop → finalized saved source, playback and recoverable capture errors. Deliver value without account/profile setup or AI processing.
2. Saved source → manual node editor → persistent focused map. Add import as a secondary entry path, evidence links, revisions and export. Manual use remains complete without AI.
3. Optional AI choice after capture, progress, direct review, partial acceptance and failure/cancellation. Clearly label simulated processing in a prototype.
4. Library, text search, reuse and history so users can return to earlier ideas. Preserve the original context and active screen state.
5. Test the full individual phone loop before desktop, shared roles, corporate connectors or agent access.

Choose the smallest coherent implementation. The recorder-first entry overrides earlier dashboard-first or Library-first flow descriptions, including preserved historical agent-file wording. Public profiles, social discovery and collaborator matching are not the initial product.

### Acceptance checks

- Entry: opening the app exposes Record without scrolling or navigating. After microphone permission is granted, one tap starts recording.
- Capture: Stop persists the source before success, without requiring a second Save tap, a title or project selection. Interrupted capture is recoverable.
- First-use AI: permission is requested after capture and before processing; declining leaves the recording usable.
- Sequence: ready ideas open Review directly; a session map opens after acceptance without mandatory project filing.

- AI off: import a source, create and connect an idea, save, reload, search and export without any model call.
- AI on: a generated proposal does not alter accepted records until selected changes are accepted; dismissal keeps the source.
- Evidence: clicking a citation opens the correct source version and range; missing audio never gets a fabricated timestamp.
- Reuse: the same idea can appear in two projects; branching creates a new node with provenance. Neither destroys the original context.
- Revision: editing and restoring preserve history; stale simultaneous edits are returned for resolution.
- Access: a second user cannot retrieve private node labels, source excerpts, semantic matches or export content through a shared project. Test the service boundary, not just hidden UI.
- Recovery: duplicate retries do not duplicate sources; cancelled/deleted material cannot reappear through a queued job.
- Map usability: readable focus, pan/zoom, keyboard-accessible selection, visible status, and return to the same view after closing a drawer.

### Research and unresolved choices

The idea is not validated by the existence of the diagrams. Compare retrieval and reuse against a person’s current transcript, summary and search workflow. Measure correction effort and voluntary return after time has passed. Test shared handover later with a second person.

Resolve these when they affect implementation: native/web delivery and recording lifecycle within the confirmed mobile-first direction; storage/sync model; authentication; supported import formats; AI provider and retention terms; conflict/review policy; node deletion versus source deletion behavior; and export packaging. Make reasonable reversible defaults visible in the project documentation. Ask the user only when a choice materially changes scope, privacy, cost or the promised experience.

## Detailed interaction contracts

I01–I28 are implementation/review identifiers, not new screens. The diagram preserves these IDs in editable object metadata. One branch can summarize several small interactions; do not count it as one tap. Routine Back, permission failures and view restoration are specified here even when omitted from the main path for legibility.

### Capture without breaking flow

#### I01 · Tap Record

**Entry:** U08 · Ready. **Response:** Show live recording + timer. **Next:** U08 · Recording.

Start only after a deliberate tap and required microphone permission. If denied, offer recovery or import/write. Opening the app never starts recording.

#### I02 · Pause / Resume

**Entry:** U08 · Recording. **Response:** Show the actual capture state. **Next:** U08 · Same session.

A reversible state change, with an accessible label and visible feedback. Do not start a second recording or lose prior audio.

#### I03 · Tap Stop

**Entry:** U08 · Recording. **Response:** Finalize + persist the audio. **Next:** U04 · Source saved.

No second Save tap. Show saved only after persistence succeeds; keep recoverable material on failure. Supply a default title and leave the session unfiled.

#### I04 · Keep audio only

**Entry:** U04 · Source saved. **Response:** Retain the original. **Next:** U05 · Saved source.

Keeping the original is a complete valid outcome. No automatic transcript or map is required.

#### I05 · Build idea map · optional AI

**Entry:** U04 · Source saved. **Response:** Check permitted processing scope. **Next:** U05 · Or U07 first-use choice.

AI is optional. If no permitted scope exists, ask in U07 after saving; otherwise start the allowed processing directly. Declining keeps the source and manual path.

#### I06 · Library / Import / Updates

**Entry:** U08 · Ready. **Response:** Open the chosen destination. **Next:** U01 / U03 / U06.

Secondary ready-state destinations: Library to U01, Import to U03, Updates to U06. Never require these before Record. Returning during capture restores active/interrupted state.

### Turn a capture into trusted ideas

#### I07 · Review ideas · optional AI

**Entry:** U05 · Ready / U06 · Updates. **Response:** Open source-linked proposals. **Next:** U11 · Draft review.

U05 processing becomes ready automatically. Review is directly available; Updates is only a return-later alternative. Leaving processing does not discard the job.

#### I08 · View evidence

**Entry:** U11 · Draft review. **Response:** Jump to the cited passage. **Next:** U16 · Source viewer.

Open actual supporting text or audio time. Back restores proposal selection and review position. Missing or uncertain evidence is visible, never fabricated.

#### I09 · Edit a proposal

**Entry:** U11 · Draft review. **Response:** Load an unaccepted draft. **Next:** U10 · Draft editor.

Editing a draft does not accept it. U10 retains draft mode and the return target U11.

#### I10 · Accept selected

**Entry:** U11 · Draft review. **Response:** Save ideas + evidence + revision. **Next:** U14 · Focused map.

Accept only the clearly displayed selection of nodes and relationships. Unreviewed items remain proposals. No project naming is needed. An accepted idea may still be tentative.

#### I11 · Dismiss selected

**Entry:** U11 · Draft review. **Response:** Remove proposals; keep source. **Next:** U11 · Remaining proposals.

Dismissal never deletes the recording. If no proposals remain, show a clear empty review state with source/manual/leave options. Offer an accessible undo for accidental dismissal.

#### I12 · Add idea

**Entry:** U05 · Source / U14 · Map. **Response:** Carry source or map context. **Next:** U10 · Manual editor.

Manual path works without AI. Carry the current source as available evidence, but let the person specify the actual supporting excerpt or mark the idea as their own note.

#### I13 · Save draft / Save idea

**Entry:** U10 · Editor. **Response:** Persist in the correct mode. **Next:** Draft → U11  /  Idea → U14.

Save draft returns to review without publication. Save idea creates or revises an accepted manual record and opens the map. Cancel returns to the entry context; unsaved work must be recoverable.

### Recover thinking and carry it forward

#### I14 · Search / Open project

**Entry:** U01 · Library. **Response:** Keep query or project context. **Next:** U12 · Results / U14 · Map.

Text search is available without AI. Query entry, reading results and choosing a result are distinct effort, even if the interface avoids a submit tap. No results preserves the query.

#### I15 · Select an idea

**Entry:** U12 · Results / U14 · Map. **Response:** Show meaning + evidence links. **Next:** U15 · Idea details.

Selecting opens the same idea identity with its context; it does not create a copy. Provide accessible list and keyboard alternatives to precise node tapping.

#### I16 · View source / History

**Entry:** U15 · Idea details. **Response:** Open the relevant evidence/version. **Next:** U16 · Source / U19 · History.

View source opens U16 at the real excerpt/time. History opens U19 with attributable versions. Return restores the current idea, not the top of Library.

#### I17 · Back / Close

**Entry:** U15 / U16 / U19. **Response:** Restore focus, query + position. **Next:** Previous screen + state.

Use the actual invoking context. U16 opened from review returns to U11; from details it returns to U15. Do not reset the map or require repeated searching.

#### I18 · Related ideas · optional AI

**Entry:** U14 · Map. **Response:** Explain suggested connections. **Next:** U13 · Inspect → U15.

Semantic suggestions require allowed AI scope. U13 explains the reason and evidence; selecting opens U15. Dismissing adds no relationship. Search remains the AI-off alternative.

#### I19 · Reuse idea

**Entry:** U14 · Map. **Response:** Show link / derivative choices. **Next:** U18 · Reuse.

Start from the selected idea. Destination selection is necessary here, even though filing was optional at capture.

#### I20 · Choose destination + confirm

**Entry:** U18 · Reuse. **Response:** Link same idea / create derivative. **Next:** U14 · Destination map.

This is several microinteractions: choose destination, choose Link this idea or Create a derivative, confirm. Linking preserves identity; a derivative has a new identity and origin relationship. Cancel leaves the original intact.

### Keep control while removing busywork

#### I21 · Choose material → Save

**Entry:** U03 · Import / write. **Response:** Validate + retain original. **Next:** U04 · Source saved.

Entry: U08 Import directly, or U01 Add → U02 → U03. File pick/paste/write and Save are separate actions. Preserve input on failure. Keeping an attachment does not imply every format is AI-readable.

#### I22 · Choose processing scope · optional AI

**Entry:** U07 · AI settings. **Response:** Apply preference + show status. **Next:** Invoking source or settings.

Explain which material is processed before enabling it. First-use decline returns to saved material/manual options. Disable stops new AI work; disclose any already-running work. Do not claim data deletion from an AI toggle.

#### I23 · Retry / Use fallback

**Entry:** U09 · Recovery. **Response:** Keep recoverable work. **Next:** Origin / U03 · Import/write.

A shared recovery state, not a new route. Explain the actual failure and what is retained. Retry must avoid duplicate sessions/jobs/changes. Never show saved or ready before success.

#### I24 · Apply / Clear filters

**Entry:** U14 · Map → U17 · Filters. **Response:** Change visible scope only. **Next:** U14 · Filtered map.

Selection, pan/zoom, focus/fit and filters affect the view, not meaning. Show active filters, preserve position and provide a clear reset. Reordering a node is not a semantic relationship.

#### I25 · Compare → Restore version

**Entry:** U19 · History. **Response:** Create a new revision. **Next:** U15 · Updated idea.

Comparison and restoration are separate interactions. Show the version being restored; retain history and attribution. A stale edit needs resolution instead of silent overwrite.

#### I26 · Review impact → Delete

**Entry:** U16 · Source → U20 · Confirm. **Response:** Remove source; flag lost evidence. **Next:** Return with truthful source state.

Preview affected references before confirmation. Cancel preserves the source. After successful deletion, close the dead source view and return to the prior idea/map with missing-evidence status. Do not promise Undo unless bytes can actually be restored.

#### I27 · Review scope → Export

**Entry:** U14 · Map → U25 · Export. **Response:** Package selected permitted context. **Next:** Native save/share → map.

Menu open, scope review and export are distinct actions. Preview included ideas, relationships, references and uncertainty. Cancellation returns to the same map; export does not imply upload/publication. Available without AI.

#### I28 · Share → choose people + roles · later

**Entry:** U14 · Map · LATER. **Response:** Apply explicit access scope. **Next:** U21 → U22 → U23 → U24.

Future macro, not one tap: scope preview → invite/access → shared map → comments/changes. Review before sharing; comments do not automatically become accepted decisions. Not needed for individual first value.

## Diagram handoff

The current Maps folder contains exactly five `.drawio` files:

- [01 User Journey - UI Screens](Maps/01%20User%20Journey%20-%20UI%20Screens.drawio)
- [02 Backend System](Maps/02%20Backend%20System.drawio)
- [03 Mobile Sitemap](Maps/03%20Mobile%20Sitemap.drawio)
- [04 Screen Sequence - Record First](Maps/04%20Screen%20Sequence%20-%20Record%20First.drawio)
- [05 Interaction Breakdown](Maps/05%20Interaction%20Breakdown.drawio)

**Interaction handoff rule:** use one file with two clearly named pages. The continuous core flow belongs on page 01; the complete layout/component inventory belongs on page 02. Put control names, screen destinations and state changes on the visible page. Do not require a designer to inspect object metadata to find basic design tasks. Keep detailed I01–I28 implementation contracts in this file and metadata.

Use white backgrounds, readable screen titles and short action labels. Draw primary forward actions and short local branches. Where a return or reused destination would create a long crossing arrow, write the exact action and destination beside its control, for example “Save draft → U11.” Do not invent an outcome screen or a “Map controls” screen to explain a state change. Keep variations inside the owning screen. Preserve U identifiers; component C identifiers refer to shared assets, not screens.

For Miro, use its **Draw.io Diagrams** integration to open/import the `.drawio`, then choose the page within the Draw.io editor. Both pages are in this single file. Text, screen containers, controls and connectors remain editable within that integration. They are not loose native Miro board objects. The agent rendered and inspected both pages and tested decoding plus save/reload in mxGraph 4.2.2 and the current Draw.io viewer engine. A live Miro reimport has not been performed.

As requested, only the five Draw.io deliverables remain in Maps. Do not add PNG, SVG, HTML viewers, authoring scripts or per-diagram Markdown there. Detailed system guidance lives here; CONTEXT.md and UIUX.md are brief entry/style guides. Preserved AGENTS.md, CLAUDE.md and role files are unchanged.

The prior interaction file and this revision's authoring/QA evidence are in workspace `Archive/2026-10-17 UIUX Interaction Handoff`. Previous agent guides are retained in `07 MD Files/Archive/2026-10-17 UIUX Interaction Handoff`. Earlier consolidation and import-repair archives remain historical reference. Artifact checks confirm structure and rendering, not phone behavior, end-user usability or product validation.

### Draw.io import compatibility

Use namespaced internal cell IDs such as `branch_flow_U14`. Avoid bare JavaScript array/object member names (`map`, `filter`, `constructor`, `length`, and similar), which collide with older decoder caches. Keep visible U/I/C identifiers as labels or metadata. The earlier `map` ID reproduced `d.insertEdge is not a function` in mxGraph 4.2.2; renaming the ID and its references repaired that file. Reordering cells alone did not fix the collision.

XML well-formedness and valid references are insufficient validation. Decode each page's graph model in a compatible engine, verify every connector has actual source/target cells, encode and reload, and render to inspect text. Each page has its own standard root/layer IDs; extract its model before using a raw mxCodec, as Draw.io does when loading a page. The current handoff passed both engines on both pages, with no unresolved edge terminals, prototype-collision IDs or measured text overflow. Temporary raster previews and test results are QA material, not additional current diagram deliverables.
