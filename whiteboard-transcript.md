# Whiteboard Transcript: Branch Interaction Walkthrough

**Historical prototype reference · 18 October 2026:** the document below describes the earlier creative-exchange concept and is preserved for design history. Read [current context](CONTEXT.md) and the [team-first product definition](docs/context/product-definition.md) before new design/build work. Inherited “primary source,” screen and interaction requirements below do not override that direction. The live team experience remains proposed, not implemented or validated by this sync.

**Source:** Video IMG_0837.MOV (6 min 55 s), whiteboard walkthrough recorded by Cassius Palacio. Transcribed with TurboScribe, then lightly cleaned. Board panels identified from video frames.
**Status:** PRIMARY SOURCE. This file is the origin of `interaction-model.md`. If the two files disagree, this file shows what was intended, and the conflict should be raised with the team, not resolved silently.
**For agents:** Read this file in full before any UI or interaction work. Section 1 is the raw intent. Section 3 is the decisions that came out of it. Section 4 is what has not been decided yet.

---

## How to read this file

- **Section 1:** The transcript, split into the moments of the walkthrough, with what was being drawn at that moment.
- **Section 2:** A description of the finished whiteboard, panel by panel.
- **Section 3:** Interaction decisions. Each one is tagged with where it came from:
  - `[VIDEO]` = said or drawn in the walkthrough
  - `[CLARIFIED]` = Cassius's answer in the follow-up interview (Oct 17, 2026)
  - `[ASSISTANT CALL]` = a gap filled by the assistant and not yet confirmed by the team. Treat these as provisional and change them if the team disagrees.
- **Section 4:** Open questions.
- **Section 5:** Rules for agents using this file.

Timestamps are approximate (estimated from video frames, ±10 s).

---

## 1. Transcript

### Moment 1: The infinite canvas and the profile at the center (~0:00 to 1:10)
*Drawing: a large green rectangle with arrows at all four corners pointing outward (the canvas extends forever), labeled "(INFINITE CANVAS)". Inside: a center dot, several hatched squares (projects/pages) around it, linked by curved arrows. Label above: "ANON OR USER CURIOSITY".*

> So this is what I call an infinite canvas. And the reason why it's so important is because we're going to place our user profile in the middle. And that's how they're introduced to our product first.
>
> And then we'll have different things surfacing across their node network or pages. And maybe we can even show different glyphs of how they all talk to each other, or why they talk to each other. And showing live active dialogue.
>
> And then this is how they explore that, either anonymously or as a user. So this is how we keep their curiosity.

### Moment 2: Logging in (~1:10 to 1:30)
*Drawing: a small "LOGIN" tag with an arrow, between the first canvas and the second.*

> Then when you log into the platform, you'll click that. You'll log in. This little person here has more control.

### Moment 3: The profile's two interaction modes (~1:30 to 2:50)
*Drawing: second green canvas. A single dot in the center, which grows into a cluster of small circles around it ("bloom"). Below the canvas: small circles "OOO" being drawn, then clustered around a center.*

> So there's two ways you can interact with this. Either as a list, where you're accessing settings, skills, or integrations, etc. And they'll show up here. And then it'll keep going like a node.
>
> Or they'll show up like this instead, where there's different smaller nodes around the circle that show the user what options they have.
>
> And I kind of liked what the little glyph was doing in the video we saw earlier, where it was jiggling into each other. Like bulbing. Of course there's some circle cut out. But like that. Where you can select your different options.
>
> But the main one was creating a new node, or a new project.

### Moment 4: Starting a project by dragging things in (~2:50 to 3:50)
*Drawing: third green canvas below the second. Hatched squares (artifacts) inside. An arrow out to a 3D cube drawn outside the canvas, with a curved arrow bringing it back in. A document/stacked-page icon drawn below the canvas. A dot (the profile) moves toward a corner.*

> Now on top of this, you also have the ability to just drag in new projects.
>
> So how that happens is, you'll be idly by, right? A new project might surface here. Something might surface there. You still have autonomy over your settings and such.
>
> But you can only start a new project when you start dragging in certain items. So let's take this 3D model, for instance. I'm just going to drag it in here. And maybe also even a project too. Let me just do two.
>
> So that's then going to start. Your profile is going to move to the corner, to show that you started a new project. You probably have a way to name said project, and that will show up here.

### Moment 5: Hot corners (~3:50 to 4:40)
*Drawing: fourth green canvas, top right, marked with a circled "2". Corner arrows on all four corners. Top-right corner: a circled dot labeled "AI". Bottom-right corner: a hatched mark labeled "HOT CORNERS". Bottom-left corner: a small "?" box. Along the top: a small circle, a bar, and "..." (a title/name bar).*

> And then, what were in these hot corners? I know one is a call for help, always. Which is the AI portion. What was here and here? We're thinking like a save button. Yeah, so a constant save here.
>
> There's something else, but it will come to us. Some hot corner here. So just mention hot corners.

