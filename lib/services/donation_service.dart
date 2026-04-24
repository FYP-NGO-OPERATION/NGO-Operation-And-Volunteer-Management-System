import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';

/// Service for donation CRUD operations.
class DonationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _donations =>
      _db.collection('donations');
  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _db.collection('campaigns');

  // ═══════════════════════════════════════════
  // ─── CREATE ───
  // ═══════════════════════════════════════════

  /// Add a new donation record (admin only)
  Future<DonationModel> addDonation(DonationModel donation) async {
    final docRef = _donations.doc();
    final donationWithId = DonationModel(
      id: docRef.id,
      campaignId: donation.campaignId,
      campaignTitle: donation.campaignTitle,
      donorName: donation.donorName,
      donorPhone: donation.donorPhone,
      donorCnic: donation.donorCnic,
      category: donation.category,
      quantity: donation.quantity,
      amount: donation.amount,
      amountCash: donation.amountCash,
      amountOnline: donation.amountOnline,
      paymentMethod: donation.paymentMethod,
      purpose: donation.purpose,
      description: donation.description,
      receivedBy: donation.receivedBy,
      receivedByName: donation.receivedByName,
      receivedAt: donation.receivedAt,
    );

    // Use batch to save donation + update campaign counters
    final batch = _db.batch();
    batch.set(docRef, donationWithId.toMap());

    // Update campaign donation counters
    final totalMoney = donation.amountCash + donation.amountOnline;
    batch.update(_campaigns.doc(donation.campaignId), {
      'totalDonationsCount': FieldValue.increment(1),
      'totalDonationsAmount': FieldValue.increment(totalMoney),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return donationWithId;
  }

  // ═══════════════════════════════════════════
  // ─── READ ───
  // ═══════════════════════════════════════════

  /// Get donations stream for a campaign (real-time)
  Stream<List<DonationModel>> getDonationsStream(String campaignId) {
    return _donations
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('receivedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DonationModel.fromMap(doc.data()))
            .toList());
  }

  /// Get all donations (admin)
  Stream<List<DonationModel>> getAllDonationsStream() {
    return _donations
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DonationModel.fromMap(doc.data()))
            .toList());
  }

  /// Get donation by ID
  Future<DonationModel?> getDonationById(String id) async {
    final doc = await _donations.doc(id).get();
    if (!doc.exists) return null;
    return DonationModel.fromMap(doc.data()!);
  }

  // ═══════════════════════════════════════════
  // ─── DELETE ───
  // ═══════════════════════════════════════════

  /// Delete a donation record
  Future<void> deleteDonation(DonationModel donation) async {
    final batch = _db.batch();
    batch.delete(_donations.doc(donation.id));

    // Decrement campaign counters
    final totalMoney = donation.amountCash + donation.amountOnline;
    batch.update(_campaigns.doc(donation.campaignId), {
      'totalDonationsCount': FieldValue.increment(-1),
      'totalDonationsAmount': FieldValue.increment(-totalMoney),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ═══════════════════════════════════════════
  // ─── STATS ───
  // ═══════════════════════════════════════════

  /// Get donation summary for a campaign
  Future<Map<String, dynamic>> getDonationStats(String campaignId) async {
    final snapshot = await _donations
        .where('campaignId', isEqualTo: campaignId)
        .get();

    double totalCash = 0, totalOnline = 0;
    int totalCount = snapshot.docs.length;
    Map<String, int> categoryCounts = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      totalCash += (data['amountCash'] ?? 0).toDouble();
      totalOnline += (data['amountOnline'] ?? 0).toDouble();
      final cat = data['category'] ?? 'other';
      categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
    }

    return {
      'totalCount': totalCount,
      'totalCash': totalCash,
      'totalOnline': totalOnline,
      'totalAmount': totalCash + totalOnline,
      'categoryCounts': categoryCounts,
    };
  }
}
