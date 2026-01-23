import 'dart:math';
import '../models/ai_result.dart';

class AIService {
  static final Random _random = Random();

  // Mock crop types
  static const Map<String, List<String>> cropDiseases = {
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

  // Mock AI analysis
  static Future<AIResult> analyzeCropDamage({
    required String cropType,
    required int imageCount,
    required double totalAreaAcres,
  }) async {
    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 3));

    // Get random disease for the crop
    List<String> diseases = cropDiseases[cropType] ?? ['Unknown Disease'];
    String diseaseName = diseases[_random.nextInt(diseases.length)];

    // Generate mock confidence (80-95%)
    double confidence = 0.80 + _random.nextDouble() * 0.15;

    // Generate mock damage assessment
    double areaAffected =
        totalAreaAcres *
        (0.10 + _random.nextDouble() * 0.40); // 10-50% area affected
    double avgDamage =
        40 +
        _random.nextDouble() * 50; // 40-90% average damage in affected area
    double overallLoss =
        (areaAffected / totalAreaAcres) * avgDamage; // Overall field loss

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
  }

  static String _getDiseaseDescription(String diseaseName) {
    final descriptions = {
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
