import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_mode.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/header_widget.dart';

class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('app_name')),
        actions: [
          // Language switcher button
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: t.get('select_language'),
            onPressed: () {
              Navigator.pushNamed(context, '/language');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWidget(
                title: t.get('select_mode'),
                subtitle: t.get('choose_language'),
              ),

              const SizedBox(height: 32),

              // Mode selection cards
              Expanded(
                child: ListView(
                  children: [
                    _ModeCard(
                      icon: '👨‍🌾',
                      title: t.get('farmer'),
                      description: t.get('farmer_desc'),
                      onTap: () => _selectMode(context, UserMode.farmer),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      icon: '🏢',
                      title: t.get('operator'),
                      description: t.get('operator_desc'),
                      onTap: () => _selectMode(context, UserMode.cscOperator),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      icon: '🔍',
                      title: t.get('agent'),
                      description: t.get('agent_desc'),
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
    appState.setUserSession(mode);

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
  final String icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      description,
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
}
