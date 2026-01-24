import 'damage_type.dart';

class ClaimData {
  String farmerName;
  String policyId;
  String cropType;
  double landArea;
  String village;
  String? district;
  String? state;
  String? season;
  String? year;
  String? incidentType;
  DamageType damageType; // New field for damage type

  ClaimData({
    this.farmerName = '',
    this.policyId = '',
    this.cropType = '',
    this.landArea = 0.0,
    this.village = '',
    this.district,
    this.state,
    this.season,
    this.year,
    this.incidentType,
    this.damageType = DamageType.disease, // Default to disease
  });

  /// Returns damage category: Disease or Natural Calamity
  String get damageCategory => damageType.category;
}

class FieldBoundary {
  final List<LatLng> points;
  final double areaInAcres;

  FieldBoundary({required this.points, required this.areaInAcres});
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

class CaptureMetadata {
  final String imagePath;
  final LatLng location;
  final DateTime timestamp;
  final int captureIndex;

  CaptureMetadata({
    required this.imagePath,
    required this.location,
    required this.timestamp,
    required this.captureIndex,
  });
}
