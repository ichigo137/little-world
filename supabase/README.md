# Her Little World — private Supabase photo storage

The app keeps music bundled locally. Supabase Storage is used only for the 11 photo memories and `manifest.json`.

## 1. Choose the correct Supabase project

Use the Supabase project that owns the `her-little-world-photos` bucket. Do not create a second project or bucket just because the app cannot connect.

The bucket must remain **Private**. The app signs in as the one account created for the recipient and requests short-lived signed image URLs.

## 2. Required bucket layout

Upload these objects to the private bucket named `her-little-world-photos`:

```text
manifest.json
photos/
  garden/
    garden_01.webp
    garden_02.webp
    garden_03.webp
    garden_04.webp
    garden_05.webp
    garden_06.webp
  treehouse/
    treehouse_01.webp
    treehouse_02.webp
    treehouse_03.webp
    treehouse_04.webp
    treehouse_05.webp
```

Use JPEG, PNG or WebP. Keep each image below 10 MB; around 150–400 KB is a good target for quick loading.

## 3. Manifest

Copy `manifest.example.json` to `manifest.json`, then upload `manifest.json` to the bucket root.

Each array entry maps by index to the corresponding memory in the app. The `path` must stay inside its own collection folder. A blank `message` uses the app's fallback caption from `lib/content.dart`; a non-empty message overrides it.

Do not rename the expected object paths unless you also update the manifest.

## 4. Storage access policy

The bucket must be private. Authenticated users need a SELECT policy on `storage.objects` scoped to this bucket. The app does not upload, update or delete objects.

The SQL in `storage_setup.sql` creates/configures the private bucket and the read policy. Run it only in the intended project and only if the bucket/policy still needs setup. It is safe to review first; do not run it against an unrelated project.

Disable public sign-ups in Supabase Auth and create the recipient's email/password user manually in Authentication > Users. Do not put a service-role key or secret key in the Flutter app.

## 5. Local Flutter configuration

Copy `local.config.example.json` to `local.config.json` and replace the two values with the intended project's Project URL and **publishable** key from Project Settings > API Keys.

`local.config.json` is ignored by Git. Never commit it if it contains project-specific credentials.

Run:

```powershell
flutter pub get
flutter run --dart-define-from-file=supabase/local.config.json
```

Build:

```powershell
flutter build apk --release --dart-define-from-file=supabase/local.config.json
```

The app can still run without this file/configuration, using its local fallback content. To load private cloud photos, the URL, publishable key, authenticated user, bucket, policy, manifest and all referenced image objects must exist.

## 6. Refresh and offline behavior

The app creates 24-hour signed URLs and refreshes the manifest after approximately 23 hours when it resumes. If an individual photo is missing or cannot be signed, that memory still loads with its caption and local placeholder instead of blocking the entire collection.

Music is always bundled in the APK and does not depend on Supabase.
