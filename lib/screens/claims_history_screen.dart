import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

/// Claims History Screen - Shows all submitted claims
class ClaimsHistoryScreen extends StatelessWidget {
  const ClaimsHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);
    final claims = appState.submittedClaims;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('my_claims')),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const AppDrawer(),
      body: claims.isEmpty
          ? _buildEmptyState(t)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: claims.length,
              itemBuilder: (context, index) {
                final claim = claims[index];
                return _buildClaimCard(context, claim, t);
              },
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            t.get('no_claims_title'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.get('no_claims_subtitle'),
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context, claim, AppLocalizations t) {
    // Get  status color
    Color statusColor;
    String localizedStatus;
    switch (claim.status) {
      case 'Approved':
        statusColor = Colors.green;
        localizedStatus = t.get('approved');
        break;
      case 'Rejected':
        statusColor = Colors.red;
        localizedStatus = t.get('rejected');
        break;
      case 'Under Review':
        statusColor = Colors.orange;
        localizedStatus = t.get('under_review');
        break;
      default:
        statusColor = Colors.blue;
        localizedStatus = claim.status; // Fallback if status is not localized
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showClaimDetails(context, claim, t),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Claim ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    claim.claimId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      localizedStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Claim Details
              _buildInfoRow(
                Icons.grass,
                t.get('crop_label'),
                claim.claimData.cropType != null
                    ? t.get('crop_${claim.claimData.cropType!.toLowerCase()}')
                    : t.get('n_a'),
              ),
              _buildInfoRow(
                Icons.landscape,
                t.get('area_label'),
                '${claim.claimData.landArea ?? 0} ${t.get('acres_label')}',
              ),
              _buildInfoRow(
                Icons.location_on,
                t.get('village_label'),
                claim.claimData.village ?? t.get('n_a'),
              ),
              _buildInfoRow(
                Icons.calendar_today,
                t.get('submitted_label'),
                '${claim.formattedDate} ${t.get('at_separator')} ${claim.formattedTime}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showClaimDetails(BuildContext context, claim, AppLocalizations t) {
    String localizedStatus;
    switch (claim.status) {
      case 'Approved':
        localizedStatus = t.get('approved');
        break;
      case 'Rejected':
        localizedStatus = t.get('rejected');
        break;
      case 'Under Review':
        localizedStatus = t.get('under_review');
        break;
      default:
        localizedStatus = claim.status;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(claim.claimId),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(t.get('status_label'), localizedStatus),
              _buildDetailRow(
                t.get('crop_type_label'),
                claim.claimData.cropType != null
                    ? t.get('crop_${claim.claimData.cropType!.toLowerCase()}')
                    : t.get('n_a'),
              ),
              _buildDetailRow(
                t.get('land_area_label'),
                '${claim.claimData.landArea ?? 0} ${t.get('acres_label')}',
              ),
              _buildDetailRow(
                t.get('village_label'),
                claim.claimData.village ?? t.get('n_a'),
              ),
              _buildDetailRow(
                t.get('district'),
                claim.claimData.district ?? t.get('n_a'),
              ),
              _buildDetailRow(
                t.get('state_label'),
                claim.claimData.state ?? t.get('n_a'),
              ),
              _buildDetailRow(
                t.get('season'),
                claim.claimData.season ?? t.get('n_a'),
              ),
              _buildDetailRow(
                t.get('year_label'),
                claim.claimData.year ?? t.get('n_a'),
              ),
              _buildDetailRow(
                t.get('incident_type'),
                claim.claimData.incidentType ?? t.get('n_a'),
              ),
              _buildDetailRow(
                t.get('submitted_label'),
                '${claim.formattedDate} ${t.get('at_separator')} ${claim.formattedTime}',
              ),
              if (claim.aiResult != null) ...[
                const Divider(),
                Text(
                  t.get('ai_analysis_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  t.get('overall_damage_label'),
                  '${claim.aiResult!.damage.overallFieldLossPercentage.toStringAsFixed(1)}%',
                ),
                if (claim.aiResult!.disease != null)
                  _buildDetailRow(
                    t.get('confidence_label'),
                    '${(claim.aiResult!.disease!.confidence * 100).toStringAsFixed(0)}%',
                  ),
                if (claim.aiResult!.damage.severityLevel != null)
                  _buildDetailRow(
                    t.get('severity_label'),
                    claim.aiResult!.damage.severityLevel!,
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.get('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
