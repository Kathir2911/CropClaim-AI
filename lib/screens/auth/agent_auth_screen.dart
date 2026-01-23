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

class AgentAuthScreen extends StatefulWidget {
  const AgentAuthScreen({super.key});

  @override
  State<AgentAuthScreen> createState() => _AgentAuthScreenState();
}

class _AgentAuthScreenState extends State<AgentAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _agentIdController = TextEditingController();
  final _mobileController = TextEditingController();
  final _pinController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  bool _useBiometric = false;
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insurance Agent Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeaderWidget(
                  title: 'Insurance Agent Login',
                  subtitle: 'Krushi Sahayak - Highest accountability role',
                ),

                const SizedBox(height: 32),

                // Agent ID
                TextFormField(
                  controller: _agentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Agent ID *',
                    hintText: 'AGT001, AGT002, etc.',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Agent ID';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Mobile Number
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Registered Mobile Number *',
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

                  // Biometric Toggle
                  Card(
                    child: SwitchListTile(
                      title: const Text('Use Biometric Authentication'),
                      subtitle: const Text('Mocked for prototype'),
                      value: _useBiometric,
                      onChanged: (value) {
                        setState(() {
                          _useBiometric = value;
                        });
                      },
                      secondary: Icon(
                        Icons.fingerprint,
                        color: _useBiometric
                            ? AppTheme.accentColor
                            : Colors.grey,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PIN (if not using biometric)
                  if (!_useBiometric)
                    TextFormField(
                      controller: _pinController,
                      decoration: const InputDecoration(
                        labelText: 'Agent PIN *',
                        hintText: '4-6 digit PIN',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 6,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (_useBiometric) return null;
                        if (value == null || value.length < 4) {
                          return 'PIN must be at least 4 digits';
                        }
                        return null;
                      },
                    ),
                ],

                const SizedBox(height: 24),

                // Info Cards
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🔍 Audit Enabled',
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'All actions will be logged and monitored',
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Agents cannot manually edit AI detection results',
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
                  text: 'Login as Agent',
                  icon: Icons.login,
                  onPressed: _loginAsAgent,
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

  void _loginAsAgent() async {
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

    // Verify biometric or PIN
    if (_useBiometric) {
      final bioValid = await AuthService.verifyBiometric();
      if (!bioValid) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric verification failed'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }
    } else {
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
    }

    // Fetch agent name
    final agentName = await AuthService.fetchAgentName(_agentIdController.text);

    if (agentName == null) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agent ID not found'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    // Create agent auth
    final agentAuth = AgentAuth(
      agentId: _agentIdController.text.toUpperCase(),
      mobile: _mobileController.text,
      agentName: agentName,
      auditEnabled: true,
      authenticatedAt: DateTime.now(),
    );

    // Store in app state
    if (mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.authenticateAgent(agentAuth);

      setState(() {
        _isLoading = false;
      });

      // Navigate to claim details
      Navigator.pushReplacementNamed(context, '/claim-details');
    }
  }

  @override
  void dispose() {
    _agentIdController.dispose();
    _mobileController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}
