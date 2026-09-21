import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/beneficiary_model.dart';
import '../models/distribution_model.dart';
import '../utils/network_resilience_helper.dart';

/// Service for Beneficiary and Distribution CRUD operations.
class DistributionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _beneficiaries =>
      _db.collection('beneficiaries');
  CollectionReference<Map<String, dynamic>> get _distributions =>
      _db.collection('distributions');
  CollectionReference<Map<String, dynamic>> get _campaigns =>
      _db.collection('campaigns');

  // ═══════════════════════════════════════════
  // ─── BENEFICIARY CRUD ───
  // ═══════════════════════════════════════════

  Future<BeneficiaryModel> addBeneficiary(BeneficiaryModel beneficiary) async {
    final docRef = _beneficiaries.doc();
    final newBeneficiary = BeneficiaryModel(
      id: docRef.id,
      campaignId: beneficiary.campaignId,
      name: beneficiary.name,
      phone: beneficiary.phone,
      address: beneficiary.address,
      familySize: beneficiary.familySize,
      itemsReceived: beneficiary.itemsReceived,
      receivedAt: beneficiary.receivedAt,
      notes: beneficiary.notes,
      addedBy: beneficiary.addedBy,
    );

    final batch = _db.batch();
    batch.set(docRef, newBeneficiary.toMap());

    // Update campaign's beneficiaryCount (increment by familySize)
    batch.update(_campaigns.doc(beneficiary.campaignId), {
      'beneficiaryCount': FieldValue.increment(beneficiary.familySize),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await ChaosResilience.withRetry(() => batch.commit());

    return newBeneficiary;
  }

  Query<Map<String, dynamic>> getBeneficiariesQuery(String campaignId) {
    return _beneficiaries
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('receivedAt', descending: true);
  }

  Future<void> deleteBeneficiary(
    String beneficiaryId,
    String campaignId,
    int familySize,
  ) async {
    final batch = _db.batch();
    batch.delete(_beneficiaries.doc(beneficiaryId));

    // Decrement campaign's beneficiaryCount
    batch.update(_campaigns.doc(campaignId), {
      'beneficiaryCount': FieldValue.increment(-familySize),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // AUDIT LOG (Zero-Trust)
    final auditRef = _db.collection('audit_logs').doc();
    batch.set(auditRef, {
      'action': 'DELETE_BENEFICIARY',
      'adminId': FirebaseAuth.instance.currentUser?.uid ?? 'UNKNOWN',
      'campaignId': campaignId,
      'beneficiaryId': beneficiaryId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await ChaosResilience.withRetry(() => batch.commit());
  }

  // ═══════════════════════════════════════════
  // ─── DISTRIBUTION CRUD ───
  // ═══════════════════════════════════════════

  Future<DistributionModel> addDistribution(
    DistributionModel distribution,
  ) async {
    final docRef = _distributions.doc();
    final newDistribution = DistributionModel(
      id: docRef.id,
      campaignId: distribution.campaignId,
      itemType: distribution.itemType,
      quantity: distribution.quantity,
      unit: distribution.unit,
      distributedTo: distribution.distributedTo,
      distributedBy: distribution.distributedBy,
      distributedAt: distribution.distributedAt,
      location: distribution.location,
      notes: distribution.notes,
    );

    final batch = _db.batch();
    batch.set(docRef, newDistribution.toMap());

    // Update campaign's distributionCount (increment by quantity)
    batch.update(_campaigns.doc(distribution.campaignId), {
      'distributionCount': FieldValue.increment(distribution.quantity),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await ChaosResilience.withRetry(() => batch.commit());

    return newDistribution;
  }

  Query<Map<String, dynamic>> getDistributionsQuery(String campaignId) {
    return _distributions
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('distributedAt', descending: true);
  }

  Future<void> deleteDistribution(
    String distributionId,
    String campaignId,
    int quantity,
  ) async {
    final batch = _db.batch();
    batch.delete(_distributions.doc(distributionId));

    // Decrement campaign's distributionCount
    batch.update(_campaigns.doc(campaignId), {
      'distributionCount': FieldValue.increment(-quantity),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // AUDIT LOG (Zero-Trust)
    final auditRef = _db.collection('audit_logs').doc();
    batch.set(auditRef, {
      'action': 'DELETE_DISTRIBUTION',
      'adminId': FirebaseAuth.instance.currentUser?.uid ?? 'UNKNOWN',
      'campaignId': campaignId,
      'distributionId': distributionId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await ChaosResilience.withRetry(() => batch.commit());
  }
}
