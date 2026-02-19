import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Navigation drawer with role-based menu visibility
/// Shows different menu items based on authenticated user's role
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer Header with user info
            _buildDrawerHeader(context, appState),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // "View My Claims"
                  _buildMenuItem(
                    context: context,
                    icon: Icons.assignment,
                    title: t.get('claims_history'),
                    subtitle: t.get('claims_history'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/claim-details');
                    },
                  ),

                  // "Create New Claim"
                  _buildMenuItem(
                    context: context,
                    icon: Icons.add_circle_outline,
                    title: t.get('claim_details'),
                    subtitle: t.get('farmer_desc'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/claim-details');
                    },
                  ),

                  const Divider(),

                  // "Manage Requests" - Only for Operators and Agents
                  if (appState.canManageRequests)
                    _buildMenuItem(
                      context: context,
                      icon: Icons.manage_accounts,
                      title: t.get('manage_requests'),
                      subtitle: t.get('agent_desc'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/manage-requests');
                      },
                      highlighted: true,
                    ),

                  const Divider(),

                  // Change Language
                  _buildMenuItem(
                    context: context,
                    icon: Icons.translate,
                    title: t.get('select_language'),
                    subtitle: t.get('choose_language'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/language');
                    },
                  ),

                  // Logout
                  _buildMenuItem(
                    context: context,
                    icon: Icons.logout,
                    title: t.get('logout'),
                    subtitle: t.get('logout'),
                    onTap: () => _showLogoutDialog(context, appState),
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            // Footer
            _buildDrawerFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, AppState appState) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final t = AppLocalizations(locale.languageCode);
    final roleDisplay = appState.currentRoleDisplay ?? t.get('user_role');
    String userName = t.get('guest_user');
    String userDetails = '';

    // Get user-specific details based on role
    if (appState.farmerAuth != null) {
      userName = t.get('farmer_role');
      userDetails =
          '${t.get('policy_prefix')}: ${appState.farmerAuth!.policyId ?? 'N/A'}';
    } else if (appState.operatorAuth != null) {
      userName = t.get('operator_role');
      userDetails = '${t.get('id_prefix')}: ${appState.operatorAuth!.cscId}';
    } else if (appState.agentAuth != null) {
      userName = t.get('agent_role');
      userDetails = '${t.get('id_prefix')}: ${appState.agentAuth!.agentId}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo/Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.agriculture,
              size: 40,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(height: 16),

          // User Name
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              roleDisplay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // User Details
          if (userDetails.isNotEmpty)
            Text(
              userDetails,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlighted = false,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Colors.red.shade700
        : (highlighted ? AppTheme.accentColor : Colors.grey.shade800);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: highlighted ? FontWeight.bold : FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final t = AppLocalizations(locale.languageCode);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, size: 16, color: AppTheme.accentColor),
              const SizedBox(width: 8),
              Text(
                t.get('app_name'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.get('pmfby_digital'),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final t = AppLocalizations(locale.languageCode);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.orange),
              SizedBox(width: 8),
              Text(t.get('confirm_logout')),
            ],
          ),
          content: Text(
            t.get('logout_confirm_msg'),
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                t.get('cancel'),
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Close dialog
                Navigator.pop(dialogContext);
                // Close drawer
                Navigator.pop(context);
                // Perform logout
                appState.logout();
                // Navigate to mode selection screen
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/mode-selection',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
              ),
              child: Text(t.get('logout')),
            ),
          ],
        );
      },
    );
  }
}
