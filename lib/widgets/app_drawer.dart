import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

/// Navigation drawer with role-based menu visibility
/// Shows different menu items based on authenticated user's role
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

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
                  // "View My Claims" - Available to all roles
                  _buildMenuItem(
                    context: context,
                    icon: Icons.assignment,
                    title: 'View My Claims',
                    subtitle: 'See all submitted claims',
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.pushNamed(context, '/claim-details');
                    },
                  ),

                  // "Create New Claim" - Available to all roles
                  _buildMenuItem(
                    context: context,
                    icon: Icons.add_circle_outline,
                    title: 'Create New Claim',
                    subtitle: 'Start a new damage assessment',
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
                      title: 'Manage Requests',
                      subtitle: 'Review and verify claims',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/manage-requests');
                      },
                      highlighted: true,
                    ),

                  const Divider(),

                  // Logout
                  _buildMenuItem(
                    context: context,
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () => _showLogoutDialog(context, appState),
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            // Footer
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, AppState appState) {
    final roleDisplay = appState.currentRoleDisplay ?? 'User';
    String userName = 'Guest';
    String userDetails = '';

    // Get user-specific details based on role
    if (appState.farmerAuth != null) {
      userName = 'Farmer';
      userDetails = 'Policy: ${appState.farmerAuth!.policyId}';
    } else if (appState.operatorAuth != null) {
      userName = 'CSC/PACS Operator';
      userDetails = 'ID: ${appState.operatorAuth!.cscId}';
    } else if (appState.agentAuth != null) {
      userName = 'Insurance Agent';
      userDetails = 'ID: ${appState.agentAuth!.agentId}';
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

  Widget _buildDrawerFooter() {
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
                'CropClaim AI',
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
            'PMFBY Digital Solution',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.logout, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirm Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?\n\nAny unsaved progress will be lost.',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
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
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
