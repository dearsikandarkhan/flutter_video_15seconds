import 'package:flutter/material.dart';

/// Visual configuration for the capture, trim and preview widgets.
///
/// Every field has a sensible default, so `const ShortVideoTheme()` works out
/// of the box. Override only what you need:
///
/// ```dart
/// const ShortVideoTheme(accentColor: Colors.teal, recordRingColor: Colors.teal)
/// ```
class ShortVideoTheme {
  /// Creates a theme. All parameters are optional.
  const ShortVideoTheme({
    this.accentColor = const Color(0xFFE91E63),
    this.recordRingColor = const Color(0xFFFF1744),
    this.recordButtonColor = Colors.white,
    this.countdownTextStyle,
    this.overlayColor = Colors.black54,
  });

  /// Primary accent used for the trim handles and controls.
  final Color accentColor;

  /// Color of the circular countdown ring drawn around the record button.
  final Color recordRingColor;

  /// Fill color of the idle record button.
  final Color recordButtonColor;

  /// Text style for the remaining-seconds countdown. Falls back to a bold
  /// white label when null.
  final TextStyle? countdownTextStyle;

  /// Scrim color used behind controls and loading states.
  final Color overlayColor;

  /// The default theme used when none is supplied.
  static const ShortVideoTheme fallback = ShortVideoTheme();
}
