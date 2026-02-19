import 'package:flutter/material.dart';

/// Web stub for CameraService.
/// Always returns false/null — camera is not supported on web.
/// The demo MockFieldView will be shown instead.
class CameraService {
  static CameraService? _instance;

  CameraService._();

  static CameraService get instance {
    _instance ??= CameraService._();
    return _instance!;
  }

  /// Always false on web.
  bool get isInitialized => false;

  /// Always null on web.
  String? get errorMessage => 'Camera not supported on web';

  /// Returns null — no camera preview on web.
  Widget? get previewWidget => null;

  /// Always returns false on web.
  Future<bool> initialize() async => false;

  /// Always returns null on web.
  Future<String?> takePicture() async => null;

  /// No-op on web.
  Future<void> dispose() async {}

  /// No-op on web.
  static Future<void> reset() async {
    _instance = null;
  }
}
