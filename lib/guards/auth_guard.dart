import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

/// Guard widget that protects routes requiring authentication
/// Redirects to mode selection if user is not authenticated
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        // Check if user is authenticated
        final isAuthenticated = appState.isAuthenticated;

        // Redirect to mode selection if not authenticated
        if (!isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mode-selection',
              (route) => false,
            );
          });

          // Show loading screen while redirecting
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is authenticated, show the protected content
        return child;
      },
    );
  }
}
