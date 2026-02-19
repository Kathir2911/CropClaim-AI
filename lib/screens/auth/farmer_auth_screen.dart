import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/auth_models.dart';
import '../../providers/app_state.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/otp_input.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/header_widget.dart';

class FarmerAuthScreen extends StatefulWidget {
  const FarmerAuthScreen({super.key});

  @override
  State<FarmerAuthScreen> createState() => _FarmerAuthScreenState();
}

class _FarmerAuthScreenState extends State<FarmerAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _policyIdController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);
    return Scaffold(
      appBar: AppBar(title: Text(t.get('farmer_verification'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderWidget(
                  title: t.get('farmer_verification'),
                  subtitle: t.get('farmer_desc'),
                ),

                const SizedBox(height: 32),

                // Mobile Number
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: '${t.get('mobile_number')} *',
                    hintText: t.get('mobile_hint'),
                    prefixIcon: const Icon(Icons.phone, size: 28),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    if (value == null || value.length != 10) {
                      return t.get('valid_mobile');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Aadhaar Number
                TextFormField(
                  controller: _aadhaarController,
                  decoration: InputDecoration(
                    labelText: '${t.get('aadhaar_number')} *',
                    hintText: t.get('aadhaar_hint'),
                    prefixIcon: const Icon(Icons.badge, size: 28),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    if (value == null ||
                        (value.length != 12 && value.length != 4)) {
                      return t.get('enter_aadhaar');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Optional Policy ID
                TextFormField(
                  controller: _policyIdController,
                  decoration: InputDecoration(
                    labelText: t.get('pmfby_policy_optional'),
                    hintText: t.get('policy_hint'),
                    prefixIcon: const Icon(Icons.policy, size: 28),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 24),

                // Send OTP Button
                if (!_otpSent)
                  CustomButton(
                    text: t.get('send_otp'),
                    icon: Icons.message,
                    onPressed: _sendOTP,
                    isEnabled: !_isLoading,
                  ),

                // OTP Input
                if (_otpSent) ...[
                  const SizedBox(height: 24),
                  Text(
                    t.get('enter_otp'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  OTPInput(
                    onCompleted: (otp) {
                      setState(() {
                        _otp = otp;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      t.get('demo_otp_hint'),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Info Card
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.get('info_secured'),
                            style: TextStyle(
                              color: Colors.green.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Verify Button
                CustomButton(
                  text: t.get('verify_continue'),
                  icon: Icons.check_circle,
                  onPressed: _verifyAndContinue,
                  isEnabled: _otpSent && _otp.isNotEmpty && !_isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await AuthService.sendOTP(_mobileController.text);

    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final t = AppLocalizations(locale.languageCode);

    setState(() {
      _isLoading = false;
      if (success) {
        _otpSent = true;
      }
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.get('otp_sent')),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.get('otp_failed')),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _verifyAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final t = AppLocalizations(locale.languageCode);

    setState(() {
      _isLoading = true;
    });

    // Verify OTP
    final otpValid = await AuthService.verifyOTP(_mobileController.text, _otp);

    if (!otpValid) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('invalid_otp')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Validate Aadhaar
    if (!AuthService.validateAadhaar(_aadhaarController.text)) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('invalid_aadhaar')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Create farmer auth
    final farmerAuth = FarmerAuth(
      mobile: _mobileController.text,
      aadhaar: _aadhaarController.text,
      policyId: _policyIdController.text.isNotEmpty
          ? _policyIdController.text
          : null,
      authenticatedAt: DateTime.now(),
    );

    // Store in app state
    if (mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.authenticateFarmer(farmerAuth);

      setState(() {
        _isLoading = false;
      });

      // Navigate to claim details
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _aadhaarController.dispose();
    _policyIdController.dispose();
    super.dispose();
  }
}
