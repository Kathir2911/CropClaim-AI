class AIResult {
  final String detectedCrop;
  final DiseaseDetection? disease; // Nullable for disaster damage
  final DamageAssessment damage;

  AIResult({
    required this.detectedCrop,
    this.disease, // Optional - null for natural disasters
    required this.damage,
  });
}

class DiseaseDetection {
  final String diseaseName;
  final double confidence; // 0.0 to 1.0
  final String description;

  DiseaseDetection({
    required this.diseaseName,
    required this.confidence,
    required this.description,
  });
}

class DamageAssessment {
  final double areaAffectedAcres;
  final double totalAreaAcres;
  final double averageDamagePercentage;
  final double overallFieldLossPercentage;
  final String? severityLevel; // New: Low/Medium/Severe for disasters

  DamageAssessment({
    required this.areaAffectedAcres,
    required this.totalAreaAcres,
    required this.averageDamagePercentage,
    required this.overallFieldLossPercentage,
    this.severityLevel,
  });
}

class PMFBYCalculation {
  final double sumInsured;
  final double calculatedLoss;
  final double thresholdPercentage;
  final double eligibleClaimAmount;
  final bool isEligible;
  final String message;

  PMFBYCalculation({
    required this.sumInsured,
    required this.calculatedLoss,
    required this.thresholdPercentage,
    required this.eligibleClaimAmount,
    required this.isEligible,
    required this.message,
  });
}
