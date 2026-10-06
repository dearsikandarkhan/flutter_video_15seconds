# Launch posts for short_video_kit

Copy-from reference for the launch. Voice: **humble builder** across all channels.

**Before posting — fill these placeholders everywhere (`⟨…⟩`):**
- `⟨REPO_URL⟩` → `https://github.com/dearsikandarkhan/flutter_video_15seconds` (confirm the repo exists)
- `⟨PUB_URL⟩` → `https://pub.dev/packages/short_video_kit` (⚠️ confirm the name is free on pub.dev first; if taken, fall back to `reel_kit` / `snap_video_kit` and sweep-replace)
- `⟨GIF_URL⟩` → a hosted recording GIF (the countdown-ring record flow is the best hook)
- `⟨HANDLE⟩` → your X handle

**Tactics:** post Tue–Thu morning US time; lead with the GIF everywhere; reply to every comment in the first 48h; don't fire all channels in the same hour (stagger a day or two); on Reddit ask for *feedback*, not stars.

---

## 1 — Reddit (r/FlutterDev), flair: "Package"

**Title:** I got tired of re-wiring camera + trimmer + player every project, so I made a package for 15s video capture

**Body:**

Every time I needed "record a short clip or pick one and trim it" in a Flutter app, I ended up gluing together `camera`, `image_picker`, `video_trimmer`, `video_player` and `path_provider` — plus permission handling, controller lifecycle, and a countdown UI. Same ~200 lines, copied app to app, breaking in slightly new ways each time.

So I pulled it into a package: **short_video_kit**. The whole record-or-pick-trim-preview flow is now one call:

```dart
final result = await ShortVideoKit.capture(
  context,
  maxDuration: const Duration(seconds: 15),
  source: CaptureSource.recordOrGallery,
);
if (result != null) print(result.path);
```

What's in it:
- Duration-limited recording with an animated countdown ring (auto-stop)
- Pick-from-gallery + trim, capped to your max length
- A looping preview widget
- Permissions handled with graceful denial callbacks (no silent crashes)
- Themeable, null-safe, Android + iOS

It's MIT, there's a runnable example app, and I'd genuinely like feedback — especially on the API surface and anything that'd stop you using it in a real project. What would you want `capture()` to do that it doesn't?

Repo: ⟨REPO_URL⟩ · pub.dev: ⟨PUB_URL⟩

*(First comment from me: the one gotcha is iOS Podfile permission macros — documented in the README's Platform setup, since that's where I personally lost an afternoon.)*

---

## 2 — X / Twitter thread

**1/ (hook + GIF)**
I kept rewriting the same 200 lines of Flutter video plumbing in every project, so I turned it into a package.

Record a 15s clip or pick + trim one from the gallery → one call. 👇
⟨GIF_URL⟩

**2/ (the pain)**
"Short video capture" sounds simple until you're juggling camera + image_picker + video_trimmer + video_player + path_provider, plus permissions, controller lifecycle and a countdown UI. Every app. Slightly broken a new way each time.

**3/ (the fix — code)**
short_video_kit collapses all of it:

```dart
final result = await ShortVideoKit.capture(
  context,
  maxDuration: Duration(seconds: 15),
);
```

Countdown ring, trim, preview, permissions — handled.

