import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);

    if (!appState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Role Icon
          Icon(_getRoleIcon(appState), color: Colors.white, size: 20),

          const SizedBox(width: 8),

          // User Display
          Flexible(
            child: Text(
              appState.authenticatedUserDisplay ?? t.get('user_label'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Audit Badge (for agents)
          if (appState.agentAuth?.auditEnabled == true) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    t.get('audit_badge'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(width: 8),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            onPressed: () => _logout(context, appState, t),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: t.get('logout'),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(AppState appState) {
    if (appState.farmerAuth != null) return Icons.agriculture;
    if (appState.operatorAuth != null) return Icons.business;
    if (appState.agentAuth != null) return Icons.badge;
    return Icons.person;
  }

  void _logout(BuildContext context, AppState appState, AppLocalizations t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.get('confirm_logout')),
        content: Text(t.get('logout_confirm_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              appState.logout();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: Text(
              t.get('logout'),
              style: const TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
