# Branch: Conceptual Model

**Historical prototype reference · 18 October 2026:** the document below describes the earlier creative-exchange concept and is preserved for design history. Read [current context](../../CONTEXT.md) and the [team-first product definition](../../docs/context/product-definition.md) before new design/build work. Inherited “primary source,” screen and interaction requirements below do not override that direction. The live team experience remains proposed, not implemented or validated by this sync.

A guide to the "Copy of Conceptual Model" frame on the SVSD Winners Miro board. It explains who Branch is for, how people move through it, and why it is designed the way it is. Step names in **bold** match the labels on the board exactly.

> **Changed since the board, October 16, 2026: no requests.** Creators never approve or decline anything. When someone branches their work, the creator gets a quiet notification. Branches appear as linked offshoots beside the original project, visibly credited to whoever made them. The creator's own story only changes when the creator adds to it. The board may still show the old request flow, with Review a Request, Accept and Decline. This document follows the new decision. See `DECISIONS.md`.

---

## 1. Overview

Branch is a creative exchange for student makers who want to share unfinished work and discover what it could become in someone else's hands. Today, work is split across tools by medium (GitHub for code, Hackster for hardware, Behance and Dribbble for visuals), so a designer, a programmer and a musician rarely find each other's projects or a place to join in. In Branch, a creator publishes a living **Project Story**: the question that started it, the experiments tried, the decisions made, and the paths not yet explored, all as connected nodes. Others can follow how the project grew, find where they fit, and branch it in a new direction. Their branch grows beside the original, linked and credited, and the creator is quietly notified. No one needs permission.

The product answers the SVSD brief theme of storytelling: the node graph itself is the story of how a project changes over time.

---

## 2. Design principles

### Exploratory by design

The model is built for wandering, not just "finish the task and leave."

- **Many ways in.** **Explore** offers five discovery views: **Pecha Kuchas**, **Tinder Style**, **Wander the Graph**, **Shuffle** and **Follow a Person**. Guests can reach them from **Browse Anonymously** with no account.
- **Stumbling onto things.** **Shuffle** lands you on a random project, and **Wander the Graph** lets you hover a node to see who made it and jump anywhere. From **Tinder Style** you can also branch off to **Wander the Graph**.
- **Joining, not just viewing.** **Find Your Place** offers four choices: **Save for Later**, **Contribute a Skill**, **Revive an Experiment** (pick up an abandoned dead end) or **Start a New Branch**.
- **Safe to experiment.** **Try It Privately** is a private draft where "the original is never touched." **Keep or Undo** either keeps the work, sends you to "try again," or discards it and returns you to **Home Hub**. Undo also appears across the reference tables ("Undo brings it back," "Nothing is a dead end").
- **No dead ends.** Every task ends with a way back to **Home Hub**.
- **No gatekeeping.** Joining in never waits on approval. Branches sit beside the original rather than changing it, so there is nothing for a creator to approve.
- **Several ways to tell a story.** The Modes of Storytelling are **Free Form**, **Quick Design Sessions**, **Assisted (optional AI)** and **AI Draft (optional AI)**. **Free Form** can start from a **Starting Question** or a **Starting Artifact**.

### AI as an option

AI supports the maker's own creativity. It is never the product and never a required step.

- Every AI step is **pink** and is marked "(optional AI)" or labeled "can opt into."
- AI steps are side branches that rejoin the main flow:
  - **Organize with AI** "returns suggestions to" **Connect Nodes**.
  - **Suggest Where I Fit** "returns ideas to" **Find Your Place**.
  - **Assisted (optional AI)** "returns a draft to" **Project Story**.
  - **Assisted Q (optional AI)** offers an editable prompt you can keep or toss.
- AI output is labeled, editable and dismissable: Organize with AI works "only on material you select; suggested links are labeled AI, editable, or dismissable," and Suggest Where I Fit "shows possibilities, never prescribes; labeled AI, ignorable."
- Every journey completes without AI. The legend says: "Skip it and every journey still works." The exploratory journey even shows an "or skip AI" path that goes straight from **Find Your Place** to **Start a New Branch**.
- The board pins a note listing five commitments: AI is optional, clear data practices (no selling creator data, no training on projects), visible human authorship, real portability (export files, graph, history and attribution), and an understandable business model. It also says onboarding should open with "What are you exploring?" and "Where could someone contribute?", and only bring in AI when someone wants help organizing.

---

## 3. Users

