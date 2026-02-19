import '../models/claim_data.dart';

/// Web stub for ImageWatermarkService — no watermarking on web.
class ImageWatermarkService {
  /// On web, just returns the original path unchanged.
  static Future<String> watermarkAndSave({
    required String imagePath,
    required LatLng location,
    required DateTime timestamp,
    required int captureIndex,
    required String claimId,
  }) async {
    // No watermarking on web — return original path
    return imagePath;
  }
}
