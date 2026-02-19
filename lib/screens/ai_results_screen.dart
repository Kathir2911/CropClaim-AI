import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/pmfby_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/header_widget.dart';
import '../widgets/mock_annotated_image.dart';
import '../widgets/app_drawer.dart';

class AIResultsScreen extends StatelessWidget {
  const AIResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);
    final aiResult = appState.aiResult;

    if (aiResult == null) {
      return Scaffold(body: Center(child: Text(t.get('no_results'))));
    }

    final disease = aiResult.disease;
    final damage = aiResult.damage;

    return Scaffold(
      appBar: AppBar(title: Text(t.get('analysis_results'))),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            HeaderWidget(
              title: t.get('ai_complete'),
              subtitle: t.get('ai_complete_subtitle'),
            ),

            const SizedBox(height: 24),

            // Detection result
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.grass,
                            color: AppTheme.accentColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.get('crop_detected'),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                t.get(
                                  'crop_${aiResult.detectedCrop.toLowerCase()}',
                                ),
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // Disease info OR Disaster severity info
                    if (disease != null) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.warning,
                              color: AppTheme.errorColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.get('disease_detected'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  disease.diseaseName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(color: AppTheme.errorColor),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  disease.description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Confidence score
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.get('confidence_score'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: disease.confidence,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    disease.confidence >= 0.85
                                        ? AppTheme.successColor
                                        : AppTheme.warningColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${(disease.confidence * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: disease.confidence >= 0.85
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Natural disaster severity display
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.flood,
                              color: AppTheme.warningColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.get('natural_disaster_damage'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  damage.severityLevel != null
                                      ? t.get(
                                          damage.severityLevel!.toLowerCase(),
                                        )
                                      : t.get('assessed'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(color: AppTheme.warningColor),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  t.get('disaster_assessed'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Mock annotated image
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      t.get('annotated_image'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  MockAnnotatedImage(
                    cropType: aiResult.detectedCrop,
                    disease: disease?.diseaseName ?? t.get('n_a'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Damage statistics
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('damage_statistics'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),

                    _StatRow(
                      label: t.get('area_affected'),
                      value:
                          '${damage.areaAffectedAcres.toStringAsFixed(1)} / ${damage.totalAreaAcres.toStringAsFixed(1)} ${t.get('acres_label')}',
                      icon: Icons.location_on,
                    ),
                    const Divider(height: 24),

                    _StatRow(
                      label: t.get('avg_damage'),
                      value:
                          '${damage.averageDamagePercentage.toStringAsFixed(1)}%',
                      icon: Icons.percent,
                      valueColor: AppTheme.errorColor,
                    ),
                    const Divider(height: 24),

                    _StatRow(
                      label: t.get('overall_loss'),
                      value:
                          '${damage.overallFieldLossPercentage.toStringAsFixed(1)}%',
                      icon: Icons.trending_down,
                      valueColor: AppTheme.errorColor,
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: t.get('generate_report'),
              icon: Icons.description,
              onPressed: () {
                // Calculate PMFBY before proceeding
                final calculation = PMFBYService.calculateClaim(
                  cropType: appState.claimData.cropType,
                  areaInAcres: appState.claimData.landArea,
                  damageAssessment: damage,
                );
                appState.setPMFBYCalculation(calculation);

                Navigator.pushNamed(context, '/pmfby-logic');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isHighlighted;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: valueColor ?? AppTheme.textPrimary,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