| User | Goal on the board |
| --- | --- |
| **Creator** (student maker) | Share an unfinished project as a story, get help when stuck, and see the project grow through other people's branches. |
| **Explorer / contributor** | Discover projects across disciplines, understand how they developed, and find a meaningful place to contribute or branch off. |
| **Guest** | Browse with no account ("Wander, no account needed") and only sign up when they want to join. |
| **Returning user** | Skip onboarding, pick up a draft, see who branched their work, and explore. |
| **Locked-out user** | Recover from a failed login and get back in. |

The narrative on the board names example makers: a designer with a physical prototype, a programmer who wants to experiment with an interaction, and a musician who imagines a sound-based version.

---

## 4. Core concepts

These are the objects a user understands, from the "What a user understands" reference block.

| Concept | Includes | Can be |
| --- | --- | --- |
| **Project** | a Story (starting question, experiments, decisions), Nodes, Branches, Contributors | Draft (private), Shared, Stuck, Branched, Revived |
| **Node** | Media (sketch, recording, prototype, file), Connections, Author | Added, Connected, Organized (optional AI), Undone |
| **Branch** | an Origin link, a New purpose, Credit to everyone involved | Tried privately, Kept (shown beside the original), Discarded |
| **Living Map** | Interests, Experiments, Collaborations | Browsed anonymously, Followed, Exported |

Other concepts that appear on the map:

- **Project Story:** the question that started it, experiments tried, decisions made, paths not yet explored.
- **Chapter:** what a contribution or branch adds to a project ("Adds a Chapter"). It appears as a linked offshoot beside the original story, not inside it. It shows on every contributor's Living Map, and the original creator gets a quiet notification. The creator never has to approve it.
- **Open Invite:** a call for collaborators. On the map it is posted from **Ask for Help** as **Open Invite Posted**. In the reference tables, marking "paths not yet explored" also creates open invites.
- **Domain of Possibility:** where your skills could fit in a project. It labels **Calibration** and **Find Your Place**.
- **Home Hub:** "every task starts and ends here."

---

## 5. How the map is organized

### Zones, in order

1. **Entry:** Start, Create Account, Login, Browse Anonymously, and login recovery.
2. **Onboarding:** About Me, Integrations, Archive of Previous Works, Calibration.
3. **Home Hub:** the center of the map. It holds Nothing Here Yet (empty state) and the shortcuts New Story, Resume Draft, Explore and My Map.
4. **Core Tasks:** creating a story, from Modes of Storytelling through Export Anytime, plus I'm Stuck, Ask for Help and Open Invite Posted.
5. **Exploration:** Explore through Adds a Chapter.
6. **Optional AI:** pink side branches tucked under the steps they belong to, inside the Core Tasks and Exploration lanes.
7. **Save, Share, Settings & Help:** Notifications, Settings & Profile, Help.
8. **Exit:** Log Out.
9. **Reference** (below the map): Key States, What a User Understands, User Journeys, Every Interaction, and Open Questions for the Team. These are tables, not steps in the flow.

### How to read it (from the Legend)

- **Direction:** left to right. Core Tasks sits above the Home Hub row, Exploration below it, and Settings, Help and Exit at the bottom left.
- **Blue step:** something the user sees or does.
- **Pink step:** an optional AI step, or the guest path. Skip it and every journey still works.
- **Gray text in parentheses:** a zone or group label, for example "(Error)" or "(Empty state)."
- **Gray text on a line:** what that arrow means, for example "leads to," "can choose," "can opt into" or "back to Home Hub."
- **Black arrow:** main flow. **Pink arrow:** optional AI branch.
- **"back to Home Hub":** the return path. Every task ends there.
- **?:** an assumption to validate.
- **PROTOTYPE 1 to 3 (black tags):** build these first as high-fidelity interactive prototypes. (1) is Follow Its Story, (2) is Find Your Place, and (3) is the Open Invite loop.

### Main flow at a glance

    Start > Login / Create Account / Browse Anonymously
      > Onboarding (first-time only)
      > Home Hub
          > Core Tasks (create and publish a story)  > back to Home Hub
          > Exploration (discover and join)          > back to Home Hub
          > Notifications / Settings & Profile / Help > back to Home Hub
      > Log Out (then: signed-out landing page)

---

## 6. User journeys

The journeys are numbered as they appear in the board legend and the User Journeys reference.

### (1) First-time user

Sign up, onboard, make a first story, log out.

1. Start
2. Create Account ("new user")
3. About Me
4. Calibration
5. Free Form
6. Starting Question
7. Project Story
8. Add Nodes
9. Connect Nodes
10. Review & Share
11. Living Map
12. Home Hub
13. Log Out

**Key decisions and branches**

