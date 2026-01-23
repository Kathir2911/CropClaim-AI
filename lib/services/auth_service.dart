import '../models/auth_models.dart';

class AuthService {
  // Mock OTP that always works
  static const String VALID_OTP = '123456';

  // Mock operator database
  static final Map<String, Map<String, String>> _operators = {
    'CSC001': {'name': 'Rajesh Kumar', 'center': 'Shirur CSC Center'},
    'CSC002': {'name': 'Priya Sharma', 'center': 'Baramati PACS'},
    'PACS001': {'name': 'Amit Deshmukh', 'center': 'Indapur PACS Center'},
  };

  // Mock agent database
  static final Map<String, String> _agents = {
    'AGT001': 'Suresh Patil',
    'AGT002': 'Meera Joshi',
    'AGT003': 'Kiran Naik',
  };

  // Send OTP (mocked - always succeeds)
  static Future<bool> sendOTP(String mobile) async {
    await Future.delayed(const Duration(seconds: 1));

    // Validate mobile number format
    if (mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      return false;
    }

    return true;
  }

  // Verify OTP (mocked - accepts 123456 or any 6-digit code)
  static Future<bool> verifyOTP(String mobile, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Accept any 6-digit OTP for prototype
    if (otp.length == 6 && RegExp(r'^[0-9]+$').hasMatch(otp)) {
      return true;
    }

    return false;
  }

  // Validate Aadhaar (12 digits full or 4 digits last)
  static bool validateAadhaar(String aadhaar) {
    if (aadhaar.length == 12 || aadhaar.length == 4) {
      return RegExp(r'^[0-9]+$').hasMatch(aadhaar);
    }
    return false;
  }

  // Fetch operator details (mocked)
  static Future<Map<String, String>?> fetchOperatorDetails(String cscId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return _operators[cscId.toUpperCase()];
  }

  // Validate Agent ID (mocked)
  static Future<String?> fetchAgentName(String agentId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return _agents[agentId.toUpperCase()];
  }

  // Validate PIN (mocked - accepts any 4-6 digit PIN)
  static bool validatePIN(String pin) {
    if (pin.length >= 4 && pin.length <= 6) {
      return RegExp(r'^[0-9]+$').hasMatch(pin);
    }
    return false;
  }

  // Mock biometric verification (always succeeds)
  static Future<bool> verifyBiometric() async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
