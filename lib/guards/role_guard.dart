import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/user_mode.dart';

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
        final userMode = appState.userSession?.mode;

        // Check if user's role is in the allowed list
        final hasAccess = userMode != null && allowedRoles.contains(userMode);

        if (!hasAccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Show access denied message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.block, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Access restricted to your role',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );

            // Redirect to default route or claim details
            final targetRoute = redirectRoute ?? '/claim-details';
            Navigator.pushReplacementNamed(context, targetRoute);
          });

          // Show loading screen while redirecting
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Access Denied',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Redirecting...'),
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
