import 'dart:math';
import '../models/claim_data.dart';

class GPSService {
  // Mock GPS coordinates for different regions in India
  static final Random _random = Random();

  // Mock current location
  static LatLng getMockLocation() {
    // Simulating location in rural India (example: near Pune, Maharashtra)
    double baseLat = 18.5204 + (_random.nextDouble() - 0.5) * 0.1;
    double baseLng = 73.8567 + (_random.nextDouble() - 0.5) * 0.1;
    return LatLng(baseLat, baseLng);
  }

  // Mock village name based on coordinates
  static String getVillageName(LatLng location) {
    final villages = [
      'Shirur',
      'Baramati',
      'Indapur',
      'Daund',
      'Malegaon',
      'Junnar',
      'Ambegaon',
      'Khed',
      'Mulshi',
      'Haveli',
    ];
    return villages[_random.nextInt(villages.length)];
  }

  // Calculate distance between two points (in meters)
  static double calculateDistance(LatLng point1, LatLng point2) {
    // Simple mock distance calculation
    double latDiff = (point1.latitude - point2.latitude).abs();
    double lngDiff = (point1.longitude - point2.longitude).abs();

    // Rough conversion to meters (simplified)
    double distance = sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111000;
    return distance;
  }

  // Generate mock field boundary points
  static FieldBoundary generateMockBoundary(double areaInAcres) {
    LatLng center = getMockLocation();
    List<LatLng> points = [];

    // Create a rough rectangular boundary
    double sideLength = sqrt(areaInAcres) * 0.0005; // Rough conversion

    points.add(
      LatLng(center.latitude + sideLength, center.longitude + sideLength),
    );
    points.add(
      LatLng(center.latitude + sideLength, center.longitude - sideLength),
    );
    points.add(
      LatLng(center.latitude - sideLength, center.longitude - sideLength),
    );
    points.add(
      LatLng(center.latitude - sideLength, center.longitude + sideLength),
    );

    return FieldBoundary(points: points, areaInAcres: areaInAcres);
  }

  // Check if capture location is valid (not too close to previous)
  static bool isValidCaptureLocation(
    LatLng newLocation,
    List<CaptureMetadata> previousCaptures,
  ) {
    const double minDistanceMeters = 20.0; // Minimum 20 meters apart

    for (var capture in previousCaptures) {
      double distance = calculateDistance(newLocation, capture.location);
      if (distance < minDistanceMeters) {
        return false;
      }
    }
    return true;
  }
}
