import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/claim_data.dart';

/// GPS service that provides real location on mobile and mock on web.
class GPSService {
  static final Random _random = Random();

  /// Last GPS status message for display on screen
  static String lastStatus = 'Not initialized';

  /// Whether real GPS was used (true) or mock (false)
  static bool isRealGPS = false;

  /// Get current location with fast initial lock.
  /// Uses getLastKnownPosition first (instant), then getCurrentPosition for accuracy.
  static Future<LatLng> getCurrentLocation() async {
    if (kIsWeb) {
      lastStatus = 'Web platform — using demo GPS';
      isRealGPS = false;
      return getMockLocation();
    }

    try {
      // Step 1: Check if location services are enabled
      lastStatus = 'Checking location services...';
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        lastStatus =
            'Location services DISABLED. Please enable GPS in settings.';
        isRealGPS = false;
        // Try to open location settings
        await Geolocator.openLocationSettings();
        return getMockLocation();
      }

      // Step 2: Check and request permission
      lastStatus = 'Checking location permission...';
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        lastStatus = 'Requesting location permission...';
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          lastStatus = 'Location permission DENIED.';
          isRealGPS = false;
          return getMockLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        lastStatus =
            'Location PERMANENTLY DENIED. Open Settings > Apps > CropClaimAI.';
        isRealGPS = false;
        await Geolocator.openAppSettings();
        return getMockLocation();
      }

      // Step 3: Try getLastKnownPosition first (instant)
      lastStatus = 'Getting last known position...';
      Position? lastPosition = await Geolocator.getLastKnownPosition();

      if (lastPosition != null) {
        // Use last known position immediately, then try to get current in background
        lastStatus =
            'GPS OK (cached): ${lastPosition.latitude.toStringAsFixed(6)}, ${lastPosition.longitude.toStringAsFixed(6)}';
        isRealGPS = true;

        // Try to get fresh position in background (don't block UI)
        _refreshPosition();

        return LatLng(lastPosition.latitude, lastPosition.longitude);
      }

      // Step 4: No cached position — get fresh position (may take a few seconds)
      lastStatus = 'Getting GPS fix (please wait)...';
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      lastStatus =
          'GPS OK: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      isRealGPS = true;
      _lastLatLng = LatLng(position.latitude, position.longitude);
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      lastStatus = 'GPS Error: $e';
      isRealGPS = false;
      return getMockLocation();
    }
  }

  /// Cached latest position for background refresh
  static LatLng? _lastLatLng;
  static LatLng? get lastKnownLatLng => _lastLatLng;

  /// Refresh position in background (non-blocking)
  static Future<void> _refreshPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
      _lastLatLng = LatLng(position.latitude, position.longitude);
      lastStatus =
          'GPS OK (fresh): ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
    } catch (_) {
      // Silently fail — we already have last known position
    }
  }

  /// Mock GPS coordinates near Pune, Maharashtra (fallback).
  static LatLng getMockLocation() {
    double baseLat = 18.5204 + (_random.nextDouble() - 0.5) * 0.1;
    double baseLng = 73.8567 + (_random.nextDouble() - 0.5) * 0.1;
    return LatLng(baseLat, baseLng);
  }

  /// Get village name from GPS location (fallback mock names).
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

  /// Calculate distance between two points (in meters).
  static double calculateDistance(LatLng point1, LatLng point2) {
    double latDiff = (point1.latitude - point2.latitude).abs();
    double lngDiff = (point1.longitude - point2.longitude).abs();
    double distance = sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111000;
    return distance;
  }

  /// Generate field boundary points centered on real GPS location.
  static Future<FieldBoundary> generateBoundary(double areaInAcres) async {
    LatLng center = await getCurrentLocation();
    List<LatLng> points = [];
    double sideLength = sqrt(areaInAcres) * 0.0005;

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

  /// Generate mock field boundary.
  static FieldBoundary generateMockBoundary(double areaInAcres) {
    LatLng center = getMockLocation();
    List<LatLng> points = [];
    double sideLength = sqrt(areaInAcres) * 0.0005;

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

  /// Check if capture location is valid (not too close to previous).
  static bool isValidCaptureLocation(
    LatLng newLocation,
    List<CaptureMetadata> previousCaptures,
  ) {
    const double minDistanceMeters = 20.0;
    for (var capture in previousCaptures) {
      double distance = calculateDistance(newLocation, capture.location);
      if (distance < minDistanceMeters) return false;
    }
    return true;
  }
}
