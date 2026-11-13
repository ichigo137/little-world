# Hyperframes Composition Brief: Her Little World

## Objective
Create a short launch-style brag video for Her Little World — a cozy, hand-illustrated interactive birthday surprise built entirely with Flutter's CustomPainter.

## Output
- Composition directory: `brag-output-2026-09-19-120000/composition/`
- Rendered video: `brag-output-2026-09-19-120000/brag.mp4`
- Format: landscape — 1280x720
- Duration: 20s

## Source Material
- Project root: `C:\Users\roypa\Downloads\her_little_world\her_little_world`
- Primary files read: `lib/content.dart`, `lib/theme/app_theme.dart`, `lib/screens/gift_screen.dart`, `lib/screens/garden_screen.dart`, `lib/screens/starry_hill_screen.dart`, `lib/screens/finale_screen.dart`, `lib/main.dart`, `README.md`, `pubspec.yaml`
- Product name: Her Little World
- Tagline / strongest claim: "a tiny world I built, just for you"
- Key UI or visual moment to recreate: the gift box (blush-pink with gold ribbon, breathing glow, sparkles on open), the garden flowers (elastic petal bloom), the constellation heart (stars connecting with lines, pulsing gold), the candle (flickering flame with warm halo)
- Copy that must appear verbatim:
  - "a tiny world I built, just for you"
  - "The first time we talked, I knew this year would be different."
  - "Every playlist you've ever sent me — still on repeat."
  - "Every star up there is a reason I'm glad you exist."
  - "Make a wish..."
  - "Happy Birthday"
  - "MISHTU"
  - "one more little thing"

## Creative Direction
- Tone preset: default
- Creative direction: warm handmade love letter in app form
- Interpretation: playful, cozy, personal. Room for each moment to breathe. Pacing feels like unwrapping something precious. Typography is mixed-case, warm, comfortable weight. No corporate energy.
- Angle: This isn't a product launch — it's a love letter you can hold. The video shows something this personal, built entirely in code, no shortcuts.
- Hook: The gift box breathing in the night sky with "a tiny world I built, just for you"
- Outro / punchline: "Happy Birthday" in gold shimmer, then "one more little thing" (the QR code hint)
- Avoid:
  - Generic SaaS language ("streamline", "boost", "unlock")
  - Abstract filler visuals (color washes, particle systems unrelated to the product)
  - Unrelated visual redesign — use the project's exact palette and style

## Visual Identity
- Background: #1B1533 (nightDeep), #22383C (nightMoss), #1F1B3A (skyNightDeep)
- Text: #F4F0FF (textLight)
- Accent: #E8B86D (gold)
- Secondary accents: #FFD6E8 (blush), #DCC9FF (lavender), #C9F2DC (mint), #FFDFC0 (peach)
- Display font: Caveat (handwritten titles — "Happy Birthday", "MISHTU", "Make a wish...")
- Body font: Comfortaa (rounded body text — taglines, memory text, messages)
- Visual references from the project:
  - Gift box: blush body, gold ribbon, peach lid with bow, radial gold glow, sparkle burst
  - Garden flowers: 6 hand-painted flowers with elastic petal bloom, golden centers, green stems
  - Constellation: white stars connected by white lines, gold glow halos, shooting star arc
  - Candle: blush wax body, gold-to-pink gradient flame, warm halo, smoke wisps
  - Balloons: glossy teardrop shapes in blush/gold/lavender/mint/peach with shine highlight
  - Night sky: deep indigo backgrounds with soft aurora, drifting clouds, fireflies

## Storyboard
Use the storyboard in `brag-output-2026-09-19-120000/brag-plan.md` as the creative contract.

Scene summary:
1. The Gift — 4.5s — gift box breathing in night sky, tagline "a tiny world I built, just for you" with shimmer
2. The Garden — 5s — 6 flowers bloom one by one, memory cards appear, petals fall, butterflies cross
3. The Constellation — 5s — stars connect into heart constellation, shooting star, message revealed
4. The Finale — 5.5s — candle flame dies, confetti burst, balloons rise, "Happy Birthday" + "MISHTU" + QR hint

