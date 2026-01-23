import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_mode.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/header_widget.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CropClaim AI')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderWidget(
                title: 'Who is submitting the claim?',
                subtitle: 'Select your role to continue',
              ),

              const SizedBox(height: 32),

              // Mode selection cards
              Expanded(
                child: ListView(
                  children: [
                    _ModeCard(
                      mode: UserMode.farmer,
                      onTap: () => _selectMode(context, UserMode.farmer),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      mode: UserMode.cscOperator,
                      onTap: () => _selectMode(context, UserMode.cscOperator),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      mode: UserMode.insuranceAgent,
                      onTap: () =>
                          _selectMode(context, UserMode.insuranceAgent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectMode(BuildContext context, UserMode mode) {
    final appState = Provider.of<AppState>(context, listen: false);

    // Store the selected mode
    appState.setUserSession(mode);

    // Navigate to appropriate authentication screen
    switch (mode) {
      case UserMode.farmer:
        Navigator.pushNamed(context, '/auth/farmer');
        break;
      case UserMode.cscOperator:
        Navigator.pushNamed(context, '/auth/operator');
        break;
      case UserMode.insuranceAgent:
        Navigator.pushNamed(context, '/auth/agent');
        break;
    }
  }
}

class _ModeCard extends StatelessWidget {
  final UserMode mode;
  final VoidCallback onTap;

  const _ModeCard({required this.mode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(mode.icon, style: const TextStyle(fontSize: 32)),
                ),
              ),

              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDescription(mode),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDescription(UserMode mode) {
    switch (mode) {
      case UserMode.farmer:
        return 'Submit your own claim';
      case UserMode.cscOperator:
        return 'Help farmers submit claims';
      case UserMode.insuranceAgent:
        return 'Process and verify claims';
    }
  }
}
