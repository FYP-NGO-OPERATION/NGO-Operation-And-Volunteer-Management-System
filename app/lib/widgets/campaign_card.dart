import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../theme/app_spacing.dart';
import '../models/campaign_model.dart';
import '../enums/app_enums.dart';

/// Beautiful, modern campaign card for the campaign list.
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
    
    final bool hasImage = campaign.coverImageUrl != null || campaign.galleryUrls.isNotEmpty;
    final String? displayImageUrl = campaign.coverImageUrl ?? (campaign.galleryUrls.isNotEmpty ? campaign.galleryUrls.first : null);
    
    // The date to display (prefer eventDate over startDate)
    final displayDate = campaign.eventDate ?? campaign.startDate;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _typeColor.withValues(alpha: isDark ? 0.2 : 0.15),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Top Section: Image with Badges & Title Overlay ───
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image or Gradient
                    if (hasImage)
                      CachedNetworkImage(
                        imageUrl: displayImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: _typeColor.withValues(alpha: 0.2)),
                        errorWidget: (context, url, error) => Container(color: _typeColor.withValues(alpha: 0.2)),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _typeColor.withValues(alpha: isDark ? 0.4 : 0.2),
                              _typeColor.withValues(alpha: isDark ? 0.2 : 0.05),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.volunteer_activism, size: 60, color: _typeColor.withValues(alpha: 0.3)),
                        ),
                      ),
                      
                    // Gradient Overlay (dark at bottom for text readability)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3), // Slightly dark at top for badges
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8), // Dark at bottom for text
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    
                    // Top Badges (Type & Status)
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Type Badge
                          _MagicalTypeBadge(type: campaign.type, typeColor: _typeColor),
                          // Status Badge
                          _buildStatusChip(),
                        ],
                      ),
                    ),
                    
                    // Bottom Overlay Text (Title & Location)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  campaign.location,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.event, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd').format(displayDate),
                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Bottom Section: Body & Stats ───
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      campaign.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 16),

                    // Progress Bar (if active and has progress)
                    if (campaign.isActive && campaign.progressPercent > 0) ...[
                      Row(
                        children: [
                          Text(
                            'Campaign Progress',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textTheme.bodySmall?.color),
                          ),
                          const Spacer(),
                          Text(
                            '${campaign.progressPercent}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: campaign.progressPercent / 100,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          color: AppColors.primary,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Stats Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : _typeColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? Colors.white10 : _typeColor.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(Icons.people_alt, '${campaign.totalVolunteers}', 'Volunteers', AppColors.info, isDark),
                          _buildDivider(isDark),
                          _buildStatItem(
                            Icons.volunteer_activism, 
                            campaign.totalDonationsAmount > 0 
                                ? 'Rs.${campaign.totalDonationsAmount >= 1000 ? (campaign.totalDonationsAmount / 1000).toStringAsFixed(1) + 'k' : campaign.totalDonationsAmount.toInt()}'
                                : '${campaign.totalDonationsCount}', 
                            'Donations', 
                            AppColors.warning,
                            isDark
                          ),
                          _buildDivider(isDark),
                          _buildStatItem(Icons.family_restroom, '${campaign.beneficiaryCount}', 'Impact', AppColors.success, isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 4)]),
              ),
              const SizedBox(width: 8),
              Text(
                campaign.status.label,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 24,
      width: 1,
      color: isDark ? Colors.white24 : Colors.grey.shade300,
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color iconColor, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w700)),
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

class _MagicalTypeBadge extends StatefulWidget {
  final CampaignType type;
  final Color typeColor;

  const _MagicalTypeBadge({required this.type, required this.typeColor});

  @override
  State<_MagicalTypeBadge> createState() => _MagicalTypeBadgeState();
}

class _MagicalTypeBadgeState extends State<_MagicalTypeBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * 2 * math.pi;
        final shiftX = math.cos(angle) * 0.5;
        final shiftY = math.sin(angle) * 0.5;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.typeColor.withValues(alpha: 0.4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Animated multi-gradient background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.typeColor.withValues(alpha: 0.9),
                          widget.typeColor.withValues(alpha: 0.6),
                          widget.typeColor.withValues(alpha: 1.0),
                          widget.typeColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment(shiftX, shiftY),
                        end: Alignment(-shiftX, -shiftY),
                      ),
                    ),
                  ),
                ),
                // Magical Stars
                ...List.generate(6, (index) {
                  final starAngle = angle * (index % 2 == 0 ? 1 : -1) + (index * math.pi / 2);
                  final opacity = (math.sin(starAngle * (2 + index % 3)) + 1) / 2 * 0.9;
                  final sizeScale = (math.cos(starAngle * 3) + 1) / 2;
                  final size = 1.0 + (sizeScale * 2.0);
                  
                  final top = 4.0 + (index * 13.0) % 25;
                  final left = 8.0 + (index * 27.0) % 100;
                  
                  return Positioned(
                    top: top,
                    left: left,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.white, blurRadius: 2.0, spreadRadius: 1.0),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                // Glass effect
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                // Text Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.type.icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        widget.type.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
