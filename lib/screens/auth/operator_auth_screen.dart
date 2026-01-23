import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/auth_models.dart';
import '../../providers/app_state.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('CSC / PACS Operator Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderWidget(
                  title: 'CSC / PACS Operator Login',
                  subtitle: 'Assisted capture mode - Higher accountability',
                ),

                const SizedBox(height: 32),

                // CSC/PACS ID
                TextFormField(
                  controller: _cscIdController,
                  decoration: const InputDecoration(
                    labelText: 'CSC ID or PACS ID *',
                    hintText: 'CSC001, PACS001, etc.',
                    prefixIcon: Icon(Icons.business),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter CSC or PACS ID';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Mobile Number
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Operator Mobile Number *',
                    hintText: '10 digit mobile number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.length != 10) {
                      return 'Please enter valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Send OTP Button
                if (!_otpSent)
                  CustomButton(
                    text: 'Send OTP',
                    icon: Icons.message,
                    onPressed: _sendOTP,
                    isEnabled: !_isLoading,
                  ),

                // OTP Input
                if (_otpSent) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Enter OTP',
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
                      'For demo: Use 123456',
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
                    decoration: const InputDecoration(
                      labelText: 'Operator PIN *',
                      hintText: '4-6 digit PIN',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.length < 4) {
                        return 'PIN must be at least 4 digits';
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
                            'All assisted captures will be tagged with your operator ID for accountability',
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
                  text: 'Login as Operator',
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

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully!'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid OTP'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid PIN'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSC/PACS ID not found'),
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
      Navigator.pushReplacementNamed(context, '/claim-details');
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
