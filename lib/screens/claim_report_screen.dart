import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/app_state.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_button.dart';
import '../widgets/header_widget.dart';

class ClaimReportScreen extends StatelessWidget {
  const ClaimReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);
    final claimData = appState.claimData;
    final aiResult = appState.aiResult;
    final pmfbyCalculation = appState.pmfbyCalculation;
    final userSession = appState.userSession;

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    // Generate mock hash for QR code
    final reportHash = 'PMFBY-${DateTime.now().millisecondsSinceEpoch}';

    return Scaffold(
      appBar: AppBar(title: Text(t.get('claim_report'))),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  HeaderWidget(
                    title: t.get('crop_damage_report'),
                    subtitle: t.get('official_pmfby'),
                  ),

                  const SizedBox(height: 24),

                  // Report header
                  Card(
                    color: AppTheme.primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.agriculture,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.get('cropclaim_report'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${t.get('generated_on')} ${dateFormat.format(DateTime.now())}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Farmer details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.get('farmer_details'),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            label: t.get('name_label'),
                            value: claimData.farmerName,
                          ),
                          _InfoRow(
                            label: t.get('policy_id'),
                            value: claimData.policyId,
                          ),
                          _InfoRow(
                            label: t.get('village'),
                            value: claimData.village,
                          ),
                          _InfoRow(
                            label: t.get('land_area'),
                            value:
                                '${claimData.landArea} ${t.get('acres_label')}',
                          ),
                          if (userSession?.operatorId != null)
                            _InfoRow(
                              label: t.get('operator_id'),
                              value: userSession!.operatorId!,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Crop and disease
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.get('assessment_results'),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            label: t.get('crop_type'),
                            value: aiResult?.detectedCrop ?? 'N/A',
                          ),
                          _InfoRow(
                            label: t.get('disease_detected'),
                            value:
                                aiResult?.disease?.diseaseName ??
                                t.get('natural_disaster'),
                          ),
                          _InfoRow(
                            label: t.get('confidence'),
                            value: aiResult?.disease != null
                                ? '${(aiResult!.disease!.confidence * 100).toStringAsFixed(0)}%'
                                : 'N/A',
                          ),
                          _InfoRow(
                            label: t.get('overall_loss'),
                            value: aiResult != null
                                ? '${aiResult.damage.overallFieldLossPercentage.toStringAsFixed(1)}%'
                                : 'N/A',
                          ),
                          _InfoRow(
                            label: t.get('images_captured'),
                            value: '${appState.capturedImages.length}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PMFBY calculation
                  Card(
                    color: pmfbyCalculation?.isEligible == true
                        ? AppTheme.successColor.withOpacity(0.1)
                        : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.get('claim_calculation'),
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: pmfbyCalculation?.isEligible == true
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            label: t.get('sum_insured'),
                            value: pmfbyCalculation != null
                                ? currencyFormat.format(
                                    pmfbyCalculation.sumInsured,
                                  )
                                : 'N/A',
                          ),
                          _InfoRow(
                            label: t.get('eligible_amount'),
                            value: pmfbyCalculation != null
                                ? currencyFormat.format(
                                    pmfbyCalculation.eligibleClaimAmount,
                                  )
                                : 'N/A',
                            isBold: true,
                          ),
                          _InfoRow(
                            label: t.get('status_label'),
                            value: pmfbyCalculation?.isEligible == true
                                ? t.get('eligible')
                                : t.get('not_eligible'),
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // QR code and verification
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            t.get('verification_code'),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          QrImageView(
                            data: reportHash,
                            version: QrVersions.auto,
                            size: 150.0,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            reportHash,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t.get('scan_verify'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer
                  Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance,
                                size: 16,
                                color: Colors.grey.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.get('pmfby_full'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.get('govt_ministry'),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _downloadPDF();
                        _showDownloadMessage(context);
                      },
                      icon: const Icon(Icons.file_download, size: 22),
                      label: Text(
                        t.get('download_pdf'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: t.get('submit_insurer'),
                      icon: Icons.send,
                      onPressed: () => _submitClaim(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadPDF() {
    // Mock PDF download with visual feedback
    // In real app, would generate PDF using pdf package
    // For now, show a message
  }

  void _showDownloadMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.file_download, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations(
                  Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).languageCode,
                ).get('pdf_complete'),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitClaim(BuildContext context) {
    // Save claim to history
    final appState = Provider.of<AppState>(context, listen: false);
    appState.submitClaim();

    final t = AppLocalizations(
      Provider.of<LocaleProvider>(context, listen: false).languageCode,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.successColor),
            const SizedBox(width: 12),
            Text(t.get('claim_submitted')),
          ],
        ),
        content: Text(t.get('claim_submitted_msg')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Return to profile page instead of mode selection
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/profile',
                (route) => false,
              );
            },
            child: Text(t.get('ok')),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
