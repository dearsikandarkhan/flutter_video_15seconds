/// Drop-in short-video capture for Flutter: record a duration-limited clip or
/// pick & trim one from the gallery, then preview it.
///
/// The fastest way in is the one-call [ShortVideoKit.capture]:
///
/// ```dart
/// final result = await ShortVideoKit.capture(
///   context,
///   maxDuration: const Duration(seconds: 15),
///   source: CaptureSource.recordOrGallery,
/// );
/// if (result != null) print(result.path);
/// ```
///
/// For full control, use the widgets directly: [ShortVideoRecorder],
/// [VideoTrimmerView] and [ShortVideoPreview].
library short_video_kit;

import 'package:flutter/material.dart';

import 'src/models/short_video_result.dart';
import 'src/theme/short_video_theme.dart';
import 'src/widgets/short_video_recorder.dart';
import 'src/widgets/video_trimmer_view.dart';

export 'src/models/short_video_result.dart';
export 'src/theme/short_video_theme.dart';
export 'src/widgets/short_video_preview.dart';
export 'src/widgets/short_video_recorder.dart';
export 'src/widgets/video_trimmer_view.dart';

/// Entry point for the one-call capture flow.
class ShortVideoKit {
  const ShortVideoKit._();

  /// Opens a capture flow and resolves with the chosen clip, or `null` if the
  /// user cancels or denies a permission.
  ///
  /// When [source] is [CaptureSource.recordOrGallery] a chooser sheet is shown
  /// first. Pass [CaptureSource.record] or [CaptureSource.gallery] to skip it.
  static Future<ShortVideoResult?> capture(
    BuildContext context, {
    Duration maxDuration = const Duration(seconds: 15),
    Duration minDuration = Duration.zero,
    CaptureSource source = CaptureSource.recordOrGallery,
    ShortVideoTheme theme = ShortVideoTheme.fallback,
  }) async {
    final navigator = Navigator.of(context);

    var effective = source;
    if (source == CaptureSource.recordOrGallery) {
      final chosen = await showModalBottomSheet<CaptureSource>(
        context: context,
        builder: (_) => const _SourceSheet(),
      );
      if (chosen == null) return null;
      effective = chosen;
    }

    final Widget screen = effective == CaptureSource.gallery
        ? _CaptureScaffold(
            title: 'Pick & trim',
            child: VideoTrimmerView(
              maxDuration: maxDuration,
              theme: theme,
              onTrimmed: (r) => navigator.pop(r),
              onCancelled: () => navigator.pop(),
              onError: (_) => navigator.pop(),
              onPermissionDenied: () => navigator.pop(),
            ),
          )
        : _CaptureScaffold(
            fullscreen: true,
            child: ShortVideoRecorder(
              maxDuration: maxDuration,
              minDuration: minDuration,
              theme: theme,
              onRecorded: (r) => navigator.pop(r),
              onError: (_) => navigator.pop(),
              onPermissionDenied: () => navigator.pop(),
            ),
          );

    return navigator.push<ShortVideoResult>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _CaptureScaffold extends StatelessWidget {
  const _CaptureScaffold({
    required this.child,
    this.title,
    this.fullscreen = false,
  });

  final Widget child;
  final String? title;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fullscreen ? Colors.black : null,
      extendBodyBehindAppBar: fullscreen,
      appBar: AppBar(
        title: title == null ? null : Text(title!),
        backgroundColor: fullscreen ? Colors.transparent : null,
        elevation: 0,
        foregroundColor: fullscreen ? Colors.white : null,
      ),
      body: child,
    );
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.videocam_rounded),
            title: const Text('Record a video'),
            onTap: () => Navigator.pop(context, CaptureSource.record),
          ),
          ListTile(
            leading: const Icon(Icons.video_library_rounded),
            title: const Text('Pick from gallery'),
            onTap: () => Navigator.pop(context, CaptureSource.gallery),
          ),
        ],
      ),
    );
  }
}
