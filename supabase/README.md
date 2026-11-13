# Her Little World — Supabase photo storage

Music remains bundled in Flutter assets. Supabase stores only photos and the JSON manifest.

## Supabase setup

1. Create a Supabase project in the dashboard.
2. In Authentication settings, disable public sign-ups. Create one user for Mishtu from Authentication > Users.
3. Open SQL Editor and run `storage_setup.sql` from this folder.
4. Open Storage > `her-little-world-photos` and upload:
   - `manifest.json` (copy and edit `manifest.example.json`)
   - `photos/garden/garden_01.webp` through `garden_06.webp`
   - `photos/treehouse/treehouse_01.webp` through `treehouse_05.webp`
5. Use the project URL and publishable key from Project Settings > API Keys / Connect.

The bucket is private. Its SELECT policy permits authenticated users to read objects. Public sign-ups should remain disabled; only the account created for Mishtu should exist.

## Flutter build

From the project root:

```powershell
flutter pub get
flutter run --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

Build the APK:

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

The publishable key is designed for client apps. Never use a secret or service-role key in Flutter.

## Photo manifest

The app downloads `manifest.json` from the private bucket after Mishtu signs in. It creates short-lived signed URLs for image files. The app expects six Garden memories and five Treehouse memories; missing items fall back to original bundled captions.

Keep photos compressed as WebP or JPEG. Target 150–400 KB per photo where possible and keep each image below 10 MB. The 1 GB Free storage quota is shared by all objects in the project.

## Music

Keep tracks and artwork referenced by `AppContent.finalePlaylist` in `assets/music/`. The playlist remains local and works without internet.
