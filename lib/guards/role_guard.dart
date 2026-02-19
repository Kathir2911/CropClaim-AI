import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/user_mode.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

/// Guard widget that restricts access based on user role
/// Shows access denied message and redirects if role not allowed
class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<UserMode> allowedRoles;
  final String? redirectRoute;

  const RoleGuard({
    Key? key,
    required this.child,
    required this.allowedRoles,
    this.redirectRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final locale = Provider.of<LocaleProvider>(context);
        final t = AppLocalizations(locale.languageCode);
        final userMode = appState.userSession?.mode;

        // Check if user's role is in the allowed list
        final hasAccess = userMode != null && allowedRoles.contains(userMode);

        if (!hasAccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Show access denied message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.block, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      t.get('access_restricted'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );

            // Redirect to default route or claim details
            final targetRoute = redirectRoute ?? '/claim-details';
            Navigator.pushReplacementNamed(context, targetRoute);
          });

          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    t.get('access_denied'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(t.get('redirecting')),
                ],
              ),
            ),
          );
        }

        // User has access, show the protected content
        return child;
      },
    );
  }
}
