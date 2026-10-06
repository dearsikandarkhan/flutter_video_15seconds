# 🎥 short_video_kit

**Add TikTok / Reels-style short-video capture to any Flutter app in a few lines.**

Recording a duration-limited clip, or picking one from the gallery and trimming it,
normally means wiring together `camera`, `image_picker`, `video_trimmer`,
`video_player` and `path_provider` — plus permissions, lifecycle and a countdown UI.
`short_video_kit` does all of that behind one call.

[![pub version](https://img.shields.io/pub/v/short_video_kit.svg)](https://pub.dev/packages/short_video_kit)
[![pub points](https://img.shields.io/pub/points/short_video_kit)](https://pub.dev/packages/short_video_kit/score)
[![likes](https://img.shields.io/pub/likes/short_video_kit)](https://pub.dev/packages/short_video_kit/score)
[![CI](https://github.com/dearsikandarkhan/flutter_video_15seconds/actions/workflows/ci.yml/badge.svg)](https://github.com/dearsikandarkhan/flutter_video_15seconds/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

| Record | Pick & Trim | Preview |
|--------|-------------|---------|
| ![Record](assets/demo/record.gif) | ![Pick](assets/demo/pick.gif) | ![Home](assets/demo/home.gif) |

---

## ✨ Why

```dart
// Everything below — camera, 15s limit, countdown ring, trim, permissions — is this:
final result = await ShortVideoKit.capture(
  context,
  maxDuration: const Duration(seconds: 15),
  source: CaptureSource.recordOrGallery,
);
if (result != null) {
  print('Got ${result.duration} clip at ${result.path}');
}
```

- ⏱️ **Duration-limited** recording with an animated **countdown ring** (auto-stop).
- 🖼️ **Pick & trim** from the gallery, capped to your max length.
- 🔁 **Looping preview** widget you can drop anywhere.
- 🔐 **Permissions handled** for you, with graceful denial callbacks (no crashes).
- 🎨 **Zero-config, fully themeable** — override only what you want.
- 📱 **Android + iOS**, null-safe, no analyzer warnings.

## 📦 Install

```yaml
dependencies:
  short_video_kit: ^0.1.0
```

```bash
flutter pub add short_video_kit
```

## 🚀 Quick start

```dart
import 'package:short_video_kit/short_video_kit.dart';

final result = await ShortVideoKit.capture(context);
if (result != null) {
  // result.file — the .mp4 on disk
  // result.duration — how long the clip is
}
```

Pass `source: CaptureSource.record` or `CaptureSource.gallery` to skip the chooser.

### Use the widgets directly

```dart
ShortVideoRecorder(
  maxDuration: const Duration(seconds: 30),
  onRecorded: (r) => Navigator.pop(context, r),
  onPermissionDenied: () => showMySettingsDialog(),
);

VideoTrimmerView(
  maxDuration: const Duration(seconds: 15),
  onTrimmed: (r) => Navigator.pop(context, r),
);

ShortVideoPreview(file: result.file); // looping, tap to play/pause
```

### Theme it

```dart
ShortVideoKit.capture(
  context,
  theme: const ShortVideoTheme(
    accentColor: Colors.teal,
    recordRingColor: Colors.teal,
  ),
);
```

## 🔧 Platform setup

> This is the step most video packages skip — and the #1 cause of runtime crashes.

**Android** — `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

Minimum `minSdkVersion 21`.

**iOS** — `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Record short videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Record audio with your videos.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Pick videos to trim.</string>
```

`short_video_kit` uses [`permission_handler`](https://pub.dev/packages/permission_handler).
On iOS add the matching macros to your `ios/Podfile` (`PERMISSION_CAMERA`,
`PERMISSION_MICROPHONE`, `PERMISSION_PHOTOS`) — see its install notes.

## 📚 API

| Symbol | What it does |
|--------|--------------|
| `ShortVideoKit.capture(context, …)` | One-call flow → `Future<ShortVideoResult?>` |
| `ShortVideoRecorder` | Camera widget with countdown ring, flip & flash |
| `VideoTrimmerView` | Gallery picker + trimmer |
| `ShortVideoPreview` | Looping play/pause preview player |
| `ShortVideoResult` | `{ File file; Duration duration; }` |
| `ShortVideoTheme` | Colors & styling |
| `CaptureSource` | `record` · `gallery` · `recordOrGallery` |

A full example lives in [`example/`](example/lib/main.dart).

## 🤝 Contributing

PRs and issues welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

⭐ **If this saved you a day of plumbing, a star genuinely helps others find it.**

## 📝 License

MIT © profsikandarkhan
