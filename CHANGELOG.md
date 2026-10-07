# Changelog

## 0.1.1

- Widen dependency constraints to support the latest stable `camera` (0.12.x),
  `video_trimmer` (5.x) and `permission_handler` (13.x).
- Shorten the package description to meet pub.dev conventions.
- Correct the repository / homepage / issue-tracker URLs.

## 0.1.0

Initial release.

- `ShortVideoKit.capture()` one-call flow (record / gallery / chooser).
- `ShortVideoRecorder` with configurable duration, animated countdown ring,
  camera flip and torch toggle.
- `VideoTrimmerView` — gallery pick + trim to a max duration.
- `ShortVideoPreview` — looping, tap-to-play/pause preview.
- Built-in permission handling with graceful denial callbacks.
- `ShortVideoTheme` for zero-config theming.
- Android + iOS support.
