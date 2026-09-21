import '../models/campaign_model.dart';
import '../models/user_model.dart';
import '../models/match_result_model.dart';
import '../models/volunteer_model.dart';
import '../enums/app_enums.dart';
import '../config/feature_flags.dart';
import 'package:flutter/foundation.dart';

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
        
    // O(1) Hash Map Optimization
    final pastCampaignTypes = existingRegistrations
        .map((e) => e.campaignTitle.toLowerCase())
        .toSet();
    
    // O(1) Skill Mapping Precomputation
    final Set<String> normalizedUserSkills = user.skills.map((s) => s.toLowerCase().trim()).toSet();
    final Set<CampaignType> userMappedTypes = {};
    for (String skill in normalizedUserSkills) {
      final mappedTypes = _skillCampaignMap[skill] ?? [CampaignType.custom];
      userMappedTypes.addAll(mappedTypes);
    }

    for (var campaign in campaigns) {
      if (campaign.status != CampaignStatus.active) continue;
      if (campaign.isFull) continue;

      double skillScore = _calculateSkillScore(normalizedUserSkills, userMappedTypes, campaign);
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
    Set<String> normalizedUserSkills,
    Set<CampaignType> userMappedTypes,
    CampaignModel campaign,
  ) {
    if (normalizedUserSkills.isEmpty) return 0.3;

    // Exact match based on required skills via O(1) hash set lookup
    if (campaign.requiredSkills.isNotEmpty) {
      int matches = 0;
      for (String req in campaign.requiredSkills) {
        if (normalizedUserSkills.contains(req.toLowerCase().trim())) {
          matches++;
        }
      }
      if (matches >= campaign.requiredSkills.length &&
          campaign.requiredSkills.isNotEmpty) {
        return 1.0;
      }
      if (matches > 0) return 0.8;
    }

    // Fallback to type mapping using O(1) set
    if (userMappedTypes.contains(campaign.type)) {
      return 1.0; // Assume 1 match is enough for fallback type mapping score bump
    }
    
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
    Set<String> pastHistory,
    CampaignModel campaign,
  ) {
    if (pastHistory.isEmpty) return 0.2;
    
    final cTitle = campaign.title.toLowerCase();
    
    // Check if the first word of the title exists in past history (fastest)
    if (pastHistory.any((h) => cTitle.contains(h.split(' ')[0]))) {
      return 1.0;
    }
    
    // Check Campaign Type explicitly
    if (pastHistory.any((h) => h.contains(campaign.type.name.toLowerCase()))) {
      return 0.8;
    }
    
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
    if (s >= 0.7 && l >= 0.8) {
      return 'Perfectly matches your skills and is located near you.';
    }
    if (s >= 0.7) return 'Strong match for your declared skills.';
    if (l >= 0.8) return 'This campaign is happening in your area.';
    if (a >= 0.8) return 'Based on your previous volunteer activity.';
    return 'Recommended based on general community needs.';
  }
}
