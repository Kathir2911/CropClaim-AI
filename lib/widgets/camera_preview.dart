import 'package:flutter/material.dart';
import '../services/camera_service.dart';
import 'mock_field_view.dart';

/// Camera preview widget that works on all platforms.
/// On mobile: shows real camera feed from CameraService.
/// On web/emulator: shows MockFieldView with "DEMO MODE" badge.
class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({super.key});

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  bool _loading = true;
  bool _cameraAvailable = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final success = await CameraService.instance.initialize();
      if (mounted) {
        setState(() {
          _cameraAvailable = success;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraAvailable = false;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Try to get the real camera preview from CameraService
    final preview = CameraService.instance.previewWidget;

    if (!_cameraAvailable || preview == null) {
      // Fallback: show mock view for web/emulators/desktop
      return Stack(
        children: [
          const MockFieldView(),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'DEMO MODE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Real camera preview from mobile CameraService
    return preview;
  }
}
