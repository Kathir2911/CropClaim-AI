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

class OperatorAuthScreen extends StatefulWidget {
  const OperatorAuthScreen({super.key});

  @override
  State<OperatorAuthScreen> createState() => _OperatorAuthScreenState();
}

class _OperatorAuthScreenState extends State<OperatorAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cscIdController = TextEditingController();
  final _mobileController = TextEditingController();
  final _pinController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final t = AppLocalizations(locale.languageCode);
    return Scaffold(
      appBar: AppBar(title: Text(t.get('operator_login'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderWidget(
                  title: t.get('operator_login'),
                  subtitle: t.get('operator_subtitle'),
                ),

                const SizedBox(height: 32),

                // CSC/PACS ID
                TextFormField(
                  controller: _cscIdController,
                  decoration: InputDecoration(
                    labelText: '${t.get('csc_id')} *',
                    hintText: t.get('csc_hint'),
                    prefixIcon: const Icon(Icons.business),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.get('enter_csc_id');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Mobile Number
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: '${t.get('operator_mobile')} *',
                    hintText: t.get('mobile_hint'),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.length != 10) {
                      return t.get('valid_mobile');
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  OTPInput(
                    onCompleted: (otp) {
                      setState(() {
                        _otp = otp;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      t.get('demo_otp_hint'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // PIN
                  TextFormField(
                    controller: _pinController,
                    decoration: InputDecoration(
                      labelText: '${t.get('operator_pin')} *',
                      hintText: t.get('pin_hint'),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.length < 4) {
                        return t.get('valid_pin');
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 24),

                // Info Card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t.get('operator_accountability'),
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                CustomButton(
                  text: t.get('login_operator'),
                  icon: Icons.login,
                  onPressed: _loginAsOperator,
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

    setState(() {
      _isLoading = false;
      if (success) {
        _otpSent = true;
      }
    });

    final locale = Provider.of<LocaleProvider>(context, listen: false);
    final t = AppLocalizations(locale.languageCode);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.get('otp_sent')),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _loginAsOperator() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
        final locale = Provider.of<LocaleProvider>(context, listen: false);
        final t = AppLocalizations(locale.languageCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('invalid_otp')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Validate PIN
    if (!AuthService.validatePIN(_pinController.text)) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final locale = Provider.of<LocaleProvider>(context, listen: false);
        final t = AppLocalizations(locale.languageCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('invalid_pin')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Fetch operator details
    final operatorDetails = await AuthService.fetchOperatorDetails(
      _cscIdController.text,
    );

    if (operatorDetails == null) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final locale = Provider.of<LocaleProvider>(context, listen: false);
        final t = AppLocalizations(locale.languageCode);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('csc_not_found')),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Create operator auth
    final operatorAuth = OperatorAuth(
      cscId: _cscIdController.text.toUpperCase(),
      mobile: _mobileController.text,
      operatorName: operatorDetails['name']!,
      centerName: operatorDetails['center']!,
      authenticatedAt: DateTime.now(),
    );

    // Store in app state
    if (mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.authenticateOperator(operatorAuth);

      setState(() {
        _isLoading = false;
      });

      // Navigate to claim details
      Navigator.pushReplacementNamed(context, '/profile');
    }
  }

  @override
  void dispose() {
    _cscIdController.dispose();
    _mobileController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
