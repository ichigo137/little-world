# Her Little World 🎁

A cozy, hand-illustrated interactive journey (not a photo timeline!):
gift unwrap → a tiny world map → a Garden that blooms, a Treehouse
with windows to light up, a Starry Hill where she connects a
constellation → a candle she blows out → confetti, balloons, your
message → one last secret: a QR code that opens a live surprise
site in her browser.

Everything visual is drawn live with Flutter's own CustomPainter and
animation system — no external art/image assets required, which is
what keeps it small and butter-smooth. Her real photos are optional
and layered on top.

---

## 1. One-time setup (10 minutes)

You need the Flutter SDK installed. If you don't have it yet:
https://docs.flutter.dev/get-started/install — pick your OS, it
walks you through it.

Then, in a terminal:

```bash
flutter create --org com.yourname her_little_world_app
```

This generates the `android/`, `ios/` etc. folders Flutter needs to
actually build an app (I can't generate those here without the SDK).
Now replace the generated `lib/` folder and `pubspec.yaml` in that
new project with the ones from this package:

```bash
cd her_little_world_app
rm -rf lib
cp -r /path/to/her_little_world/lib .
cp /path/to/her_little_world/pubspec.yaml .
cp -r /path/to/her_little_world/assets .
```

Then install the packages:

```bash
flutter pub get
```

## 2. Personalize it (the fun part)

Open **`lib/content.dart`** — it's the only file you need to touch.
Everything is labeled: her name, the tagline, the 6 garden memories,
the 5 treehouse captions, the constellation message, the finale
message, and `secretLinkUrl` (the site hidden in the final QR
code). Just edit the strings.

To add real photos: drop images into `assets/photos/`, then point a
`MemoryItem`'s `photoAsset` at the path, e.g.:

```dart
MemoryItem(
  message: 'The day we got matching bad haircuts',
  photoAsset: 'assets/photos/haircuts.jpg',
),
```

Any memory left with `photoAsset: null` just shows a soft heart
placeholder instead — the app looks complete either way, so you can
ship it without photos and add them later.

## 3. Run it / test it

Plug in an Android phone (or start an emulator) and run:

```bash
flutter run
```

Hot reload (`r` in the terminal) lets you tweak text/colors and see
changes instantly without losing your place — great for polishing.

## 4. Build the real APK to send her

```bash
flutter build apk --release
```

The installable file lands at:
`build/app/outputs/flutter-apk/app-release.apk`

Send that file to her phone (WhatsApp, Google Drive, USB, whatever's
easiest), she opens it, Android will ask to allow install from that
source once — approve it, and it installs like a normal app.

## Where to look if you want to go further

- `lib/content.dart` — all your words and photos (edit this)
- `lib/screens/` — one file per scene, each fairly short and
  readable if you want to add a 4th garden flower, reword the
  candle-blow interaction, etc.
- `lib/widgets/animated_background.dart` — the drifting-cloud /
  twinkling-star engine used behind every screen
- `lib/theme/app_theme.dart` — the pastel color palette, change
  these hex values to shift the whole app's mood

Happy birthday to her. Good luck. 🎂
