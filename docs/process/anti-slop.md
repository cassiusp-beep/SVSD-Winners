# Anti-slop rules

Judges look at hundreds of AI-assisted entries. Anything that looks like a default will read as no decision at all. Check every screen and every line of copy against this list.

## Visual

- **No default gradients.** Avoid purple-to-blue hero gradients, glassmorphism on everything, and glowing orbs.
- **No identical card grids.** Rows of same-size rounded cards with an icon, title and two lines of text are the most common AI layout. Use hierarchy and varied scale instead.
- **No generic type.** Inter at every size with no typographic voice is a habit. Choose type on purpose and use real contrast in size and weight.
- **No decorative emoji.** Don't use emoji as icons or bullet points.
- **No stock illustrations or 3D blobs.** Use real content, real project images and the actual node graph.
- **Spacing and alignment are deliberate.** Use one spacing scale and keep to it.

## Interaction and motion

- **Motion explains something.** Every animation should show where something came from, where it went, or how two things relate. If it only decorates, cut it.
- **No spinner-only loading.** Show progress in the shape of the result, or explain what is happening.
- **Every state is designed.** That includes empty, loading, error and first-time use, not only the happy path.

## Copy

- **No filler microcopy.** Avoid "Unlock your potential," "Seamlessly," "Elevate," "Empower," "Revolutionize" and "Your journey starts here."
- **Specific beats clever.** Say what the thing does in plain words.
- **No AI-voice enthusiasm.** No "Great question!" or exclamation marks on every line.

## The test

Before handing anything off, ask: could this screen belong to any other AI app? If yes, it is not done. Give it a point of view, such as one memorable interaction, an editorial layout, or a real typographic voice.

## Postmortem check: October 16, 2026

The first Branch implementation passed a build but failed the anti-slop test. It looked like a generic AI-generated prototype because it was scaffolded before the visual direction had been made concrete and reviewed. The result used invented pastel surfaces, abstract CSS “artifacts,” familiar dashboard-like composition, and a graph that decorated the screen instead of carrying the project's story.

Before implementation:

- Make one representative screen concrete enough to review visually: composition, type, media, graph treatment, and interaction.
- Confirm that the screen could only belong to this product, not merely any creative collaboration app.
- Use real or deliberately authored project artifacts; do not substitute generic shapes for the work the product is meant to foreground.
- Do not expand to multiple routes or flows until the representative slice earns approval.
- A successful build, responsive layout, or complete click path does not compensate for a weak visual point of view.
