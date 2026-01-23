import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/claim_data.dart';
import '../providers/app_state.dart';
import '../services/gps_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mock_field_view.dart';

class GuidedCaptureScreen extends StatefulWidget {
  const GuidedCaptureScreen({super.key});

  @override
  State<GuidedCaptureScreen> createState() => _GuidedCaptureScreenState();
}

class _GuidedCaptureScreenState extends State<GuidedCaptureScreen> {
  bool _gpsLocked = true;
  bool _canCapture = true;
  String _instruction = 'Move closer to crop';

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final captureCount = appState.capturedImages.length;
    final requiredCount = appState.requiredCaptureCount;
    final progress = captureCount / requiredCount;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Mock camera view with realistic field simulation
            const MockFieldView(),

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
                        _instruction,
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
                          label: _gpsLocked ? 'GPS Locked' : 'GPS Searching',
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
                      child: const Text(
                        'Ensure crop fills the frame',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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

    // Mock capture location
    final location = GPSService.getMockLocation();

    // Check if location is valid (fraud prevention)
    if (!GPSService.isValidCaptureLocation(location, appState.capturedImages)) {
      setState(() {
        _canCapture = false;
        _instruction = 'Move further from last capture point';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Capture too close to previous point. Please move at least 20 meters.',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );

      // Re-enable after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _canCapture = true;
            _instruction = 'Move closer to crop';
          });
        }
      });
      return;
    }

    // Add capture
    final metadata = CaptureMetadata(
      imagePath: 'mock_image_${appState.capturedImages.length + 1}.jpg',
      location: location,
      timestamp: DateTime.now(),
      captureIndex: appState.capturedImages.length + 1,
    );

    appState.addCapturedImage(metadata);

    // Flash effect
    setState(() {
      _instruction = 'Photo captured!';
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _instruction = 'Move to next location';
      });
    }
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
