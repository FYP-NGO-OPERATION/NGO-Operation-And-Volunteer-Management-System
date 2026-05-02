import '../models/campaign_model.dart';

/// Result of volunteer-campaign matching with score and explanation.
class MatchResult {
  final CampaignModel campaign;
  final double score; // 0.0 to 1.0
  final String reason;
  final Map<String, double> breakdown;

  MatchResult({
    required this.campaign,
    required this.score,
    required this.reason,
    required this.breakdown,
  });

  /// Match quality label based on score.
  String get qualityLabel {
    if (score >= 0.8) return 'Excellent Match';
    if (score >= 0.6) return 'Good Match';
    if (score >= 0.4) return 'Fair Match';
    return 'Low Match';
  }

  /// Match percentage for display.
  int get percentage => (score * 100).round();
}
