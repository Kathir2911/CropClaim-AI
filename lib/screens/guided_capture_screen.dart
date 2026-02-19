import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/claim_data.dart';
import '../models/damage_type.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/camera_service.dart';
import '../services/gps_service.dart';
import '../services/image_watermark_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/camera_preview.dart';

class GuidedCaptureScreen extends StatefulWidget {
  const GuidedCaptureScreen({super.key});

  @override
  State<GuidedCaptureScreen> createState() => _GuidedCaptureScreenState();
}

class _GuidedCaptureScreenState extends State<GuidedCaptureScreen> {
  bool _gpsLocked = true;
  bool _canCapture = true;
  bool _showFlash = false;
  String _instruction = ''; // Will be set in build/effect

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);
    final captureCount = appState.capturedImages.length;
    final requiredCount = appState.requiredCaptureCount;
    final progress = captureCount / requiredCount;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Real camera preview (falls back to mock on emulator)
            const CameraPreviewWidget(),

            // Flash overlay for capture feedback
            if (_showFlash)
              Positioned.fill(
                child: Container(color: Colors.white.withOpacity(0.7)),
              ),

            // Top overlay - instructions and stats
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Column(
                  children: [
                    // Instruction
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appState.claimData.damageType.getLocalizedGuidance(t),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Capture count
                        _StatChip(
                          icon: Icons.photo_camera,
                          label: '$captureCount / $requiredCount',
                          color: progress >= 1.0
                              ? AppTheme.successColor
                              : AppTheme.primaryColor,
                        ),

                        // GPS status
                        _StatChip(
                          icon: _gpsLocked
                              ? Icons.gps_fixed
                              : Icons.gps_not_fixed,
                          label: _gpsLocked
                              ? t.get('gps_locked')
                              : t.get('gps_searching'),
                          color: _gpsLocked
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Progress bar
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0
                            ? AppTheme.successColor
                            : AppTheme.accentColor,
                      ),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
            ),

            // Center guideline/frame
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _canCapture
                        ? AppTheme.accentColor
                        : AppTheme.errorColor,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.get('ensure_crop_frame'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: _canCapture ? _captureImage : null,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _canCapture ? Colors.white : Colors.grey,
                          border: Border.all(
                            color: _canCapture
                                ? AppTheme.accentColor
                                : Colors.grey.shade600,
                            width: 4,
                          ),
                        ),
                        child: Icon(
                          Icons.camera,
                          size: 40,
                          color: _canCapture
                              ? AppTheme.accentColor
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),

                    // Progress button
                    IconButton(
                      onPressed: captureCount >= requiredCount
                          ? () => Navigator.pushNamed(
                              context,
                              '/capture-progress',
                            )
                          : null,
                      icon: Icon(
                        Icons.arrow_forward,
                        color: captureCount >= requiredCount
                            ? Colors.white
                            : Colors.grey,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _captureImage() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final t = AppLocalizations(locale.languageCode);

    // Get real GPS location (real on mobile, mock on web)
    final location = await GPSService.getCurrentLocation();

    // Check if location is valid (fraud prevention)
    if (!GPSService.isValidCaptureLocation(location, appState.capturedImages)) {
      setState(() {
        _canCapture = false;
        _instruction = t.get('move_further_msg');
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.get('too_close')),
          backgroundColor: AppTheme.errorColor,
        ),
      );

      // Re-enable after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _canCapture = true;
            _instruction = t.get('move_closer');
          });
        }
      });
      return;
    }

    // Flash effect
    setState(() {
      _showFlash = true;
      _canCapture = false;
      _instruction = t.get('processing');
    });

    final now = DateTime.now();
    final captureIndex = appState.capturedImages.length + 1;
    final claimId =
        'CLM_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.millisecondsSinceEpoch}';

    // Try real camera capture, fall back to mock path
    String imagePath;
    final realPath = await CameraService.instance.takePicture();
    if (realPath != null) {
      // Apply GPS watermark and save to dedicated folder
      imagePath = await ImageWatermarkService.watermarkAndSave(
        imagePath: realPath,
        location: location,
        timestamp: now,
        captureIndex: captureIndex,
        claimId: claimId,
      );
    } else {
      // Fallback for emulator/desktop/web
      imagePath = 'mock_image_$captureIndex.jpg';
    }

    // Upload image to Supabase Storage
    String finalPath = imagePath;
    final uploadUrl = await SupabaseService.uploadImage(
      filePath: imagePath,
      claimId: claimId,
      captureIndex: captureIndex,
    );
    if (uploadUrl != null) {
      finalPath = uploadUrl; // Use cloud URL
    }

    // Add capture metadata (with cloud URL if available)
    final metadata = CaptureMetadata(
      imagePath: finalPath,
      location: location,
      timestamp: now,
      captureIndex: captureIndex,
    );

    appState.addCapturedImage(metadata);

    // End flash
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() {
        _showFlash = false;
        _instruction =
            '${t.get('photo_captured')} | ${t.get('gps_status')}: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
      });

      // Show upload status
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uploadUrl != null
                ? '✅ ${t.get('photo_uploaded')} ($captureIndex)'
                : '⚠️ ${t.get('photo_local')} - ${SupabaseService.lastUploadStatus}',
          ),
          backgroundColor: uploadUrl != null ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _canCapture = true;
        _instruction = t.get('move_next_location');
      });
    }
  }

  @override
  void dispose() {
    // Dispose the camera when leaving this screen
    CameraService.instance.dispose();
    super.dispose();
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
