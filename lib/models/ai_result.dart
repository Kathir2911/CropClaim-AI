class AIResult {
  final String detectedCrop;
  final DiseaseDetection disease;
  final DamageAssessment damage;

  AIResult({
    required this.detectedCrop,
    required this.disease,
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

  DamageAssessment({
    required this.areaAffectedAcres,
    required this.totalAreaAcres,
    required this.averageDamagePercentage,
    required this.overallFieldLossPercentage,
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
