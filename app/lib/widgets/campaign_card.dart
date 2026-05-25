import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../theme/app_spacing.dart';
import '../models/campaign_model.dart';
import '../enums/app_enums.dart';

/// Beautiful campaign card for the campaign list.
class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback onTap;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs + 2),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header with Image or color band ───
            Container(
              width: double.infinity,
              height: (campaign.coverImageUrl != null || campaign.galleryUrls.isNotEmpty) ? 140 : null,
              decoration: BoxDecoration(
                gradient: (campaign.coverImageUrl == null && campaign.galleryUrls.isEmpty) ? LinearGradient(
                  colors: [
                    _typeColor.withValues(alpha: isDark ? 0.3 : 0.1),
                    _typeColor.withValues(alpha: isDark ? 0.15 : 0.03),
                  ],
                ) : null,
                image: (campaign.coverImageUrl != null || campaign.galleryUrls.isNotEmpty)
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(campaign.coverImageUrl ?? campaign.galleryUrls.first),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
                      )
                    : null,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (campaign.coverImageUrl != null || campaign.galleryUrls.isNotEmpty) 
                          ? Colors.black.withValues(alpha: 0.6) 
                          : _typeColor.withValues(alpha: isDark ? 0.4 : 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: (campaign.coverImageUrl != null || campaign.galleryUrls.isNotEmpty) ? _typeColor : Colors.transparent),
                    ),
                    child: Text(
                      '${campaign.type.icon} ${campaign.type.label}',
                      style: TextStyle(
                        color: (campaign.coverImageUrl != null || campaign.galleryUrls.isNotEmpty) ? Colors.white : _typeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status chip
                  _buildStatusChip(hasImage: (campaign.coverImageUrl != null || campaign.galleryUrls.isNotEmpty)),
                ],
              ),
            ),

            // ─── Body ───
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    campaign.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    campaign.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Date & Location row
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: AppColors.primaryLight),
                      const SizedBox(width: 4),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(campaign.startDate),
                          style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.primaryLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            campaign.location,
                            style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress bar (for active campaigns)
                  if (campaign.isActive && campaign.progressPercent > 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: campaign.progressPercent / 100,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              color: AppColors.primary,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${campaign.progressPercent}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Stats row
                  Divider(height: 1, color: theme.dividerColor),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(Icons.people_outline, '${campaign.totalVolunteers}', 'volunteers'.tr()),
                      _buildStat(
                        Icons.volunteer_activism, 
                        campaign.totalDonationsAmount > 0 
                            ? 'Rs.${campaign.totalDonationsAmount >= 1000 ? (campaign.totalDonationsAmount / 1000).toStringAsFixed(1) + 'k' : campaign.totalDonationsAmount.toInt()}'
                            : '${campaign.totalDonationsCount}', 
                        'donations'.tr()
                      ),
                      _buildStat(Icons.family_restroom, '${campaign.beneficiaryCount}', 'helped'.tr()),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip({bool hasImage = false}) {
    Color color;
    switch (campaign.status) {
      case CampaignStatus.active:
        color = AppColors.success;
        break;
      case CampaignStatus.completed:
        color = AppColors.info;
        break;
      case CampaignStatus.upcoming:
        color = AppColors.warning;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hasImage ? Colors.black.withValues(alpha: 0.6) : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            campaign.status.label,
            style: TextStyle(color: hasImage ? Colors.white : color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryLight),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
      ],
    );
  }

  Color get _typeColor {
    switch (campaign.type) {
      case CampaignType.winterDrive:
        return AppColors.winterDrive;
      case CampaignType.ramadan:
        return AppColors.ramadan;
      case CampaignType.eid:
        return AppColors.eid;
      case CampaignType.orphanage:
        return AppColors.orphanage;
      case CampaignType.medical:
        return AppColors.medical;
      case CampaignType.education:
        return AppColors.education;
      default:
        return AppColors.primary;
    }
  }
}
