---
name: Roadracer dev setup preferences
description: Local iOS simulator and pnpm-wrapped Flutter workflow this user prefers
type: user
originSessionId: 87631d21-204e-4348-9b5d-1e20a448f0fd
---
User runs the iOS app on the **iPhone 17 Pro simulator** locally — that's the default device for `pnpm mobile:run:sim`.

User is not familiar with the Flutter CLI and prefers all mobile commands wrapped as pnpm scripts at the repo root (`pnpm mobile:install`, `mobile:analyze`, `mobile:run`, `mobile:run:sim`, `mobile:build:ios`, `mobile:build:ipa`, `mobile:pods`). When suggesting mobile commands, use the pnpm wrapper rather than raw `flutter ...` invocations.

**How to apply:** When the user asks to run / test / build the iOS app, default to the relevant `pnpm mobile:*` script. If the iPhone 17 Pro simulator is ever decommissioned (Xcode upgrade, etc.) update the `mobile:run:sim` script in `package.json` rather than telling the user to switch devices manually.
