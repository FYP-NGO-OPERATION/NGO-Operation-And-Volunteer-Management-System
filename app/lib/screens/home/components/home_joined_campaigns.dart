import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_tokens.dart';
import '../../../../models/volunteer_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/campaign_provider.dart';
import '../../../../services/volunteer_service.dart';
import '../../../../services/certificate_service.dart';
import '../../campaigns/campaign_detail_screen.dart';

class HomeJoinedCampaigns extends StatelessWidget {
  final String userId;
  final Function(int) onTabChange;

  const HomeJoinedCampaigns({
    Key? key,
    required this.userId,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'my_campaigns'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<VolunteerModel>>(
          stream: VolunteerService().getUserCampaignsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.campaign_outlined, size: 40, color: AppColors.lightTextHint),
                      const SizedBox(height: 8),
                      Text(
                        'not_joined_campaign'.tr(),
                        style: const TextStyle(color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => onTabChange(1),
                        child: Text('${'browse_campaigns'.tr()} →'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final attended = records.where((r) => r.status.toString() == 'VolunteerStatus.attended').length;
            final totalPoints = attended * 10;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, 'Joined', '${records.length}', Icons.handshake, AppColors.info)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, 'Attended', '$attended', Icons.check_circle, AppColors.success)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, 'Points', '$totalPoints', Icons.stars, Colors.amber)),
                  ],
                ),
                if (attended >= 5) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        final user = authProvider.user;
                        if (user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Generating Certificate...')),
                          );
                          await CertificateService.generateAndDownloadCertificate(
                            volunteerName: user.name,
                            campaignsAttended: attended,
                          );
                        }
                      },
                      icon: const Icon(Icons.workspace_premium, color: Colors.white),
                      label: const Text('Download Gold Certificate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ...records.take(5).map((record) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _volunteerStatusColor(record.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.campaign, color: _volunteerStatusColor(record.status)),
                      ),
                      title: Text(
                        record.campaignTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Status: ${record.status.label}',
                        style: TextStyle(
                          fontSize: 12,
                          color: _volunteerStatusColor(record.status),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final campaignProvider = Provider.of<CampaignProvider>(context, listen: false);
                        final campaign = campaignProvider.campaigns.firstWhere(
                          (c) => c.id == record.campaignId,
                          orElse: () => campaignProvider.campaigns.first,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CampaignDetailScreen(campaign: campaign),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _volunteerStatusColor(dynamic status) {
    switch (status.toString()) {
      case 'VolunteerStatus.pending': return AppColors.textHint;
      case 'VolunteerStatus.registered': return AppColors.info;
      case 'VolunteerStatus.confirmed': return AppColors.warning;
      case 'VolunteerStatus.attended': return AppColors.success;
      case 'VolunteerStatus.absent': return AppColors.error;
      default: return AppColors.info;
    }
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        borderRadius: AppTokens.borderRadiusMd,
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
        boxShadow: AppTokens.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: AppTokens.borderRadiusSm,
            ),
            child: Icon(icon, color: color, size: AppTokens.iconMd),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTextStyles.statValue(color: color)),
          ),
          AppSpacing.vGapXs,
          Text(title,
              style: AppTextStyles.caption(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
