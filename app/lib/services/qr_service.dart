import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'volunteer_service.dart';
import '../enums/app_enums.dart';
import '../config/feature_flags.dart';

/// QR Code Attendance Service (FYP-02 Feature Module).
///
/// ARCHITECTURE: Generate → Scan → Verify → Mark
///
/// Flow:
///   1. ADMIN generates a QR code for a campaign (QrGenerateScreen)
///   2. QR encodes a JSON payload: {type, campaignId, campaignTitle, generatedAt}
///   3. VOLUNTEER scans the QR using device camera (mobile_scanner package)
///   4. System parses payload, validates 'hras_attendance' type marker
///   5. System queries Firestore for volunteer's registration record
///   6. If registered → marks status as 'attended' with timestamp
///   7. If not registered / already attended → shows appropriate error
///
/// Security:
///   - QR payloads include a 'type' field to reject non-HRAS QR codes
///   - Volunteer must be pre-registered for the campaign
///   - Duplicate attendance is prevented by status check
///
/// Platform Support:
///   - Mobile: Uses mobile_scanner for native camera QR scanning
///   - Web: Fallback message shown (camera scanning not supported)
///
/// VIVA PREP EXPLANATION (QR Attendance):
/// Q: How does the QR Attendance work under the hood?
/// A:
/// 1. The Admin creates a campaign. A unique JSON payload is generated encoding the Campaign ID.
/// 2. This JSON is visually represented as a QR code using the 'qr_flutter' package.
/// 3. When a Volunteer arrives, they open the app and scan it using the 'mobile_scanner' package.
/// 4. The app reads the Campaign ID, goes to Firestore, and checks if this Volunteer is registered.
/// 5. If yes, it updates their status to "attended". If no, it shows an error.
/// This prevents buddy-punching (proxy attendance) because it checks the user's logged-in Firebase ID.
class QrService {
  QrService._();

  /// Generate QR code payload for a campaign.
  ///
  /// Returns a JSON string containing campaign ID and metadata.
  /// The QR code encodes this string which is then scanned by volunteers.
  static String generateQrPayload({
    required String campaignId,
    required String campaignTitle,
  }) {
    final payload = {
      'type': 'hras_attendance',
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
      'generatedAt': DateTime.now().toIso8601String(),
    };
    return jsonEncode(payload);
  }

  /// Parse a scanned QR code payload.
  ///
  /// Returns null if the QR code is invalid, not from HRAS, or expired.
  static Map<String, dynamic>? parseQrPayload(String rawData) {
    try {
      final data = jsonDecode(rawData) as Map<String, dynamic>;
      if (data['type'] != 'hras_attendance') return null;
      if (data['campaignId'] == null) return null;

      // FYP-03 Security Fix: TTL Expiry Check (Guarded by Phase Flag)
      if (FeatureFlags.isSecureQrEnabled && data['generatedAt'] != null) {
        final generatedAt = DateTime.parse(data['generatedAt']);
        final difference = DateTime.now().difference(generatedAt).inSeconds;

        // If QR is older than 60 seconds, it's considered an expired screenshot
        if (difference > 60 || difference < -5) {
          // -5 allows for slight clock skew
          return {'error': 'EXPIRED_QR'};
        }
      }

      return data;
    } catch (_) {
      return null;
    }
  }

  /// Mark attendance for a volunteer by scanning a QR code.
  ///
  /// Finds the volunteer's registration for the campaign and updates
  /// their status to 'attended' with the current timestamp.
  static Future<QrScanResult> markAttendance({
    required String qrRawData,
    required String userId,
    required String userName,
  }) async {
    // Parse QR
    final payload = parseQrPayload(qrRawData);
    if (payload == null) {
      return QrScanResult(
        success: false,
        message: 'Invalid QR code. This is not an HRAS attendance code.',
      );
    }

    if (payload['error'] == 'EXPIRED_QR') {
      return QrScanResult(
        success: false,
        message:
            'Security Alert: This QR code has expired (Screenshot detected). Ask the admin to refresh their screen.',
      );
    }

    final campaignId = payload['campaignId'] as String;
    final campaignTitle =
        payload['campaignTitle'] as String? ?? 'Unknown Campaign';

    try {
      // Find volunteer registration for this campaign
      final snapshot = await FirebaseFirestore.instance
          .collection('volunteers')
          .where('campaignId', isEqualTo: campaignId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return QrScanResult(
          success: false,
          message:
              'You are not registered for "$campaignTitle". Please register first.',
        );
      }

      final doc = snapshot.docs.first;
      final currentStatus = doc.data()['status'] as String?;

      if (currentStatus == VolunteerStatus.attended.name) {
        return QrScanResult(
          success: false,
          message: 'Attendance already marked for "$campaignTitle".',
        );
      }

      // Mark as attended
      await VolunteerService().updateVolunteerStatus(
        doc.id,
        VolunteerStatus.attended,
      );

      return QrScanResult(
        success: true,
        message: 'Attendance marked for "$campaignTitle"!',
        campaignId: campaignId,
        campaignTitle: campaignTitle,
      );
    } catch (e) {
      return QrScanResult(
        success: false,
        message: 'Failed to mark attendance: ${e.toString()}',
      );
    }
  }
}

/// Result of a QR scan attempt.
class QrScanResult {
  final bool success;
  final String message;
  final String? campaignId;
  final String? campaignTitle;

  QrScanResult({
    required this.success,
    required this.message,
    this.campaignId,
    this.campaignTitle,
  });
}
