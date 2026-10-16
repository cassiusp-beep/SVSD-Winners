# Features

Source: `docs/context/conceptual-model.md`. Step names in **bold** match the Miro board. The deadline is Monday, October 19 at 11:59 PM Pacific, so scope hard.

## Hero path: build these first

The board tags three flows as PROTOTYPE 1 to 3. Each one should be a high-fidelity, interactive prototype. Together they form the path the video walks through.

### Prototype 1: Follow Its Story

**Open a Project** → **Follow Its Story**

- [ ] A project opens as its **Project Story**: the starting question, experiments, decisions and paths not yet explored, shown as connected nodes.
- [ ] The viewer can move through the story in the order the project grew. This is the storytelling moment, so the graph's growth over time must be clear.
- [ ] Each node shows its media (sketch, recording, prototype, file or note) and its author.
- [ ] "Paths not yet explored" are visible as open ends, since they double as open invites.
- [ ] Branches and chapters from other contributors are visible and credited.

### Prototype 2: Find Your Place

**Find Your Place** → **Start a New Branch** → **Try It Privately** → **Keep or Undo** → **Adds a Chapter**

- [ ] **Find Your Place** offers four choices: **Save for Later**, **Contribute a Skill**, **Revive an Experiment** and **Start a New Branch**.
- [ ] The "domain of possibility" shows where the viewer's skills could fit in the project.
- [ ] **Suggest Where I Fit** is optional AI. It is labeled as AI, can be ignored, and the flow works fully without it.
- [ ] **Try It Privately** is a private draft, and the original is never touched.
- [ ] **Keep or Undo**: "keep" leads to **Adds a Chapter**, "try again" loops back, and "discard" returns to **Home Hub**.
- [ ] **Adds a Chapter** shows the new branch growing beside the original project's graph, linked to its origin and credited. The original story is not changed.

### Prototype 3: Open Invite loop

**I'm Stuck** → **Ask for Help** → **Open Invite Posted** → an explorer finds it and branches it → the creator is quietly notified → the branch appears beside the original

There are no requests to approve. See `DECISIONS.md`.

- [ ] **I'm Stuck** from inside a **Project Story**.
- [ ] **Ask for Help** frames the invite as "not permission to use it, help to iterate."
- [ ] **Open Invite Posted** shows up in **Tinder Style**, where explorers can swipe on it.
- [ ] The explorer branches the project through Prototype 2. Nothing waits on the creator.
- [ ] The creator gets a quiet notification: "someone branched your work." It has no Accept or Decline buttons and no badge pressure.
- [ ] From the notification, the creator sees the branch beside the original, with the contributor credited.

## Supporting screens the hero path needs

Build these only as far as the video requires. They can be lighter or partly faked.

| Screen | Why the demo needs it | Fidelity |
|---|---|---|
| **Home Hub** | Every task starts and ends here | Medium |
| **Explore** with **Wander the Graph** | How an explorer finds the project in Prototypes 1 and 2 | Medium to high |
| **Tinder Style** feed | Where the open invite appears in Prototype 3 | Medium |
| **Notifications** | Where the creator quietly learns someone branched their work | Medium. Its calm tone is part of the story. |
| **Living Map** | Shows the new chapter on the contributor's profile | Low |
| **Browse Anonymously** | Shows a guest can explore with no account | Low. It can be a single entry point. |

## Later, or show only as stills

These are in the conceptual model but are not needed to tell the story in the video.

- **Onboarding:** About Me, Integrations, Archive of Previous Works, Calibration.
- **Creating a story from scratch:** Modes of Storytelling, Free Form, Quick Design Sessions, Assisted, AI Draft, Add Nodes, Connect Nodes, Organize with AI, Review & Share, Export Anytime.
- **Other discovery views:** Pecha Kuchas, Shuffle, Follow a Person.
- **Account flows:** Create Account, Login, the locked-out journey, Settings & Profile, Help, Log Out.
- **Error states:** Upload Failed and Publish Failed. Show one in the video if time allows, since it proves the "nothing lost" promise.

## Demo data needed

- [ ] One seeded project with a rich story: a starting question, several experiments, at least one dead end and at least one open path.
- [ ] Three contributors from different disciplines. The board's narrative uses a designer with a physical prototype, a programmer experimenting with an interaction, and a musician imagining a sound-based version.
- [ ] Real-looking media for each node. Use no stock images and no lorem ipsum. See `anti-slop.md`.

## Cut list

Move features here when they're cut, with one line on why. The cuts are part of the story we tell in the video.

- **Review a Request, Accept and Decline.** Cut on October 16. Approval contradicted "help, not permission," and branches never touch the original, so there was nothing to approve.
