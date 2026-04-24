import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/campaign_model.dart';
import '../models/expense_model.dart';
import '../enums/app_enums.dart';

/// Service for Campaign and Expense CRUD operations on Firestore.
class CampaignService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Collection References ───
  CollectionReference<Map<String, dynamic>> get _campaigns => _db.collection('campaigns');
  CollectionReference<Map<String, dynamic>> get _expenses => _db.collection('expenses');

  // ═══════════════════════════════════════════
  // ─── CAMPAIGN CRUD ───
  // ═══════════════════════════════════════════

  /// Create a new campaign
  Future<CampaignModel> createCampaign(CampaignModel campaign) async {
    final docRef = _campaigns.doc();
    final newCampaign = CampaignModel(
      id: docRef.id,
      title: campaign.title,
      description: campaign.description,
      type: campaign.type,
      status: campaign.status,
      startDate: campaign.startDate,
      endDate: campaign.endDate,
      location: campaign.location,
      coverImageUrl: campaign.coverImageUrl,
      posterImageUrl: campaign.posterImageUrl,
      targetGoal: campaign.targetGoal,
      achievedGoal: campaign.achievedGoal,
      itemsNeeded: campaign.itemsNeeded,
      volunteerLimit: campaign.volunteerLimit,
      createdBy: campaign.createdBy,
      createdByName: campaign.createdByName,
      createdAt: DateTime.now(),
    );
    await docRef.set(newCampaign.toMap());
    return newCampaign;
  }

  /// Get all campaigns (real-time stream)
  Stream<List<CampaignModel>> getCampaignsStream() {
    return _campaigns
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CampaignModel.fromMap(doc.data()))
            .toList());
  }

  /// Get campaigns by status
  Stream<List<CampaignModel>> getCampaignsByStatus(CampaignStatus status) {
    return _campaigns
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CampaignModel.fromMap(doc.data()))
            .toList());
  }

  /// Get single campaign by ID
  Future<CampaignModel?> getCampaignById(String campaignId) async {
    final doc = await _campaigns.doc(campaignId).get();
    if (!doc.exists) return null;
    return CampaignModel.fromMap(doc.data()!);
  }

  /// Get single campaign stream (for real-time updates on detail screen)
  Stream<CampaignModel?> getCampaignStream(String campaignId) {
    return _campaigns.doc(campaignId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CampaignModel.fromMap(doc.data()!);
    });
  }

  /// Update campaign
  Future<void> updateCampaign(CampaignModel campaign) async {
    await _campaigns.doc(campaign.id).update(campaign.toMap());
  }

  /// Update campaign status
  Future<void> updateCampaignStatus(String campaignId, CampaignStatus status) async {
    await _campaigns.doc(campaignId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update campaign progress
  Future<void> updateProgress(String campaignId, int progress) async {
    await _campaigns.doc(campaignId).update({
      'progressPercent': progress,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete campaign and its subcollections (Cascading Delete)
  Future<void> deleteCampaign(String campaignId) async {
    final batch = _db.batch();

    // 1. Delete related expenses
    final expenseDocs = await _expenses.where('campaignId', isEqualTo: campaignId).get();
    for (var doc in expenseDocs.docs) {
      batch.delete(doc.reference);
    }

    // 2. Delete related donations
    final donationDocs = await _db.collection('donations').where('campaignId', isEqualTo: campaignId).get();
    for (var doc in donationDocs.docs) {
      batch.delete(doc.reference);
    }

    // 3. Delete related volunteers and decrement their counters
    final volunteerDocs = await _db.collection('campaign_volunteers').where('campaignId', isEqualTo: campaignId).get();
    for (var doc in volunteerDocs.docs) {
      final userId = doc.data()['userId'] as String?;
      if (userId != null) {
        batch.update(_db.collection('users').doc(userId), {
          'campaignsJoined': FieldValue.increment(-1),
        });
      }
      batch.delete(doc.reference);
    }

    // 4. Delete related beneficiaries
    final beneficiaryDocs = await _db.collection('beneficiaries').where('campaignId', isEqualTo: campaignId).get();
    for (var doc in beneficiaryDocs.docs) {
      batch.delete(doc.reference);
    }

    // 5. Delete related distributions
    final distributionDocs = await _db.collection('distributions').where('campaignId', isEqualTo: campaignId).get();
    for (var doc in distributionDocs.docs) {
      batch.delete(doc.reference);
    }

    // 6. Delete related photos (Firestore AND Storage)
    final photoDocs = await _db.collection('campaign_photos').where('campaignId', isEqualTo: campaignId).get();
    for (var doc in photoDocs.docs) {
      final imageUrl = doc.data()['imageUrl'] as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        } catch (e) {
          // Ignore if file doesn't exist
        }
      }
      batch.delete(doc.reference);
    }

    // 7. Delete campaign itself
    batch.delete(_campaigns.doc(campaignId));

    // Commit all deletions and updates atomically
    await batch.commit();
  }

  /// Increment volunteer count
  Future<void> incrementVolunteers(String campaignId) async {
    await _campaigns.doc(campaignId).update({
      'totalVolunteers': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Decrement volunteer count
  Future<void> decrementVolunteers(String campaignId) async {
    await _campaigns.doc(campaignId).update({
      'totalVolunteers': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update donation totals
  Future<void> updateDonationTotals(String campaignId, double amount) async {
    await _campaigns.doc(campaignId).update({
      'totalDonationsCount': FieldValue.increment(1),
      'totalDonationsAmount': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update expense total
  Future<void> updateExpenseTotal(String campaignId, double amount) async {
    await _campaigns.doc(campaignId).update({
      'totalExpenses': FieldValue.increment(amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════
  // ─── EXPENSE CRUD ───
  // ═══════════════════════════════════════════

  /// Add expense to a campaign
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final docRef = _expenses.doc();
    final newExpense = ExpenseModel(
      id: docRef.id,
      campaignId: expense.campaignId,
      itemName: expense.itemName,
      category: expense.category,
      quantity: expense.quantity,
      unit: expense.unit,
      unitPrice: expense.unitPrice,
      totalAmount: expense.totalAmount,
      vendor: expense.vendor,
      billImageUrl: expense.billImageUrl,
      notes: expense.notes,
      addedBy: expense.addedBy,
      addedByName: expense.addedByName,
      createdAt: DateTime.now(),
    );
    await docRef.set(newExpense.toMap());

    // Update campaign total expenses
    await updateExpenseTotal(expense.campaignId, newExpense.totalAmount);

    return newExpense;
  }

  /// Get expenses for a campaign
  Stream<List<ExpenseModel>> getExpensesStream(String campaignId) {
    return _expenses
        .where('campaignId', isEqualTo: campaignId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromMap(doc.data()))
            .toList());
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId, String campaignId, double amount) async {
    await _expenses.doc(expenseId).delete();
    // Subtract from campaign total
    await _campaigns.doc(campaignId).update({
      'totalExpenses': FieldValue.increment(-amount),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ═══════════════════════════════════════════
  // ─── SEARCH & FILTER ───
  // ═══════════════════════════════════════════

  /// Search campaigns by title
  Future<List<CampaignModel>> searchCampaigns(String query) async {
    final snapshot = await _campaigns.get();
    final allCampaigns = snapshot.docs
        .map((doc) => CampaignModel.fromMap(doc.data()))
        .toList();

    final lowerQuery = query.toLowerCase();
    return allCampaigns
        .where((c) =>
            c.title.toLowerCase().contains(lowerQuery) ||
            c.description.toLowerCase().contains(lowerQuery) ||
            c.location.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Get campaign count
  Future<int> getCampaignCount() async {
    final snapshot = await _campaigns.count().get();
    return snapshot.count ?? 0;
  }
}
