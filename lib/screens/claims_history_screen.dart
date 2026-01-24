import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

/// Claims History Screen - Shows all submitted claims
class ClaimsHistoryScreen extends StatelessWidget {
  const ClaimsHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final claims = appState.submittedClaims;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims'),
        backgroundColor: AppTheme.primaryColor,
      ),
      drawer: const AppDrawer(),
      body: claims.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: claims.length,
              itemBuilder: (context, index) {
                final claim = claims[index];
                return _buildClaimCard(context, claim);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No Claims Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your submitted claims will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context, claim) {
    // Get  status color
    Color statusColor;
    switch (claim.status) {
      case 'Approved':
        statusColor = Colors.green;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        break;
      case 'Under Review':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showClaimDetails(context, claim),
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
                      claim.status,
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
                'Crop',
                claim.claimData.cropType ?? 'N/A',
              ),
              _buildInfoRow(
                Icons.landscape,
                'Area',
                '${claim.claimData.landArea ?? 0} acres',
              ),
              _buildInfoRow(
                Icons.location_on,
                'Village',
                claim.claimData.village ?? 'N/A',
              ),
              _buildInfoRow(
                Icons.calendar_today,
                'Submitted',
                '${claim.formattedDate} at ${claim.formattedTime}',
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

  void _showClaimDetails(BuildContext context, claim) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(claim.claimId),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', claim.status),
              _buildDetailRow('Crop Type', claim.claimData.cropType ?? 'N/A'),
              _buildDetailRow(
                'Land Area',
                '${claim.claimData.landArea ?? 0} acres',
              ),
              _buildDetailRow('Village', claim.claimData.village ?? 'N/A'),
              _buildDetailRow('District', claim.claimData.district ?? 'N/A'),
              _buildDetailRow('State', claim.claimData.state ?? 'N/A'),
              _buildDetailRow('Season', claim.claimData.season ?? 'N/A'),
              _buildDetailRow('Year', claim.claimData.year ?? 'N/A'),
              _buildDetailRow(
                'Incident Type',
                claim.claimData.incidentType ?? 'N/A',
              ),
              _buildDetailRow(
                'Submitted',
                '${claim.formattedDate} ${claim.formattedTime}',
              ),
              if (claim.aiResult != null) ...[
                const Divider(),
                const Text(
                  'AI Analysis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Overall Damage',
                  '${claim.aiResult!.overallDamagePercentage}%',
                ),
                _buildDetailRow('Confidence', '${claim.aiResult!.confidence}%'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
