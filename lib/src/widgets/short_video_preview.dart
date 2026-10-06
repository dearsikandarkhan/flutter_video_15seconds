import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/short_video_theme.dart';

/// A looping, tap-to-play/pause preview of a local video [file].
///
/// Owns and disposes its own [VideoPlayerController], so you can drop it into
/// any layout:
///
/// ```dart
/// ShortVideoPreview(file: result.file)
/// ```
class ShortVideoPreview extends StatefulWidget {
  /// Creates a preview for [file].
  const ShortVideoPreview({
    super.key,
    required this.file,
    this.autoPlay = true,
    this.looping = true,
    this.theme = ShortVideoTheme.fallback,
  });

  /// The local video file to play.
  final File file;

  /// Whether playback starts automatically once initialized.
  final bool autoPlay;

  /// Whether playback loops when it reaches the end.
  final bool looping;

  /// Visual configuration.
  final ShortVideoTheme theme;

  @override
  State<ShortVideoPreview> createState() => _ShortVideoPreviewState();
}

class _ShortVideoPreviewState extends State<ShortVideoPreview> {
  VideoPlayerController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final controller = VideoPlayerController.file(widget.file);
    try {
      await controller.initialize();
      await controller.setLooping(widget.looping);
      if (widget.autoPlay) await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      await controller.dispose();
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void didUpdateWidget(ShortVideoPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path) {
      _controller?.dispose();
      _controller = null;
      _error = null;
      _init();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggle() {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not play video:\n$_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: _toggle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
          if (!controller.value.isPlaying)
            Icon(
              Icons.play_arrow_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.85),
            ),
        ],
      ),
    );
  }
}
