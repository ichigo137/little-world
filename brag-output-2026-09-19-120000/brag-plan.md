# Brag Plan: Her Little World

## What is this app?
A cozy, hand-illustrated interactive birthday surprise built entirely in Flutter's CustomPainter — no images, no templates, just code drawing a tiny world: gift unwrap, a garden of blooming memories, a constellation heart, a blowable candle, confetti, and a secret QR code finale.

## The angle
This isn't a product launch. It's a love letter you can hold. The video should feel like unwrapping something someone made just for you — hand-painted, pixel by pixel, with no shortcuts. The hook is the contrast: something this personal, built entirely in code.

## Hook (first 2-3 seconds)
The gift box — breathing, glowing, sitting alone in a deep indigo sky. Text: "a tiny world I built, just for you." The shimmer on the tagline draws the eye. The viewer wants to know what's inside.

## Key moments (the middle)
- **The garden blooms.** Six pastel flowers unfurl one by one, each revealing a short memory. Petals fall, butterflies cross the screen. This is the app at its most alive.
- **The constellation heart.** Stars connect into a heart shape against a Milky Way sky, then a shooting star arcs across. The most visually striking moment — pure CustomPainter magic.
- **The candle blowout.** A single candle with a flickering flame. The flame dies, confetti bursts, balloons rise. Interactive, emotional, the climax of the journey.

## Outro / punchline
"Happy Birthday" in gold Caveat script with a shimmer sweep. Her name. The finale message card. Then the QR code — one more little thing. The share line: "Made her a tiny world. Hand-painted entirely in code."

## User flow worth showing
The real flow: tap gift box to open → tap flowers in the garden to bloom memories → connect stars into a constellation heart on Starry Hill → blow out the candle (mic or touch) → confetti + birthday message + secret QR code. This is the centerpiece — the video shows the journey, not a feature list.

## Tone
- Preset: default
- Creative direction: warm handmade love letter in app form
- Interpretation: playful, cozy, and personal. Room for each moment to breathe. The pacing should feel like unwrapping something precious — not rushing through features. Typography is mixed-case, warm, comfortable weight.

## Format: landscape — 1280x720
## Duration: 20s

## Visual identity (from the project)
- Background: #1B1533 (nightDeep) — deep indigo night sky
- Accent: #E8B86D (gold) — the warm accent that ties everything together
- Text: #F4F0FF (textLight) — soft white-lavender
- Secondary: #DCC9FF (lavender), #FFD6E8 (blush), #C9F2DC (mint)
- Display font: Caveat (handwritten feel for titles)
- Body font: Comfortaa (rounded, friendly for body text)
- Strongest visual element: the hand-painted gift box with gold ribbon, breathing glow, and sparkles — plus the constellation heart pulsing against a starry sky

## Share copy (draft)
Made her a tiny world. Hand-painted entirely in code — no images, no templates, just CustomPainter and love.

## Audio direction
- Role: warm bed — cozy, inviting, matching the intimate handmade feel
- Music: happy-beats-business-moves-vol-9-by-ende-dot-app.mp3 (mid-energy, warm, slightly laid-back — fits the cozy default tone)
- Music treatment: fade in at 0.2s, bed at 0.32 volume, gentle fade out over last 1.5s. Beat-aligned reveals at garden bloom and constellation completion.
- Music cue guidance: use precomputed preset from assets/music/cues/happy-beats-business-moves-vol-9-by-ende-dot-app.music-cues.json. Strong cues at 4.23s (gift reveal landing), 6.34s (garden bloom start), 10.54s (constellation completion), 12.65s (candle blowout). Tempo ~115 BPM.
- Audio-reactive treatment: subtle; use music RMS to make the gift box glow breathe slightly and the night sky background depth shift gently. No waveform visuals.
- SFX posture: moderate — 4-5 well-timed cues. Soft sparkle/drop for flower blooms, a resonant bell for constellation completion, a whoosh for confetti burst.
- Audio-coupled moments: flower blooms appear one by one synced to beats; constellation stars connect on beat-grid; candle flame dies on a strong cue; confetti burst on a strong beat.
- Restraint rule: audio must never overpower the visual storytelling. The hand-painted art is the star.

