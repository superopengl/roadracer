# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Road Racer — a top-down browser game. This is a vibe coding craft by Leo, a 10 year old boy. The entire game is one self-contained HTML file: `Roadracer.html`. There is no build system, no package manager, no test suite, and no external dependencies — pure HTML/CSS/vanilla JS using a `<canvas>` 2D context.

Keep this context in mind when proposing changes: prefer small, readable edits over refactors or new abstractions, and don't introduce tooling (bundlers, frameworks, lint configs, test harnesses) unless asked.

## Running it

```sh
./dev.sh           # serves on http://localhost:8000/Roadracer.html and opens the browser
PORT=9000 ./dev.sh # override the port
```

The script just runs `python3 -m http.server`. The HTML itself embeds a small auto-reload script (bottom of the file) that polls the page URL every second and triggers `location.reload()` when the bytes change — so editing and saving is the dev loop, no rebuild needed.

Auto-reload only works when the file is served over HTTP. Opening via `file://` will silently fail the polling fetch, and you'll need to refresh manually.

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

## Conventions

- Match the existing style: 2-space indent, double-quoted strings, semicolons, plain `function` declarations at top level, arrow functions for one-off callbacks, no modules.
- Coordinates: `track` is the playfield rect (50,50,700,600 inside an 800×800 canvas). `numLanes = 5`. Use `getLaneCenterX(lane, vehicleWidth)` rather than recomputing lane math.
- Frame-based timers: counters like `gameTimer = 3600`, `gameOverTimer = 180`, `resetTimer = 120` assume 60 fps. Don't switch units mid-file.

## Git

Commit messages: short imperative summaries (see existing log). Do not add `Co-Authored-By` trailers.
