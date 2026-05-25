import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../models/campaign_model.dart';
import '../../../../enums/app_enums.dart';
import '../../../../utils/responsive.dart';
import '../../volunteers/volunteer_list_screen.dart';
import '../../beneficiaries/beneficiary_list_screen.dart';
import '../photo_gallery_screen.dart';

class CampaignInfoTab extends StatelessWidget {
  final CampaignModel campaign;

  const CampaignInfoTab({Key? key, required this.campaign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status & Type badges
              Row(
                children: [
                  _chip('${campaign.type.icon} ${campaign.type.label}', AppColors.primary),
                  AppSpacing.hGapSm,
                  _statusBadge(),
                ],
              ),
              AppSpacing.vGapLg,
              Text(campaign.title, style: AppTextStyles.headlineMedium()),
              AppSpacing.vGapMd,
              Text(campaign.description, style: AppTextStyles.bodyMedium(
                color: theme.brightness == Brightness.dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              AppSpacing.vGapXl,

              // Info Grid
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _infoRow(context, Icons.calendar_today, 'start_date'.tr(), dateFormat.format(campaign.startDate)),
                      if (campaign.endDate != null)
                        _infoRow(context, Icons.event, 'end_date'.tr(), dateFormat.format(campaign.endDate!)),
                      _infoRow(context, Icons.location_on, 'location'.tr(), campaign.location),
                      _infoRow(context, Icons.flag, 'target'.tr(), campaign.targetGoal),
                      if (campaign.achievedGoal != null)
                        _infoRow(context, Icons.check_circle, 'achieved'.tr(), campaign.achievedGoal!),
                      if (campaign.itemsNeeded != null)
                        _infoRow(context, Icons.list, 'items_needed'.tr(), campaign.itemsNeeded!),
                      _infoRow(context, Icons.person, 'created_by'.tr(), campaign.createdByName),
                      if (campaign.latitude != null && campaign.longitude != null) ...[
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.map, color: AppColors.primary),
                          title: const Text('Open in Google Maps', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          trailing: const Icon(Icons.open_in_new, color: AppColors.primary, size: 16),
                          onTap: () async {
                            final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${campaign.latitude},${campaign.longitude}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress
              if (campaign.progressPercent > 0) ...[
                Text('progress'.tr(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: campaign.progressPercent / 100,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    color: AppColors.primary,
                    minHeight: 12,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${campaign.progressPercent}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Stats Cards
              Text('statistics'.tr(), style: AppTextStyles.titleLarge()),
              AppSpacing.vGapMd,
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: Responsive.isMobile(context) ? 1.5 : 2.0,
                children: [
                  _statCard('volunteers'.tr(), '${campaign.totalVolunteers}', Icons.people, AppColors.info),
                  _statCard('beneficiaries'.tr(), '${campaign.beneficiaryCount}', Icons.family_restroom, AppColors.primary),
                  _statCard('items_distributed'.tr(), '${campaign.distributionCount}', Icons.inventory_2, AppColors.success),
                  _statCard('donations'.tr(), 'Rs.${campaign.totalDonationsAmount.toStringAsFixed(0)}', Icons.volunteer_activism, AppColors.warning),
                  _statCard('expenses'.tr(), 'Rs.${campaign.totalExpenses.toStringAsFixed(0)}', Icons.receipt, AppColors.error),
                  _statCard('remaining'.tr(), 'Rs.${campaign.remainingBudget.toStringAsFixed(0)}', Icons.savings, AppColors.success),
                ],
              ),
              const SizedBox(height: 16),

              // View Volunteers button
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.people, color: AppColors.info),
                  ),
                  title: Text(
                    '${'view_volunteers'.tr()} (${campaign.totalVolunteers})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('view_volunteers_desc'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VolunteerListScreen(
                          campaignId: campaign.id,
                          campaignTitle: campaign.title,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // View Beneficiaries button
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.handshake, color: AppColors.primary),
                  ),
                  title: Text(
                    'view_impact'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('view_impact_desc'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BeneficiaryListScreen(
                          campaignId: campaign.id,
                          campaignTitle: campaign.title,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // View Photo Gallery button
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library, color: AppColors.success),
                  ),
                  title: Text(
                    'photo_gallery'.tr(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('photo_gallery_desc'.tr()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoGalleryScreen(campaign: campaign),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusBadge() {
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
    return _chip('${campaign.status.icon} ${campaign.status.label}', color);
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryLight),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
