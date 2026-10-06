import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../models/short_video_result.dart';
import '../theme/short_video_theme.dart';
import '../util/permissions.dart';

/// Picks a video from the gallery and lets the user trim it to at most
/// [maxDuration] before returning the trimmed clip.
///
/// ```dart
/// VideoTrimmerView(
///   maxDuration: const Duration(seconds: 15),
///   onTrimmed: (result) => Navigator.pop(context, result),
/// )
/// ```
class VideoTrimmerView extends StatefulWidget {
  /// Creates a trimmer view. The gallery picker opens automatically on mount.
  const VideoTrimmerView({
    super.key,
    this.maxDuration = const Duration(seconds: 15),
    this.theme = ShortVideoTheme.fallback,
    this.onTrimmed,
    this.onCancelled,
    this.onError,
    this.onPermissionDenied,
  });

  /// Maximum selectable length of the trimmed clip. Defaults to 15 seconds.
  final Duration maxDuration;

  /// Visual configuration.
  final ShortVideoTheme theme;

  /// Called with the trimmed clip once the user saves.
  final ValueChanged<ShortVideoResult>? onTrimmed;

  /// Called if the user dismisses the picker without choosing a video.
  final VoidCallback? onCancelled;

  /// Called if loading or saving the video fails.
  final ValueChanged<Object>? onError;

  /// Called when gallery access is denied.
  final VoidCallback? onPermissionDenied;

  @override
  State<VideoTrimmerView> createState() => _VideoTrimmerViewState();
}

class _VideoTrimmerViewState extends State<VideoTrimmerView> {
  final Trimmer _trimmer = Trimmer();
  bool _loaded = false;
  bool _saving = false;
  double _startMs = 0;
  double _endMs = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pick());
  }

  Future<void> _pick() async {
    try {
      final granted = await ShortVideoPermissions.requestForGallery();
      if (!granted) {
        widget.onPermissionDenied?.call();
        return;
      }
      final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (picked == null) {
        widget.onCancelled?.call();
        return;
      }
      await _trimmer.loadVideo(videoFile: File(picked.path));
      if (mounted) setState(() => _loaded = true);
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _trimmer.saveTrimmedVideo(
        startValue: _startMs,
        endValue: _endMs > _startMs
            ? _endMs
            : _startMs + widget.maxDuration.inMilliseconds,
        onSave: (path) {
          if (!mounted) return;
          setState(() => _saving = false);
          if (path == null) {
            widget.onError?.call(StateError('Trimmer returned no path.'));
            return;
          }
          widget.onTrimmed?.call(
            ShortVideoResult(
              file: File(path),
              duration: Duration(
                milliseconds: ((_endMs - _startMs).abs()).round(),
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      widget.onError?.call(e);
    }
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Expanded(child: VideoViewer(trimmer: _trimmer)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TrimViewer(
            trimmer: _trimmer,
            viewerHeight: 50,
            viewerWidth: MediaQuery.of(context).size.width,
            maxVideoLength: widget.maxDuration,
            durationStyle: DurationStyle.FORMAT_MM_SS,
            editorProperties: TrimEditorProperties(
              borderPaintColor: widget.theme.accentColor,
              borderWidth: 4,
              borderRadius: 12,
            ),
            onChangeStart: (v) => _startMs = v,
            onChangeEnd: (v) => _endMs = v,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: widget.theme.accentColor,
            ),
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_saving ? 'Saving…' : 'Use this clip'),
          ),
        ),
      ],
    );
  }
}
