import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

/// Screen for managing claim verification requests
/// Only accessible to CSC Operators and Insurance Agents
class ManageRequestsScreen extends StatelessWidget {
  const ManageRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.get('manage_requests'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.accentColor,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          _buildHeader(appState, t),
          const SizedBox(height: 24),

          // Pending Requests Section
          _buildSectionHeader(t.get('pending_requests'), Icons.pending_actions),
          const SizedBox(height: 12),
          _buildRequestCard(
            claimId: 'CLM-2024-001',
            farmerName: 'Rajesh Kumar',
            cropType: 'Wheat',
            damagePercent: 45,
            status: t.get('pending_review'),
            statusColor: Colors.orange,
            onTap: () => _showRequestDetails(context, 'CLM-2024-001', t),
          ),
          const SizedBox(height: 12),
          _buildRequestCard(
            claimId: 'CLM-2024-003',
            farmerName: 'Sunita Devi',
            cropType: t.get('crop_cotton'),
            damagePercent: 62,
            status: t.get('pending_review'),
            statusColor: Colors.orange,
            onTap: () => _showRequestDetails(context, 'CLM-2024-003', t),
          ),
          const SizedBox(height: 24),

          // Reviewed Requests Section
          _buildSectionHeader(
            t.get('recently_reviewed'),
            Icons.check_circle_outline,
          ),
          const SizedBox(height: 12),
          _buildRequestCard(
            claimId: 'CLM-2024-002',
            farmerName: 'Amit Singh',
            cropType: 'Rice',
            damagePercent: 38,
            status: t.get('approved'),
            statusColor: Colors.green,
            onTap: () => _showRequestDetails(context, 'CLM-2024-002', t),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppState appState, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.manage_accounts, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('claim_verification'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      appState.currentRoleDisplay != null
                          ? t.get(
                              appState.currentRoleDisplay!
                                      .toLowerCase()
                                      .replaceAll(' ', '_') +
                                  '_role',
                            )
                          : t.get('operator_role'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(t.get('pending'), '2', Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard(t.get('reviewed_label'), '1', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.accentColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildRequestCard({
    required String claimId,
    required String farmerName,
    required String cropType,
    required int damagePercent,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    claimId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    farmerName,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.grass, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    cropType,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: damagePercent / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        damagePercent > 50 ? Colors.red : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$damagePercent%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: damagePercent > 50 ? Colors.red : Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDetails(
    BuildContext context,
    String claimId,
    AppLocalizations t,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('${t.get('mock_view_title')}$claimId'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${t.get('mock_view_desc')} $claimId'),
              const SizedBox(height: 16),
              Text(t.get('production_info')),
              const SizedBox(height: 8),
              Text(
                '• ${t.get('detailed_farmer')}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '• ${t.get('ai_results_info')}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '• ${t.get('field_images')}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '• ${t.get('verification_options')}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.get('close')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$claimId ${t.get('approved').toLowerCase()}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              child: Text(t.get('approve')),
            ),
          ],
        );
      },
    );
  }
}
