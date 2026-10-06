import 'dart:io';

/// The outcome of a capture or trim flow.
///
/// Returned by [ShortVideoKit.capture], and by the `onRecorded` / `onTrimmed`
/// callbacks of [ShortVideoRecorder] and [VideoTrimmerView].
class ShortVideoResult {
  /// Creates a result pointing at [file] with the given [duration].
  const ShortVideoResult({required this.file, required this.duration});

  /// The resulting video file on disk (an `.mp4` in a temporary directory).
  ///
  /// Move it somewhere permanent if you need it to survive app restarts —
  /// the OS may reclaim temporary files at any time.
  final File file;

  /// The duration of the resulting clip.
  final Duration duration;

  /// The absolute path of [file]. Convenience for `file.path`.
  String get path => file.path;

  @override
  String toString() =>
      'ShortVideoResult(path: ${file.path}, duration: $duration)';
}

/// How a capture flow lets the user supply a video.
enum CaptureSource {
  /// Record a new clip with the camera.
  record,

  /// Pick an existing clip from the gallery and trim it.
  gallery,

  /// Offer both options and let the user choose.
  recordOrGallery,
}
