import '../l10n/app_localizations.dart';

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

  /// Returns guidance text for image capture (English fallback)
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

  /// Returns processing text for AI analysis (English fallback)
  String get processingText {
    return this == DamageType.disease
        ? 'Analyzing crop disease patterns...'
        : 'Analyzing disaster damage extent...';
  }
}

/// Extension to provide localized strings for DamageType
extension DamageTypeLocalization on DamageType {
  /// Returns the localized display name
  String getLocalizedName(AppLocalizations t) {
    switch (this) {
      case DamageType.disease:
        return t.get('disease');
      case DamageType.flood:
        return t.get('flood');
      case DamageType.drought:
        return t.get('drought');
      case DamageType.cyclone:
        return t.get('cyclone');
      case DamageType.hailstorm:
        return t.get('hailstorm');
    }
  }

  /// Returns localized guidance text for image capture
  String getLocalizedGuidance(AppLocalizations t) {
    switch (this) {
      case DamageType.disease:
        return t.get('disease_guidance');
      case DamageType.flood:
        return t.get('flood_guidance');
      case DamageType.drought:
        return t.get('drought_guidance');
      case DamageType.cyclone:
        return t.get('cyclone_guidance');
      case DamageType.hailstorm:
        return t.get('hailstorm_guidance');
    }
  }

  /// Returns localized processing text for AI analysis
  String getLocalizedProcessingText(AppLocalizations t) {
    return this == DamageType.disease
        ? t.get('disease_processing')
        : t.get('disaster_processing');
  }
}
