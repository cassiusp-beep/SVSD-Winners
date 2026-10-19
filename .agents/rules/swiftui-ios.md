# Swift iOS & SwiftUI Prototyping Rules

Updated 19 October 2026. Source of each rule: [DECISIONS.md](../../DECISIONS.md) Decisions 014 to 019.

1. **Target Viewport & Parity:**
   - Design for iPhone 17 (393x852) and iPhone 17 Pro Max. No iPhone SE testing (user decision).
   - Safe areas: only background layers ignore the safe area (`.ignoresSafeArea()` on the wash, canvas or fills). Never on a whole screen or a `GeometryReader` that holds controls, because the inset then reads as 0. Controls and HUD stay inside the safe bounds.
   - The shared `ScreenHeader` sits 12 pt below the top safe area.
   - The @nickname banner shows only on Profile, Integrations and Sync, 8 pt below the safe area.

2. **Visual Tokens:**
   - Main tabs: plain white or black background, black or white ink. Decision 013 sets this; the warm drafting bed and dot grid from October 17 and 18 are not used for app backgrounds.
   - Onboarding wash: warm off-white with lavender and sage glows, dimmed in dark mode. See rule 5.
   - Selected tab uses the user's family accent. Light: Cloud `#7E5FA6`, Bloom `#C9652F`, Prism `#2F7FA3`, Spark `#5E8A56`. Dark: Cloud `#A083BC`, Bloom `#E39A57`, Prism `#4598BB`, Spark `#8AAE83`. Guests use Cloud. All are at least 3:1.
   - Agent colours on Takeaways: Maya purple, Theo orange, Alex blue, Sam green. Use them as tints, never as chrome.
   - Type: system fonts. Small labels use `YaYaFont` (Berkeley Mono name, SF Mono fallback). Berkeley Mono files are not bundled; SF Mono is the accepted fallback.
   - Logo: `YaYaWordmark` (SVG letterforms with gradient eyes) and `YaYaMark` (black rounded square, white eyes). Sources in `docs/references/brand/`.

3. **Motion & Feedback:**
   - **One-moment rule:** each screen gets one arrival moment of motion. After it settles, only ambient motion remains (blinking, marquee rows). Never two attention-grabbing animations at once.
   - Haptics fire only at approved moments: quiz answer selection, Reveal sprite tap and success, capture success. The Takeaways screen has none. Do not add haptics to every state change.
   - Interactive controls must not conflict with gestures on the surface they sit on. Give tap targets at least 44 pt.
   - Reduce Motion: crossfade instead of morph, no breathing, no quiz auto-advance, logo blink off, and the launch splash skips its blink.
   - Animation constants live in `BranchMotion.swift`. Takeaways keeps its own constants in `TakeawaysIsoConstants` (`IsometricContributionGrid.swift`) and `BranchMotion.Takeaways`.

4. **Demo Readiness:**
   - Keep a persistent preset or launch route for rapid resetting during screen recordings. Routes live in `BranchApp/App.swift` (for example `-onboardingQuiz`, `-collaborationTakeaways`).
   - Demo speed-ups for recordings: `-talkFast` and `-autoplayOnboarding quiz|talk|skip`. Do not use these in review screenshots.
   - Ensure all assets are packaged locally so previews and demo runs never fail due to network drops.

5. **Onboarding:**
   - Order: Welcome, Sign up, Profile, Intro, Quiz or Talk, Reveal, Integrations, Sync, then the app. Guests skip straight to the app.
   - The Welcome wash runs behind every onboarding step, is never part of a step transition, and fades out when onboarding ends. Main tabs stay plain.
   - Navigation: the round `NextArrowButton` (56 pt) is the primary way forward. Text links and a top-right "Skip" or "Continue" are the fallbacks. Intro and Quiz have "Skip". Talk has no skip.
   - **Exception:** Welcome keeps the original full-width "Try YaYa without an account" and "Sign up" buttons (user override, Decision 017).
   - Back is a 44 pt glass circle with `chevron.left`. Intro has no back button.
   - Step transitions: the leaving step is removed quickly; the arriving step is inserted after a short delay, so text from both screens never overlaps at full weight.
   - On Integrations, continuing with zero integrations is valid, so the arrow is always enabled.

6. **Takeaways:**
   - The grid has no sprites. Agents are identified by colour (and by name on tap).
   - Tapping a block opens the moment sheet in Insights (planned).
   - Team receipt: group view names real teammates. Do not use people's names as sprites.

7. **Brand & Icons:**
   - Wordmark and mark follow the SVGs in `docs/references/brand/`. Do not draw a new logo.
   - The app icon is a full-bleed 1024 square. iOS applies the mask; do not round the corners in the asset.
   - Launch: the static launch screen hands off to `LaunchSplashView`, which draws the same mark pixel for pixel.

8. **Testing and Review:**
   - Screenshots for review are taken on iPhone 17 and iPhone 17 Pro Max, in light and dark mode.
   - Agents never use the user's simulator. Build and test on a separate simulator or a build only.
   - Reviewer and product-designer look at screenshots before any verdict.