- **Onboarding detours.** About Me "can connect" to Integrations, which leads to Archive of Previous Works and then on to Calibration.
- **Choosing a mode.** At Calibration you "can choose" Free Form or Quick Design Sessions, or "can opt into" Assisted or AI Draft. Free Form "can start from" a Starting Question or a Starting Artifact.
- **Getting stuck.** From Project Story you can say I'm Stuck (see journey 6).

**Where optional AI fits:** Assisted Q, Assisted, AI Draft, and Organize with AI between Add Nodes and Connect Nodes. All of them can be skipped.

### (2) Returning user

Log in, resume a draft, publish, explore, save, log out.

1. Start
2. Login ("returning user", which skips onboarding)
3. Home Hub
4. Resume Draft
5. Add Nodes
6. Connect Nodes
7. Review & Share
8. Living Map
9. Home Hub
10. Explore
11. Pecha Kuchas
12. Tinder Style
13. Open a Project
14. Follow Its Story
15. Find Your Place
16. Save for Later
17. Home Hub
18. Log Out

**Key decisions and branches**

- **From Home Hub:** New Story, Resume Draft, Explore, My Map, Notifications, Settings & Profile, Help or Log Out.
- **Errors on the way:**
  - Add Nodes "if it fails" goes to Upload Failed, which says "retry, nothing lost."
  - Review & Share can go to Publish Failed, where the draft is kept and you retry.
- **If the profile is unfinished:** Login also leads to About Me "to set up a profile."

**Where optional AI fits:** Organize with AI on the creation side, and Suggest Where I Fit on the exploration side.

### (3) Exploratory user

Log in, wander the graph, optionally ask AI, branch an idea, log out.

1. Start
2. Login
3. Home Hub
4. Explore
5. Wander the Graph
6. Open a Project
7. Follow Its Story
8. Find Your Place
9. Suggest Where I Fit (optional AI)
10. Find Your Place
11. Start a New Branch
12. Try It Privately
13. Keep or Undo
14. Adds a Chapter
15. Home Hub
16. Log Out

**Key decisions and branches**

- **Explore** "can choose" Pecha Kuchas, Tinder Style, Wander the Graph, Shuffle or Follow a Person.
- **Getting into a project.** Any node opens a project. Tinder Style also offers "or wander the graph."
- **Find Your Place** "can choose" Save for Later, Contribute a Skill, Revive an Experiment or Start a New Branch.
- **Keep or Undo:** "keep" leads to Adds a Chapter, "try again" loops back to Try It Privately, and "discard" goes back to Home Hub.

**Where optional AI fits:** steps 9 and 10 are optional. On the board, "or skip AI" goes straight from Find Your Place to Start a New Branch.

### (4) Guest

Browse with no account, find a project, sign up only to join, log out.

1. Start
2. Browse Anonymously ("guest")
3. Explore ("gives a glimpse into possibilities")
4. Wander the Graph
5. Open a Project
6. Follow Its Story
7. Find Your Place
8. Quick sign-up (? assumption)
9. Contribute a Skill
10. Adds a Chapter
11. Home Hub
12. Log Out

**Key decisions and branches:** a guest can use any of the five discovery views from Explore.

**Where optional AI fits:** Suggest Where I Fit is available at Find Your Place but not required.

### (5) Locked-out user

Failed login, reset password, update settings, get help, log out.

1. Start
2. Login
3. Wrong Email or Password ("if it fails")
4. Forgot Password ("forgot password?")
5. Reset Link Sent
6. Set New Password
7. Home Hub ("logs you in")
8. Settings & Profile
9. Edit profile, privacy, accounts
10. Changes Saved
11. Home Hub
12. Help
13. Guides, FAQ, or Contact Support
14. Home Hub
15. Log Out

**Key decision:** from Wrong Email or Password you can "try again" back to Login, or choose "forgot password?"

**Where optional AI fits:** none.

### (6) Stuck creator

Ask for help, post an open invite, see someone branch it, log out.

1. Start
2. Login
3. Home Hub
4. New Story
5. Project Story
6. I'm Stuck
7. Ask for Help ("not permission to use it, help to iterate")
8. Open Invite Posted
9. Home Hub ("creator returns to Home Hub")
10. An explorer branches the project (journey 3, from Find Your Place onward)
11. Notifications, a quiet "someone branched your work"
12. See the branch beside the original project, with the contributor credited
13. Home Hub
14. Log Out

**Key decisions and branches**

- **Where the invite goes.** Open Invite Posted "shows up in" Tinder Style, where explorers can swipe on it.
- **No request to answer.** The creator doesn't approve or decline. The branch already exists beside the original, credited, and the notification simply says so. The creator can follow the branch, or ignore it.