## Storyboard

### Scene 1 — The Gift — 4.5s
Night sky background (#1B1533). The gift box sits center — a blush-pink box with gold ribbon and bow, painted in the app's CustomPainter style. It breathes (subtle scale pulse). A soft gold radial glow emanates from behind it. Text fades in: "a tiny world I built, just for you" in Comfortaa, centered below. The tagline has a shimmer sweep — gold band passes across the text.
Sequential/interaction: Gift box breathes continuously (scale 1.0→1.04). Shimmer band sweeps across tagline text at 1.5s.
Audio intent: warm, inviting. Music fades in. A soft drop sound when the text settles.
Audio-coupled idea: the glow behind the gift box pulses subtly with music RMS.
Transition mood: soft crossfade → Scene 2

### Scene 2 — The Garden — 5s
The garden screen: a grid of 6 hand-painted flowers on a moss-green night sky (#22383C → #2E4744). Flowers bloom one by one — stem grows, leaves unfold, petals open with elastic spring. Each bloom reveals a short memory text in a soft card: "The first time we talked...", "That random Tuesday...", "Every playlist you've ever sent me..." Falling petals drift across the screen. Two butterflies cross.
Sequential/interaction: 3 flowers bloom in sequence (0.5s apart, beat-grid aligned at beats 4.23, 4.75, 5.28). Each bloom triggers a soft sparkle SFX. Memory cards fade in after each bloom.
Audio intent: gentle, magical. Each bloom gets a soft drop/sparkle SFX.
Audio-coupled idea: flower bloom timing snaps to beat-grid. Petal drift speed subtly varies with music energy.
Transition mood: clean crossfade → Scene 3

### Scene 3 — The Constellation — 5s
Starry Hill: deep blue-purple sky (#1F1B3A → #3B3255) with a faint Milky Way dust band. Stars appear one by one, connecting into a heart constellation. Lines draw between stars as they connect. When complete, the heart pulses with a golden glow. A shooting star arcs across the upper sky. Text fades in below: "Every star up there is a reason I'm glad you exist."
Sequential/interaction: 8-10 stars appear and connect in sequence (beat-grid aligned, ~0.5s apart). Each star connection triggers a soft star SFX. Shooting star at the end (0.9s arc). Message fades in after completion.
Audio intent: awe, wonder. Star connections get light click/sparkle SFX. Shooting star gets a whoosh.
Audio-coupled idea: star connections snap to beats. Heart pulse syncs with music energy.
Transition mood: dramatic crossfade → Scene 4

### Scene 4 — The Finale — 5.5s
Night sky with rose gradient. A candle with flickering flame (gold-to-pink gradient flame, warm halo). "Make a wish..." in Caveat above. Flame dies — smoke wisps curl up. Confetti bursts (blush, gold, lavender, mint particles). Balloons rise from below (glossy teardrop shapes in the palette colors). "Happy Birthday" appears in gold Caveat with shimmer sweep. Her name "MISHTU" below. Then a subtle QR code icon with "one more little thing."
Sequential/interaction: Candle flame flickers (continuous). Flame dies at 2s. Confetti burst at 2.2s. Balloons rise from 2.5s. "Happy Birthday" text lands at 3s. Name at 3.5s. QR hint at 4.5s.
Audio intent: emotional peak. Candle blow whoosh, confetti burst SFX, gentle balloon rise. Music swells slightly then fades.
Audio-coupled idea: candle flame death on a strong cue (10.54s from start of track, mapped to scene time). Confetti burst on the next strong beat. Music fade-out over last 1.5s.
Transition mood: fade to black over last 1s

**Music mood for this video:** warm, cozy, playful — the musical equivalent of a handwritten card
**Audio summary:** warm music bed fades in under the gift, swells gently through the garden and constellation, peaks at the candle blowout/confetti, then fades out with the final card. SFX are sparse and supportive — sparkles for blooms, clicks for stars, whoosh for the finale.
