import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/header_widget.dart';
import 'package:intl/intl.dart';

class PMFBYClaimLogicScreen extends StatelessWidget {
  const PMFBYClaimLogicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final calculation = appState.pmfbyCalculation;

    if (calculation == null) {
      return const Scaffold(
        body: Center(child: Text('No calculation available')),
      );
    }

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('PMFBY Claim Calculation')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const HeaderWidget(
              title: 'Insurance Calculation',
              subtitle: 'Transparent PMFBY claim assessment',
            ),

            const SizedBox(height: 24),

            // Calculation breakdown card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'Claim Calculation',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _CalculationRow(
                      label: 'Sum Insured',
                      value: currencyFormat.format(calculation.sumInsured),
                      icon: Icons.account_balance_wallet,
                    ),

                    const Divider(height: 32),

                    _CalculationRow(
                      label: 'Calculated Loss',
                      value:
                          '${calculation.calculatedLoss.toStringAsFixed(1)}%',
                      icon: Icons.trending_down,
                      valueColor: AppTheme.errorColor,
                    ),

                    const Divider(height: 32),

                    _CalculationRow(
                      label: 'PMFBY Threshold',
                      value:
                          '${calculation.thresholdPercentage.toStringAsFixed(0)}%',
                      icon: Icons.rule,
                      subtitle: 'Minimum loss required for eligibility',
                    ),

                    const Divider(height: 32),

                    _CalculationRow(
                      label: 'Eligible Claim Amount',
                      value: currencyFormat.format(
                        calculation.eligibleClaimAmount,
                      ),
                      icon: Icons.payments,
                      valueColor: calculation.isEligible
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Eligibility status card
            Card(
              color: calculation.isEligible
                  ? AppTheme.successColor.withOpacity(0.1)
                  : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Icon(
                      calculation.isEligible ? Icons.check_circle : Icons.info,
                      color: calculation.isEligible
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            calculation.isEligible
                                ? 'Claim Eligible'
                                : 'Claim Not Eligible',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: calculation.isEligible
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            calculation.message,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: calculation.isEligible
                                      ? Colors.green.shade900
                                      : Colors.orange.shade900,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // PMFBY Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'About PMFBY',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pradhan Mantri Fasal Bima Yojana (PMFBY) provides insurance coverage to farmers against crop loss. '
                      'Claims are processed when the damage exceeds the threshold percentage.',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            CustomButton(
              text: 'View Claim Report',
              icon: Icons.assignment,
              onPressed: () {
                Navigator.pushNamed(context, '/claim-report');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculationRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color? valueColor;
  final bool isHighlighted;

  const _CalculationRow({
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.valueColor,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isHighlighted
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: valueColor ?? AppTheme.textPrimary,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                fontSize: isHighlighted ? 20 : 16,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }
}
