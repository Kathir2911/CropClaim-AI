/// Enum representing different types of crop damage
enum DamageType {
  disease('Crop Disease / Pest'),
  flood('Flood / Waterlogging'),
  drought('Drought / Heat Stress'),
  cyclone('Cyclone / Heavy Wind'),
  hailstorm('Hailstorm / Extreme Rainfall');

  final String displayName;
  const DamageType(this.displayName);

  /// Returns the category: Disease or Natural Calamity
  String get category {
    return this == DamageType.disease ? 'Disease' : 'Natural Calamity';
  }

  /// Returns guidance text for image capture
  String get captureGuidance {
    switch (this) {
      case DamageType.disease:
        return 'Capture close-up images of affected leaves or crops';
      case DamageType.flood:
        return 'Capture wide-area images showing waterlogging or submerged crops';
      case DamageType.drought:
        return 'Capture field-wide images showing dry soil and wilting crops';
      case DamageType.cyclone:
        return 'Capture fallen or lodged crops from multiple angles';
      case DamageType.hailstorm:
        return 'Capture damaged crops and hail impact from multiple angles';
    }
  }

  /// Returns processing text for AI analysis
  String get processingText {
    return this == DamageType.disease
        ? 'Analyzing crop disease patterns...'
        : 'Analyzing disaster damage extent...';
  }
}
