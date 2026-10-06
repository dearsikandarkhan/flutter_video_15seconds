# Contributing

Thanks for helping improve **short_video_kit**!

## Getting started

```bash
git clone https://github.com/dearsikandarkhan/flutter_video_15seconds.git
cd short_video_kit
flutter pub get
cd example && flutter pub get
```

Run the example on a real device (the camera does not work on simulators/emulators
reliably):

```bash
cd example
flutter run
```

## Before you open a PR

Please make sure these pass locally — CI runs the same checks:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Guidelines

- Keep the public API small and documented (`///` on every public member).
- Prefer adding to the `example/` app when you add a feature, so it stays demoable.
- One logical change per PR; describe the motivation in the description.
- Bug reports and feature requests: use the issue templates.

By contributing you agree your work is licensed under the project's MIT license.
