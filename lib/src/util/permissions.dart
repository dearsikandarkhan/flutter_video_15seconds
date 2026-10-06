import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around [permission_handler] for the permissions this package
/// needs, so callers never have to depend on it directly.
///
/// See the README "Platform setup" section for the manifest / Info.plist
/// entries these requests rely on.
class ShortVideoPermissions {
  const ShortVideoPermissions._();

  /// Requests camera + microphone access (needed to record with audio).
  ///
  /// Returns `true` only if both are granted.
  static Future<bool> requestForRecording() async {
    final statuses = await [Permission.camera, Permission.microphone].request();
    return statuses.values.every((s) => s.isGranted);
  }

  /// Requests the permission needed to read videos from the gallery.
  ///
  /// `image_picker` uses the native photo picker on modern OS versions, which
  /// often needs no explicit permission; this is a best-effort request that
  /// treats a limited grant as success and never blocks the picker.
  static Future<bool> requestForGallery() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited || status.isRestricted;
  }
}
