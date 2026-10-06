import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../models/short_video_result.dart';
import '../theme/short_video_theme.dart';
import '../util/permissions.dart';

/// A full-screen camera recorder that captures a clip of at most [maxDuration].
///
/// Recording auto-stops when [maxDuration] elapses; a circular ring around the
/// shutter button animates down the remaining time. Supports flipping between
/// cameras and toggling the torch.
///
/// ```dart
/// ShortVideoRecorder(
///   maxDuration: const Duration(seconds: 15),
///   onRecorded: (result) => Navigator.pop(context, result),
/// )
/// ```
class ShortVideoRecorder extends StatefulWidget {
  /// Creates a recorder.
  const ShortVideoRecorder({
    super.key,
    this.maxDuration = const Duration(seconds: 15),
    this.minDuration = Duration.zero,
    this.theme = ShortVideoTheme.fallback,
    this.onRecorded,
    this.onError,
    this.onPermissionDenied,
  });

  /// Maximum length of the recording. Recording stops automatically when this
  /// elapses. Defaults to 15 seconds.
  final Duration maxDuration;

  /// Minimum length before the user is allowed to stop manually. Defaults to
  /// zero (stop any time).
  final Duration minDuration;

  /// Visual configuration.
  final ShortVideoTheme theme;

  /// Called with the recorded clip once capture completes.
  final ValueChanged<ShortVideoResult>? onRecorded;

  /// Called if camera initialization or recording fails.
  final ValueChanged<Object>? onError;

  /// Called when the camera/microphone permission is denied.
  final VoidCallback? onPermissionDenied;

  @override
  State<ShortVideoRecorder> createState() => _ShortVideoRecorderState();
}

class _ShortVideoRecorderState extends State<ShortVideoRecorder>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _cameraIndex = 0;
  bool _isRecording = false;
  bool _torchOn = false;
  Object? _initError;

  Timer? _ticker;
  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  Future<void> _setup() async {
    final granted = await ShortVideoPermissions.requestForRecording();
    if (!granted) {
      widget.onPermissionDenied?.call();
      return;
    }
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraException('no_cameras', 'No cameras available.');
      }
      await _initController(_cameraIndex);
    } catch (e) {
      if (mounted) setState(() => _initError = e);
      widget.onError?.call(e);
    }
  }

  Future<void> _initController(int index) async {
    final previous = _controller;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: true,
    );
    await controller.initialize();
    await previous?.dispose();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _cameraIndex = index;
      _torchOn = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      if (_isRecording) _stop();
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initController(_cameraIndex);
    }
  }

  Future<void> _start() async {
    final controller = _controller;
    if (controller == null || controller.value.isRecordingVideo) return;
    try {
      await controller.startVideoRecording();
      _startedAt = DateTime.now();
      setState(() {
        _isRecording = true;
        _elapsed = Duration.zero;
      });
      _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final started = _startedAt;
        if (started == null) return;
        setState(() => _elapsed = DateTime.now().difference(started));
        if (_elapsed >= widget.maxDuration) _stop();
      });
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  Future<void> _stop() async {
    final controller = _controller;
    _ticker?.cancel();
    _ticker = null;
    if (controller == null || !controller.value.isRecordingVideo) return;
    try {
      final file = await controller.stopVideoRecording();
      final elapsed = _elapsed;
      if (mounted) setState(() => _isRecording = false);
      widget.onRecorded?.call(
        ShortVideoResult(
          file: File(file.path),
          duration: elapsed > widget.maxDuration ? widget.maxDuration : elapsed,
        ),
      );
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    try {
      await _initController((_cameraIndex + 1) % _cameras.length);
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      final next = !_torchOn;
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      setState(() => _torchOn = next);
    } catch (e) {
      widget.onError?.call(e);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return _Message('Camera unavailable:\n$_initError');
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final remaining = widget.maxDuration - _elapsed;
    final progress = widget.maxDuration.inMilliseconds == 0
        ? 0.0
        : (_elapsed.inMilliseconds / widget.maxDuration.inMilliseconds)
            .clamp(0.0, 1.0);
    final canStop = _elapsed >= widget.minDuration;

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(child: CameraPreview(controller)),
          if (_isRecording)
            Positioned(
              top: 48,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${remaining.inSeconds + 1}s',
                  style: widget.theme.countdownTextStyle ??
                      const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                      ),
                ),
              ),
            ),
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: Column(
                children: [
                  _CircleIcon(
                    icon: _torchOn ? Icons.flash_on : Icons.flash_off,
                    onTap: _toggleTorch,
                    background: widget.theme.overlayColor,
                  ),
                  if (_cameras.length > 1) ...[
                    const SizedBox(height: 12),
                    _CircleIcon(
                      icon: Icons.flip_camera_ios_rounded,
                      onTap: _isRecording ? null : _flipCamera,
                      background: widget.theme.overlayColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Center(
                child: GestureDetector(
                  onTap: _isRecording ? (canStop ? _stop : null) : _start,
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: CustomPaint(
                      painter: _CountdownRingPainter(
                        progress: progress,
                        ringColor: widget.theme.recordRingColor,
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isRecording ? 32 : 64,
                          height: _isRecording ? 32 : 64,
                          decoration: BoxDecoration(
                            color: _isRecording
                                ? widget.theme.recordRingColor
                                : widget.theme.recordButtonColor,
                            borderRadius: BorderRadius.circular(
                              _isRecording ? 8 : 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  _CountdownRingPainter({required this.progress, required this.ringColor});

  final double progress;
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 3;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.white.withValues(alpha: 0.4);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = ringColor;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963267948966, // -pi/2, start at top
      6.283185307179586 * progress, // 2*pi * progress
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_CountdownRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.ringColor != ringColor;
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.onTap,
    required this.background,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(
          icon,
          color: onTap == null ? Colors.white38 : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    );
  }
}
