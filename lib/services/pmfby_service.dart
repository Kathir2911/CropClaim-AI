import '../models/ai_result.dart';

class PMFBYService {
  // PMFBY threshold - minimum 20% loss required for claim eligibility
  static const double thresholdPercentage = 20.0;

  // Calculate sum insured based on area and crop type
  static double calculateSumInsured(String cropType, double areaInAcres) {
    // Mock premium rates per acre (in INR)
    final Map<String, double> premiumPerAcre = {
      'Rice': 12000,
      'Wheat': 10000,
      'Cotton': 15000,
      'Sugarcane': 18000,
      'Maize': 11000,
      'Pulses': 9000,
      'Oilseeds': 10000,
    };

    double ratePerAcre = premiumPerAcre[cropType] ?? 10000;
    return ratePerAcre * areaInAcres;
  }

  // Calculate PMFBY claim
  static PMFBYCalculation calculateClaim({
    required String cropType,
    required double areaInAcres,
    required DamageAssessment damageAssessment,
  }) {
    double sumInsured = calculateSumInsured(cropType, areaInAcres);
    double lossPercentage = damageAssessment.overallFieldLossPercentage;

    bool isEligible = lossPercentage >= thresholdPercentage;
    double eligibleAmount = 0.0;
    String message = '';

    if (isEligible) {
      // Calculate claim amount based on loss percentage
      eligibleAmount = (sumInsured * lossPercentage / 100).roundToDouble();
      message =
          'Claim eligible. Loss exceeds PMFBY threshold of $thresholdPercentage%.';
    } else {
      message =
          'Claim not eligible. Loss (${lossPercentage.toStringAsFixed(1)}%) is below PMFBY threshold of $thresholdPercentage%.';
    }

    return PMFBYCalculation(
      sumInsured: sumInsured,
      calculatedLoss: lossPercentage,
      thresholdPercentage: thresholdPercentage,
      eligibleClaimAmount: eligibleAmount,
      isEligible: isEligible,
      message: message,
    );
  }
}
