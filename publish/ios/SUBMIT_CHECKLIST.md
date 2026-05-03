# App Store Submission Checklist — Road Racer 2026

Working bundle id: `com.techseeding.leo.roadracer`
Working display name: `Road Racer 2026`

## What's prepared in this folder

- `metadata/name.txt`, `subtitle.txt`, `description.txt`, `keywords.txt`,
  `release_notes.txt` — draft App Store listing copy. Edit to taste.
- `metadata/privacy_policy.md` — host this somewhere public (GitHub Pages,
  a static site) and use that URL in App Store Connect's Privacy Policy
  field. The contact email placeholder needs filling in.
- `screenshots/iPhone_6.1/01..05_*.png` — five 1206×2622 captures from
  the iPhone 17 Pro simulator, in narrative order: level select →
  gameplay → police chase → death → win.

## Before you submit

1. **Apple Developer account.** $99/yr. Sign up at developer.apple.com and
   wait for the team to be active in Xcode (a few hours to a day).
2. **App Store Connect entry.** Create the app at
   appstoreconnect.apple.com → My Apps → "+" → New App. Use the bundle id
   above; this is permanent.
3. **Bigger screenshots.** Apple may now require 6.9" iPhone screenshots
   (iPhone 17 Pro Max, 1320×2868) in addition to or instead of the 6.1"
   set here. Capture those from the iPhone 17 Pro Max simulator the same
   way; drop them into `screenshots/iPhone_6.9/`.
4. **Age rating questionnaire.** Will likely land at 9+ because of mild
   cartoon violence (you can crash and "die"). No drugs/alcohol/etc.
5. **Privacy nutrition label.** "Data Not Collected" — this app makes no
   network requests and stores nothing off-device.
6. **Export compliance.** No encryption beyond standard HTTPS. Set
   `ITSAppUsesNonExemptEncryption = false` in Info.plist (currently not
   set; defaults make App Store ask every submission).

## Build & upload

```sh
pnpm mobile:build:ipa   # signed .ipa at mobile/build/ios/ipa/
```

Then either:
- **Transporter.app** (free from Mac App Store) — drag the .ipa, hit
  upload. Easiest for a one-off.
- **Xcode → Organizer → Distribute App** — same outcome, integrated.
- **fastlane deliver** — if you'd rather automate. The folder layout
  under `metadata/` and `screenshots/` here is already fastlane-shaped,
  so `fastlane init` then `fastlane deliver --skip_binary_upload` will
  push the listing copy without re-uploading the binary.

After upload, the build takes ~15–30 min to process. Then attach it to a
new version in App Store Connect, fill the listing fields from
`metadata/`, attach screenshots, and submit for review. First-time review
is typically 24–48 hours.
