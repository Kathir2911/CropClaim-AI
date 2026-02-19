import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

/// User Profile/Dashboard Screen - Landing page after authentication
/// Shows user information and quick actions
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('my_profile')),
        backgroundColor: AppTheme.accentColor,
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          _buildUserInfoCard(appState, t),
          const SizedBox(height: 24),

          // Quick Actions
          _buildQuickActions(context, appState, t),
          const SizedBox(height: 24),

          // Recent Activity (if applicable)
          if (appState.canManageRequests) _buildManagementSection(context, t),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(AppState appState, AppLocalizations t) {
    String userName = t.get('user_label');
    String userRole = t.get('guest');
    List<InfoRow> userDetails = [];

    if (appState.farmerAuth != null) {
      final auth = appState.farmerAuth!;
      userName = t.get('farmer');
      userRole = t.get('pmfby_beneficiary');
      userDetails = [
        InfoRow(
          icon: Icons.phone,
          label: t.get('mobile_label'),
          value: auth.mobile,
        ),
        InfoRow(
          icon: Icons.badge,
          label: t.get('aadhaar_label'),
          value: _maskAadhaar(auth.aadhaar),
        ),
        if (auth.policyId != null)
          InfoRow(
            icon: Icons.policy,
            label: t.get('policy_id'),
            value: auth.policyId!,
          ),
        InfoRow(
          icon: Icons.calendar_today,
          label: t.get('registered_label'),
          value: _formatDate(auth.authenticatedAt),
        ),
      ];
    } else if (appState.operatorAuth != null) {
      final auth = appState.operatorAuth!;
      userName = auth.operatorName;
      userRole = t.get('operator');
      userDetails = [
        InfoRow(
          icon: Icons.badge,
          label: t.get('operator_id'),
          value: auth.cscId,
        ),
        InfoRow(
          icon: Icons.business,
          label: t.get('center_label'),
          value: auth.centerName,
        ),
        InfoRow(
          icon: Icons.phone,
          label: t.get('mobile_label'),
          value: auth.mobile,
        ),
        InfoRow(
          icon: Icons.calendar_today,
          label: t.get('login_time'),
          value: _formatDate(auth.authenticatedAt),
        ),
      ];
    } else if (appState.agentAuth != null) {
      final auth = appState.agentAuth!;
      userName = auth.agentName;
      userRole = t.get('krushi_sahayak');
      userDetails = [
        InfoRow(
          icon: Icons.badge,
          label: t.get('agent_id_label'),
          value: auth.agentId,
        ),
        InfoRow(
          icon: Icons.phone,
          label: t.get('mobile_label'),
          value: auth.mobile,
        ),
        InfoRow(
          icon: Icons.verified_user,
          label: t.get('audit_status'),
          value: auth.auditEnabled ? t.get('enabled') : t.get('disabled'),
        ),
        InfoRow(
          icon: Icons.calendar_today,
          label: t.get('login_time'),
          value: _formatDate(auth.authenticatedAt),
        ),
      ];
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentColor,
              AppTheme.accentColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          userRole,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white54, thickness: 1),
            const SizedBox(height: 12),

            // User Details
            ...userDetails.map(
              (info) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(info.icon, color: Colors.white70, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      '${info.label}: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        info.value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppState appState,
    AppLocalizations t,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.get('quick_actions'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.add_circle,
                title: t.get('new_claim'),
                subtitle: t.get('start_assessment'),
                color: AppTheme.accentColor,
                onTap: () => Navigator.pushNamed(context, '/claim-details'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.history,
                title: t.get('my_claims'),
                subtitle: t.get('view_history'),
                color: AppTheme.primaryColor,
                onTap: () {
                  // Navigate to claims history
                  Navigator.pushNamed(context, '/claims-history');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.get('management'),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.manage_accounts, color: AppTheme.accentColor),
            ),
            title: Text(
              t.get('manage_requests'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(t.get('review_verify')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/manage-requests'),
          ),
        ),
      ],
    );
  }

  String _maskAadhaar(String aadhaar) {
    if (aadhaar.length <= 4) return aadhaar;
    return 'XXXX-XXXX-${aadhaar.substring(aadhaar.length - 4)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class InfoRow {
  final IconData icon;
  final String label;
  final String value;

  InfoRow({required this.icon, required this.label, required this.value});
}