**4/ (what's inside)**
• auto-stop countdown ring 🔴
• gallery pick + trim to max length ✂️
• looping preview widget
• graceful permission callbacks (no crashes)
• themeable, null-safe, Android + iOS
MIT + a runnable example app.

**5/ (ask)**
It's early (v0.1.0) and I'd love feedback from people shipping real apps.

pub.dev → ⟨PUB_URL⟩
code → ⟨REPO_URL⟩

If you've fought this before, a ⭐ helps other folks find it. #FlutterDev #Flutter

---

## 3 — dev.to article

**Front matter:**
```
---
title: "Stop rewriting 200 lines of video plumbing in every Flutter app"
published: true
tags: flutter, dart, mobile, opensource
cover_image: ⟨GIF_URL or cover⟩
---
```

**Body:**

Every Flutter app I built that needed short-video capture started the same way: wire up `camera` for recording, `image_picker` for the gallery, `video_trimmer` to cut to length, `video_player` for preview, and `path_provider` for temp files. Then handle permissions. Then manage controller lifecycle so you don't leak the camera. Then build a countdown UI.

~200 lines. Copied from the last project. Broken in a fresh way each time.

### The part nobody mentions

The real cost isn't the happy path — it's the edges:
- iOS crashes instantly if you forget the `Info.plist` usage strings.
- The camera controller needs disposing on lifecycle changes or it locks up.
- `video_trimmer`'s start/end handles mean nothing unless you actually read them on save.
- A denied permission should degrade gracefully, not throw.

I'd re-solved all of these more than once. So I packaged them.

### The result: one call

```dart
import 'package:short_video_kit/short_video_kit.dart';

final result = await ShortVideoKit.capture(
  context,
  maxDuration: const Duration(seconds: 15),
  source: CaptureSource.recordOrGallery,
);

if (result != null) {
  // result.file — the .mp4 on disk
  // result.duration — how long the clip is
}
```

That's the whole record-or-pick → trim → return flow, permissions and lifecycle included.

### Prefer the widgets? They're exposed too

```dart
ShortVideoRecorder(
  maxDuration: const Duration(seconds: 30),
  onRecorded: (r) => Navigator.pop(context, r),
  onPermissionDenied: () => openAppSettings(),
);

ShortVideoPreview(file: result.file); // looping, tap to play/pause
```

### The one gotcha (so you don't lose an afternoon like I did)

On iOS you need the usage strings in `Info.plist` **and** the matching `permission_handler` macros in your `Podfile`. The README's "Platform setup" section has the exact snippets.

### Try it

- pub.dev: ⟨PUB_URL⟩
- GitHub (MIT, with a runnable example): ⟨REPO_URL⟩

It's v0.1.0 and I'm actively looking for feedback — if there's a flag or callback you'd need before dropping this into a real app, open an issue. And if it saved you the afternoon it cost me, a ⭐ genuinely helps others find it.

---

## 4 — LinkedIn

I just open-sourced my first Flutter package, and the lesson behind it matters more than the code. 🎥

Across several projects I kept rebuilding the exact same thing: record a short video, or let the user pick one and trim it to length, then preview it. Each time meant stitching together five packages, handling permissions, managing the camera lifecycle, and building a countdown UI — roughly 200 lines, re-solved from scratch, breaking in new ways each time.

So I turned it into **short_video_kit** — the whole flow behind a single call:

final result = await ShortVideoKit.capture(context, maxDuration: Duration(seconds: 15));

Countdown ring, gallery trim, looping preview, permission handling — included. Null-safe, Android + iOS, MIT-licensed, with a runnable example app.

The takeaway: the friction you keep working around is often a product. Packaging it forced me to handle the edge cases properly — lifecycle, denied permissions, platform setup — and that's where the real learning was.

It's an early release and I'd love feedback from anyone shipping Flutter apps.

Code + docs 👉 ⟨REPO_URL⟩
#Flutter #Dart #OpenSource #MobileDevelopment

---

## 5 — Hacker News (Show HN)

**Title:** Show HN: short_video_kit – Reels-style video capture for Flutter in a few lines

**First comment (post immediately after submitting):**

Author here. I build Flutter apps and kept rewriting the same short-video flow — record a clip (or pick one from the gallery and trim it), cap it to a length, preview it. In Flutter that means composing five separate packages (camera, image_picker, video_trimmer, video_player, path_provider) and, more annoyingly, re-solving the edges every time: iOS permission strings, camera controller lifecycle, reading the trimmer's start/end handles, and graceful handling when a permission is denied.

short_video_kit wraps that into one call (`ShortVideoKit.capture(context, ...)`) returning a file + duration, while still exposing the underlying widgets if you want to compose your own UI.

Honest limitations, since this is v0.1.0: it stands on the shoulders of those packages (so it inherits their platform quirks — the iOS Podfile macros are the sharpest edge), there's no in-app filters/overlays yet, and I've tested on real Android and iOS devices but not an exhaustive device matrix. It's MIT with a runnable example.

I'd be glad for feedback on the API and on edge cases I've missed.

Repo: ⟨REPO_URL⟩ · pub.dev: ⟨PUB_URL⟩

---

## 6 — awesome-flutter PR

**Where:** Solido/awesome-flutter, under **Camera / Video** (Utils → Media section).

**One-line entry (alphabetical within its subsection):**
```
* [short_video_kit](https://github.com/dearsikandarkhan/flutter_video_15seconds) - Drop-in TikTok/Reels-style short video capture: record a duration-limited clip or pick & trim from the gallery, with permissions and a countdown UI handled.
```

**PR title:** Add short_video_kit (short video capture: record / pick / trim / preview)

**PR description:**
Adds `short_video_kit`, an MIT-licensed package that bundles duration-limited recording, gallery pick + trim, and a looping preview behind a single call, with permission handling included. Null-safe, Android + iOS, published on pub.dev with a runnable example app.

- pub.dev: ⟨PUB_URL⟩
- repo: ⟨REPO_URL⟩

I believe it fits the Camera/Video utilities section; happy to move it if you'd prefer it elsewhere. Thanks for maintaining the list!

---

## Pre-post checklist

- [ ] `⟨PUB_URL⟩` resolves (name confirmed free + package actually published).
- [ ] `⟨REPO_URL⟩` is public; README GIFs render; CI badge is green.
- [ ] `⟨GIF_URL⟩` is hosted and loads (the record/countdown-ring flow).
- [ ] All `⟨…⟩` placeholders replaced; X handle + LinkedIn link correct.
- [ ] Code snippets compile against the published API (copy-paste one into the example).
- [ ] Posts staggered across days, not fired simultaneously.
