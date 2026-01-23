enum AuthState { unauthenticated, authenticated }

class FarmerAuth {
  final String mobile;
  final String aadhaar; // Can be full or last 4 digits
  final String? policyId;
  final DateTime authenticatedAt;

  FarmerAuth({
    required this.mobile,
    required this.aadhaar,
    this.policyId,
    required this.authenticatedAt,
  });

  String get displayName => 'Farmer: $mobile';
}

class OperatorAuth {
  final String cscId;
  final String mobile;
  final String operatorName;
  final String centerName;
  final DateTime authenticatedAt;

  OperatorAuth({
    required this.cscId,
    required this.mobile,
    required this.operatorName,
    required this.centerName,
    required this.authenticatedAt,
  });

  String get displayName => '$operatorName • $centerName';
}

class AgentAuth {
  final String agentId;
  final String mobile;
  final String agentName;
  final bool auditEnabled;
  final DateTime authenticatedAt;

  AgentAuth({
    required this.agentId,
    required this.mobile,
    required this.agentName,
    this.auditEnabled = true,
    required this.authenticatedAt,
  });

  String get displayName => 'Agent: $agentName ($agentId)';
}
