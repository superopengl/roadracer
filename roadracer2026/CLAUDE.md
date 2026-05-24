# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Road Racer is a single-file HTML5 Canvas arcade game. The entire project lives in `index.html` (~2540 lines): markup, styles, and all game JavaScript are inlined. There is no build step, no package manager, no dependencies, and no tests.

## Running the game

Open `index.html` directly in a browser, or serve it from any static file server (e.g. `python3 -m http.server`). A static server is recommended because the file contains an auto-reload script (see below) that uses `fetch(location.href)`.

The bottom of `index.html` has an auto-refresh block that polls the file every 1 second and triggers `location.reload()` when the bytes change. Edits to `index.html` therefore appear live in any open tab — no manual reload needed during development.

## Architecture

The canvas is fixed at 800x800 in the DOM and scaled responsively via CSS. All game state lives in module-scope `let`/`const` variables at the top of the `<script>` block — there is no persistence (no `localStorage`), so progress and purchases reset on reload.

The game runs as a single `requestAnimationFrame` loop (`gameLoop`) at the bottom of the script. Each frame:

1. `update()` reads `keys{}` for input, moves the player car, advances obstacles, handles lane changes and inter-obstacle collision resolution, spawns new obstacles based on per-level rates, and triggers crashes.
2. A cascade of `draw*` functions paint the current screen state.

### Screen states

The game is a state machine driven by these flags, all checked inside `gameLoop`:

- `showingTitleScreen` → `drawTitleScreen()`
- `showingLevelSelect` → `drawLevelSelect()` (also draws the shop + garage; navigation uses `focusTarget` 0–4 to move between level row, shop category tabs, shop items, garage tabs, garage items)
- otherwise → in-game (track, obstacles, car, HUD); overlays for `paused`, `won`, `gameOver`, `showHelp`, and `crashMessage` are drawn on top

A single keydown listener (`document.addEventListener("keydown", ...)` around line 298) dispatches keys based on which state is active. Adding a new key binding usually means editing that listener.

### Obstacles

All moving entities — `car`, `truck`, `ambulance`, `police`, `ufo`, `person`, `dog`, `kangaroo` — live in one `obstacles` array. Vehicle types move top-to-bottom in lanes (with random lane-change and smoothing); pedestrian types (`person`/`dog`/`kangaroo`) walk left-to-right across the road. Each type has its own `draw*Obstacle(obs)` function; `drawObstacles()` dispatches by `obs.type`. Crash damage per type is in the `crashDamage` map.

### Level config

`levelConfig[1..5]` tunes obstacle speed, spawn rates (separately for vehicles, pedestrians, dogs, kangaroos), lane-change frequency, max concurrent vehicles, and starting obstacle count. `getLevelConfig()` returns the active level's settings. `startLevel(n)` resets per-run state (`blood`, `gameTimer`, `obstacles`, `stats`) and seeds the road.

### Shop / garage

`shopItems[]` defines purchasable cosmetics and upgrades across four categories: `color`, `glow`, `speed`, `headlight`. Each has `cost` (in `tokens`) and `owned`. The "shop" view shows all items in a category; the "garage" view shows only owned items and auto-equips on cursor move. Selection state is split across `selectedColor`/`selectedGlow`/`selectedSpeed`/`selectedHeadlight` (currently equipped) and `shopCursor`/`garageCursor` (UI cursor). Tokens are earned per level win (`tokenRewards[currentLevel]`).

### Controls reference

In-game: arrow keys move, `P` pause, `T` resume, `R` restart (2s hold-style timer), `U` (after winning) back to level select, `Esc` to title, `H` help.
Level select: arrows navigate (meaning depends on `focusTarget`), `Enter` or `1–5` start a level, `B` buy hovered shop item (then `Y`/`N` to confirm).

## Conventions

- Pure vanilla JS, ES2015+ (`const`/`let`, arrows, template strings). No framework, no modules.
- Drawing uses raw `ctx` calls; no sprite assets — every entity is procedurally drawn with rectangles, arcs, and gradients.
- When adding a new obstacle type: add an entry to `crashDamage`, `allTypes`, `vehicleTypes` (if vehicle) or a `random*()` spawner (if pedestrian-style), a `draw*Obstacle()` function, a dispatch case in `drawObstacles()`, and movement handling in `update()`.
- When adding a key binding, edit the single keydown handler near line 298 and respect the current state flags (`showingTitleScreen`, `showingLevelSelect`, `confirmBuy`, etc.) so the binding only fires in the right context.
