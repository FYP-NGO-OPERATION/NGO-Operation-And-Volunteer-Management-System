/// Compile-time feature flags for FYP phase-based code separation.
///
/// Usage:
///   FYP-01 Safe Mode (DEFAULT — examiner-safe):
///     flutter run --dart-define=APP_PHASE=FYP1
///
///   FYP-02 Dev Mode (all FYP-02 features):
///     flutter run --dart-define=APP_PHASE=FYP2
///
///   Full System Mode (everything unlocked):
///     flutter run --dart-define=APP_PHASE=FULL
///
/// If no --dart-define is passed, defaults to FYP1 (safe for defense).
/// 
/// VIVA PREP EXPLANATION:
/// Q: Why use Feature Flags?
/// A: Instead of creating 3 different projects or making messy Git branches, 
/// we use "--dart-define" to inject a compile-time variable. This allows us 
/// to hide advanced FYP-2 features during the FYP-1 defense so the app doesn't crash 
/// if the backend isn't fully ready yet. It is a standard industry practice.
class FeatureFlags {
  FeatureFlags._(); // Prevent instantiation

  /// Current phase read from compile-time environment.
  static const String phase = String.fromEnvironment(
    'APP_PHASE',
    defaultValue: 'FULL',
  );

  // ─── Phase Checks ───────────────────────────────────────────

  /// True when running in FYP-01 defense mode (default).
  static bool get isFyp1 => phase == 'FYP1';

  /// True when running in FYP-02 development mode.
  static bool get isFyp2 => phase == 'FYP2';

  /// True when running in full unrestricted mode.
  static bool get isFull => phase == 'FULL';

  // ─── Feature Gates ──────────────────────────────────────────

  /// Analytics dashboard & PDF report generation.
  /// Available in: FYP2, FULL
  static bool get isAnalyticsEnabled => isFyp2 || isFull;

  /// Advanced admin actions (bulk operations, advanced user mgmt).
  /// Available in: FYP2, FULL
  static bool get isAdvancedAdminEnabled => isFyp2 || isFull;

  /// Push notifications (FCM).
  /// Available in: FYP2, FULL
  static bool get isPushNotificationsEnabled => isFyp2 || isFull;

  /// Smart volunteer-campaign matching algorithm (Basic UI).
  /// Available in: FYP1, FYP2, FULL
  static bool get isSmartMatchingEnabled => true;

  /// QR-based attendance system (Basic).
  /// Available in: FYP1, FYP2, FULL
  static bool get isQrAttendanceEnabled => true;

  // ─── FYP-03 Optimization Feature Gates ───────────────────────

  /// Server-side cloud function matching (Optimized).
  /// Available in: FULL
  static bool get isServerSideMatchingEnabled => isFull;

  /// Secure QR with 60-second TTL expiry.
  /// Available in: FULL
  static bool get isSecureQrEnabled => isFull;

  // ─── Convenience ────────────────────────────────────────────

  /// Human-readable label for the current phase (useful for debug banners).
  static String get phaseLabel {
    switch (phase) {
      case 'FYP1':
        return 'FYP-01 (Defense Mode)';
      case 'FYP2':
        return 'FYP-02 (Development)';
      case 'FULL':
        return 'Full System';
      default:
        return 'FYP-01 (Defense Mode)';
    }
  }
}
