import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../models/match_result_model.dart';
import '../../models/user_model.dart';
import '../../services/matching_service.dart';
import '../../services/campaign_service.dart';
import '../../services/volunteer_service.dart';
import 'campaign_detail_screen.dart';

/// Shows AI-recommended campaigns sorted by match score.
/// Only visible when FeatureFlags.isSmartMatchingEnabled is true.
class RecommendedCampaignsScreen extends StatefulWidget {
  final UserModel user;
  const RecommendedCampaignsScreen({super.key, required this.user});

  @override
  State<RecommendedCampaignsScreen> createState() => _RecommendedCampaignsScreenState();
}

class _RecommendedCampaignsScreenState extends State<RecommendedCampaignsScreen> {
  List<MatchResult> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final campaigns = await CampaignService().fetchAllCampaigns();
      final registrations = await VolunteerService().fetchUserRegistrations(widget.user.uid);

      final results = MatchingService.getRecommendations(
        user: widget.user,
        campaigns: campaigns,
        existingRegistrations: registrations,
      );

      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended For You', style: AppTextStyles.titleLarge()),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: AppColors.lightTextHint),
                      AppSpacing.vGapLg,
                      Text('No recommendations available',
                          style: AppTextStyles.bodyLarge(color: AppColors.lightTextSecondary)),
                      AppSpacing.vGapSm,
                      Text('Add skills to your profile for better matches',
                          style: AppTextStyles.bodyMedium(color: AppColors.lightTextHint)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRecommendations,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final result = _results[index];
                      return _MatchCard(result: result, isDark: isDark);
                    },
                  ),
                ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchResult result;
  final bool isDark;

  const _MatchCard({required this.result, required this.isDark});

  Color get _scoreColor {
    if (result.score >= 0.7) return AppColors.success;
    if (result.score >= 0.4) return AppColors.warning;
    return AppColors.lightTextHint;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppTokens.borderRadiusMd,
        side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CampaignDetailScreen(campaign: result.campaign),
            ),
          );
        },
        borderRadius: AppTokens.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title + Score Badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      result.campaign.title,
                      style: AppTextStyles.titleMedium(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.hGapMd,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: _scoreColor.withValues(alpha: 0.15),
                      borderRadius: AppTokens.borderRadiusPill,
                    ),
                    child: Text(
                      '${result.percentage}%',
                      style: AppTextStyles.labelLarge(color: _scoreColor),
                    ),
                  ),
                ],
              ),
              AppSpacing.vGapSm,

              // Quality label
              Text(
                result.qualityLabel,
                style: AppTextStyles.labelSmall(color: _scoreColor),
              ),
              AppSpacing.vGapMd,

              // Campaign meta
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                  AppSpacing.hGapSm,
                  Text(result.campaign.type.label,
                      style: AppTextStyles.bodySmall(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  AppSpacing.hGapLg,
                  Icon(Icons.location_on, size: 16, color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint),
                  AppSpacing.hGapSm,
                  Expanded(
                    child: Text(result.campaign.location,
                        style: AppTextStyles.bodySmall(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              AppSpacing.vGapMd,

              // Reason
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.08),
                  borderRadius: AppTokens.borderRadiusSm,
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: AppColors.info),
                    AppSpacing.hGapSm,
                    Expanded(
                      child: Text(
                        result.reason,
                        style: AppTextStyles.caption(color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),

              // Score Breakdown
              AppSpacing.vGapMd,
              Row(
                children: [
                  _ScoreBar(label: 'Skills', value: result.breakdown['skills'] ?? 0, color: AppColors.primary),
                  AppSpacing.hGapSm,
                  _ScoreBar(label: 'Location', value: result.breakdown['location'] ?? 0, color: AppColors.warning),
                  AppSpacing.hGapSm,
                  _ScoreBar(label: 'Available', value: result.breakdown['availability'] ?? 0, color: AppColors.success),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ScoreBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.caption(color: color)),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
