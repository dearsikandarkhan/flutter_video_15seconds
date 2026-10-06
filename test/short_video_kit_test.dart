import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:short_video_kit/short_video_kit.dart';

void main() {
  group('ShortVideoResult', () {
    final result = ShortVideoResult(
      file: File('/tmp/clip.mp4'),
      duration: const Duration(seconds: 12),
    );

    test('exposes path and duration', () {
      expect(result.path, '/tmp/clip.mp4');
      expect(result.duration, const Duration(seconds: 12));
    });

    test('toString includes path and duration', () {
      expect(result.toString(), contains('/tmp/clip.mp4'));
      expect(result.toString(), contains('0:00:12'));
    });
  });

  group('CaptureSource', () {
    test('has record, gallery and recordOrGallery', () {
      expect(CaptureSource.values, hasLength(3));
      expect(CaptureSource.values, contains(CaptureSource.record));
      expect(CaptureSource.values, contains(CaptureSource.gallery));
      expect(CaptureSource.values, contains(CaptureSource.recordOrGallery));
    });
  });

  group('ShortVideoTheme', () {
    test('provides zero-config defaults', () {
      const theme = ShortVideoTheme();
      expect(theme.accentColor, isA<Color>());
      expect(theme.recordButtonColor, Colors.white);
      expect(theme.countdownTextStyle, isNull);
    });

    test('fallback is a const instance', () {
      expect(ShortVideoTheme.fallback, isA<ShortVideoTheme>());
    });

    test('overrides are respected', () {
      const theme = ShortVideoTheme(accentColor: Colors.teal);
      expect(theme.accentColor, Colors.teal);
    });
  });
}
