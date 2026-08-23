import 'dart:ui' as ui;
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
import '../../../../services/live_tracking_service.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../live_mission_map_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignInfoTab extends StatelessWidget {
  final CampaignModel campaign;

  const CampaignInfoTab({Key? key, required this.campaign}) : super(key: key);

  Color get _themeColor {
    switch (campaign.type) {
      case CampaignType.winterDrive: return AppColors.winterDrive;
      case CampaignType.ramadan: return AppColors.ramadan;
      case CampaignType.eid: return AppColors.eid;
      case CampaignType.orphanage: return AppColors.orphanage;
      case CampaignType.medical: return AppColors.medical;
      case CampaignType.education: return AppColors.education;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Stack(
      children: [
        // Magical Background Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.5, -0.8),
                radius: 1.5,
                colors: [
                  _themeColor.withValues(alpha: isDark ? 0.3 : 0.1),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Badges
                  Row(
                    children: [
                      _glassChip('${campaign.type.icon} ${campaign.type.label}', _themeColor, isDark),
                      const SizedBox(width: 8),
                      _statusBadge(isDark),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    campaign.title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    campaign.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quick Info Grid (Glassmorphic)
                  _buildGlassContainer(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mission Brief', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _themeColor)),
                        const SizedBox(height: 16),
                        _infoRow(context, Icons.calendar_today, 'Start Date', dateFormat.format(campaign.startDate), isDark),
                        if (campaign.eventDate != null)
                          _infoRow(context, Icons.event, 'Event Date', dateFormat.format(campaign.eventDate!), isDark),
                        _infoRow(context, Icons.location_on, 'Location', campaign.location, isDark),
                        _infoRow(context, Icons.flag, 'Target', campaign.targetGoal, isDark),
                        _infoRow(context, Icons.person, 'Coordinator', campaign.createdByName, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Donation Goal Progress
                  _buildDonationGoalCard(context, isDark),
                  const SizedBox(height: 24),

                  // Stats Grid
                  Text('Live Statistics', style: AppTextStyles.titleLarge().copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: Responsive.isMobile(context) ? 1.4 : 1.8,
                    children: [
                      _glassStatCard('Volunteers', '${campaign.totalVolunteers}', Icons.people, AppColors.info, isDark),
                      _glassStatCard('Impact', '${campaign.beneficiaryCount}', Icons.family_restroom, AppColors.primary, isDark),
                      _glassStatCard('Items', '${campaign.distributionCount}', Icons.inventory_2, AppColors.success, isDark),
                      _glassStatCard('Donations', 'Rs.${campaign.totalDonationsAmount.toInt()}', Icons.volunteer_activism, AppColors.warning, isDark),
                      _glassStatCard('Expenses', 'Rs.${campaign.totalExpenses.toInt()}', Icons.receipt, AppColors.error, isDark),
                      _glassStatCard('Remaining', 'Rs.${campaign.remainingBudget.toInt()}', Icons.savings, AppColors.success, isDark),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons (Volunteers, Beneficiaries, Gallery)
                  _buildActionTiles(context, isDark),
                  const SizedBox(height: 32),
                  
                  // Map
                  _buildMapSection(context, isDark),
                  const SizedBox(height: 24),

                  // Live Tracking
                  _LiveTrackingCard(campaign: campaign, isDark: isDark),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassContainer({required Widget child, required bool isDark, EdgeInsetsGeometry padding = const EdgeInsets.all(24)}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withValues(alpha: 0.05),
            blurRadius: 30,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _glassChip(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text, 
        style: TextStyle(
          color: isDark ? color.withValues(alpha: 0.9) : color, 
          fontSize: 13, 
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _statusBadge(bool isDark) {
    Color color;
    switch (campaign.status) {
      case CampaignStatus.active: color = AppColors.success; break;
      case CampaignStatus.completed: color = AppColors.info; break;
      case CampaignStatus.upcoming: color = AppColors.warning; break;
    }
    return _glassChip('${campaign.status.icon} ${campaign.status.label}', color, isDark);
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: _themeColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontSize: 15, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _glassStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.05 : 0.05),
            blurRadius: 20,
            spreadRadius: -5,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Reduced blur for performance
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value, 
                    style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87, fontSize: 18), 
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label, 
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDonationGoalCard(BuildContext context, bool isDark) {
    final goalAmount = double.tryParse(campaign.targetGoal.replaceAll(RegExp(r'[^0-9.]'), ''));
    final collected = campaign.totalDonationsAmount;

    if (goalAmount == null || goalAmount <= 0) return const SizedBox.shrink();

    final progress = (collected / goalAmount).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    final remaining = (goalAmount - collected).clamp(0.0, goalAmount);

    Color progressColor;
    IconData goalIcon;
    String goalMessage;

    if (percentage >= 100) {
      progressColor = AppColors.success;
      goalIcon = Icons.celebration;
      goalMessage = '🎉 Goal Achieved!';
    } else if (percentage >= 75) {
      progressColor = const Color(0xFF43A047);
      goalIcon = Icons.trending_up;
      goalMessage = 'Almost there! Keep going!';
    } else if (percentage >= 50) {
      progressColor = const Color(0xFFFFA726);
      goalIcon = Icons.auto_graph;
      goalMessage = 'Halfway there!';
    } else {
      progressColor = const Color(0xFF42A5F5);
      goalIcon = Icons.flag;
      goalMessage = 'Help us reach the goal!';
    }

    return _buildGlassContainer(
      isDark: isDark,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(goalIcon, color: progressColor, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Donation Goal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: progressColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$percentage%',
                  style: TextStyle(color: progressColor, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Bar
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: progressColor.withValues(alpha: 0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [progressColor.withValues(alpha: 0.7), progressColor],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Collected', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${NumberFormat('#,###').format(collected)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: progressColor),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Goal', style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${NumberFormat('#,###').format(goalAmount)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: progressColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: progressColor.withValues(alpha: 0.8)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    percentage < 100 ? 'Rs. ${NumberFormat('#,###').format(remaining)} more needed • $goalMessage' : goalMessage,
                    style: TextStyle(fontSize: 13, color: progressColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTiles(BuildContext context, bool isDark) {
    return Column(
      children: [
        _actionTile(
          context: context,
          icon: Icons.people_alt_rounded,
          color: AppColors.info,
          title: '${'view_volunteers'.tr()} (${campaign.totalVolunteers})',
          subtitle: 'view_volunteers_desc'.tr(),
          isDark: isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VolunteerListScreen(campaignId: campaign.id, campaignTitle: campaign.title))),
        ),
        const SizedBox(height: 12),
        _actionTile(
          context: context,
          icon: Icons.handshake_rounded,
          color: AppColors.primary,
          title: 'view_impact'.tr(),
          subtitle: 'view_impact_desc'.tr(),
          isDark: isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BeneficiaryListScreen(campaignId: campaign.id, campaignTitle: campaign.title))),
        ),
        const SizedBox(height: 12),
        _actionTile(
          context: context,
          icon: Icons.photo_library_rounded,
          color: AppColors.success,
          title: 'photo_gallery'.tr(),
          subtitle: 'photo_gallery_desc'.tr(),
          isDark: isDark,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoGalleryScreen(campaign: campaign))),
        ),
      ],
    );
  }

  Widget _actionTile({required BuildContext context, required IconData icon, required Color color, required String title, required String subtitle, required bool isDark, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 0)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: isDark ? Colors.white30 : Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, bool isDark) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('campaigns').doc(campaign.id).snapshots(),
      builder: (context, snapshot) {
        double? lat = campaign.latitude;
        double? lng = campaign.longitude;
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          lat = data['latitude'] as double? ?? lat;
          lng = data['longitude'] as double? ?? lng;
        }

        if (lat == null || lng == null) return const SizedBox.shrink();

        return _buildGlassContainer(
          isDark: isDark,
          padding: const EdgeInsets.all(0), // No padding for map
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.map_rounded, color: _themeColor),
                    const SizedBox(width: 12),
                    Text('Operation Location', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? Colors.white : Colors.black87)),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                width: double.infinity,
                child: Stack(
                  children: [
                    AbsorbPointer(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(lat, lng),
                          initialZoom: 14.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'org.hras.ngo_volunteer_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(lat, lng),
                                width: 50,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.location_on, color: AppColors.error, size: 40),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                            try {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              debugPrint('Could not launch maps: $e');
                            }
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.open_in_new, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text('Navigate', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveTrackingCard extends StatefulWidget {
  final CampaignModel campaign;
  final bool isDark;
  
  const _LiveTrackingCard({required this.campaign, required this.isDark});

  @override
  State<_LiveTrackingCard> createState() => _LiveTrackingCardState();
}

class _LiveTrackingCardState extends State<_LiveTrackingCard> {
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _isTracking = LiveTrackingService().isTracking;
  }

  void _toggleTracking() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    if (_isTracking) {
      await LiveTrackingService().stopTracking();
      setState(() => _isTracking = false);
    } else {
      try {
        await LiveTrackingService().startTracking(widget.campaign.id, user.uid, user.name);
        setState(() => _isTracking = true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not start tracking: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isAdmin = user?.isAdmin == true;

    if (isAdmin) {
      return Container(
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.error.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveMissionMapScreen(
                    campaignId: widget.campaign.id,
                    campaignTitle: widget.campaign.title,
                    initialLat: widget.campaign.latitude,
                    initialLng: widget.campaign.longitude,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.satellite_alt, color: AppColors.error),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Live Mission Map', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.error)),
                        const SizedBox(height: 4),
                        Text('View real-time volunteer locations', style: TextStyle(color: widget.isDark ? Colors.white60 : Colors.black54, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.error),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _isTracking 
            ? AppColors.error.withValues(alpha: 0.1) 
            : (widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02)),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _isTracking 
              ? AppColors.error.withValues(alpha: 0.3) 
              : (widget.isDark ? Colors.white10 : Colors.black12)
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        secondary: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isTracking ? AppColors.error.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isTracking ? Icons.my_location : Icons.location_disabled,
            color: _isTracking ? AppColors.error : Colors.grey,
          ),
        ),
        title: Text(
          'Live Mission Tracking',
          style: TextStyle(fontWeight: FontWeight.w900, color: _isTracking ? AppColors.error : (widget.isDark ? Colors.white : Colors.black87)),
        ),
        subtitle: Text(
          _isTracking
              ? 'Your location is being shared with Admins'
              : 'Share location during active mission',
          style: TextStyle(color: widget.isDark ? Colors.white60 : Colors.black54),
        ),
        value: _isTracking,
        activeColor: AppColors.error,
        onChanged: (val) => _toggleTracking(),
      ),
    );
  }
}
