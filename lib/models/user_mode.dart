enum UserMode { farmer, cscOperator, insuranceAgent }

extension UserModeExtension on UserMode {
  String get displayName {
    switch (this) {
      case UserMode.farmer:
        return 'Farmer (Self Capture)';
      case UserMode.cscOperator:
        return 'CSC / PACS Operator';
      case UserMode.insuranceAgent:
        return 'Insurance Agent / Krushi Sahayak';
    }
  }

  String get icon {
    switch (this) {
      case UserMode.farmer:
        return '👨‍🌾';
      case UserMode.cscOperator:
        return '🏢';
      case UserMode.insuranceAgent:
        return '🧑‍💼';
    }
  }
}

class UserSession {
  final UserMode mode;
  final String? operatorId;

  UserSession({required this.mode, this.operatorId});
}
