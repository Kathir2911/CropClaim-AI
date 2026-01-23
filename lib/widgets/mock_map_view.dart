import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MockMapView extends StatelessWidget {
  final bool boundaryDefined;
  final int requiredImages;

  const MockMapView({
    super.key,
    this.boundaryDefined = false,
    this.requiredImages = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC), // Beige background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Grid pattern
          CustomPaint(painter: _GridPainter(), child: Container()),

          // Field patches (green areas)
          Positioned(
            top: 60,
            left: 40,
            child: _FieldPatch(width: 120, height: 100),
          ),
          Positioned(
            top: 80,
            right: 50,
            child: _FieldPatch(width: 100, height: 80),
          ),
          Positioned(
            bottom: 80,
            left: 60,
            child: _FieldPatch(width: 90, height: 90),
          ),
          Positioned(
            bottom: 100,
            right: 70,
            child: _FieldPatch(width: 110, height: 85),
          ),

          // Boundary outline (if defined)
          if (boundaryDefined)
            CustomPaint(painter: _BoundaryPainter(), child: Container()),

          // Capture point markers (if boundary defined)
          if (boundaryDefined) ...[
            _CaptureMarker(top: 100, left: 80, number: 1),
            _CaptureMarker(top: 120, right: 100, number: 2),
            _CaptureMarker(bottom: 150, left: 100, number: 3),
            _CaptureMarker(bottom: 130, right: 120, number: 4),
            _CaptureMarker(top: 180, left: 160, number: 5),
          ],

          // Compass
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'N',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    child: Icon(Icons.navigation, color: Colors.red, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Scale indicator
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 3, color: Colors.black),
                  const SizedBox(width: 8),
                  const Text(
                    '50m',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BoundaryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.25)
      ..lineTo(size.width * 0.75, size.height * 0.2)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width * 0.25, size.height * 0.75)
      ..close();

    canvas.drawPath(path, paint);

    // Fill with semi-transparent green
    final fillPaint = Paint()
      ..color = AppTheme.accentColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FieldPatch extends StatelessWidget {
  final double width;
  final double height;

  const _FieldPatch({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.green.shade200.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade400, width: 1),
      ),
    );
  }
}

class _CaptureMarker extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final int number;

  const _CaptureMarker({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
          ],
        ),
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
