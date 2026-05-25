import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign_model.dart';
import '../models/donation_model.dart';
import '../models/expense_model.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<CampaignModel>> getCampaignsForReport(String ngoId, DateTime start, DateTime end) async {
    final snapshot = await _db.collection('campaigns')
        .where('ngoId', isEqualTo: ngoId)
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .get();
        
    return snapshot.docs.map((doc) => CampaignModel.fromMap(doc.data())).toList();
  }

  Future<List<DonationModel>> getDonationsForReport(DateTime start, DateTime end) async {
    // In a real production app, donations should have an `ngoId` to filter securely.
    // For now we will fetch by date and filter client side if needed, or assume admin has access to all.
    final snapshot = await _db.collection('donations')
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .get();
        
    return snapshot.docs.map((doc) => DonationModel.fromMap(doc.data())).toList();
  }

  Future<List<ExpenseModel>> getExpensesForReport(DateTime start, DateTime end) async {
    final snapshot = await _db.collection('expenses')
        .where('createdAt', isGreaterThanOrEqualTo: start)
        .where('createdAt', isLessThanOrEqualTo: end)
        .get();
        
    return snapshot.docs.map((doc) => ExpenseModel.fromMap(doc.data())).toList();
  }
}
