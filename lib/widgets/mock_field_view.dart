import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MockFieldView extends StatefulWidget {
  const MockFieldView({super.key});

  @override
  State<MockFieldView> createState() => _MockFieldViewState();
}

class _MockFieldViewState extends State<MockFieldView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF87CEEB), // Sky blue
            const Color(0xFF98D98E), // Light green
            AppTheme.accentColor, // Dark green
            const Color(0xFF6B8E23), // Olive green
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Ground texture lines
          ...List.generate(20, (index) {
            return Positioned(
              bottom: index * 30.0,
              left: 0,
              right: 0,
              child: Container(height: 1, color: Colors.white.withOpacity(0.1)),
            );
          }),

          // Crop patches (simulating plants)
          Positioned(bottom: 100, left: 50, child: _CropPatch()),
          Positioned(bottom: 150, right: 80, child: _CropPatch()),
          Positioned(bottom: 80, left: 150, child: _CropPatch()),
          Positioned(bottom: 200, right: 120, child: _CropPatch()),

          // Scanning line animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: _controller.value * MediaQuery.of(context).size.height,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.accentColor.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Center text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Camera Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CropPatch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade700, Colors.green.shade900],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: CustomPaint(painter: _LeafPainter()),
    );
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade400
      ..style = PaintingStyle.fill;

    // Draw simple leaf shapes
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final y = size.height * 0.3 + (i * 15);
      path.moveTo(size.width * 0.5, y);
      path.quadraticBezierTo(size.width * 0.3, y - 10, size.width * 0.2, y - 5);
      path.moveTo(size.width * 0.5, y);
      path.quadraticBezierTo(size.width * 0.7, y - 10, size.width * 0.8, y - 5);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
