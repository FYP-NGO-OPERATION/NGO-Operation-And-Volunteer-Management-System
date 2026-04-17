import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/volunteer_model.dart';
import '../enums/app_enums.dart';

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
      status: VolunteerStatus.registered,
      registeredAt: DateTime.now(),
    );

    // Write volunteer doc and increment campaign counter in batch
    final batch = _db.batch();
    batch.set(docRef, volunteer.toMap());
    batch.update(_campaigns.doc(campaignId), {
      'totalVolunteers': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    // Also increment user's campaignsJoined
    batch.update(_db.collection('users').doc(userId), {
      'campaignsJoined': FieldValue.increment(1),
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
    await batch.commit();
  }

  // ═══════════════════════════════════════════
  // ─── QUERIES ───
  // ═══════════════════════════════════════════

  /// Check if user already joined a campaign
  Future<VolunteerModel?> getUserVolunteerRecord(
      String campaignId, String userId) async {
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
        .orderBy('registeredAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VolunteerModel.fromMap(doc.data()))
            .toList());
  }

  /// Get all campaigns a user has joined
  Stream<List<VolunteerModel>> getUserCampaignsStream(String userId) {
    return _volunteers
        .where('userId', isEqualTo: userId)
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VolunteerModel.fromMap(doc.data()))
            .toList());
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
      String volunteerId, VolunteerStatus status) async {
    final Map<String, dynamic> data = {
      'status': status.name,
    };
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
      List<String> volunteerIds, VolunteerStatus status) async {
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

  /// Get attendance stats for a campaign
  Future<Map<String, int>> getAttendanceStats(String campaignId) async {
    final snapshot = await _volunteers
        .where('campaignId', isEqualTo: campaignId)
        .get();

    int registered = 0, confirmed = 0, attended = 0, absent = 0;
    for (final doc in snapshot.docs) {
      final status = doc.data()['status'] ?? 'registered';
      switch (status) {
        case 'registered':
          registered++;
          break;
        case 'confirmed':
          confirmed++;
          break;
        case 'attended':
          attended++;
          break;
        case 'absent':
          absent++;
          break;
      }
    }
    return {
      'registered': registered,
      'confirmed': confirmed,
      'attended': attended,
      'absent': absent,
      'total': registered + confirmed + attended + absent,
    };
  }
}
