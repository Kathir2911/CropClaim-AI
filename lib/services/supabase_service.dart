import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service for cloud storage and database.
class SupabaseService {
  static const String _supabaseUrl = 'https://udydpksximxkaivtujil.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVkeWRwa3N4aW14a2FpdnR1amlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE0ODY1MDEsImV4cCI6MjA4NzA2MjUwMX0.Rii2qRdGPa_pYtLMhuM8lHSHPSARAZErO2eb_nnPVUU';
  static const String _storageBucket = 'crop-images';

  /// Last upload status for on-screen display
  static String lastUploadStatus = '';
  static bool lastUploadSuccess = false;

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase — call once in main()
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
      lastUploadStatus = 'Supabase connected';
      debugPrint('Supabase: Initialized');
    } catch (e) {
      lastUploadStatus = 'Supabase init FAILED: $e';
      debugPrint('Supabase: Init error: $e');
    }
  }

  /// Upload an image to Supabase Storage.
  /// Returns the public URL of the uploaded image.
  static Future<String?> uploadImage({
    required String filePath,
    required String claimId,
    required int captureIndex,
  }) async {
    if (kIsWeb) {
      lastUploadStatus = 'Skipped (web)';
      lastUploadSuccess = false;
      return null;
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        lastUploadStatus = 'ERROR: File not found: $filePath';
        lastUploadSuccess = false;
        debugPrint('Supabase: $lastUploadStatus');
        return null;
      }

      final fileSize = await file.length();
      final fileName = '${claimId}/capture_$captureIndex.jpg';
      lastUploadStatus =
          'Uploading $fileName (${(fileSize / 1024).toStringAsFixed(0)}KB)...';
      debugPrint('Supabase: $lastUploadStatus');

      final fileBytes = await file.readAsBytes();

      await client.storage
          .from(_storageBucket)
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // Get public URL
      final publicUrl = client.storage
          .from(_storageBucket)
          .getPublicUrl(fileName);

      lastUploadStatus = 'Upload OK → $publicUrl';
      lastUploadSuccess = true;
      debugPrint('Supabase: $lastUploadStatus');
      return publicUrl;
    } catch (e) {
      lastUploadStatus = 'UPLOAD FAILED: $e';
      lastUploadSuccess = false;
      debugPrint('Supabase: $lastUploadStatus');
      return null;
    }
  }

  /// Save a claim record to the Supabase database.
  static Future<bool> saveClaim({
    required String claimId,
    required String farmerName,
    required String policyId,
    required String cropType,
    required double landArea,
    required String village,
    required String damageType,
    required String damageCategory,
    required List<String> imageUrls,
    required List<Map<String, double>> gpsCoordinates,
    double? aiSeverity,
    String? aiFinding,
    String status = 'Submitted',
  }) async {
    try {
      debugPrint('Supabase: Saving claim $claimId...');

      await client.from('claims').insert({
        'claim_id': claimId,
        'farmer_name': farmerName,
        'policy_id': policyId,
        'crop_type': cropType,
        'land_area': landArea,
        'village': village,
        'damage_type': damageType,
        'damage_category': damageCategory,
        'image_urls': imageUrls,
        'gps_coordinates': gpsCoordinates,
        'ai_severity': aiSeverity,
        'ai_finding': aiFinding,
        'status': status,
        'submitted_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Supabase: Claim saved successfully');
      return true;
    } catch (e) {
      debugPrint('Supabase: Save claim error: $e');
      return false;
    }
  }

  /// Fetch all claims from the database (for admin view).
  static Future<List<Map<String, dynamic>>> getClaims() async {
    try {
      final response = await client
          .from('claims')
          .select()
          .order('submitted_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase: Fetch claims error: $e');
      return [];
    }
  }

  /// Fetch images for a specific claim.
  static Future<List<String>> getClaimImages(String claimId) async {
    try {
      final response = await client
          .from('claims')
          .select('image_urls')
          .eq('claim_id', claimId)
          .single();
      return List<String>.from(response['image_urls'] ?? []);
    } catch (e) {
      debugPrint('Supabase: Fetch images error: $e');
      return [];
    }
  }
}
