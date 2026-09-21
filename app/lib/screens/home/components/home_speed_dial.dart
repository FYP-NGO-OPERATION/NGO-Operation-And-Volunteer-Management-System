import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/feature_flags.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../models/ngo_model.dart';
import '../../../../widgets/common/custom_speed_dial.dart';
import '../../campaigns/create_campaign_screen.dart';
import '../../campaigns/recommended_campaigns_screen.dart';
import '../../campaigns/qr_scan_screen.dart';
import '../../announcements/create_announcement_screen.dart';
import '../../sessions/create_session_screen.dart';
import '../../admin/analytics_screen.dart';
import '../../analytics/predictive_dashboard_screen.dart';
import '../../profile/user_list_screen.dart';
import '../../admin/workspace_settings_screen.dart';
import '../../admin/manage_ngos_screen.dart';
import '../ai_assistant_screen.dart';
import '../../donations/blood_donation_screen.dart';
import '../../donations/needs_marketplace_screen.dart';
import '../../../../services/sos_service.dart';
import '../../../../utils/snackbar_helper.dart';

class HomeSpeedDial extends StatelessWidget {
  final bool isAdmin;
  final bool isSuperAdmin;
  final NgoModel? currentNgo;

  const HomeSpeedDial({
    super.key,
    required this.isAdmin,
    required this.isSuperAdmin,
    this.currentNgo,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return CustomSpeedDial(
        actions: [
          if (currentNgo?.features.contains('campaigns') ?? true)
            SpeedDialAction(
              icon: Icons.campaign,
              label: 'add_campaign'.tr(),
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateCampaignScreen(),
                  ),
                );
              },
            ),
          SpeedDialAction(
            icon: Icons.announcement,
            label: 'add_announcement'.tr(),
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateAnnouncementScreen(),
                ),
              );
            },
          ),
          if (currentNgo?.features.contains('virtual_sessions') ?? false)
            SpeedDialAction(
              icon: Icons.videocam,
              label: 'schedule_session'.tr(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateSessionScreen(),
                  ),
                );
              },
            ),
          if (FeatureFlags.isAnalyticsEnabled)
            SpeedDialAction(
              icon: Icons.analytics,
              label: 'Analytics & Reports',
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                );
              },
            ),
          SpeedDialAction(
            icon: Icons.psychology,
            label: 'AI Resource Engine',
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PredictiveDashboardScreen(),
                ),
              );
            },
          ),
          SpeedDialAction(
            icon: Icons.manage_accounts,
            label: 'Manage Users',
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserListScreen()),
              );
            },
          ),
          if (isAdmin &&
              currentNgo != null &&
              currentNgo!.adminId ==
                  Provider.of<AuthProvider>(context, listen: false).user?.uid)
            SpeedDialAction(
              icon: Icons.settings_applications,
              label: 'Workspace Settings',
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkspaceSettingsScreen(),
                  ),
                );
              },
            ),
          if (isSuperAdmin)
            SpeedDialAction(
              icon: Icons.admin_panel_settings,
              label: 'Manage NGOs',
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageNgosScreen()),
                );
              },
            ),
          SpeedDialAction(
            icon: Icons.bloodtype,
            label: 'blood_emergency'.tr(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BloodDonationScreen()),
              );
            },
          ),
          SpeedDialAction(
            icon: Icons.store,
            label: 'needs_marketplace'.tr(),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NeedsMarketplaceScreen(),
                ),
              );
            },
          ),
        ],
      );
    } else {
      if (FeatureFlags.isSmartMatchingEnabled ||
          FeatureFlags.isQrAttendanceEnabled) {
        return Builder(
          builder: (context) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            return CustomSpeedDial(
              mainIcon: Icons.auto_awesome,
              activeIcon: Icons.close,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                SpeedDialAction(
                  icon: Icons.bloodtype,
                  label: 'blood_emergency'.tr(),
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BloodDonationScreen(),
                      ),
                    );
                  },
                ),
                SpeedDialAction(
                  icon: Icons.store,
                  label: 'needs_marketplace'.tr(),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NeedsMarketplaceScreen(),
                      ),
                    );
                  },
                ),
                if (FeatureFlags.isSmartMatchingEnabled)
                  SpeedDialAction(
                    icon: Icons.recommend,
                    label: 'recommended_campaigns'.tr(),
                    backgroundColor: AppColors.info,
                    foregroundColor: Colors.white,
                    onTap: () {
                      final user = auth.user;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecommendedCampaignsScreen(user: user),
                          ),
                        );
                      }
                    },
                  ),
                if (FeatureFlags.isQrAttendanceEnabled)
                  SpeedDialAction(
                    icon: Icons.qr_code_scanner,
                    label: 'scan_qr_attendance'.tr(),
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    onTap: () {
                      final user = auth.user;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QrScanScreen(
                              userId: user.uid,
                              userName: user.name,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                SpeedDialAction(
                  icon: Icons.smart_toy,
                  label: 'ai_assistant'.tr(),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AiAssistantScreen(),
                      ),
                    );
                  },
                ),
                SpeedDialAction(
                  icon: Icons.sos,
                  label: 'emergency_sos_button'.tr(),
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  onTap: () async {
                    final user = auth.user;
                    if (user != null) {
                      try {
                        SnackbarHelper.showSuccess(context, 'sending_sos'.tr());
                        await SosService.sendSosAlert(user.uid, user.name);
                        if (context.mounted) {
                          SnackbarHelper.showSuccess(
                            context,
                            'sos_alert_sent'.tr(),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          SnackbarHelper.showError(
                            context,
                            '${'failed_to_send_sos'.tr()} $e',
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      }
      return const SizedBox.shrink();
    }
  }
}