### Moment 6: Validate, then explore (~4:40 to 5:40)
*Drawing: inside the fourth canvas, two small artifact squares, then nodes branching outward to the right, splitting into three directions labeled x, y, z. Below the canvas: "① VALIDATION ② EXPLORE", bracketed together and labeled "PARAMETERS".*

> And then you're constantly... You have your first two artifacts here. And then you're on your way validating what you have. So first you validate. Then you explore. And the nodes visualize the parameters of your exploration.
>
> So you can go here. It's meant to be a document. Go here. This could branch off here. Here, here.

### Moment 7: Gaps, help, and the next big question (~5:40 to 6:55)
*Drawing: more nodes added to the branches in the fourth canvas, with some marked as gaps.*

> And as you're going, you might be like, "I don't know how to answer this question." Or the AI, if you have it on, has noticed a gap here as well. They're shifted to different colors. So here and here.
>
> So then when you realize, "Oh, I need help," it will come in and be like, "Hey, have you thought of this one?" And you can put that here. And we also address these gaps here. Here and here.
>
> And then you keep going with that next big question, or whatever your solution is.
>
> And that's how I see the basis of interaction. Where it's just an infinite canvas and whiteboard, to keep pulsing and exploring and being curious.
>
> I think my goal is retention of... "Oh, I'll never be satisfied with the right answer. But I know I'm going in the right path."

---

## 2. The finished whiteboard, panel by panel

| Panel | Position on board | What's drawn | What it means |
|---|---|---|---|
| 1 | Top left | Infinite canvas, center dot, scattered projects linked by curved arrows. "Anon or user curiosity." | Entry. Profile at center, living network around it. Guests and users both land here. |
| Login tag | Between 1 and 2 | Small "LOGIN" label with arrow | Login is a small action on the canvas, not a separate gate or page. |
| 2 | Top middle | Center dot blooming into a cluster; "OOO" circles below | Logged in. The profile node gains control; options appear as a list or as small nodes ringing the profile. |
| 3 | Below panel 2 | Artifacts on canvas, 3D cube dragged in and back, document icon below | Starting a project by dragging artifacts (3D model, an existing project) in. Profile moves to the corner. |
| 4 ("②") | Top right | Title bar on top; AI in top-right corner; "?" bottom left; "Hot corners" bottom right; artifacts branching into x, y, z; "① Validation ② Explore } Parameters" | The project canvas. Hot corners frame the work. Validate first, then explore in branches. Gaps highlighted in a different color. |

**Colors on the board:** green marker for canvas frames and arrows (structure), red/orange marker for content (projects, artifacts, nodes, labels). This is a whiteboard convention, not a color spec, but it is a possible starting point for the visual direction.

---

## 3. Interaction decisions

### 3.1 The canvas
- Branch is a single infinite canvas. Users pan and zoom. There are no pages, tabs, or screen-to-screen navigation. `[VIDEO]`
- The canvas should feel alive: things surface over time, connections pulse. "Keep pulsing and exploring and being curious." `[VIDEO]`

### 3.2 Entry: the profile at the center
- Every visitor lands on the canvas with a profile node at the center. Guests get an anonymous node. `[VIDEO]`
- Nodes surfacing around the profile are a mix: other makers' projects, the user's own work, and suggested collaborators. `[CLARIFIED]`
- Glyphs on the connections show how and why nodes relate. `[VIDEO]`
- "Live active dialogue" means animated connections plus comment snippets on or beside them. `[CLARIFIED]`
- Guests can explore anonymously. The purpose of this view is curiosity. `[VIDEO]`

### 3.3 Logging in
- Login is a small, always-available action on the canvas. `[VIDEO]`
- After login, the profile node "has more control." `[VIDEO]`

### 3.4 Profile options: list AND radial
- Both modes exist. `[CLARIFIED]`
  - **List:** settings, skills, integrations, expanding outward as nodes. `[VIDEO]`
  - **Radial:** small option nodes ring the profile circle. `[VIDEO]`
- The primary option in both is "New project." `[VIDEO]`
- Radial option nodes jiggle and bulge into each other ("bulbing"), like the glyph in a reference video the team watched. `[VIDEO]`

### 3.5 The morph behavior
- Reference: a glyph that morphed when something was dragged near it. The exact video has not been found. `[CLARIFIED]`
- Behavior: when the user drags anything near a node, the node morphs toward it (a gooey, metaball-like merge). This signals that the node will accept the drop. `[CLARIFIED]`
- Suggested technique: SVG goo filter (blur plus alpha contrast) or a metaball shader. `[ASSISTANT CALL]`
- Reduced-motion fallback: a clear outline highlight instead of the morph. `[ASSISTANT CALL]`

### 3.6 Starting a project: drag in
- While idle, projects keep surfacing around the user, and settings stay reachable. `[VIDEO]`
- A new project starts only when the user drags items in. `[VIDEO]`
- Items can come from:
  - files from the user's computer (example given: a 3D model) `[VIDEO]` `[CLARIFIED]`
  - existing projects or nodes already on the canvas `[VIDEO]` `[CLARIFIED]`
