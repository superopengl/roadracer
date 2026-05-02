# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Road Racer — a top-down browser game. This is a vibe coding craft by Leo, a 10 year old boy.

The repo has two targets that share one source of truth:

1. **The game itself** — `Roadracer.html` at the repo root. One self-contained HTML file: pure HTML/CSS/vanilla JS using an HTML5 `<canvas>` 2D context. No build step, no runtime JS dependencies. The only tooling is a static dev server (`pnpm dev`); see "Running the browser game" below.
2. **iOS app wrapper** — `mobile/`, a Flutter 3 + `webview_flutter` project that bundles the same HTML as an asset and renders it fullscreen in WKWebView. iOS only.

Keep this in mind when proposing changes: prefer small, readable edits over refactors or new abstractions in the game itself, and don't introduce runtime tooling (bundlers, frameworks, transpilers) on the HTML side unless asked — the game must stay loadable as a single file. The Flutter project is a thin shell; don't grow it beyond the WebView wrapper without a specific reason.

## Running the browser game

Toolchain: Node 24 (pinned in `.nvmrc`), pnpm (declared via `packageManager` in `package.json`), `serve` for static hosting.

```sh
nvm use            # picks Node 24 from .nvmrc
pnpm install       # one-time, installs `serve`
pnpm dev           # serves http://localhost:8000/Roadracer.html
PORT=9000 pnpm dev # override the port
```

`pnpm dev` runs `serve --listen ${PORT:-8000} --no-clipboard .`. `serve.json` sits next to `package.json` and (a) disables `serve`'s default clean-URL rewriting so `/Roadracer.html` resolves directly instead of redirecting to `/Roadracer`, and (b) 301-redirects `/` to `/Roadracer.html` so the bare host URL just works.

The HTML itself embeds a small auto-reload script (bottom of the file) that polls the page URL every second and triggers `location.reload()` when the bytes change — so editing and saving is the dev loop, no rebuild needed. Auto-reload only works when the file is served over HTTP; opening via `file://` will silently fail the polling fetch.

## Architecture

Everything lives in the inline `<script>` near the top of `Roadracer.html` (roughly lines 41–2381). The structure to know:

- **Game state is a flat set of module-level `let`s.** `showingTitleScreen`, `showingLevelSelect`, `currentLevel`, `paused`, `won`, `gameOver`, `resetting`, `crashFrozen`, `showHelp`, plus the `car` object, `obstacles[]` array, `explosionParticles[]`, `damagePopups[]`, etc. There is no scene/state-machine abstraction — code branches on these flags inline. When adding a new screen or mode, follow the same pattern (a new `showingX` flag plus explicit checks in input handler and `gameLoop`).

- **Single `gameLoop()`** drives everything via `requestAnimationFrame`. It branches on the flags above to decide whether to draw the title screen, level select + shop + garage UI, the gameplay scene, or overlays (pause, help, won, game over). `update()` only runs during active gameplay.

- **Obstacles share one array.** Cars, trucks, ambulances, police, UFOs, pedestrians, dogs, and kangaroos all live in `obstacles[]` and are distinguished by `obs.type`. Spawn helpers: `randomObstacle()` (vehicles), `randomPedestrian()`, `randomDog()`, `randomKangaroo()`. Per-type damage is in `crashDamage`; per-type counters live in `stats[type]`.

- **Levels are data, not code.** `levelConfig[1..5]` holds tuning knobs (`obstacleSpeed`, `spawnRate`, `pedRate`, `dogRate`, `rooRate`, `laneChangeRate`, `maxVehicles`, `startObstacles`). To rebalance a level, edit that table — don't add branches in update logic. Index 0 is a deliberate `null` placeholder so `levelConfig[currentLevel]` works directly.

- **Shop / garage / cosmetics.** `shopItems[]` is the catalog (id, category ∈ {color, glow, speed, headlight}, value, cost, owned). The currently equipped item per category is tracked by `selectedColor`/`selectedGlow`/`selectedSpeed`/`selectedHeadlight` (item ids, not values). Use the `getSelectedX()` helpers to resolve to the actual value. `speed` cosmetics double as gameplay tuning — buying "Turbo" sets `car.speed` on the next `startLevel()`.

- **Input is two `keydown` listeners on `document`** (lines ~241 and ~252). The first just records held keys into `keys{}` for movement polling. The second handles discrete actions and is a large branch on the current screen flag (`showingTitleScreen` → `showingLevelSelect` → in-game). When adding a key binding, put it in the branch that matches the screen it applies to. Movement uses the held-keys map; everything else uses the discrete handler.

- **Level-select navigation uses a `focusTarget` (0–4)** to move focus across regions on the level-select screen: levels row, shop category tabs, shop items, garage category tabs, garage items. Arrow keys' behavior depends on `focusTarget`. Keep this in mind before adding new arrow-key bindings on that screen.

- **No persistence.** Tokens, owned items, and selected cosmetics reset on page reload. If adding save state, `localStorage` is the natural fit; nothing currently reads or writes it.

## iOS app wrapper (`mobile/`)

Flutter 3 + `webview_flutter ^4.13` that wraps `Roadracer.html` in a fullscreen `WebView`. iOS only — no Android directory was generated, so don't run `flutter create --platforms=android` here without intent.

- **Single source of truth**: the HTML is bundled via a symlink at `mobile/assets/Roadracer.html` → `../../Roadracer.html`. Edit only the file at the repo root; the Flutter build follows the symlink. Don't replace the symlink with a copy.
- **Entry point**: `mobile/lib/main.dart` reads the asset with `rootBundle.loadString` and hands it to `WebViewController.loadHtmlString` with `baseUrl: 'about:blank'`. The HTML's dev auto-reloader (`fetch(location.href)`) silently fails inside WKWebView, which is fine — auto-reload is a desktop-dev convenience, not a mobile feature.
- **iOS config**: bundle id `com.leo.roadracer.roadracer`, display name "Road Racer", deployment target 13.0 (pinned in `mobile/ios/Podfile`, required by `webview_flutter_wkwebview`). Org prefix is `com.leo.roadracer`.
- **No widget tests**: the scaffolded `test/widget_test.dart` was removed because the WebView wrapper isn't worth a smoke test. Don't recreate it without a real test to put there.

```sh
cd mobile
flutter pub get
flutter analyze                           # should report no issues
flutter run                               # debug on connected iPhone or simulator
flutter build ios --release --no-codesign # release build (no signing)
flutter build ipa                         # signed .ipa for distribution
```

If Xcode complains about missing pods after pulling new packages: `cd mobile/ios && pod install`. The CocoaPods warning about `Pods-Runner.profile.xcconfig` not being a base config is cosmetic — Flutter's Profile build picks up Release pod settings via `Flutter/Release.xcconfig`.

## Conventions

- Match the existing style: 2-space indent, double-quoted strings, semicolons, plain `function` declarations at top level, arrow functions for one-off callbacks, no modules.
- Coordinates: `track` is the playfield rect (50,50,700,600 inside an 800×800 canvas). `numLanes = 5`. Use `getLaneCenterX(lane, vehicleWidth)` rather than recomputing lane math.
- Frame-based timers: counters like `gameTimer = 3600`, `gameOverTimer = 180`, `resetTimer = 120` assume 60 fps. Don't switch units mid-file.

## Git

Commit messages: short imperative summaries (see existing log). Do not add `Co-Authored-By` trailers.