## Audio
- Audio role: warm bed — cozy, intimate, matching the handmade feel
- Audio arc: music fades in gently under the gift, builds warmth through garden and constellation, peaks at candle blowout/confetti, fades out over final card
- Music: happy-beats-business-moves-vol-9-by-ende-dot-app.mp3
- Music treatment: fade in at 0.2s, bed volume 0.32, gentle fade out over last 1.5s. Beat-aligned reveals at garden bloom and constellation completion.
- Music cue guidance: use precomputed preset from `assets/music/cues/happy-beats-business-moves-vol-9-by-ende-dot-app.music-cues.json`. Strong cues at 4.23s (gift reveal), 6.34s (garden start), 10.54s (constellation done), 12.65s (candle blowout). Tempo ~115 BPM.
- Audio-reactive treatment: subtle; use music RMS to make the gift box glow breathe and night sky depth shift gently. No waveform/equalizer visuals.
- Audio-coupled moments:
  - Scene 1: gift box glow pulses with music RMS
  - Scene 2: flower blooms snap to beat-grid (beats 4.23, 4.75, 5.28), each with soft drop SFX
  - Scene 3: star connections snap to beats, shooting star on a strong cue
  - Scene 4: candle flame death on strong cue 10.54s, confetti burst on next beat, music fade-out
- SFX selection guidance: soft and supportive — drop/sparkle for blooms, light click for stars, whoosh for confetti. Low high-frequency risk for repeated moments.
- SFX analysis guidance: use `assets/sfx/sfx-analysis.md` for selection guidance. Prefer low/medium HF risk for the polished garden and constellation scenes.
- Exact SFX choice: Hyperframes should choose filenames, timestamps, density, and volume based on the implemented animation.
- Audio files: copy the chosen music and any Hyperframes-selected SFX into `brag-output-2026-09-19-120000/composition/assets/`

## Hyperframes Instructions
Load the composition-building Hyperframes domain skills — `hyperframes-core` (composition contract + `data-*` timing), `hyperframes-animation` (motion), `hyperframes-creative` (design spec, beats, audio-reactive), `hyperframes-keyframes` (seek-safe keyframes), and `hyperframes-cli` (lint/check/render). /brag is its own workflow: do not enter the `hyperframes` entry-point intent interview and do not route into its generic promo / launch-video workflow. Prefer native Hyperframes conventions over anything in `/brag`.

Requirements:
- Show at least one real UI, copy, or visual element from the source project (the gift box, garden flowers, constellation heart, candle — all from the app's CustomPainter).
- Keep all text readable in the final render.
- Keep the video within 15-25 seconds (target: 20s).
- Include the planned music/SFX layer.
- Treat `/brag` audio notes as guidance, not a fixed cue sheet. Choose SFX after the visual animation exists.
- Treat music cue metadata as optional timing hints. Hyperframes decides exact animation timing and should ignore cues that hurt readability, scene pacing, or the product story.
- Major reveals may move toward nearby strong cues within about 0.15s. Smaller entrances may align to nearby beat points within about 0.10s. Use only 1-3 strong cue locks in this 20s video.
- Use SFX to support motion: drop sounds for flower blooms, light clicks for star connections, whoosh for confetti burst.
- Honor planned music treatment such as fade-outs, beat-aligned reveals, or letting a final SFX ring over the music.
- When music is present, consider Hyperframes audio-reactive workflow: extract audio data and use RMS/frequency bands for subtle, brand-specific motion. Good targets: gift box glow, night sky depth. Avoid waveform/equalizer visuals, strobing, or heavy pulsing.
- Use local assets for audio and any required runtime/media dependencies.
- Run `hyperframes check` before render — it is brag's single gate.
