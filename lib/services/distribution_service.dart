import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/beneficiary_model.dart';
import '../models/distribution_model.dart';

/// Service for Beneficiary and Distribution CRUD operations.
class DistributionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _beneficiaries => _db.collection('beneficiaries');
  CollectionReference<Map<String, dynamic>> get _distributions => _db.collection('distributions');
  CollectionReference<Map<String, dynamic>> get _campaigns => _db.collection('campaigns');

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
    await docRef.set(newBeneficiary.toMap());

    // Update campaign's beneficiaryCount (increment by familySize)
    await _campaigns.doc(beneficiary.campaignId).update({
      'beneficiaryCount': FieldValue.increment(beneficiary.familySize),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return newBeneficiary;
  }

  Stream<List<BeneficiaryModel>> getBeneficiariesStream(String campaignId) {
    return _beneficiaries
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('receivedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BeneficiaryModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> deleteBeneficiary(String beneficiaryId, String campaignId, int familySize) async {
    await _beneficiaries.doc(beneficiaryId).delete();
    
    // Decrement campaign's beneficiaryCount
    await _campaigns.doc(campaignId).update({
      'beneficiaryCount': FieldValue.increment(-familySize),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════
  // ─── DISTRIBUTION CRUD ───
  // ═══════════════════════════════════════════

  Future<DistributionModel> addDistribution(DistributionModel distribution) async {
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
    await docRef.set(newDistribution.toMap());

    // Update campaign's distributionCount (increment by quantity)
    await _campaigns.doc(distribution.campaignId).update({
      'distributionCount': FieldValue.increment(distribution.quantity),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return newDistribution;
  }

  Stream<List<DistributionModel>> getDistributionsStream(String campaignId) {
    return _distributions
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('distributedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DistributionModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> deleteDistribution(String distributionId, String campaignId, int quantity) async {
    await _distributions.doc(distributionId).delete();

    // Decrement campaign's distributionCount
    await _campaigns.doc(campaignId).update({
      'distributionCount': FieldValue.increment(-quantity),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
