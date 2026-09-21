import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/volunteer_model.dart';
import '../enums/app_enums.dart';
import '../utils/network_resilience_helper.dart';
import 'package:uuid/uuid.dart';

/// Service for volunteer registration and attendance management.
class VolunteerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _volunteers =>
      _db.collection('volunteers');
  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _db.collection('campaigns');

  // ═══════════════════════════════════════════
  // ─── JOIN / LEAVE ───
  // ═══════════════════════════════════════════

  /// Join a campaign as volunteer
  Future<VolunteerModel> joinCampaign({
    required String campaignId,
    required String campaignTitle,
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) async {
    // Check if already joined
    final existing = await _volunteers
        .where('campaignId', isEqualTo: campaignId)
        .where('userId', isEqualTo: userId)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You have already joined this campaign.');
    }

    final docRef = _volunteers.doc();
    final volunteer = VolunteerModel(
      id: docRef.id,
      campaignId: campaignId,
      campaignTitle: campaignTitle,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      status: VolunteerStatus.pending,
      registeredAt: DateTime.now(),
    );

    final campaignRef = _campaigns.doc(campaignId);
    final userRef = _db.collection('users').doc(userId);

    // SECURE: Enforce volunteer limits using a transaction to prevent race conditions
    await _db.runTransaction((transaction) async {
      final campaignSnapshot = await transaction.get(campaignRef);
      if (!campaignSnapshot.exists) throw Exception('Campaign not found.');

      final data = campaignSnapshot.data() as Map<String, dynamic>;
      final volunteerLimit = data['volunteerLimit'] as int?;
      final totalVolunteers = data['totalVolunteers'] as int? ?? 0;

      if (volunteerLimit != null &&
          volunteerLimit > 0 &&
          totalVolunteers >= volunteerLimit) {
        throw Exception('Campaign is full. Cannot join.');
      }

      transaction.set(docRef, volunteer.toMap());
      transaction.update(campaignRef, {
        'totalVolunteers': totalVolunteers + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(userRef, {'campaignsJoined': FieldValue.increment(1)});
    });

    return volunteer;
  }

  // ═══════════════════════════════════════════
  // ─── ADMIN: MANUAL ADD ───
  // ═══════════════════════════════════════════

  /// Admin manually adds a volunteer (for past/completed campaigns).
  /// Does NOT require the volunteer to have a Firebase account.
  Future<VolunteerModel> addVolunteerManually({
    required String campaignId,
    required String campaignTitle,
    required String volunteerName,
    required String volunteerEmail,
    String? volunteerPhone,
    String statusStr = 'attended',
    required String addedByAdminId,
  }) async {
    final id = const Uuid().v4();
    final status = VolunteerStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => VolunteerStatus.attended,
    );
    final now = DateTime.now();
    final volunteer = VolunteerModel(
      id: id,
      campaignId: campaignId,
      campaignTitle: campaignTitle,
      userId: 'manual_$id', // synthetic userId — no real Firebase account
      userName: volunteerName,
      userEmail: volunteerEmail,
      userPhone: volunteerPhone,
      status: status,
      registeredAt: now,
      attendedAt: status == VolunteerStatus.attended ? now : null,
      notes: 'Added manually by admin',
    );

    final batch = _db.batch();
    batch.set(_volunteers.doc(id), volunteer.toMap());
    batch.update(_campaigns.doc(campaignId), {
      'totalVolunteers': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
    return volunteer;
  }

  /// Leave a campaign
  Future<void> leaveCampaign({
    required String volunteerId,
    required String campaignId,
    required String userId,
  }) async {
    final batch = _db.batch();
    batch.delete(_volunteers.doc(volunteerId));
    batch.update(_campaigns.doc(campaignId), {
      'totalVolunteers': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('users').doc(userId), {
      'campaignsJoined': FieldValue.increment(-1),
    });

    // AUDIT LOG (Zero-Trust)
    final auditRef = _db.collection('audit_logs').doc();
    batch.set(auditRef, {
      'action': 'VOLUNTEER_LEAVE_CAMPAIGN',
      'userId': userId,
      'campaignId': campaignId,
      'volunteerId': volunteerId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await ChaosResilience.withRetry(() => batch.commit());
  }

  // ═══════════════════════════════════════════
  // ─── QUERIES ───
  // ═══════════════════════════════════════════

  /// Check if user already joined a campaign
  Future<VolunteerModel?> getUserVolunteerRecord(
    String campaignId,
    String userId,
  ) async {
    final snapshot = await _volunteers
        .where('campaignId', isEqualTo: campaignId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return VolunteerModel.fromMap(snapshot.docs.first.data());
  }

  /// Get all volunteers for a campaign (real-time stream)
  Stream<List<VolunteerModel>> getVolunteersStream(String campaignId) {
    return _volunteers
        .where('campaignId', isEqualTo: campaignId)
        .limit(500) // SECURE: Added limit to prevent billing spikes
        .snapshots()
        .map((snapshot) {
          final list =
              snapshot.docs
                  .map((doc) => VolunteerModel.fromMap(doc.data()))
                  .toList()
                ..sort((a, b) => a.registeredAt.compareTo(b.registeredAt));
          return list;
        });
  }

  /// Get all campaigns a user has joined
  Stream<List<VolunteerModel>> getUserCampaignsStream(String userId) {
    return _volunteers
        .where('userId', isEqualTo: userId)
        .limit(500)
        .snapshots()
        .map((snapshot) {
          final list =
              snapshot.docs
                  .map((doc) => VolunteerModel.fromMap(doc.data()))
                  .toList()
                ..sort((a, b) => b.registeredAt.compareTo(a.registeredAt));
          return list;
        });
  }

  /// Get volunteer count for a campaign
  Future<int> getVolunteerCount(String campaignId) async {
    final snapshot = await _volunteers
        .where('campaignId', isEqualTo: campaignId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // ═══════════════════════════════════════════
  // ─── ATTENDANCE (Admin only) ───
  // ═══════════════════════════════════════════

  /// Mark attendance for a volunteer
  Future<void> markAttendance(
    String volunteerId,
    VolunteerStatus status,
  ) async {
    final Map<String, dynamic> data = {'status': status.name};
    if (status == VolunteerStatus.attended) {
      data['attendedAt'] = FieldValue.serverTimestamp();
    }
    if (status == VolunteerStatus.confirmed) {
      data['confirmedAt'] = FieldValue.serverTimestamp();
    }
    await _volunteers.doc(volunteerId).update(data);
  }

  /// Bulk mark attendance for multiple volunteers
  Future<void> markBulkAttendance(
    List<String> volunteerIds,
    VolunteerStatus status,
  ) async {
    final batch = _db.batch();
    for (final id in volunteerIds) {
      final Map<String, dynamic> data = {'status': status.name};
      if (status == VolunteerStatus.attended) {
        data['attendedAt'] = FieldValue.serverTimestamp();
      }
      batch.update(_volunteers.doc(id), data);
    }
    await batch.commit();
  }

  /// Fetch all registrations for a user as a one-time list (for matching algorithm).
  Future<List<VolunteerModel>> fetchUserRegistrations(String userId) async {
    final snapshot = await _volunteers
        .where('userId', isEqualTo: userId)
        .limit(500)
        .get();
    return snapshot.docs
        .map((doc) => VolunteerModel.fromMap(doc.data()))
        .toList();
  }

  /// Update volunteer status (alias used by QR service).
  Future<void> updateVolunteerStatus(
    String volunteerId,
    VolunteerStatus status,
  ) async {
    await markAttendance(volunteerId, status);
  }

  /// Reject a volunteer request (deletes the record and decrements totalVolunteers)
  Future<void> rejectVolunteer(String volunteerId, String campaignId) async {
    final batch = _db.batch();
    batch.delete(_volunteers.doc(volunteerId));
    batch.update(_campaigns.doc(campaignId), {
      'totalVolunteers': FieldValue.increment(-1),
    });

    // AUDIT LOG (Zero-Trust)
    final auditRef = _db.collection('audit_logs').doc();
    batch.set(auditRef, {
      'action': 'REJECT_VOLUNTEER',
      'adminId': FirebaseAuth.instance.currentUser?.uid ?? 'UNKNOWN',
      'campaignId': campaignId,
      'volunteerId': volunteerId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await ChaosResilience.withRetry(() => batch.commit());
  }
}
