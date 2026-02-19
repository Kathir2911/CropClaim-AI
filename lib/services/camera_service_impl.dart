import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Mobile implementation of CameraService using the real camera package.
/// This file is only loaded on platforms where dart:io is available (Android/iOS).
class CameraService {
  static CameraService? _instance;
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  String? _errorMessage;

  CameraService._();

  static CameraService get instance {
    _instance ??= CameraService._();
    return _instance!;
  }

  /// Whether the camera is ready to use.
  bool get isInitialized => _isInitialized;

  /// Error message if initialization failed.
  String? get errorMessage => _errorMessage;

  /// Returns a live camera preview widget, or null if not initialized.
  Widget? get previewWidget {
    if (!_isInitialized || _controller == null) return null;
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize?.height ?? 1,
            height: _controller!.value.previewSize?.width ?? 1,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  /// Initialize the camera.
  /// Returns true if successful, false if camera is unavailable.
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        _errorMessage = 'No cameras available on this device';
        return false;
      }

      // Prefer back-facing camera for crop photos
      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
      _errorMessage = null;
      return true;
    } on CameraException catch (e) {
      _errorMessage = 'Camera error: ${e.description}';
      _isInitialized = false;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to initialize camera: $e';
      _isInitialized = false;
      return false;
    }
  }

  /// Take a picture and return the file path.
  Future<String?> takePicture() async {
    if (!_isInitialized || _controller == null) return null;
    if (_controller!.value.isTakingPicture) return null;

    try {
      final XFile photo = await _controller!.takePicture();
      return photo.path;
    } on CameraException catch (e) {
      _errorMessage = 'Failed to capture: ${e.description}';
      return null;
    } catch (e) {
      _errorMessage = 'Failed to save photo: $e';
      return null;
    }
  }

  /// Dispose the camera controller.
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    _isInitialized = false;
  }

  /// Fully reset the singleton.
  static Future<void> reset() async {
    if (_instance != null) {
      await _instance!.dispose();
      _instance = null;
    }
  }
}
