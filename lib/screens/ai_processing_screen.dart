import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class AIProcessingScreen extends StatefulWidget {
  const AIProcessingScreen({super.key});

  @override
  State<AIProcessingScreen> createState() => _AIProcessingScreenState();
}

class _AIProcessingScreenState extends State<AIProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStep = 0;

  final List<String> _processingSteps = [
    'Detecting crop...',
    'Identifying disease...',
    'Calculating damage percentage...',
    'Applying PMFBY rules...',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _startProcessing();
  }

  void _startProcessing() async {
    final appState = Provider.of<AppState>(context, listen: false);

    // Animate through steps
    for (int i = 0; i < _processingSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
      }
    }

    // Perform AI analysis
    final result = await AIService.analyzeCropDamage(
      cropType: appState.claimData.cropType,
      imageCount: appState.capturedImages.length,
      totalAreaAcres: appState.claimData.landArea,
      damageType: appState.claimData.damageType, // Pass damage type
    );

    appState.setAIResult(result);

    // Navigate to results
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/ai-results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated processing indicator
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    RotationTransition(
                      turns: _animationController,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentColor,
                            width: 4,
                          ),
                        ),
                        child: CustomPaint(painter: _ArcPainter()),
                      ),
                    ),

                    // Center icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Current step indicator
              const Text(
                'Processing...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Processing steps
              ..._processingSteps.asMap().entries.map((entry) {
                final index = entry.key;
                final step = entry.value;
                final isComplete = index < _currentStep;
                final isCurrent = index == _currentStep;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // Step indicator
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isComplete
                              ? AppTheme.successColor
                              : isCurrent
                              ? AppTheme.accentColor
                              : Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isComplete ? Icons.check : Icons.circle,
                          color: Colors.white,
                          size: isComplete ? 20 : 12,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Step text
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.white70,
                            fontSize: 16,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),

                      // Loading indicator for current step
                      if (isCurrent)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 48),

              // Info text
              Text(
                'Please wait while we analyze your field images',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      0,
      3.14 * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
