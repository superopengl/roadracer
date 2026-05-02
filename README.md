# roadracer

A vibe coding craft by Leo, a 10 year old boy.

Road Racer is a top-down browser game written as a single self-contained HTML file (`Roadracer.html`) — pure HTML/CSS/vanilla JS on an HTML5 `<canvas>`, no build step, no dependencies. The same HTML is also wrapped in a Flutter iOS app (`mobile/`) so the game can ship as an iPhone app.

## Tech stack

- **Game**: HTML5 + vanilla JavaScript + `<canvas>` 2D context. Single file: `Roadracer.html`.
- **Dev server**: `python3 -m http.server` via `dev.sh`. The HTML embeds a 1-second polling auto-reloader, so saving the file refreshes the open tab automatically.
- **iOS app**: Flutter 3 + `webview_flutter` (WKWebView) wrapping the same HTML as a bundled asset. iOS-only; no Android target.

## Run the game in a browser

```sh
./dev.sh           # serves http://localhost:8000/Roadracer.html
PORT=9000 ./dev.sh # override the port
```

## Run the iOS app

Requires Flutter 3.x, Xcode, and CocoaPods installed.

```sh
cd mobile
flutter pub get
flutter run                               # debug build on a connected iPhone or simulator
flutter build ios --release --no-codesign # release build (no signing)
flutter build ipa                         # signed .ipa for distribution
```

The Flutter project bundles `Roadracer.html` via a symlink at `mobile/assets/Roadracer.html` → `../../Roadracer.html`, so the HTML stays the single source of truth — edit the file at the repo root and both targets pick it up.

## Repo layout

```
Roadracer.html   the game (everything is in here)
dev.sh           local dev server
mobile/          Flutter iOS app wrapper
LICENSE
```
