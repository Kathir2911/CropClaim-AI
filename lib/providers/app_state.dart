import 'package:flutter/foundation.dart';
import '../models/user_mode.dart';
import '../models/claim_data.dart';
import '../models/ai_result.dart';
import '../models/auth_models.dart';
import '../models/submitted_claim.dart';

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

  // Submitted claims history
  final List<SubmittedClaim> _submittedClaims = [];
  List<SubmittedClaim> get submittedClaims =>
      List.unmodifiable(_submittedClaims);

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

  // ✅ PROMPT 2: Proper Logout Functionality
  void logout() {
    // Clear all authentication state
    _farmerAuth = null;
    _operatorAuth = null;
    _agentAuth = null;
    _userSession = null;
    _authState = AuthState.unauthenticated;

    // Clear claim data (optional - removes in-progress claims)
    _claimData = ClaimData();
    _fieldBoundary = null;
    _capturedImages = [];
    _aiResult = null;
    _pmfbyCalculation = null;

    notifyListeners();
  }

  // Helper method to check if user has specific role
  bool hasRole(UserMode role) {
    return _userSession?.mode == role;
  }

  // Helper to check if user can access management features
  bool get canManageRequests {
    return hasRole(UserMode.cscOperator) || hasRole(UserMode.insuranceAgent);
  }

  // Get current user's role display name
  String? get currentRoleDisplay {
    switch (_userSession?.mode) {
      case UserMode.farmer:
        return 'Farmer';
      case UserMode.cscOperator:
        return 'CSC / PACS Operator';
      case UserMode.insuranceAgent:
        return 'Insurance Agent';
      default:
        return null;
    }
  }

  // Submit claim and save to history
  void submitClaim() {
    // Generate claim ID
    final claimId = 'CLM${DateTime.now().millisecondsSinceEpoch}';

    // Create submitted claim
    final submittedClaim = SubmittedClaim(
      claimId: claimId,
      submittedAt: DateTime.now(),
      claimData: _claimData,
      aiResult: _aiResult,
      calculation: _pmfbyCalculation,
      status: 'Submitted',
    );

    // Add to history
    _submittedClaims.insert(
      0,
      submittedClaim,
    ); // Add to beginning for newest first

    // Clear current claim data for next claim
    _claimData = ClaimData();
    _fieldBoundary = null;
    _capturedImages = [];
    _aiResult = null;
    _pmfbyCalculation = null;

    notifyListeners();
  }
}

enum AuthState { unauthenticated, authenticated }

class UserSession {
  final UserMode mode;
  final String? operatorId;

  UserSession({required this.mode, this.operatorId});
}
