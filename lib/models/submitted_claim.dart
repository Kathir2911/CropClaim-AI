import '../models/claim_data.dart';
import '../models/ai_result.dart';

/// Represents a submitted claim with all its data
class SubmittedClaim {
  final String claimId;
  final DateTime submittedAt;
  final ClaimData claimData;
  final AIResult? aiResult;
  final dynamic calculation; // PMFBY calculation data
  final String status; // 'Submitted', 'Under Review', 'Approved', 'Rejected'

  SubmittedClaim({
    required this.claimId,
    required this.submittedAt,
    required this.claimData,
    this.aiResult,
    this.calculation,
    this.status = 'Submitted',
  });

  String get formattedDate {
    return '${submittedAt.day}/${submittedAt.month}/${submittedAt.year}';
  }

  String get formattedTime {
    return '${submittedAt.hour}:${submittedAt.minute.toString().padLeft(2, '0')}';
  }
}