**Where optional AI fits:** none required.

**Changed from the board:** the board's version had Review a Request, then Accept leading to Contributor Credited, or Decline leading to Explorer Can Still Branch. Those steps are removed.

---

## 7. Edge cases: errors, empty states and recovery

| Situation | Where on the map | How the user recovers |
| --- | --- | --- |
| Wrong Email or Password | Entry, "(Error)" | "try again" back to Login, or Forgot Password > Reset Link Sent > Set New Password, which logs you in to Home Hub |
| Upload Failed | Above Add Nodes, "(Error)" | "retry, nothing lost," back to Add Nodes |
| Publish Failed | Above Review & Share, "(Error)" | Draft kept, retry Review & Share |
| Nothing Here Yet | Home Hub, "(Empty state)" | Shown "if you have no projects yet." Leads to Explore. |
| Experiment not worth keeping | Keep or Undo | "try again" or "discard," back to Home Hub. The original is never touched. |
| Unwanted or abusive branch | Beside the original project | Report or block someone (? assumption). The original story is never changed, so nothing needs undoing. |
| Creator is stuck | I'm Stuck | Ask for Help > Open Invite Posted |
| Guest wants to join | Find Your Place | A quick sign-up appears before joining, then you continue (? assumption) |

The Key States reference row adds: First Visit: "What are you exploring?"; Empty Map: start with one sketch (?); In Progress: drafts autosave, private (?); Error: upload failed, nothing lost, retry (?); Success: someone branched your work.

---

## 8. Open questions and assumptions

### Open Questions for the Team (on the board)

1. Guests get a quick sign-up only when they try to join a project?
2. Shuffle drops you on a random project?
3. Following a person puts their new work in your feeds?
4. You can save a Pecha Kucha for later?
5. If publishing fails, the draft is kept and you retry with one tap?
6. ~~Creators can reply to discuss a request before accepting it?~~ Resolved October 16: there are no requests. Creators get a quiet notification instead.
7. Empty map copy: "start with one sketch"?

### Other items marked "?" on the board

- Try It Privately (as a step).
- Key States: Empty Map, In Progress (drafts autosave, private), Error (upload failed, nothing lost, retry).
- Every Interaction table:
  - "Sign up only when you want to contribute."
  - "Report or block someone."
  - The Shuffle, Follow a Person, Pecha Kucha save and publish-fail rows.
  - The reply-to-discuss row is obsolete, since there are no requests.

### Questions written elsewhere on the board

- "How can we make this process feel less like an AI training playground?" (note next to Calibration)
- "Is there a way to bring the POTENTIAL of a collaboration to the forefront?" (Features frame)
- A teammate's sticky asks how you get notified when someone branches your work. The map now answers this with the "(the original creator is also told in Notifications)" note under Adds a Chapter.

### Not yet defined on the board

- What Integrations connects to exactly. Every Interaction lists "GitHub, Hackster, Figma, or social."
- How Quick Design Sessions are scheduled and matched.
- The business model. It is named in the five commitments but not shown in any flow.

---

## 9. Glossary

| Term | Meaning on this board |
| --- | --- |
| Pecha Kucha | A short slide story that shows a project at a glance |
| Tinder Style | A swipe feed. Swipe right if interested, swipe left to pass, undo the last swipe. |
| Quick Design Sessions | Short, timed co-design sessions (charrettes) |
| Charrette | A quick moment to get together and craft something |
| Run a Timed Session | Set a timer and co-design. What you made is added to the Project Story. |
| Calibration | Onboarding step where you pick skills to offer and things to learn ("Domain of Possibility") |
| Domain of Possibility | Where your experience could fit in a project |
| Node | One piece of a story: sketch, recording, prototype, file or note |
| Branch | A new direction that stays linked to the original project and grows beside it. It needs no approval. |
| Chapter | What a contribution or branch adds to a project. It appears beside the original story. |
| Revive an Experiment | Pick up a node that was marked a dead end |
| Living Map | Your profile as a map of interests, experiments and collaborations |
| Open Invite | A public call for collaborators on a project |
| Home Hub | The center of the app. Every task starts and ends here. |
| Archive of Previous Works | Past work you choose to show. More context, not a higher rank. |
| Optional AI | Pink steps a user chooses to use. Never required. |

*Source: "Copy of Conceptual Model" frame and surrounding frames on the SVSD Winners Miro board (Brief, Idea Validation, Features, Notes from ceremonies, "Cheesy Ass Narrative," UI Precedents), plus the SVSD design brief, research strategy and team transcript.*
