import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/header_widget.dart';
import '../widgets/mock_map_view.dart';
import '../widgets/app_drawer.dart';

class CaptureProgressScreen extends StatelessWidget {
  const CaptureProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);
    final capturedImages = appState.capturedImages;
    final requiredCount = appState.requiredCaptureCount;
    final progress = capturedImages.length / requiredCount;
    final isComplete = capturedImages.length >= requiredCount;

    return Scaffold(
      appBar: AppBar(title: Text(t.get('capture_progress'))),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderWidget(
                title: t.get('field_coverage'),
                subtitle: t.get('review_images'),
              ),

              const SizedBox(height: 24),

              // Progress indicator
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t.get('images_captured'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${capturedImages.length} / $requiredCount',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: isComplete
                                      ? AppTheme.successColor
                                      : AppTheme.primaryColor,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isComplete
                              ? AppTheme.successColor
                              : AppTheme.accentColor,
                        ),
                      ),
                      if (isComplete) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.successColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t.get('min_requirement'),
                              style: TextStyle(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Mini map visualization
              Expanded(
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.map, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              t.get('field_coverage_map'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: MockMapView(
                              boundaryDefined: true,
                              requiredImages: capturedImages.length,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Warning if insufficient coverage
              if (!isComplete)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: AppTheme.warningColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${t.get('capture_more_warning')} (${requiredCount - capturedImages.length})',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.add_a_photo, size: 20),
                      label: Text(
                        t.get('capture_more'),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: t.get('analyze_damage'),
                      icon: Icons.analytics,
                      isEnabled: isComplete,
                      onPressed: () {
                        Navigator.pushNamed(context, '/ai-processing');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
