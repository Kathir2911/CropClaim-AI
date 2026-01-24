import 'dart:math';
import '../models/ai_result.dart';
import '../models/claim_data.dart';
import '../models/damage_type.dart';

class AIService {
  static final Random _random = Random();

  // Mock AI analysis - adapts based on damage type
  static Future<AIResult> analyzeCropDamage({
    required String cropType,
    required int imageCount,
    required double totalAreaAcres,
    required DamageType damageType, // New parameter
  }) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 3));

    final isDiseaseType = damageType == DamageType.disease;

    if (isDiseaseType) {
      // Disease detection logic
      final diseases = _getCropDiseases(cropType);
      final diseaseName = diseases[_random.nextInt(diseases.length)];
      final confidence = 0.80 + _random.nextDouble() * 0.15;

      final areaAffected =
          totalAreaAcres * (0.10 + _random.nextDouble() * 0.40);
      final avgDamage = 40 + _random.nextDouble() * 50;
      final overallLoss = (areaAffected / totalAreaAcres) * avgDamage;

      return AIResult(
        detectedCrop: cropType,
        disease: DiseaseDetection(
          diseaseName: diseaseName,
          confidence: confidence,
          description: _getDiseaseDescription(diseaseName),
        ),
        damage: DamageAssessment(
          areaAffectedAcres: areaAffected,
          totalAreaAcres: totalAreaAcres,
          averageDamagePercentage: avgDamage,
          overallFieldLossPercentage: overallLoss,
        ),
      );
    } else {
      // Natural disaster damage assessment
      String severityLevel;
      double damagePercent;

      switch (damageType) {
        case DamageType.flood:
          damagePercent = 60 + _random.nextDouble() * 20; // 60-80%
          severityLevel = damagePercent > 70 ? 'Severe' : 'Medium';
          break;
        case DamageType.drought:
          damagePercent = 50 + _random.nextDouble() * 25; // 50-75%
          severityLevel = damagePercent > 65 ? 'Severe' : 'Medium';
          break;
        case DamageType.cyclone:
          damagePercent = 65 + _random.nextDouble() * 25; // 65-90%
          severityLevel = 'Severe';
          break;
        case DamageType.hailstorm:
          damagePercent = 55 + _random.nextDouble() * 20; // 55-75%
          severityLevel = damagePercent > 65 ? 'Severe' : 'Medium';
          break;
        default:
          damagePercent = 50.0;
          severityLevel = 'Low';
      }

      final areaAffected = totalAreaAcres * (damagePercent / 100);
      final overallLoss = damagePercent * 0.85;

      return AIResult(
        detectedCrop: cropType,
        disease: null, // No disease for disasters
        damage: DamageAssessment(
          areaAffectedAcres: areaAffected,
          totalAreaAcres: totalAreaAcres,
          averageDamagePercentage: damagePercent,
          overallFieldLossPercentage: overallLoss,
          severityLevel: severityLevel,
        ),
      );
    }
  }

  static List<String> _getCropDiseases(String cropType) {
    const cropDiseases = {
      'Rice': [
        'Bacterial Leaf Blight',
        'Brown Spot',
        'Blast Disease',
        'Sheath Blight',
      ],
      'Wheat': [
        'Rust (Yellow/Brown/Black)',
        'Powdery Mildew',
        'Smut',
        'Leaf Blight',
      ],
      'Cotton': [
        'Bacterial Blight',
        'Alternaria Leaf Spot',
        'Anthracnose',
        'Fusarium Wilt',
      ],
      'Sugarcane': ['Red Rot', 'Smut', 'Wilt', 'Grassy Shoot Disease'],
      'Maize': [
        'Common Rust',
        'Northern Corn Leaf Blight',
        'Southern Corn Leaf Blight',
        'Downy Mildew',
      ],
    };
    return cropDiseases[cropType] ?? ['Unknown Disease'];
  }

  static String _getDiseaseDescription(String diseaseName) {
    const descriptions = {
      'Bacterial Leaf Blight':
          'Water-soaked lesions on leaves, leading to wilting and drying',
      'Brown Spot': 'Brown oval spots on leaves, reducing photosynthesis',
      'Blast Disease': 'Diamond-shaped lesions on leaves and stems',
      'Sheath Blight': 'Oval lesions on leaf sheaths near waterline',
      'Rust (Yellow/Brown/Black)': 'Rust-colored pustules on leaves and stems',
      'Powdery Mildew': 'White powdery growth on leaves',
      'Smut': 'Black powdery spores replacing grain',
      'Leaf Blight': 'Brown lesions causing leaf death',
      'Bacterial Blight': 'Angular water-soaked lesions on leaves',
      'Alternaria Leaf Spot': 'Brown circular spots with concentric rings',
      'Anthracnose': 'Reddish-brown lesions on leaves and bolls',
      'Fusarium Wilt': 'Yellowing and wilting of plants',
      'Red Rot': 'Red discoloration of stem with white patches',
      'Grassy Shoot Disease': 'Excessive tillering with grassy appearance',
      'Common Rust': 'Reddish-brown pustules on leaves',
      'Northern Corn Leaf Blight': 'Long gray-green lesions on leaves',
      'Southern Corn Leaf Blight': 'Small tan spots on leaves',
      'Downy Mildew': 'White downy growth on underside of leaves',
    };

    return descriptions[diseaseName] ??
        'Disease affecting crop health and yield';
  }
}
