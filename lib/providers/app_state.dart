import 'package:flutter/foundation.dart';
import '../models/user_mode.dart';
import '../models/claim_data.dart';
import '../models/ai_result.dart';
import '../models/auth_models.dart';

class AppState extends ChangeNotifier {
  // User session
  UserSession? _userSession;
  UserSession? get userSession => _userSession;

  // Claim data
  ClaimData _claimData = ClaimData();
  ClaimData get claimData => _claimData;

  // Field boundary
  FieldBoundary? _fieldBoundary;
  FieldBoundary? get fieldBoundary => _fieldBoundary;

  // Captured images
  List<CaptureMetadata> _capturedImages = [];
  List<CaptureMetadata> get capturedImages => _capturedImages;

  // Required capture count
  int _requiredCaptureCount = 10;
  int get requiredCaptureCount => _requiredCaptureCount;

  // AI results
  AIResult? _aiResult;
  AIResult? get aiResult => _aiResult;

  // PMFBY calculation
  PMFBYCalculation? _pmfbyCalculation;
  PMFBYCalculation? get pmfbyCalculation => _pmfbyCalculation;

  // Authentication state
  AuthState _authState = AuthState.unauthenticated;
  AuthState get authState => _authState;

  FarmerAuth? _farmerAuth;
  FarmerAuth? get farmerAuth => _farmerAuth;

  OperatorAuth? _operatorAuth;
  OperatorAuth? get operatorAuth => _operatorAuth;

  AgentAuth? _agentAuth;
  AgentAuth? get agentAuth => _agentAuth;

  bool get isAuthenticated => _authState == AuthState.authenticated;

  String? get authenticatedUserDisplay {
    if (_farmerAuth != null) return _farmerAuth!.displayName;
    if (_operatorAuth != null) return _operatorAuth!.displayName;
    if (_agentAuth != null) return _agentAuth!.displayName;
    return null;
  }

  UserMode? get authenticatedUserMode => _userSession?.mode;

  void setUserSession(UserMode mode, {String? operatorId}) {
    _userSession = UserSession(mode: mode, operatorId: operatorId);
    notifyListeners();
  }

  void updateClaimData(ClaimData data) {
    _claimData = data;
    notifyListeners();
  }

  void setFieldBoundary(FieldBoundary boundary) {
    _fieldBoundary = boundary;
    // Calculate required captures: 1 per 2 acres, minimum 10
    _requiredCaptureCount = ((boundary.areaInAcres / 2).ceil()).clamp(10, 100);
    notifyListeners();
  }

  void addCapturedImage(CaptureMetadata metadata) {
    _capturedImages.add(metadata);
    notifyListeners();
  }

  void setAIResult(AIResult result) {
    _aiResult = result;
    notifyListeners();
  }

  void setPMFBYCalculation(PMFBYCalculation calculation) {
    _pmfbyCalculation = calculation;
    notifyListeners();
  }

  void resetClaim() {
    _claimData = ClaimData();
    _fieldBoundary = null;
    _capturedImages = [];
    _requiredCaptureCount = 10;
    _aiResult = null;
    _pmfbyCalculation = null;
    notifyListeners();
  }

  bool get canProceedToAnalysis =>
      _capturedImages.length >= _requiredCaptureCount;

  // Authentication methods
  void authenticateFarmer(FarmerAuth auth) {
    _farmerAuth = auth;
    _authState = AuthState.authenticated;
    notifyListeners();
  }

  void authenticateOperator(OperatorAuth auth) {
    _operatorAuth = auth;
    _authState = AuthState.authenticated;
    notifyListeners();
  }

  void authenticateAgent(AgentAuth auth) {
    _agentAuth = auth;
    _authState = AuthState.authenticated;
    notifyListeners();
  }

  void logout() {
    _authState = AuthState.unauthenticated;
    _farmerAuth = null;
    _operatorAuth = null;
    _agentAuth = null;
    _userSession = null;
    resetClaim();
    notifyListeners();
  }
}
