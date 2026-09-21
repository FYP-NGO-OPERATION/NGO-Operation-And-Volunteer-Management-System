import '../models/campaign_model.dart';
import '../models/user_model.dart';
import '../models/match_result_model.dart';
import '../models/volunteer_model.dart';
import '../enums/app_enums.dart';
import '../config/feature_flags.dart';

/// Smart Volunteer-Campaign Matching Service.
class MatchingService {
  MatchingService._();

  // Weights configuration (Strict 40/30/20/10 distribution)
  static const double _wSkill = 0.40;
  static const double _wLocation = 0.30;
  static const double _wPastActivity = 0.20;
  static const double _wAvailability = 0.10;

  static final Map<String, List<CampaignType>> _skillCampaignMap = {
    'medical': [CampaignType.medical],
    'healthcare': [CampaignType.medical],
    'doctor': [CampaignType.medical],
    'nursing': [CampaignType.medical],
    'first aid': [CampaignType.medical],
    'teaching': [CampaignType.education],
    'education': [CampaignType.education],
    'tutoring': [CampaignType.education],
    'cooking': [CampaignType.ration, CampaignType.ramadan, CampaignType.eid],
    'food': [CampaignType.ration, CampaignType.ramadan],
    'distribution': [CampaignType.ration, CampaignType.winterDrive],
    'logistics': [CampaignType.ration, CampaignType.winterDrive],
    'driving': [CampaignType.ration, CampaignType.winterDrive],
    'gardening': [CampaignType.plantation],
    'environment': [CampaignType.plantation, CampaignType.waterBirds],
    'childcare': [CampaignType.orphanage, CampaignType.education],
    'social work': [CampaignType.orphanage, CampaignType.marriage],
    'event': [CampaignType.marriage, CampaignType.eid],
    'photography': [CampaignType.marriage, CampaignType.eid],
    'fundraising': [CampaignType.custom],
    'management': [CampaignType.custom],
  };

  /// Fetches AI-recommended campaigns. Branches based on FYP Phase.
  static Future<List<MatchResult>> getRecommendations({
    required UserModel user,
    required List<CampaignModel> campaigns,
    required List<VolunteerModel> existingRegistrations,
  }) async {
    // ─── FYP-03: Optimized Server-Side Matching ───
    if (FeatureFlags.isServerSideMatchingEnabled) {
      try {
        throw Exception('Cloud Functions not configured. Fallback to local.');
      } catch (e) {
        debugPrint(
            'Failed to geocode ngo address: $e (Falling back to exact city string match)');
        // Fallback to local logic
      }
    }

    // ─── FYP-02: Basic Client-Side Matching ───
    return _calculateLocalMatches(user, campaigns, existingRegistrations);
  }

  static List<MatchResult> _calculateLocalMatches(
    UserModel user,
    List<CampaignModel> campaigns,
    List<VolunteerModel> existingRegistrations,
  ) {
    List<MatchResult> results = [];
    final registeredCampaignIds = existingRegistrations
        .map((e) => e.campaignId)
        .toSet();
    final pastCampaignTypes = existingRegistrations
        .map((e) => e.campaignTitle.toLowerCase())
        .toList();

    for (var campaign in campaigns) {
      if (campaign.status != CampaignStatus.active) continue;
      if (campaign.isFull) continue;

      double skillScore = _calculateSkillScore(user.skills, campaign);
      double locationScore = _calculateLocationScore(
        user.address,
        campaign.location,
      );
      double activityScore = _calculatePastActivityScore(
        pastCampaignTypes,
        campaign,
      );
      double availabilityScore = registeredCampaignIds.contains(campaign.id)
          ? 0.0
          : 1.0;

      double totalScore =
          (skillScore * _wSkill) +
          (locationScore * _wLocation) +
          (activityScore * _wPastActivity) +
          (availabilityScore * _wAvailability);

      if (totalScore >= 0.4) {
        results.add(
          MatchResult(
            campaign: campaign,
            score: totalScore,
            breakdown: {
              'skills': skillScore,
              'location': locationScore,
              'past_activity': activityScore,
              'availability': availabilityScore,
            },
            reason: _generateReason(skillScore, locationScore, activityScore),
          ),
        );
      }
    }
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(10).toList();
  }

  static double _calculateSkillScore(
    List<String> userSkills,
    CampaignModel campaign,
  ) {
    if (userSkills.isEmpty) return 0.3;

    // Exact match based on required skills
    if (campaign.requiredSkills.isNotEmpty) {
      int matches = 0;
      for (String req in campaign.requiredSkills) {
        if (userSkills.any((s) => s.toLowerCase() == req.toLowerCase())) {
          matches++;
        }
      }
      if (matches >= campaign.requiredSkills.length &&
          campaign.requiredSkills.isNotEmpty)
        return 1.0;
      if (matches > 0) return 0.8;
    }

    // Fallback to type mapping
    int matches = 0;
    for (String skill in userSkills) {
      final s = skill.toLowerCase().trim();
      final mappedTypes = _skillCampaignMap[s] ?? [CampaignType.custom];
      if (mappedTypes.contains(campaign.type)) matches++;
    }
    if (matches > 1) return 1.0;
    if (matches == 1) return 0.7;
    return 0.1;
  }

  static double _calculateLocationScore(
    String? userAddress,
    String campaignLocation,
  ) {
    if (userAddress == null || userAddress.isEmpty) return 0.3;
    final uLoc = userAddress.toLowerCase();
    final cLoc = campaignLocation.toLowerCase();
    if (uLoc == cLoc) return 1.0;
    if (uLoc.contains(cLoc) || cLoc.contains(uLoc)) return 0.8;
    return 0.1;
  }

  static double _calculatePastActivityScore(
    List<String> pastHistory,
    CampaignModel campaign,
  ) {
    if (pastHistory.isEmpty) return 0.2;
    final cType = campaign.type.name.toLowerCase();
    final cTitle = campaign.title.toLowerCase();
    bool exactTypeMatch = pastHistory.any(
      (h) => h.contains(cType) || cTitle.contains(h.split(' ')[0]),
    );
    if (exactTypeMatch) return 1.0;
    return 0.5;
  }

  /// Returns a human-readable label for the given match score.
  static String getLabelForScore(double score) {
    if (score >= 0.8) return 'Excellent Match';
    if (score >= 0.6) return 'Good Match';
    if (score >= 0.4) return 'Fair Match';
    return 'Low Match';
  }

  static String _generateReason(double s, double l, double a) {
    if (s >= 0.7 && l >= 0.8)
      return 'Perfectly matches your skills and is located near you.';
    if (s >= 0.7) return 'Strong match for your declared skills.';
    if (l >= 0.8) return 'This campaign is happening in your area.';
    if (a >= 0.8) return 'Based on your previous volunteer activity.';
    return 'Recommended based on general community needs.';
  }
}
