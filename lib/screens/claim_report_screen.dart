import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/header_widget.dart';

class ClaimReportScreen extends StatelessWidget {
  const ClaimReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
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
      appBar: AppBar(title: const Text('Claim Report')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const HeaderWidget(
                    title: 'Crop Damage Claim Report',
                    subtitle: 'Official PMFBY claim documentation',
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
                          const Text(
                            'CropClaim AI Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Generated on ${dateFormat.format(DateTime.now())}',
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
                            'Farmer Details',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(label: 'Name', value: claimData.farmerName),
                          _InfoRow(
                            label: 'Policy ID',
                            value: claimData.policyId,
                          ),
                          _InfoRow(label: 'Village', value: claimData.village),
                          _InfoRow(
                            label: 'Land Area',
                            value: '${claimData.landArea} acres',
                          ),
                          if (userSession?.operatorId != null)
                            _InfoRow(
                              label: 'Operator ID',
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
                            'Assessment Results',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            label: 'Crop Type',
                            value: aiResult?.detectedCrop ?? 'N/A',
                          ),
                          _InfoRow(
                            label: 'Disease Detected',
                            value: aiResult?.disease.diseaseName ?? 'N/A',
                          ),
                          _InfoRow(
                            label: 'Confidence',
                            value: aiResult != null
                                ? '${(aiResult.disease.confidence * 100).toStringAsFixed(0)}%'
                                : 'N/A',
                          ),
                          _InfoRow(
                            label: 'Overall Field Loss',
                            value: aiResult != null
                                ? '${aiResult.damage.overallFieldLossPercentage.toStringAsFixed(1)}%'
                                : 'N/A',
                          ),
                          _InfoRow(
                            label: 'Images Captured',
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
                            'Claim Calculation',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: pmfbyCalculation?.isEligible == true
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _InfoRow(
                            label: 'Sum Insured',
                            value: pmfbyCalculation != null
                                ? currencyFormat.format(
                                    pmfbyCalculation.sumInsured,
                                  )
                                : 'N/A',
                          ),
                          _InfoRow(
                            label: 'Eligible Claim Amount',
                            value: pmfbyCalculation != null
                                ? currencyFormat.format(
                                    pmfbyCalculation.eligibleClaimAmount,
                                  )
                                : 'N/A',
                            isBold: true,
                          ),
                          _InfoRow(
                            label: 'Status',
                            value: pmfbyCalculation?.isEligible == true
                                ? 'ELIGIBLE'
                                : 'NOT ELIGIBLE',
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
                            'Verification Code',
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
                            'Scan to verify claim authenticity',
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
                                'Pradhan Mantri Fasal Bima Yojana',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Government of India • Ministry of Agriculture',
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
                      label: const Text(
                        'Download PDF',
                        style: TextStyle(fontWeight: FontWeight.w600),
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
                      text: 'Submit to Insurer',
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
        content: const Row(
          children: [
            Icon(Icons.file_download, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('PDF report download complete!')),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitClaim(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            SizedBox(width: 12),
            Text('Claim Submitted'),
          ],
        ),
        content: const Text(
          'Your claim has been successfully submitted to the insurance company. '
          'You will receive a confirmation message shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('OK'),
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
