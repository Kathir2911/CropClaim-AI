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
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Verification')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderWidget(
                  title: 'Farmer Verification',
                  subtitle: 'किसान सत्यापन',
                ),

                const SizedBox(height: 32),

                // Mobile Number
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number / मोबाइल नंबर *',
                    hintText: '10 digit mobile number',
                    prefixIcon: Icon(Icons.phone, size: 28),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    if (value == null || value.length != 10) {
                      return 'Please enter valid 10-digit mobile number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Aadhaar Number
                TextFormField(
                  controller: _aadhaarController,
                  decoration: const InputDecoration(
                    labelText: 'Aadhaar Number / आधार नंबर *',
                    hintText: 'Full 12 digits or last 4 digits',
                    prefixIcon: Icon(Icons.badge, size: 28),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 18),
                  validator: (value) {
                    if (value == null ||
                        (value.length != 12 && value.length != 4)) {
                      return 'Enter full 12 digits or last 4 digits of Aadhaar';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Optional Policy ID
                TextFormField(
                  controller: _policyIdController,
                  decoration: const InputDecoration(
                    labelText: 'PMFBY Policy ID (Optional)',
                    hintText: 'Enter your policy ID if available',
                    prefixIcon: Icon(Icons.policy, size: 28),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 24),

                // Send OTP Button
                if (!_otpSent)
                  CustomButton(
                    text: 'Send OTP / OTP भेजें',
                    icon: Icons.message,
                    onPressed: _sendOTP,
                    isEnabled: !_isLoading,
                  ),

                // OTP Input
                if (_otpSent) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Enter OTP / OTP दर्ज करें',
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
                      'For demo: Use 123456',
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
                            'Your information is secured and used only for claim processing',
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
                  text: 'Verify & Continue / सत्यापित करें',
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
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send OTP'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _verifyAndContinue() async {
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
            content: Text('Invalid OTP. Please try again.'),
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
          const SnackBar(
            content: Text('Invalid Aadhaar number'),
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
      Navigator.pushReplacementNamed(context, '/claim-details');
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
