import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign_model.dart';
import '../enums/app_enums.dart';

class AnalyticsData {
  final int totalCampaigns;
  final int activeCampaigns;
  final int completedCampaigns;
  final int totalVolunteers;
  final int totalBeneficiaries;
  final double totalDonations;
  final Map<String, int> campaignsByType;

  AnalyticsData({
    required this.totalCampaigns,
    required this.activeCampaigns,
    required this.completedCampaigns,
    required this.totalVolunteers,
    required this.totalBeneficiaries,
    required this.totalDonations,
    required this.campaignsByType,
  });
}

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AnalyticsData> getNgoAnalytics(String ngoId) async {
    try {
      final snapshot = await _firestore
          .collection('campaigns')
          .where('ngoId', isEqualTo: ngoId)
          .get();

      int total = snapshot.docs.length;
      int active = 0;
      int completed = 0;
      int volunteers = 0;
      int beneficiaries = 0;
      double donations = 0.0;
      Map<String, int> byType = {};

      for (var doc in snapshot.docs) {
        final campaign = CampaignModel.fromMap(doc.data()..['id'] = doc.id);

        if (campaign.status == CampaignStatus.active) active++;
        if (campaign.status == CampaignStatus.completed) completed++;
        
        volunteers += campaign.totalVolunteers;
        beneficiaries += campaign.beneficiaryCount;
        donations += campaign.totalDonationsAmount;

        final typeName = campaign.type.label;
        byType[typeName] = (byType[typeName] ?? 0) + 1;
      }

      return AnalyticsData(
        totalCampaigns: total,
        activeCampaigns: active,
        completedCampaigns: completed,
        totalVolunteers: volunteers,
        totalBeneficiaries: beneficiaries,
        totalDonations: donations,
        campaignsByType: byType,
      );
    } catch (e) {
      throw Exception('Failed to load analytics: $e');
    }
  }
}
