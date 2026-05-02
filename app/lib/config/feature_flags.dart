/// Compile-time feature flags for FYP phase-based code separation.
///
/// Usage:
///   FYP-01 Safe Mode (DEFAULT — examiner-safe):
///     flutter run --dart-define=APP_PHASE=FYP1
///
///   Full System Mode (all features):
///     flutter run --dart-define=APP_PHASE=FULL
///
///   FYP-02 Dev Mode:
///     flutter run --dart-define=APP_PHASE=FYP2
///
/// If no --dart-define is passed, defaults to FYP1 (safe for defense).
class FeatureFlags {
  FeatureFlags._(); // Prevent instantiation

  /// Current phase read from compile-time environment.
  static const String phase = String.fromEnvironment(
    'APP_PHASE',
    defaultValue: 'FYP1',
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
  /// Available in: FULL only (FYP-03 feature)
  static bool get isPushNotificationsEnabled => isFull;

  /// Smart volunteer-campaign matching algorithm.
  /// Available in: FULL only (FYP-03 feature)
  static bool get isSmartMatchingEnabled => isFull;

  /// QR-based attendance system.
  /// Available in: FULL only (FYP-03 feature)
  static bool get isQrAttendanceEnabled => isFull;

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
