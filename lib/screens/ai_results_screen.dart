import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
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
    final aiResult = appState.aiResult;

    if (aiResult == null) {
      return const Scaffold(body: Center(child: Text('No results available')));
    }

    final disease = aiResult.disease;
    final damage = aiResult.damage;

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Results')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const HeaderWidget(
              title: 'AI Analysis Complete',
              subtitle: 'Review the detected disease and damage assessment',
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
                                'Crop Detected',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                aiResult.detectedCrop,
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 32),

                    // Disease info
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
                                'Disease Detected',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                disease!.diseaseName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: AppTheme.errorColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                disease!.description,
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
                                'Confidence Score',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: disease!.confidence,
                                minHeight: 12,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  disease!.confidence >= 0.85
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${(disease!.confidence * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: disease!.confidence >= 0.85
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                              ),
                        ),
                      ],
                    ),
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
                      'Annotated Image',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  MockAnnotatedImage(
                    cropType: aiResult.detectedCrop,
                    disease: disease?.diseaseName ?? 'N/A',
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
                      'Damage Statistics',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),

                    _StatRow(
                      label: 'Area Affected',
                      value:
                          '${damage.areaAffectedAcres.toStringAsFixed(1)} / ${damage.totalAreaAcres.toStringAsFixed(1)} acres',
                      icon: Icons.location_on,
                    ),
                    const Divider(height: 24),

                    _StatRow(
                      label: 'Avg Damage in Affected Area',
                      value:
                          '${damage.averageDamagePercentage.toStringAsFixed(1)}%',
                      icon: Icons.percent,
                      valueColor: AppTheme.errorColor,
                    ),
                    const Divider(height: 24),

                    _StatRow(
                      label: 'Overall Field Loss',
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
              text: 'Generate Claim Report',
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
