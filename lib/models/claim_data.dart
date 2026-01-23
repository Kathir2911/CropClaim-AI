class ClaimData {
  String farmerName;
  String policyId;
  String cropType;
  double landArea;
  String village;

  ClaimData({
    this.farmerName = '',
    this.policyId = '',
    this.cropType = '',
    this.landArea = 0.0,
    this.village = '',
  });
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
