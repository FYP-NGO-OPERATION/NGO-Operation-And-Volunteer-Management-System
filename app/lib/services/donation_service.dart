import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';
import '../enums/app_enums.dart';
import '../utils/network_resilience_helper.dart';

class DonationService {
  final FirebaseFirestore _db;

  DonationService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

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
      transactionId: donation.transactionId,
      status: donation.status,
      isAnonymous: donation.isAnonymous,
    );

    await ChaosResilience.withRetry(
      () => _db.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);
        if (docSnapshot.exists) {
          throw Exception("Donation already exists.");
        }

        transaction.set(docRef, donationWithId.toMap());

        // Update campaign donation counters ONLY if approved
        if (donationWithId.status == DonationStatus.approved) {
          final totalMoney = donation.amountCash + donation.amountOnline;
          transaction.update(_campaigns.doc(donation.campaignId), {
            'totalDonationsCount': FieldValue.increment(1),
            'totalDonationsAmount': FieldValue.increment(totalMoney),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }),
    );

    return donationWithId;
  }

  /// Update donation status (approve/reject)
  Future<void> updateDonationStatus(
    DonationModel donation,
    DonationStatus newStatus,
  ) async {
    if (donation.status == newStatus) return;

    await ChaosResilience.withRetry(
      () => _db.runTransaction((transaction) async {
        final docRef = _donations.doc(donation.id);
        final docSnapshot = await transaction.get(docRef);
        if (!docSnapshot.exists) {
          throw Exception("Donation does not exist.");
        }

        final currentStatusStr = docSnapshot.data()?['status'] as String?;
        if (currentStatusStr == newStatus.name) {
          return; // Idempotency check: Already processed
        }

        transaction.update(docRef, {
          'status': newStatus.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // If changing to approved from anything else -> INCREMENT counters
        if (newStatus == DonationStatus.approved &&
            currentStatusStr != DonationStatus.approved.name) {
          final totalMoney = donation.amountCash + donation.amountOnline;
          transaction.update(_campaigns.doc(donation.campaignId), {
            'totalDonationsCount': FieldValue.increment(1),
            'totalDonationsAmount': FieldValue.increment(totalMoney),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        // If changing from approved to something else (e.g., rejected) -> DECREMENT counters
        else if (currentStatusStr == DonationStatus.approved.name &&
            newStatus != DonationStatus.approved) {
          final totalMoney = donation.amountCash + donation.amountOnline;
          transaction.update(_campaigns.doc(donation.campaignId), {
            'totalDonationsCount': FieldValue.increment(-1),
            'totalDonationsAmount': FieldValue.increment(-totalMoney),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }),
    );
  }

  // ═══════════════════════════════════════════
  // ─── READ ───
  // ═══════════════════════════════════════════

  /// Get donations stream for a campaign (real-time)
  Stream<List<DonationModel>> getDonationsStream(String campaignId) {
    return _donations
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('receivedAt', descending: true)
        .limit(
          500,
        ) // SECURE: Added limit to prevent massive billing spikes on large campaigns
        .snapshots()
        .map((snapshot) {
          final list =
              snapshot.docs
                  .map((doc) => DonationModel.fromMap(doc.data()))
                  .toList()
                ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
          return list;
        });
  }

  /// Get all donations (admin)
  Stream<List<DonationModel>> getAllDonationsStream() {
    return _donations
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DonationModel.fromMap(doc.data()))
              .toList(),
        );
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
    await _db.runTransaction((transaction) async {
      final docRef = _donations.doc(donation.id);
      final docSnapshot = await transaction.get(docRef);
      if (!docSnapshot.exists) {
        return; // Already deleted
      }

      transaction.delete(docRef);

      // Decrement campaign counters ONLY if it was approved
      final currentStatusStr = docSnapshot.data()?['status'] as String?;
      if (currentStatusStr == DonationStatus.approved.name) {
        final totalMoney = donation.amountCash + donation.amountOnline;
        transaction.update(_campaigns.doc(donation.campaignId), {
          'totalDonationsCount': FieldValue.increment(-1),
          'totalDonationsAmount': FieldValue.increment(-totalMoney),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
