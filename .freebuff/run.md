# Run doc — her_little_world (live preview)

Flutter interactive birthday app, served in the browser via a release web
build + static file server. No `.env.local` or other secret files exist in
this project, so nothing needs copying from the main checkout.

## Reproduce the uncommitted artifacts

The project originally shipped with only the `android/` platform. A fresh
checkout needs web support, dependencies, and the release web bundle:

```bash
flutter create --platforms web .   # writes web/ + touches .metadata only
flutter pub get
flutter build web --release        # outputs build/web (~75s)
```

`flutter create --platforms web .` does not modify `lib/` or `pubspec.yaml`.

## Run the server

Default Flutter web-server port is 8080, which is often occupied by other
threads' servers — prefer it if free, otherwise pick another free port (8081
works) and pass it explicitly. Bind to loopback so the preview can reach it:

```bash
nohup python -m http.server 8081 --bind 127.0.0.1 --directory build/web \
  > .freebuff/preview-677eb07c-a099-43d2-a75f-b415c339677a.log 2>&1 &
```

Verify `http://127.0.0.1:8081/` answers HTTP 200, then register the preview
with the PID listening on the port (`netstat -ano | grep :8081`). To stop:
kill that PID.

> Note: `flutter run -d web-server` (debug/DDC mode) stalls before the app
> bootstraps in the embedded preview browser — the release build served
> statically is the reliable path.
