import '../models/campaign_model.dart';
import '../models/user_model.dart';
import '../models/match_result_model.dart';
import '../models/volunteer_model.dart';
import '../enums/app_enums.dart';

/// Smart Volunteer-Campaign Matching Service.
///
/// Uses a weighted scoring algorithm to recommend campaigns to volunteers:
///   - Skills match (50%): Maps user skills to campaign types
///   - Location match (30%): Compares user address with campaign location
///   - Availability (20%): Bonus if not already registered
///
/// This is a real, explainable algorithm — not fake AI.
class MatchingService {
  MatchingService._();

  // ─── Weights ──────────────────────────────────────────────────
  static const double _skillWeight = 0.50;
  static const double _locationWeight = 0.30;
  static const double _availabilityWeight = 0.20;

  // ─── Skill-to-CampaignType Mapping ────────────────────────────
  /// Maps user skill keywords to relevant campaign types.
  static final Map<String, List<CampaignType>> _skillCampaignMap = {
    'medical':     [CampaignType.medical],
    'healthcare':  [CampaignType.medical],
    'doctor':      [CampaignType.medical],
    'nursing':     [CampaignType.medical],
    'first aid':   [CampaignType.medical],
    'teaching':    [CampaignType.education],
    'education':   [CampaignType.education],
    'tutoring':    [CampaignType.education],
    'cooking':     [CampaignType.ration, CampaignType.ramadan, CampaignType.eid],
    'food':        [CampaignType.ration, CampaignType.ramadan],
    'distribution':[CampaignType.ration, CampaignType.winterDrive],
    'logistics':   [CampaignType.ration, CampaignType.winterDrive],
    'driving':     [CampaignType.ration, CampaignType.winterDrive],
    'gardening':   [CampaignType.plantation],
    'environment': [CampaignType.plantation, CampaignType.waterBirds],
    'childcare':   [CampaignType.orphanage, CampaignType.education],
    'social work': [CampaignType.orphanage, CampaignType.marriage],
    'event':       [CampaignType.marriage, CampaignType.eid],
    'photography': [CampaignType.marriage, CampaignType.eid],
    'fundraising': [CampaignType.custom],
    'management':  [CampaignType.custom],
  };

  /// Returns sorted list of campaign recommendations for a volunteer.
  ///
  /// [user] — The logged-in volunteer's profile.
  /// [campaigns] — All available active/upcoming campaigns.
  /// [existingRegistrations] — Campaigns the user is already registered for.
  static List<MatchResult> getRecommendations({
    required UserModel user,
    required List<CampaignModel> campaigns,
    List<VolunteerModel> existingRegistrations = const [],
  }) {
    final registeredCampaignIds =
        existingRegistrations.map((v) => v.campaignId).toSet();

    final results = <MatchResult>[];

    for (final campaign in campaigns) {
      // Skip completed campaigns
      if (campaign.isCompleted) continue;
      // Skip full campaigns
      if (campaign.isFull) continue;

      final skillScore = _calculateSkillScore(user.skills, campaign.type);
      final locationScore = _calculateLocationScore(user.address, campaign.location);
      final availabilityScore = registeredCampaignIds.contains(campaign.id) ? 0.0 : 1.0;

      final totalScore =
          (skillScore * _skillWeight) +
          (locationScore * _locationWeight) +
          (availabilityScore * _availabilityWeight);

      final reason = _buildReason(skillScore, locationScore, availabilityScore, campaign);

      results.add(MatchResult(
        campaign: campaign,
        score: totalScore,
        reason: reason,
        breakdown: {
          'skills': skillScore,
          'location': locationScore,
          'availability': availabilityScore,
        },
      ));
    }

    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  /// Calculate skill match score (0.0 - 1.0).
  static double _calculateSkillScore(List<String> userSkills, CampaignType campaignType) {
    if (userSkills.isEmpty) return 0.3; // Neutral score for users without skills

    int matchCount = 0;
    for (final skill in userSkills) {
      final normalizedSkill = skill.toLowerCase().trim();
      final mappedTypes = _skillCampaignMap[normalizedSkill];
      if (mappedTypes != null && mappedTypes.contains(campaignType)) {
        matchCount++;
      }
    }

    if (matchCount == 0) return 0.1; // Has skills but none match
    if (matchCount == 1) return 0.7;
    return 1.0; // Multiple skills match
  }

  /// Calculate location match score (0.0 - 1.0).
  /// Uses simple string containment — not GPS-based.
  static double _calculateLocationScore(String? userAddress, String campaignLocation) {
    if (userAddress == null || userAddress.isEmpty) return 0.3; // Unknown = neutral

    final userLower = userAddress.toLowerCase();
    final campaignLower = campaignLocation.toLowerCase();

    // Extract city names for comparison
    final userCity = _extractCity(userLower);
    final campaignCity = _extractCity(campaignLower);

    if (userCity == campaignCity && userCity.isNotEmpty) return 1.0; // Same city
    if (campaignLower.contains(userLower) || userLower.contains(campaignLower)) return 0.8;
    return 0.1; // Different location
  }

  /// Extract city name from address string.
  static String _extractCity(String address) {
    // Common Pakistani city names
    const cities = [
      'multan', 'lahore', 'karachi', 'islamabad', 'rawalpindi',
      'faisalabad', 'peshawar', 'quetta', 'hyderabad', 'sialkot',
      'gujranwala', 'bahawalpur', 'sargodha', 'sahiwal', 'dera ghazi khan',
    ];
    for (final city in cities) {
      if (address.contains(city)) return city;
    }
    return '';
  }

  /// Build human-readable reason for the match.
  static String _buildReason(
    double skillScore,
    double locationScore,
    double availabilityScore,
    CampaignModel campaign,
  ) {
    final parts = <String>[];

    if (skillScore >= 0.7) {
      parts.add('Your skills match this ${campaign.type.label} campaign');
    } else if (skillScore >= 0.3) {
      parts.add('This campaign type may interest you');
    }

    if (locationScore >= 0.8) {
      parts.add('near your area');
    }

    if (availabilityScore == 0.0) {
      parts.add('(already registered)');
    }

    return parts.isEmpty ? 'Recommended campaign' : parts.join(' • ');
  }
}