- Dropping onto an existing project or branch starts a branch from it. This is the entry to the **Find Your Place** flow, and the target depends on which project or branch the item is dropped onto. `[CLARIFIED]`
- When a project starts, the profile node moves to a corner to show a project is underway. `[VIDEO]` The corner is top-left. `[ASSISTANT CALL]`
- The user names the project, and the name shows in a title bar along the top of the project canvas. `[VIDEO]`

### 3.7 Hot corners
| Corner | Function | Source |
|---|---|---|
| Top-right | **Help.** Always present. Offers both: ask people (Open Invite) and ask AI (only if AI is on). | `[VIDEO]` AI here; `[CLARIFIED]` both people and AI |
| Bottom-right | **Save.** Constant save, plus save status. | `[VIDEO]` |
| Top-left | **Profile.** Where the profile docks once a project starts; returns to the home canvas. | `[ASSISTANT CALL]` |
| Bottom-left | **Story.** Timeline of chapters and decisions, with undo and history. | `[ASSISTANT CALL]` |

- In the help corner, people are listed first and AI second, to match the principle that AI is an option, not the product. `[ASSISTANT CALL]`
- Note: the board shows a "?" in the bottom-left corner. It may have been meant as help. Confirm with the team. `[OPEN]`

### 3.8 Validate, then explore
- **Validate first.** Validation means showing your research: the sources that inspire you, and the one specific piece or part that matters. It is about showing your work, and then being open to sharing it. `[CLARIFIED]`
- **Explore second.** From the validated starting point, nodes branch outward. Branches can split into several directions (drawn as x, y, z). `[VIDEO]`
- The nodes visualize the parameters of the exploration. `[VIDEO]`
- A node can be a document. `[VIDEO]`

### 3.9 Gaps and help
- Gaps are shown in a different color from regular nodes. `[VIDEO]`
- A gap appears when:
  - the user marks that they don't know how to answer a question, or `[VIDEO]`
  - the AI, if switched on, notices one. `[VIDEO]`
- When the user asks for help, a suggestion comes back ("Hey, have you thought of this one?") and the user places it on the canvas themselves. `[VIDEO]`
- Help can come from people (Open Invite) or AI. `[CLARIFIED]`
- AI never adds nodes to the canvas on its own; its suggestions are placed, edited, or dismissed by the user. `[ASSISTANT CALL, consistent with design-principles.md]`
- After a gap is addressed, the user moves on to the next big question. `[VIDEO]`

### 3.10 Phone
- A phone equivalent must be designed now, not deferred. `[CLARIFIED]`
- Proposed translation `[ASSISTANT CALL]`:
  - Same canvas: pinch to zoom, one-finger pan, profile node centered on entry.
  - Radial menu on tap of the profile. List view as a bottom sheet.
  - Long-press to pick up a node or artifact, then drop. Also an "Add to..." action on every item that opens a sheet of target projects and branches. File upload button for files.
  - Hot corners become four fixed controls in thumb reach: Profile and Help at the top, Story and Save in a bottom bar.
  - Dialogue snippets become tappable badges on connections.
  - Morph still plays on drag. Haptic feedback on drop where supported.

### 3.11 The goal
- Retention through curiosity. The user should feel: "I'll never be satisfied with the right answer, but I know I'm going in the right path." `[VIDEO]`

---

## 4. Open questions

1. **The reference glyph video.** Not yet found. If found, add the link here; it defines the morph and the radial menu motion.
2. **Bottom-left and top-left corners.** Assigned by the assistant (Story, Profile). The board's "?" in the bottom-left may mean help. Team to confirm.
3. **"Live active dialogue" between projects vs. people.** Confirmed as animated connections and comment snippets. Undecided: whether it shows only real activity in seed data, or also simulated activity for the demo.
4. **Naming a project.** "You probably have a way to name said project." The exact moment (immediately on first drop, or after the second artifact) is undecided.
5. **Color.** The board uses green for structure and red/orange for content. Whether this carries into the product palette is undecided. Gap color is not yet chosen.
6. **The x, y, z branches.** Drawn as three branch directions. Undecided whether these are user-defined, suggested by others, or tied to specific parameters.

---

## 5. Rules for agents using this file

1. Do not invent pages, tabs, sidebars, or screen-to-screen navigation. Everything happens on the canvas.
2. Anything tagged `[VIDEO]` or `[CLARIFIED]` is a requirement. Anything tagged `[ASSISTANT CALL]` is provisional; follow it unless the team has decided otherwise in another file, and flag the conflict.
3. Every journey must work with AI turned off.
4. Every animation must show a real relationship or a real change (a connection, a drop target, a new contribution). No decorative motion. See `anti-slop.md`.
5. When something here is unclear, check Section 4. If it's listed there, ask the team instead of guessing.
6. When you build a behavior from this file, cite the section number (for example, "per whiteboard-transcript.md 3.6") in your summary, so the team can trace it.
