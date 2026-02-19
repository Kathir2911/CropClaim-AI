import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/claim_data.dart';

/// Mobile implementation — applies GPS watermark to captured images
/// and saves them to a dedicated folder.
class ImageWatermarkService {
  /// Apply GPS watermark to an image and save to dedicated folder.
  /// Returns the path of the watermarked image.
  static Future<String> watermarkAndSave({
    required String imagePath,
    required LatLng location,
    required DateTime timestamp,
    required int captureIndex,
    required String claimId,
  }) async {
    try {
      // Read the original image
      final File originalFile = File(imagePath);
      if (!await originalFile.exists()) return imagePath;

      final Uint8List imageBytes = await originalFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(imageBytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image originalImage = frame.image;

      // Create a canvas to draw watermark on top of the image
      final int width = originalImage.width;
      final int height = originalImage.height;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      // Draw original image
      canvas.drawImage(originalImage, Offset.zero, Paint());

      // --- Draw watermark bar at the bottom ---
      final double barHeight = height * 0.08; // 8% of image height
      final double barTop = height - barHeight;

      // Semi-transparent black background
      final Paint barPaint = Paint()
        ..color = const Color(0xCC000000); // 80% opacity black
      canvas.drawRect(
        Rect.fromLTWH(0, barTop, width.toDouble(), barHeight),
        barPaint,
      );

      // --- Draw text ---
      final double fontSize = barHeight * 0.28;
      final double padding = width * 0.02;

      // Line 1: GPS Coordinates
      final String coordsText =
          'GPS: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      _drawText(
        canvas,
        coordsText,
        padding,
        barTop + padding,
        fontSize,
        width.toDouble(),
      );

      // Line 2: Timestamp + Capture Index
      final String timeText =
          '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} '
          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}'
          '  |  Capture #$captureIndex';
      _drawText(
        canvas,
        timeText,
        padding,
        barTop + padding + fontSize + 4,
        fontSize,
        width.toDouble(),
      );

      // Line 3: Claim ID
      final String claimText = 'Claim: $claimId';
      _drawText(
        canvas,
        claimText,
        padding,
        barTop + padding + (fontSize + 4) * 2,
        fontSize * 0.85,
        width.toDouble(),
      );

      // Render the picture
      final ui.Picture picture = recorder.endRecording();
      final ui.Image watermarkedImage = await picture.toImage(width, height);
      final ByteData? byteData = await watermarkedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) return imagePath;

      // --- Save to dedicated folder ---
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String claimFolder =
          '${appDir.path}${Platform.pathSeparator}CropClaimAI${Platform.pathSeparator}$claimId';

      await Directory(claimFolder).create(recursive: true);

      final String fileName =
          'capture_${captureIndex}_${timestamp.millisecondsSinceEpoch}.jpg';
      final String savePath = '$claimFolder${Platform.pathSeparator}$fileName';

      final File savedFile = File(savePath);
      await savedFile.writeAsBytes(byteData.buffer.asUint8List());

      // Clean up
      originalImage.dispose();
      watermarkedImage.dispose();

      return savedFile.path;
    } catch (e) {
      // On any error, return original path without watermark
      return imagePath;
    }
  }

  /// Helper to draw white text on the canvas.
  static void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    double fontSize,
    double maxWidth,
  ) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.left,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    builder.pushStyle(
      ui.TextStyle(
        color: const Color(0xFFFFFFFF), // White text
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    );
    builder.addText(text);
    builder.pop();

    final ui.Paragraph paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: maxWidth - x * 2));
    canvas.drawParagraph(paragraph, Offset(x, y));
  }
}
