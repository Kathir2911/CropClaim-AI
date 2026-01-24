import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/mode_selection_screen.dart';
import 'screens/auth/farmer_auth_screen.dart';
import 'screens/auth/operator_auth_screen.dart';
import 'screens/auth/agent_auth_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/claims_history_screen.dart';
import 'screens/claim_details_screen.dart';
import 'screens/field_boundary_screen.dart';
import 'screens/guided_capture_screen.dart';
import 'screens/capture_progress_screen.dart';
import 'screens/ai_processing_screen.dart';
import 'screens/ai_results_screen.dart';
import 'screens/pmfby_claim_logic_screen.dart';
import 'screens/claim_report_screen.dart';
import 'screens/manage_requests_screen.dart';
import 'guards/auth_guard.dart';
import 'guards/role_guard.dart';
import 'models/user_mode.dart';

void main() {
  runApp(const CropClaimApp());
}

class CropClaimApp extends StatelessWidget {
  const CropClaimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'CropClaim AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/mode-selection': (context) => const ModeSelectionScreen(),
          '/auth/farmer': (context) => const FarmerAuthScreen(),
          '/auth/operator': (context) => const OperatorAuthScreen(),
          '/auth/agent': (context) => const AgentAuthScreen(),

          // Protected routes - require authentication
          '/profile': (context) => const AuthGuard(child: ProfileScreen()),
          '/claims-history': (context) =>
              const AuthGuard(child: ClaimsHistoryScreen()),
          '/claim-details': (context) =>
              const AuthGuard(child: ClaimDetailsScreen()),
          '/field-boundary': (context) =>
              const AuthGuard(child: FieldBoundaryScreen()),
          '/guided-capture': (context) =>
              const AuthGuard(child: GuidedCaptureScreen()),
          '/capture-progress': (context) =>
              const AuthGuard(child: CaptureProgressScreen()),
          '/ai-processing': (context) =>
              const AuthGuard(child: AIProcessingScreen()),
          '/ai-results': (context) => const AuthGuard(child: AIResultsScreen()),
          '/pmfby-logic': (context) =>
              const AuthGuard(child: PMFBYClaimLogicScreen()),
          '/claim-report': (context) =>
              const AuthGuard(child: ClaimReportScreen()),

          // Role-restricted route - operators and agents only
          '/manage-requests': (context) => const AuthGuard(
            child: RoleGuard(
              allowedRoles: [UserMode.cscOperator, UserMode.insuranceAgent],
              child: ManageRequestsScreen(),
            ),
          ),
        },
      ),
    );
  }
}
